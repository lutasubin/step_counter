import 'package:get/get.dart';
import 'package:step_counter/features/home/model/activity_data_model.dart';

/// Controller quản lý logic của home screen
class HomeController extends GetxController {
  final _activityData = ActivityDataModel.empty().obs;

  /// Dữ liệu hoạt động
  ActivityDataModel get activityData => _activityData.value;

  /// Số bước chân
  int get stepCount => _activityData.value.stepCount;

  /// Calories
  double get calories => _activityData.value.calories;

  /// Khoảng cách (km)
  double get distance => _activityData.value.distance;

  /// Thời gian
  String get duration => _activityData.value.duration;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Load dữ liệu ban đầu
  void _loadData() {
    // TODO: Load data từ service/repository
  }

  /// Cập nhật dữ liệu hoạt động
  void updateActivityData(ActivityDataModel data) {
    _activityData.value = data;
  }
}
