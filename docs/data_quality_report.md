# Olist Data Quality Report (Báo cáo chất lượng dữ liệu Olist)

**Project (Dự án):** E-commerce Order & Delivery Performance Analysis  
**Database (Cơ sở dữ liệu):** `olist_ecommerce`  
**Scope (Phạm vi):** Ba bảng Orders, Order Items và Customers sử dụng trong phiên bản phân tích hiện tại.

## 1. Overview (Tổng quan)

Báo cáo ghi nhận các kiểm tra về **Completeness (Tính đầy đủ)**, **Uniqueness (Tính duy nhất)**, **Referential Integrity (Tính toàn vẹn tham chiếu)** và **Validity (Tính hợp lệ)**. Các phát hiện được giữ nguyên để người đọc thấy cách xử lý dữ liệu, không xóa các bản ghi bất thường một cách tùy tiện.

| SQL Table (Bảng SQL) | Rows (Số dòng) | Grain (Một dòng đại diện cho) |
|---|---:|---|
| `dbo.olist_orders` | 99.441 | Một đơn hàng |
| `dbo.olist_order_items` | 112.650 | Một dòng sản phẩm trong đơn |
| `dbo.olist_customers` | 99.441 | Một bản ghi khách hàng gắn với lần đặt hàng |

## 2. Data Quality Checks (Kiểm tra chất lượng dữ liệu)

### 2.1. Keys and Duplicates (Khóa và trùng lặp)

- Orders: 99.441 dòng, 99.441 mã `order_id` duy nhất; không phát hiện trùng khóa.
- Order Items: không phát hiện trùng khóa ghép (`order_id`, `order_item_id`).
- Customers: 99.441 dòng, 99.441 mã `customer_id` duy nhất và 0 giá trị `customer_id` NULL.

### 2.2. Missing Values (Giá trị thiếu)

- Cả bảy cột được kiểm tra trong Order Items (`order_id`, `order_item_id`, `product_id`, `seller_id`, `shipping_limit_date`, `price`, `freight_value`) đều không có giá trị NULL.
- Trong 96.478 đơn có trạng thái `delivered`, có **8 đơn thiếu `order_delivered_customer_date`** và **0 đơn thiếu `order_estimated_delivery_date`**.
- Kết quả không có NULL chỉ áp dụng cho các cột đã kiểm tra, **không có nghĩa toàn bộ dữ liệu đều đầy đủ**.

### 2.3. Referential Integrity (Toàn vẹn tham chiếu)

- **98.666** đơn có ít nhất một dòng Order Items.
- **775** đơn không có dòng Order Items.
- Có **0** mã `order_id` trong Order Items không khớp với Orders.
- Có **0** đơn hàng không khớp `customer_id` trong Customers.

### 2.4. Monetary Plausibility (Tính hợp lý của giá trị tiền)

- Không phát hiện `price` hoặc `freight_value` âm trong Order Items.
- Có **383** dòng với `freight_value = 0`; không tự coi đây là lỗi.
- Khi nhập SQL Server, `price` và `freight_value` bị tăng **100 lần** so với giá trị ở CSV gốc. Việc chuẩn hóa và đối soát được nêu tại Finding 2.

## 3. Findings and Decisions (Phát hiện và cách xử lý)

### Finding 1 — Orders Without Items (Đơn hàng không có dòng sản phẩm)

| Order Status (Trạng thái đơn) | Orders (Số đơn) |
|---|---:|
| `unavailable` (Không thể xử lý) | 603 |
| `canceled` (Đã hủy) | 164 |
| `created` (Mới tạo) | 5 |
| `invoiced` (Đã lập hóa đơn) | 2 |
| `shipped` (Đã gửi vận chuyển) | 1 |
| **Total (Tổng)** | **775** |

**767/775 đơn (98,97%)** thuộc hai trạng thái `unavailable` hoặc `canceled`. Đây có thể là đặc điểm nghiệp vụ của đơn không hoàn tất, **không đủ bằng chứng kết luận là lỗi**.

**Decision (Quyết định):** Giữ cả 775 đơn trong Orders. KPI `Total Orders` vẫn đếm toàn bộ trạng thái; KPI `Total Item Value` chỉ cộng dòng sản phẩm của đơn `delivered`.

### Finding 2 — Monetary Import Scaling (Sai hệ số tiền khi nhập dữ liệu)

Hai cột tiền trong bảng `dbo.olist_order_items` sau import có giá trị lớn gấp 100 lần CSV. Ví dụ với `order_id = '00010242fe8c5a6d1ba2dd792cb16214'`, `order_item_id = 1`:

| Field (Trường) | Raw SQL Import (SQL sau import) | Original CSV / Clean View (CSV gốc / View chuẩn hóa) |
|---|---:|---:|
| `price` | 5.890,00 | 58,90 |
| `freight_value` | 1.329,00 | 13,29 |

**Transformation (Chuyển đổi):** Giữ nguyên bảng SQL nhập ban đầu; tạo `dbo.v_olist_order_items_clean` với:

