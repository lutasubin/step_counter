import 'dart:math';

/// Helper class để tính toán BPM từ PPG signal
class BPMCalculator {
  static const int minFrames = 90; // Tối thiểu 3 giây với 30 FPS

  /// Tính BPM từ danh sách red values
  static int? calculateBPM(List<double> redValues) {
    if (redValues.length < minFrames) return null;

    // Lọc nhiễu bằng moving average
    final smoothed = _smoothSignal(redValues);

    // Tìm peaks
    final peaks = _findPeaks(smoothed);
    if (peaks.length < 2) return null;

    // Tính khoảng cách trung bình giữa các peaks
    final intervals = <int>[];
    for (int i = 1; i < peaks.length; i++) {
      intervals.add(peaks[i] - peaks[i - 1]);
    }

    if (intervals.isEmpty) return null;

    // Tính trung bình interval (trong frames)
    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    // Giả sử 30 FPS, tính BPM
    // BPM = (60 * FPS) / avgInterval
    const fps = 30.0;
    final bpm = (60 * fps / avgInterval).round();

    // Validate BPM trong khoảng hợp lý (40-200)
    return bpm.clamp(40, 200);
  }

  /// Làm mượt signal bằng moving average
  static List<double> _smoothSignal(List<double> signal) {
    const windowSize = 5;
    final smoothed = <double>[];

    for (int i = 0; i < signal.length; i++) {
      int start = (i - windowSize ~/ 2).clamp(0, signal.length - 1);
      int end = (i + windowSize ~/ 2).clamp(0, signal.length - 1);

      double sum = 0;
      int count = 0;
      for (int j = start; j <= end; j++) {
        sum += signal[j];
        count++;
      }
      smoothed.add(sum / count);
    }

    return smoothed;
  }

  /// Tìm các peaks trong signal
  static List<int> _findPeaks(List<double> signal) {
    final peaks = <int>[];
    final threshold = _calculateThreshold(signal);

    for (int i = 1; i < signal.length - 1; i++) {
      if (signal[i] > signal[i - 1] &&
          signal[i] > signal[i + 1] &&
          signal[i] > threshold) {
        peaks.add(i);
      }
    }

    return peaks;
  }

  /// Tính threshold để tìm peaks
  static double _calculateThreshold(List<double> signal) {
    final mean = signal.reduce((a, b) => a + b) / signal.length;
    final variance =
        signal.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
        signal.length;
    final stdDev = sqrt(variance);
    return mean + stdDev * 0.5;
  }
}
