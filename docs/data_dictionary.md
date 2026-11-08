# Data Dictionary (Từ điển dữ liệu)

## 1. Dataset Overview (Tổng quan dữ liệu)

Phiên bản project này sử dụng **ba bảng** từ Olist Brazilian E-Commerce. Số dòng đã đối chiếu với CSV gốc và kết quả SQL.

| SQL Table (Bảng SQL) | Rows (Số dòng) | Grain (Một dòng đại diện cho) |
|---|---:|---|
| `dbo.olist_orders` | 99.441 | Một đơn hàng |
| `dbo.olist_order_items` | 112.650 | Một dòng sản phẩm trong đơn hàng |
| `dbo.olist_customers` | 99.441 | Một bản ghi khách hàng gắn với lần đặt hàng |

## 2. Orders (Đơn hàng)

**Table (Bảng):** `dbo.olist_orders`  
**Grain (Mức chi tiết):** Một dòng trên `order_id`  
**Primary Business Key (Khóa nghiệp vụ):** `order_id` — 99.441 giá trị duy nhất, không phát hiện trùng.

| Column (Tên cột) | Business Meaning (Ý nghĩa nghiệp vụ) |
|---|---|
| `order_id` | Mã đơn hàng |
| `customer_id` | Mã bản ghi khách hàng gắn với đơn hàng |
| `order_status` | Trạng thái đơn hàng |
| `order_purchase_timestamp` | Thời điểm khách đặt hàng |
| `order_approved_at` | Thời điểm đơn được phê duyệt |
| `order_delivered_carrier_date` | Thời điểm đơn được bàn giao cho đơn vị vận chuyển |
| `order_delivered_customer_date` | Thời điểm khách nhận hàng thực tế |
| `order_estimated_delivery_date` | Ngày giao hàng dự kiến |

**Calculated Column (Cột tính trong Power BI):** `Purchase Month` dùng `DATE(YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), 1)` để phân nhóm theo tháng đặt hàng. Đây là trường **phát sinh trong Power BI**, không có sẵn trong CSV gốc.

## 3. Order Items (Chi tiết dòng sản phẩm)

**Raw SQL Table (Bảng SQL đã nhập):** `dbo.olist_order_items`  
**Clean View (Bảng ảo đã chuẩn hóa):** `dbo.v_olist_order_items_clean`  
**Grain (Mức chi tiết):** Một dòng sản phẩm trong một đơn.  
**Composite Key (Khóa ghép):** (`order_id`, `order_item_id`) — không phát hiện trùng.

| Column | Business Meaning (Ý nghĩa nghiệp vụ) |
|---|---|
| `order_id` | Mã đơn hàng chứa dòng sản phẩm |
| `order_item_id` | Số thứ tự dòng sản phẩm trong đơn |
| `product_id` | Mã sản phẩm |
| `seller_id` | Mã người bán |
| `shipping_limit_date` | Thời hạn bàn giao hàng phục vụ vận chuyển |
| `price` | Giá trị hàng hóa ở dòng sản phẩm, BRL |
| `freight_value` | Phí vận chuyển ở dòng sản phẩm, BRL |

**Transformation (Chuyển đổi):** Hai cột tiền trong bảng SQL nhập ban đầu cao gấp 100 lần CSV; Clean View chia `price` và `freight_value` cho 100 và ép kiểu `DECIMAL(18,2)`. **Power BI dùng Clean View**, không dùng hai cột tiền chưa chuẩn hóa. Đã đối soát tổng tiền với CSV; xem `docs/data_quality_report.md` và `docs/validation_report.md`.

## 4. Customers (Khách hàng)

**Table (Bảng):** `dbo.olist_customers`  
**Grain (Mức chi tiết):** Một dòng trên `customer_id`.  
**Key Check (Kiểm chứng khóa):** 99.441 dòng; 99.441 `customer_id` duy nhất; 0 NULL.

| Column | Business Meaning (Ý nghĩa nghiệp vụ) |
|---|---|
| `customer_id` | Mã bản ghi khách hàng gắn với một lần đặt hàng |
| `customer_unique_id` | Mã dùng để nhận diện cùng một khách hàng ở nhiều lần mua |
| `customer_zip_code_prefix` | Phần đầu mã bưu chính |
| `customer_city` | Thành phố của khách hàng |
| `customer_state` | Bang của khách hàng tại Brazil |

**Important Distinction (Phân biệt quan trọng):** `customer_id` không phải mã định danh duy nhất của một **người mua** qua mọi lần mua. Không dùng nó để tính số khách hàng quay lại; việc đó cần đánh giá trên `customer_unique_id`.

## 5. Table Relationships (Quan hệ giữa các bảng)

| Relationship (Quan hệ) | Join Key (Khóa nối) | Observed Grain (Mức chi tiết đã kiểm chứng) |
|---|---|---|
| Orders → Order Items | `order_id` | Orders 1 → nhiều Items (`1:*`); mỗi Order có thể không có Item |
| Customers → Orders | `customer_id` | `1:1` trong tập dữ liệu hiện tại; mỗi đơn khớp một bản ghi Customers |

**Referential Integrity (Toàn vẹn tham chiếu):**

- 98.666 đơn có ít nhất một Item; 775 đơn không có Item.
- 0 dòng Items tham chiếu đến `order_id` không tồn tại trong Orders.
- 0 đơn không khớp `customer_id` với Customers.

**Power BI Model (Mô hình Power BI):** Có ba đối tượng dữ liệu (`olist_orders`, `olist_customers`, `v_olist_order_items_clean`). Thiết lập quan hệ đã được thực hiện trong Power BI Desktop khi xây dựng báo cáo. Khi dùng trường `customer_state` để lọc tỷ lệ giao trễ, các phép đo phải đi theo quan hệ Customers–Orders; khi dùng đơn hàng để lọc giá trị hàng hóa, phải đi theo quan hệ Orders–Clean Items.

## 6. Data Modeling Cautions (Lưu ý khi mô hình hóa)

- Không dùng `COUNT(*)` sau JOIN Orders–Items làm số đơn hàng: JOIN có thể nhân bản đơn có nhiều dòng sản phẩm.
- Dùng `DISTINCTCOUNT(order_id)` hoặc đếm trực tiếp trong bảng Orders đúng mức chi tiết.
- Các tháng trên Dashboard nhóm theo **ngày đặt hàng**, không phải ngày giao hàng.
- CSV gốc trong `data/raw/` không được thay đổi; các bước sửa sai được đặt trong View SQL.

**SQL Reference:** `sql/olist_analysis.sql`, mục 1.3–1.15, 1A.1–1A.3 và 5.1.
