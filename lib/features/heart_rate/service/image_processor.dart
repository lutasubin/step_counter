import 'package:camera/camera.dart';

/// Helper class để xử lý camera image và tính toán PPG signal
class ImageProcessor {
  /// Tính giá trị màu đỏ trung bình từ camera image
  /// Sử dụng vùng trung tâm để tối ưu performance
  static double calculateRedValue(CameraImage image) {
    // Lấy vùng trung tâm của ảnh (khoảng 20% diện tích)
    final centerX = image.width ~/ 2;
    final centerY = image.height ~/ 2;
    final regionSize = (image.width * 0.2).round();

    int totalRed = 0;
    int pixelCount = 0;

    // Chỉ lấy mẫu một số pixel để tối ưu performance
    const step = 2;
    for (int y = centerY - regionSize ~/ 2;
        y < centerY + regionSize ~/ 2;
        y += step) {
      if (y < 0 || y >= image.height) continue;
      for (int x = centerX - regionSize ~/ 2;
          x < centerX + regionSize ~/ 2;
          x += step) {
        if (x < 0 || x >= image.width) continue;

        // Lấy pixel từ YUV420 format
        final yIndex = y * image.width + x;
        final uvIndex = (y ~/ 2) * (image.width ~/ 2) + (x ~/ 2);

        final yValue = image.planes[0].bytes[yIndex];
        final uValue = image.planes[1].bytes[uvIndex];
        final vValue = image.planes[2].bytes[uvIndex];

        // Convert YUV to RGB
        final r = _yuvToR(yValue, uValue, vValue);
        totalRed += r;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalRed / pixelCount : 0.0;
  }

  /// Convert YUV to Red component
  static int _yuvToR(int y, int u, int v) {
    final r = (y + 1.402 * (v - 128)).round().clamp(0, 255);
    return r;
  }
}
