# KPI Dictionary (Từ điển chỉ số đo lường)

**Scope (Phạm vi):** Phân tích đơn hàng và hiệu quả giao hàng Olist trên ba bảng Orders, Order Items, Customers. Các KPI trên Dashboard dùng quy tắc dưới đây; **không thay đổi công thức chỉ để điều chỉnh cách hiển thị**.

## 1. Total Orders (Tổng số đơn hàng)

- **Business Meaning (Ý nghĩa):** Số đơn được ghi nhận, bất kể trạng thái.
- **SQL Formula (Công thức SQL):** `COUNT(DISTINCT o.order_id)` trên `dbo.olist_orders`.
- **Power BI Measure (Phép đo DAX):** `DISTINCTCOUNT('olist_orders'[order_id])`.
- **Date Basis (Mốc thời gian):** `order_purchase_timestamp` (thời điểm đặt hàng).
- **Filter (Điều kiện):** Bao gồm **tất cả** trạng thái đơn hàng.
- **All-period Result (Kết quả toàn kỳ):** **99.441 đơn**.

## 2. Total Item Value (Tổng giá trị hàng hóa của đơn đã giao)

- **Business Meaning (Ý nghĩa):** Tổng giá trị các dòng sản phẩm thuộc đơn có trạng thái `delivered` (đã giao).
- **SQL Formula (Công thức SQL):** `SUM(i.price)` từ `dbo.v_olist_order_items_clean AS i` nối `dbo.olist_orders AS o` bằng `order_id`, lọc `o.order_status = 'delivered'`.
- **Power BI Logic (Logic DAX):** `CALCULATE(SUM('v_olist_order_items_clean'[price]), 'olist_orders'[order_status] = "delivered")`.
- **Date Basis (Mốc thời gian):** Tháng đặt hàng từ `order_purchase_timestamp`, **không phải tháng giao hàng**.
- **All-period Result (Kết quả toàn kỳ):** **13.221.498,11 BRL** (96.478 đơn `delivered`).
- **November 2017 (Tháng 11/2017):** **987.765,37 BRL**, 7.289 đơn đã giao.

**Important Notes (Lưu ý):**

- `price` đã được chuẩn hóa bằng phép chia 100 trong Clean View; không dùng `price` từ bảng SQL nhập sai hệ số.
- Không gồm `freight_value` (phí vận chuyển).
- Đây là **giá trị hàng hóa**, không đồng nghĩa với doanh thu kế toán, tiền thực nhận hoặc lợi nhuận.
- Tổng giá trị của **toàn bộ** dòng Items, không lọc `delivered`, là 13.591.643,70 BRL; **không nhầm** số này với KPI.

## 3. Eligible Delivered Orders (Số đơn đã giao đủ điều kiện đánh giá trễ)

- **Business Meaning (Ý nghĩa):** Mẫu số dùng để đo tỷ lệ giao trễ.
- **Rule (Quy tắc):** `order_status = 'delivered'` và **cả hai** `order_delivered_customer_date`, `order_estimated_delivery_date` khác NULL.
- **Source (Nguồn):** `dbo.olist_orders`.
- **All-period Result (Kết quả toàn kỳ):** **96.470 đơn**; có 8 đơn `delivered` bị loại khỏi mẫu số do thiếu ngày nhận thực tế.

## 4. Late Orders (Số đơn giao trễ)

- **Business Meaning (Ý nghĩa):** Số đơn `delivered`, đủ hai ngày và giao sau ngày dự kiến.
- **Rule (Quy tắc):** `CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE)`.
- **Date Rule (Quy tắc ngày):** So sánh **ngày lịch**, không so giờ. Nếu nhận muộn trong cùng ngày dự kiến thì **không** tính là trễ.
- **All-period Result (Kết quả toàn kỳ):** **6.534 đơn**.

## 5. Late Delivery Rate (Tỷ lệ giao trễ)

**Formula (Công thức):**

`Late Delivery Rate (%) = Late Orders / Eligible Delivered Orders × 100`

- **DAX Formula (Công thức DAX):** `DIVIDE([Late Orders], [Eligible Delivered Orders], 0)`, định dạng Percentage (Phần trăm) với 2 chữ số thập phân.
- **All-period Result (Kết quả toàn kỳ):** 6.534 / 96.470 = **6,77%**.
- **Limitation (Giới hạn):** Kết quả `0` khi mẫu số bằng 0 là lựa chọn hiển thị của DAX hiện tại; trong một nhóm không có đơn đủ điều kiện, cần tránh diễn giải `0%` như một tỷ lệ trễ thực sự.

## 6. Late Delivery Rate by State (Tỷ lệ giao trễ theo bang)

- **Business Meaning (Ý nghĩa):** So sánh tỷ lệ trễ theo `customer_state`, bang của khách hàng.
- **Join Key (Khóa nối):** `dbo.olist_orders.customer_id = dbo.olist_customers.customer_id`.
- **Formula (Công thức):** Late Orders của bang / Eligible Delivered Orders của bang × 100%.
- **Filter (Điều kiện):** Cùng tiêu chí về trạng thái và ngày như KPI toàn kỳ.
- **Coverage (Phạm vi):** **27 bang**, tổng mẫu số 96.470 và tổng tử số 6.534.

| State (Bang) | Eligible Orders (Đơn đủ điều kiện) | Late Orders (Đơn trễ) | Late Delivery Rate (Tỷ lệ trễ) |
|---|---:|---:|---:|
| AL | 397 | 85 | 21,41% |
| MA | 717 | 125 | 17,43% |
| CE | 1.279 | 176 | 13,76% |
| BA | 3.256 | 396 | 12,16% |
| RJ | 12.350 | 1.495 | 12,11% |
| SP | 40.494 | 1.820 | 4,49% |

**Interpretation Note (Lưu ý diễn giải):** Không xếp mức độ ưu tiên chỉ dựa vào tỷ lệ. Bang có ít đơn có thể có tỷ lệ cao nhưng ít trường hợp trễ; cần đọc cùng `Late Orders` và `Eligible Delivered Orders`.

## 7. Time Scope and Validation (Phạm vi thời gian và kiểm chứng)

- **All-period Cards (Thẻ KPI toàn kỳ):** Sử dụng toàn bộ các bản ghi phù hợp với định nghĩa KPI (dữ liệu đơn đặt từ 09/2016 đến 10/2018).
- **Monthly Trends (Biểu đồ xu hướng theo tháng):** Tập trung **01/2017–08/2018** để hạn chế ảnh hưởng của các tháng rìa rất ít bản ghi. Khoảng này **không** thay đổi kết quả KPI toàn kỳ mặc định.
- **Validation Status (Trạng thái kiểm chứng):** Các chỉ số trên đã được đối chiếu với SQL và ghi nhận kết quả tương ứng trên Power BI. Chi tiết và giới hạn bằng chứng xem `docs/validation_report.md`.

**SQL Reference:** `sql/olist_analysis.sql`, mục 2.1–2.4 và 5.1–5.2.
