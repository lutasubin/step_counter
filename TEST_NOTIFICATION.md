# Hướng dẫn Test Notification Nhắc Nhở Uống Nước

## Bước 1: Build và cài đặt app lên điện thoại

### Cách 1: Build APK và cài thủ công
```bash
# Build APK release
flutter build apk --release

# Hoặc build APK debug (nhanh hơn để test)
flutter build apk --debug

# File APK sẽ ở: build/app/outputs/flutter-apk/app-release.apk
# Copy file này sang điện thoại và cài đặt
```

### Cách 2: Chạy trực tiếp qua USB (khuyến nghị)
```bash
# Kết nối điện thoại qua USB
# Bật USB Debugging trên điện thoại
# Kiểm tra thiết bị đã kết nối
flutter devices

# Chạy app trực tiếp
flutter run --release
```

## Bước 2: Cấp quyền Notification

1. Mở app trên điện thoại
2. Khi app yêu cầu quyền notification (Android 13+), chọn **"Cho phép"**
3. Nếu đã từ chối trước đó:
   - Vào **Settings** → **Apps** → **Step Counter** → **Notifications** → Bật **"Allow notifications"**

## Bước 3: Test Notification

### Test 1: Bật Remind và chọn thời gian gần (với interval theo phút)

1. Mở app → Vào màn hình **Drink Water Settings**
2. Bật toggle **"Remind"**
3. Chọn **Start Time**: Chọn thời gian **sau 1-2 phút** so với thời gian hiện tại
   - Ví dụ: Bây giờ là 10:00 AM → Chọn 10:02 AM
4. Chọn **End Time**: Chọn thời gian sau start time (ví dụ: 10:10 AM)
5. Chọn **Interval**: 
   - Nhấn vào button **Interval**
   - Chọn tab **"Minutes"** (thay vì Hours)
   - Chọn **1 min**, **2 min**, hoặc **5 min** để test nhanh
6. Nhấn **Save**

### Test 2: Kiểm tra Notification

1. **Đợi đến thời gian đã chọn** (hoặc đặt thời gian gần để test nhanh)
2. Khi đến giờ, bạn sẽ thấy notification:
   - **Title**: "Nhắc nhở uống nước"
   - **Body**: "Đã đến lúc uống nước rồi! Hãy uống nước để duy trì sức khỏe."
3. Notification sẽ có:
   - Icon app
   - Âm thanh (nếu điện thoại không ở chế độ im lặng)
   - Rung (nếu bật)

### Test 3: Test nhiều notifications với interval phút

1. Đặt **Start Time**: 10:00 AM
2. Đặt **End Time**: 10:10 AM  
3. Chọn **Interval**: 
   - Tab **"Minutes"**
   - Chọn **2 min**
4. Sẽ có notifications lúc: 10:00, 10:02, 10:04, 10:06, 10:08, 10:10

**Lưu ý**: Interval theo phút chỉ dùng để **test nhanh**. Trong thực tế, nên dùng interval theo giờ (1, 2, 3, 4, 6, 8 hours).

### Test 4: Test tắt Remind

1. Vào **Drink Water Settings**
2. Tắt toggle **"Remind"**
3. Nhấn **Save**
4. Tất cả notifications đã schedule sẽ bị hủy
5. Không còn notification nào được gửi nữa

## Bước 4: Kiểm tra Log (nếu cần debug)

```bash
# Xem log real-time
flutter logs

# Hoặc dùng adb logcat
adb logcat | grep -i "drink\|notification"
```

## Lưu ý quan trọng

1. **Thời gian test**: 
   - Để test nhanh, đặt start time **sau 1-2 phút** so với thời gian hiện tại
   - Notification sẽ được schedule cho **ngày mai** nếu thời gian đã qua

2. **Battery Optimization**:
   - Một số điện thoại có thể tắt notification khi app ở background
   - Vào **Settings** → **Battery** → **App optimization** → Tắt cho **Step Counter**

3. **Do Not Disturb Mode**:
   - Đảm bảo điện thoại không ở chế độ **Do Not Disturb**
   - Hoặc cho phép notification từ app này trong DND settings

4. **Android Version**:
   - Notification hoạt động tốt trên Android 8.0+ (API 26+)
   - Android 13+ (API 33+) cần permission POST_NOTIFICATIONS (đã có trong manifest)

## Troubleshooting

### Notification không hiện:
1. Kiểm tra quyền notification đã được cấp
2. Kiểm tra app không bị tối ưu pin
3. Kiểm tra Do Not Disturb mode
4. Xem log để tìm lỗi: `flutter logs`

### Notification chỉ hiện 1 lần:
- Đây là bình thường nếu bạn test với thời gian đã qua
- Notification sẽ lặp lại **mỗi ngày** cùng giờ nếu schedule đúng

### Muốn test lại nhanh:
- Tắt remind → Save
- Bật lại remind với thời gian mới → Save
- Notification sẽ được schedule lại với thời gian mới
