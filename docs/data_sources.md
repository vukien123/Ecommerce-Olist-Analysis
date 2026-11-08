# Data Sources (Nguồn dữ liệu)

## 1. Dataset (Bộ dữ liệu)

**Tên:** Brazilian E-Commerce Public Dataset by Olist

**Nhà cung cấp:** Olist

**Nền tảng công bố:** Kaggle

**Đường dẫn gốc:**
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

**Time Coverage (Khoảng thời gian dữ liệu):** Các đơn hàng trong CSV có `order_purchase_timestamp` từ **04/09/2016 đến 17/10/2018**. Báo cáo xu hướng chính tập trung 01/2017–08/2018 vì một số tháng rìa rất ít bản ghi.

**Định dạng:** CSV (Tệp dữ liệu dạng bảng, các giá trị phân cách bằng dấu phẩy).

**License (Giấy phép được ghi nhận trong hồ sơ nguồn):** CC BY-NC-SA 4.0 (Ghi công – Phi thương mại – Chia sẻ tương tự). Trước khi phân phối lại dữ liệu, cần đối chiếu điều khoản hiện hành tại trang nguồn Kaggle.

## 2. Tables Used (Các bảng được sử dụng)

Dự án hiện sử dụng 3 bảng:

| Tệp CSV gốc | Bảng SQL Server | Số dòng |
|---|---|---:|
| olist_orders_dataset.csv | dbo.olist_orders | 99.441 |
| olist_order_items_dataset.csv | dbo.olist_order_items | 112.650 |
| olist_customers_dataset.csv | dbo.olist_customers | 99.441 |

Các số dòng trên được ghi nhận từ kết quả kiểm tra trong SQL Server.

## 3. Data Storage (Nơi lưu dữ liệu)

**Dữ liệu gốc:** `data/raw/`

**Cơ sở dữ liệu SQL Server:** `olist_ecommerce`

**File câu lệnh SQL:** `sql/olist_analysis.sql`

**Nguyên tắc:** Giữ nguyên các tệp CSV gốc, không chỉnh sửa trực tiếp.

## 4. Known Data Issues (Vấn đề dữ liệu đã phát hiện)

Khi nhập dữ liệu vào SQL Server, hai cột `price` (giá sản phẩm) và `freight_value` (phí vận chuyển) xuất hiện giá trị cao gấp 100 lần so với dữ liệu tham chiếu.

**Cách xử lý:** Tạo View (Bảng ảo) `dbo.v_olist_order_items_clean` để chia các giá trị cho 100 khi phân tích.

**Validation Status (Trạng thái kiểm chứng):** Đã đối soát độc lập từ CSV gốc và SQL Clean View ở **mức số dòng, tổng giá trị hàng hóa và tổng phí vận chuyển**: 112.650 dòng, 13.591.643,70 BRL và 2.251.909,54 BRL tương ứng. **Chưa đối chiếu từng dòng**; xem `docs/validation_report.md`.

Chi tiết đã được ghi trong `docs/data_quality_report.md` (Báo cáo chất lượng dữ liệu).

## 5. Usage (Mục đích sử dụng)

Dữ liệu được sử dụng cho dự án học tập và Portfolio (Hồ sơ dự án cá nhân), nhằm phân tích đơn hàng và hiệu quả giao hàng.

Khi công bố dự án trên GitHub, cần dẫn nguồn Olist/Kaggle và **không tải ba CSV gốc lên repository (Kho lưu trữ mã nguồn)** theo phạm vi công bố dự kiến; chỉ dẫn người xem tải dữ liệu từ trang nguồn. ZIP lưu trữ nội bộ hiện có các file CSV để đối chiếu. Ngoài ra, Power BI dùng dữ liệu được import từ SQL Server; việc Refresh (Làm mới) trên máy khác có thể cần cấu hình SQL Server tương ứng.
