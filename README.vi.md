# Adonis — nhật ký tiếng Việt

Adonis là bản sửa đổi, không phải ứng dụng chính thức. Ứng dụng nhật ký từ [mã nguồn Daily You](https://github.com/demizo/daily_you), phiên bản 3.7.0. Giữ nguyên giấy phép và các điều khoản của dự án gốc.

## Môi trường

- Flutter 3.47.4, Dart 3.13.3 đã được dùng để kiểm tra trên Windows.
- Visual Studio với workload **Desktop development with C++**, Windows SDK và thành phần **C++ ATL for latest build tools (x86 & x64)**.
- Git và kết nối mạng cho lần tải thư viện đầu tiên. Sau khi cài đặt, ứng dụng lưu dữ liệu trên thiết bị và hoạt động ngoại tuyến.

## Cài đặt và chạy

Chạy tại thư mục dự án:

```powershell
flutter pub get
flutter gen-l10n
flutter run -d windows
```

Tạo bản phát hành:

```powershell
flutter build windows --release
```

Mở [daily_you.exe](build/windows/x64/runner/Release/daily_you.exe). Khi chuyển sang máy khác, cần chép **toàn bộ thư mục Release**, bao gồm các DLL và thư mục dữ liệu, không chỉ tệp EXE.

Nếu máy có nhiều bộ Visual Studio và CMake chọn nhầm bộ thiếu ATL, cấu hình lại bộ công cụ bằng đường dẫn cài đặt thực tế, ví dụ trên máy phát triển này:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe' `
  -S windows -B build/windows/x64 `
  '-DCMAKE_GENERATOR_INSTANCE=C:/Program Files/Microsoft Visual Studio/18/Community'
flutter build windows --release
```

Lệnh cấu hình này dùng sau khi Flutter đã tạo cấu hình Windows. Bản sửa tương thích coroutine trong [windows/CMakeLists.txt](windows/CMakeLists.txt) hỗ trợ các plugin C++/WinRT hiện tại với MSVC 14.51.

## Phạm vi tiếng Việt

- Hoàn thiện 298 chuỗi trong [intl_vi.arb](lib/l10n/intl_vi.arb): điều hướng, nhật ký, lịch, thống kê, cài đặt, thẻ, mẫu, bảo mật, nhập/xuất, sao lưu/khôi phục và thông báo lỗi.
- Cài đặt mới mặc định dùng tiếng Việt, độc lập với ngôn ngữ hệ điều hành. Người dùng vẫn có thể chọn ngôn ngữ khác hoặc theo hệ thống trong **Cài đặt → Ngôn ngữ**. Tùy chọn đã lưu được giữ nguyên.
- Ngày giờ và nút điều khiển Material/Cupertino dùng bộ bản địa hóa tiếng Việt. Thông báo nền lấy ngôn ngữ từ cùng thiết lập ứng dụng.
- Giữ nguyên tên sản phẩm, tên ứng dụng nhập dữ liệu, định dạng chuẩn (JSON, Markdown), AMOLED và mã giấy phép GPL-3.0.
- Nội dung người dùng đã viết, chi tiết kỹ thuật của ngoại lệ và văn bản pháp lý của bên thứ ba được giữ nguyên. Hộp thoại chọn tệp, cấp quyền và sinh trắc học do hệ điều hành cung cấp tuân theo ngôn ngữ của hệ điều hành.

Sửa bản dịch tại tệp ARB rồi chạy `flutter gen-l10n`; không chỉnh trực tiếp mã được sinh tự động.

## Kiểm tra

```powershell
flutter analyze --no-pub
flutter test --no-pub test/l10n/vietnamese_test.dart
flutter test --no-pub --concurrency=1
```

Các kiểm thử tiếng Việt kiểm tra độ phủ khóa dịch, tham số ICU, số lượng, tiến độ, ngôn ngữ mặc định và bố cục màn hình chọn ngôn ngữ ở chiều rộng 360 và 1280 px.

Kết quả xác minh trên Windows: bản release build thành công; `flutter analyze --no-pub` không phát hiện vấn đề; toàn bộ **512 kiểm thử đạt**. Đã kiểm tra trực tiếp việc khởi động, lịch, thư viện, bài chào mừng, trình soạn thảo, cài đặt và danh sách mẫu mặc định bằng tiếng Việt. Chưa kiểm tra trên thiết bị Android, iOS hoặc macOS.

Các sửa lỗi vận hành đi kèm: đóng kết nối kiểm tra SQLite ngay cả khi lỗi, đóng luồng đọc ZIP, chờ đóng tệp khi hủy nén, tuần tự hóa việc lưu cấu hình, chuẩn hóa đường dẫn Windows và hỗ trợ tạo ảnh thu nhỏ từ WebP. Cấu hình đóng gói Windows đã bổ sung thư viện native từ Dart build hooks để tránh thiếu `sqlite3.dll` khi khởi động.

## Windows và localhost

Đây là ứng dụng Flutter native dùng SQLite, hệ thống tệp và các plugin nền tảng. Mã nguồn gốc chưa có nền tảng web. Bản Windows chạy trực tiếp trên máy; địa chỉ localhost của Flutter DevTools khi chạy debug là công cụ phát triển, không phải bản web của ứng dụng. Muốn sử dụng trong trình duyệt cần triển khai riêng lớp lưu trữ và các tính năng tương thích web.

Một số chức năng như lời nhắc nền và sao lưu theo lịch chỉ được dự án gốc triển khai cho Android. Cần thiết bị Android để xác minh các chức năng này.
