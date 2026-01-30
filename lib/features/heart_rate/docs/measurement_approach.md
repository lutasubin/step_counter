# Phương pháp đo nhịp tim

## Phương pháp đã chọn: Camera + PPG (Photoplethysmography)

### Tổng quan
Sử dụng camera của điện thoại để đo nhịp tim thông qua phương pháp PPG (Photoplethysmography):
- Người dùng đặt ngón tay lên camera và đèn flash
- Camera capture video frames liên tục
- Phân tích sự thay đổi cường độ ánh sáng qua ngón tay (do máu lưu thông)
- Tính toán BPM từ tần số dao động của ánh sáng

### Packages sử dụng
1. **camera: ^0.11.0+2** - Truy cập camera và capture video frames
2. **image: ^4.3.0** - Xử lý ảnh để tính toán cường độ ánh sáng

### Ưu điểm
- Không cần thiết bị ngoài
- Dễ triển khai
- Phù hợp với Android

### Nhược điểm
- Độ chính xác phụ thuộc vào điều kiện ánh sáng
- Cần người dùng giữ yên ngón tay
- Thời gian đo: 30-50 giây

### Các bước triển khai
1. Request camera permission
2. Khởi tạo camera controller
3. Capture video frames (30 FPS)
4. Xử lý mỗi frame: tính trung bình cường độ màu đỏ
5. Lọc nhiễu và tìm peaks trong signal
6. Tính BPM từ khoảng cách giữa các peaks
7. Hiển thị kết quả real-time
