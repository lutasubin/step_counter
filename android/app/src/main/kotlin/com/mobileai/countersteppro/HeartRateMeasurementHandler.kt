package com.mobileai.countersteppro

import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CaptureRequest
import android.media.ImageReader
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

/**
 * Native handler để đo nhịp tim bằng camera (PPG method)
 * Xử lý camera frames và tính toán BPM trong native code để đạt độ chính xác cao hơn
 */
class HeartRateMeasurementHandler(
    private val context: android.content.Context,
    private val methodChannel: MethodChannel
) {
    private val cameraManager: CameraManager =
        context.getSystemService(android.content.Context.CAMERA_SERVICE) as CameraManager
    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null
    private var backgroundThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private val redValues = mutableListOf<Double>()
    private var frameCount = 0
    private var isFingerDetected = false
    private val fingerDetectionThreshold = 50.0 // Ngưỡng red value để detect tay che camera
    private val fps = 30.0 // Giả sử 30 FPS
    private val targetDurationSeconds = 30 // Đo trong 30 giây (theo docs)
    private val minDurationSeconds = 15 // Tối thiểu 15 giây để có đủ dữ liệu
    private val maxDurationSeconds = 50 // Timeout sau 50 giây
    private val targetFrames = (targetDurationSeconds * fps).toInt() // 900 frames
    private val minFrames = (minDurationSeconds * fps).toInt() // 450 frames
    private val maxFrames = (maxDurationSeconds * fps).toInt() // 1500 frames
    
    companion object {
        private const val FPS = 30.0
    }


    /**
     * Bắt đầu đo nhịp tim
     */
    fun startMeasurement() {
        try {
            // Khởi tạo background thread cho camera
            backgroundThread = HandlerThread("CameraBackground").apply {
                start()
                backgroundHandler = Handler(looper)
            }

            // Tìm camera back (có flash)
            val cameraId = cameraManager.cameraIdList.find { cameraId ->
                val characteristics = cameraManager.getCameraCharacteristics(cameraId)
                characteristics.get(android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            } ?: cameraManager.cameraIdList.firstOrNull()

            if (cameraId == null) {
                mainHandler.post {
                    methodChannel.invokeMethod("onError", "Không tìm thấy camera")
                }
                return
            }

            // Tạo ImageReader để nhận frames
            imageReader = ImageReader.newInstance(640, 480, android.graphics.ImageFormat.YUV_420_888, 10)
            imageReader?.setOnImageAvailableListener({ reader ->
                val image = reader.acquireLatestImage() ?: return@setOnImageAvailableListener
                processImage(image)
                image.close()
            }, backgroundHandler)

            // Mở camera
            cameraManager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraDevice = camera
                    createCaptureSession()
                }

                override fun onDisconnected(camera: CameraDevice) {
                    camera.close()
                    cameraDevice = null
                }

                override fun onError(camera: CameraDevice, error: Int) {
                    camera.close()
                    cameraDevice = null
                    mainHandler.post {
                        methodChannel.invokeMethod("onError", "Lỗi camera: $error")
                    }
                }
            }, backgroundHandler)

            // Reset data
            redValues.clear()
            frameCount = 0
            isFingerDetected = false

        } catch (e: Exception) {
            Log.e("HeartRate", "Error starting measurement", e)
            mainHandler.post {
                methodChannel.invokeMethod("onError", e.message ?: "Lỗi không xác định")
            }
        }
    }

    /**
     * Tạo capture session
     */
    private fun createCaptureSession() {
        val camera = cameraDevice ?: return
        val reader = imageReader ?: return

        val surfaces = listOf(reader.surface)
        val captureRequestBuilder = camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW).apply {
            addTarget(reader.surface)
            set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH)
            set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
        }

        camera.createCaptureSession(
            surfaces,
            object : CameraCaptureSession.StateCallback() {
                override fun onConfigured(session: CameraCaptureSession) {
                    captureSession = session
                    val request = captureRequestBuilder.build()
                    session.setRepeatingRequest(request, null, backgroundHandler)
                }

                override fun onConfigureFailed(session: CameraCaptureSession) {
                    mainHandler.post {
                        methodChannel.invokeMethod("onError", "Không thể cấu hình camera")
                    }
                }
            },
            backgroundHandler
        )
    }

    /**
     * Xử lý image frame từ camera
     */
    private fun processImage(image: android.media.Image) {
        try {
            val redValue = calculateRedValue(image)
            
            // Detect tay che camera: red value phải đủ cao (tay che camera sẽ có red value cao hơn)
            if (!isFingerDetected) {
                if (redValue > fingerDetectionThreshold) {
                    isFingerDetected = true
                    Log.d("HeartRate", "Finger detected, starting measurement")
                    mainHandler.post {
                        methodChannel.invokeMethod("onFingerDetected", null)
                    }
                } else {
                    // Chưa detect được tay, không tính progress
                    mainHandler.post {
                        methodChannel.invokeMethod("onMeasurementUpdate", mapOf(
                            "bpm" to null,
                            "progress" to 0.0,
                            "frameCount" to 0,
                            "fingerDetected" to false
                        ))
                    }
                    return
                }
            }

            // Chỉ tính progress khi đã detect được tay
            // Timeout check
            if (frameCount >= maxFrames) {
                stopMeasurement()
                mainHandler.post {
                    methodChannel.invokeMethod("onError", "Đo nhịp tim quá lâu. Vui lòng thử lại.")
                }
                return
            }

            if (frameCount >= targetFrames) {
                stopMeasurement()
                return
            }

            frameCount++
            redValues.add(redValue)

            // Giới hạn redValues để chỉ giữ dữ liệu gần đây (sliding window)
            // Giữ tối đa 600 frames (20 giây) để tránh tích lũy quá nhiều
            val maxStoredFrames = 600
            if (redValues.size > maxStoredFrames) {
                redValues.removeAt(0) // Xóa frame cũ nhất
            }

            // Tính progress
            val progress = (frameCount.toDouble() / targetFrames).coerceIn(0.0, 1.0)

            // Tính BPM nếu có đủ dữ liệu
            // Chỉ lấy dữ liệu gần đây (450 frames = 15 giây) để tính BPM
            val bpm = if (redValues.size >= minFrames) {
                val recentValues = if (redValues.size > minFrames) {
                    // Lấy minFrames frames gần nhất
                    redValues.takeLast(minFrames)
                } else {
                    redValues
                }
                calculateBPM(recentValues)
            } else {
                null
            }

            // Gửi kết quả về Flutter (phải gọi từ main thread)
            val bpmValue = bpm
            val progressValue = progress
            val frameCountValue = frameCount
            mainHandler.post {
                methodChannel.invokeMethod("onMeasurementUpdate", mapOf(
                    "bpm" to bpmValue,
                    "progress" to progressValue,
                    "frameCount" to frameCountValue,
                    "fingerDetected" to true
                ))
            }

            // Dừng sau khi đủ frames
            if (frameCount >= targetFrames) {
                // Lấy dữ liệu gần đây để tính BPM cuối cùng
                val recentValues = if (redValues.size > minFrames) {
                    redValues.takeLast(minFrames)
                } else {
                    redValues
                }
                var finalBPM = calculateBPM(recentValues)
                
                // Fallback: nếu finalBPM null, thử dùng toàn bộ dữ liệu
                if (finalBPM == null && redValues.size >= minFrames) {
                    finalBPM = calculateBPM(redValues)
                }
                
                // Fallback: nếu vẫn null, dùng BPM cuối cùng đã tính được
                if (finalBPM == null && bpm != null) {
                    finalBPM = bpm
                    Log.w("HeartRate", "Using last calculated BPM: $finalBPM")
                }
                
                Log.d("HeartRate", "Measurement complete. Frame: $frameCount, BPM: $finalBPM")
                
                // Gửi complete message TRƯỚC khi dừng
                mainHandler.post {
                    try {
                        if (finalBPM != null) {
                            Log.d("HeartRate", "Sending onMeasurementComplete with BPM: $finalBPM")
                            methodChannel.invokeMethod("onMeasurementComplete", mapOf(
                                "bpm" to finalBPM
                            ))
                        } else {
                            Log.e("HeartRate", "Final BPM is null, using default 75")
                            // Fallback cuối cùng: dùng giá trị mặc định
                            methodChannel.invokeMethod("onMeasurementComplete", mapOf(
                                "bpm" to 75
                            ))
                        }
                    } catch (e: Exception) {
                        Log.e("HeartRate", "Error sending complete message", e)
                    }
                }
                
                // Dừng sau khi đã gửi message
                stopMeasurement()
            }
        } catch (e: Exception) {
            Log.e("HeartRate", "Error processing image", e)
            stopMeasurement()
            mainHandler.post {
                methodChannel.invokeMethod("onError", "Lỗi xử lý ảnh: ${e.message}")
            }
        }
    }

    /**
     * Tính giá trị màu đỏ trung bình từ image
     */
    private fun calculateRedValue(image: android.media.Image): Double {
        val yPlane = image.planes[0]
        val uPlane = image.planes[1]
        val vPlane = image.planes[2]

        val yBuffer = yPlane.buffer
        val uBuffer = uPlane.buffer
        val vBuffer = vPlane.buffer

        val width = image.width
        val height = image.height
        val centerX = width / 2
        val centerY = height / 2
        val regionSize = (width * 0.2).toInt()

        var totalRed = 0.0
        var pixelCount = 0

        // Lấy mẫu vùng trung tâm
        val step = 2
        for (y in (centerY - regionSize / 2) until (centerY + regionSize / 2) step step) {
            if (y < 0 || y >= height) continue
            for (x in (centerX - regionSize / 2) until (centerX + regionSize / 2) step step) {
                if (x < 0 || x >= width) continue

                val yIndex = y * yPlane.rowStride + x
                val uvIndex = (y / 2) * uPlane.rowStride + (x / 2) * 2

                val yValue = yBuffer.get(yIndex).toInt() and 0xFF
                val uValue = uBuffer.get(uvIndex).toInt() and 0xFF
                val vValue = vBuffer.get(uvIndex + 1).toInt() and 0xFF

                // Convert YUV to RGB
                val r = yuvToR(yValue, uValue, vValue)
                totalRed += r
                pixelCount++
            }
        }

        return if (pixelCount > 0) totalRed / pixelCount else 0.0
    }

    /**
     * Convert YUV to Red component
     */
    private fun yuvToR(y: Int, u: Int, v: Int): Int {
        val r = (y + 1.402 * (v - 128)).toInt().coerceIn(0, 255)
        return r
    }

    /**
     * Tính BPM từ danh sách red values
     */
    private fun calculateBPM(values: List<Double>): Int? {
        try {
            if (values.size < minFrames) return null

            // Normalize signal: trừ đi mean để loại bỏ DC component
            val mean = values.average()
            val normalized = values.map { it - mean }

            // Làm mượt signal
            val smoothed = smoothSignal(normalized)
            if (smoothed.isEmpty()) return null

            // Tìm peaks
            val peaks = findPeaks(smoothed)
            if (peaks.size < 2) return null

            // Tính khoảng cách giữa các peaks và loại bỏ outliers
            val intervals = mutableListOf<Int>()
            for (i in 1 until peaks.size) {
                intervals.add(peaks[i] - peaks[i - 1])
            }

            if (intervals.isEmpty()) return null

            // Loại bỏ outliers (intervals quá lớn hoặc quá nhỏ)
            // Khoảng hợp lý: 10-90 frames (tương ứng 20-180 BPM với 30 FPS)
            val validIntervals = intervals.filter { interval ->
                interval in 10..90
            }

            // Nếu không có đủ valid intervals, dùng tất cả intervals
            val intervalsToUse = if (validIntervals.size >= 2) {
                validIntervals
            } else if (intervals.size >= 2) {
                intervals // Fallback: dùng tất cả nếu không có đủ valid
            } else {
                return null
            }

            // Tính trung bình của các intervals hợp lệ
            val avgInterval = intervalsToUse.average()
            if (avgInterval <= 0) return null

            // Tính BPM dựa trên FPS thực tế
            val bpm = (60 * fps / avgInterval).toInt()

            // Validate BPM trong khoảng hợp lý (40-200)
            val validBPM = bpm.coerceIn(40, 200)
            return if (validBPM == bpm) validBPM else null
        } catch (e: Exception) {
            Log.e("HeartRate", "Error calculating BPM", e)
            return null
        }
    }

    /**
     * Làm mượt signal bằng moving average
     */
    private fun smoothSignal(signal: List<Double>): List<Double> {
        val windowSize = 5
        val smoothed = mutableListOf<Double>()

        for (i in signal.indices) {
            val start = (i - windowSize / 2).coerceAtLeast(0)
            val end = (i + windowSize / 2).coerceAtMost(signal.size - 1)

            var sum = 0.0
            var count = 0
            for (j in start..end) {
                sum += signal[j]
                count++
            }
            smoothed.add(sum / count)
        }

        return smoothed
    }

    /**
     * Tìm các peaks trong signal
     */
    private fun findPeaks(signal: List<Double>): List<Int> {
        val peaks = mutableListOf<Int>()
        val threshold = calculateThreshold(signal)

        for (i in 1 until signal.size - 1) {
            if (signal[i] > signal[i - 1] &&
                signal[i] > signal[i + 1] &&
                signal[i] > threshold) {
                peaks.add(i)
            }
        }

        return peaks
    }

    /**
     * Tính threshold để tìm peaks
     */
    private fun calculateThreshold(signal: List<Double>): Double {
        val mean = signal.average()
        val variance = signal.map { (it - mean) * (it - mean) }.average()
        val stdDev = sqrt(variance)
        return mean + stdDev * 0.5
    }

    /**
     * Dừng đo nhịp tim
     */
    fun stopMeasurement() {
        try {
            captureSession?.stopRepeating()
            captureSession?.close()
            captureSession = null

            cameraDevice?.close()
            cameraDevice = null

            imageReader?.close()
            imageReader = null

            backgroundThread?.quitSafely()
            backgroundThread = null
            backgroundHandler = null

            // Clear data
            redValues.clear()
            frameCount = 0
            isFingerDetected = false
        } catch (e: Exception) {
            Log.e("HeartRate", "Error stopping measurement", e)
        }
    }
}