```sql
CAST(price / 100.0 AS DECIMAL(18,2)) AS price,
CAST(freight_value / 100.0 AS DECIMAL(18,2)) AS freight_value
```

**Validation (Đối soát):** View có 112.650 dòng; `price` từ 0,85 đến 6.735,00 BRL; `freight_value` từ 0,00 đến 409,68 BRL. Tính tổng độc lập từ CSV gốc cho kết quả trùng khớp View:

| Measure (Chỉ tiêu) | Original CSV (CSV gốc) | Clean SQL View (View SQL chuẩn hóa) |
|---|---:|---:|
| Total Item Value (Tổng giá trị hàng hóa, mọi trạng thái) | 13.591.643,70 BRL | 13.591.643,70 BRL |
| Total Freight Value (Tổng phí vận chuyển, mọi trạng thái) | 2.251.909,54 BRL | 2.251.909,54 BRL |

**Decision (Quyết định):** Sử dụng View chuẩn hóa cho phân tích và Power BI. **Đối soát đã hoàn tất ở mức số dòng và tổng hợp**, chưa đối chiếu từng dòng với toàn bộ CSV; không được diễn đạt như đã kiểm chứng 100% các dòng riêng lẻ. Xem `docs/validation_report.md`, Test 7.2.

### Finding 3 — Missing Delivery Dates (Thiếu ngày giao hàng)

| Check (Kiểm tra) | Result (Kết quả) |
|---|---:|
| Delivered Orders (Đơn đã giao) | 96.478 |
| Missing Actual Delivery Date (Thiếu ngày giao thực tế) | 8 |
| Missing Estimated Delivery Date (Thiếu ngày giao dự kiến) | 0 |
| Excluded Orders (Đơn bị loại khỏi KPI giao trễ) | 8 |
| Eligible Delivered Orders (Đơn đủ điều kiện) | **96.470** |
| Late Orders (Đơn giao trễ) | **6.534** |
| Late Delivery Rate (Tỷ lệ giao trễ) | **6,77%** |

**Rule (Quy tắc):** Chỉ tính đơn `delivered` có cả hai ngày giao; đơn giao trễ khi `CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE)`. Bỏ phần giờ khi so sánh cùng ngày.

**Decision (Quyết định):** Giữ nguyên 8 đơn thiếu ngày; không tự điền ngày giao. Loại chúng **chỉ khỏi mẫu số KPI tỷ lệ giao trễ**. Chúng vẫn thuộc tập đơn đã giao khi tính các chỉ tiêu khác theo định nghĩa.

### Finding 4 — Delivery Timestamp Anomalies (Thứ tự thời gian giao vận bất thường)

| Check (Kiểm tra) | Result (Kết quả) |
|---|---:|
| Delivered Before Purchase (Nhận hàng trước khi đặt) | 0 đơn |
| Delivered Before Carrier Handoff (Nhận hàng trước khi bàn giao vận chuyển) | **23 đơn** |
| Estimated Date Before Purchase Date (Ngày dự kiến trước ngày đặt) | 0 đơn |

Trong 23 đơn bất thường, độ lệch khi tính bằng `DATEDIFF(MINUTE, ...)` dao động từ **23 đến 23.179 phút** (tối đa khoảng 16 ngày 2 giờ 19 phút). Cả 23 đơn có trạng thái `delivered`.

**Interpretation (Diễn giải):** Ngày khách nhận hàng xuất hiện sớm hơn thời điểm ghi nhận bàn giao vận chuyển. Chưa có bằng chứng xác định nguyên nhân (ví dụ nhập sai, đồng bộ chậm hoặc quy trình vận chuyển khác biệt).

**Decision (Quyết định):** Giữ nguyên bản ghi; không tự sửa mốc thời gian. Không loại tự động khỏi KPI giao trễ vì KPI chỉ so sánh ngày nhận thực tế và ngày dự kiến, **không sử dụng thời điểm bàn giao vận chuyển**. Không dùng các bản ghi này để suy luận thời gian vận chuyển giữa hai mốc nếu chưa điều tra.

## 4. Status and Limitations (Trạng thái và giới hạn)

**Status (Trạng thái):** Hoàn thành các kiểm tra chất lượng dữ liệu **trong phạm vi phiên bản project hiện tại**; những vấn đề phát hiện đã có cách xử lý và được ghi nhận. Không khẳng định dữ liệu không còn lỗi nào khác.

- Kiểm tra tiền đã đối soát ở **mức tổng hợp**, không phải toàn bộ từng dòng.
- Chưa xác định nguyên nhân thực tế của 23 bất thường về thời gian.
- Các KPI SQL và Power BI đã có đối chiếu riêng trong `docs/validation_report.md`.

## 5. SQL Reference (Truy vấn tham chiếu)

`sql/olist_analysis.sql`: mục 1.3–1.9, 1.11–1.15, 1A.1–1A.3, 2.1 và 5.1–5.2. Việc đối chiếu độc lập với CSV được mô tả tại `docs/validation_report.md`.
