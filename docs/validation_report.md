# Validation Report (Báo cáo kiểm chứng)

**Project (Dự án):** E-commerce Order & Delivery Performance Analysis  
**Database (Cơ sở dữ liệu):** `olist_ecommerce`  
**SQL Script (File truy vấn):** `sql/olist_analysis.sql`  
**Power BI File (File báo cáo):** `powerbi/olist_dashboard.pbix`

## 1. Purpose and Evidence (Mục đích và bằng chứng)

Đối chiếu các bước JOIN (Nối bảng), Cleaning (Chuẩn hóa dữ liệu tiền) và KPI (Chỉ số đo lường) giữa CSV gốc, SQL Server và Power BI. Các giá trị SQL/Power BI bên dưới là kết quả đã ghi nhận và kiểm tra trong quá trình xây dựng project; CSV được dùng để tính độc lập những chỉ số có thể đối chiếu từ file nguồn.

**Lưu ý về phạm vi:** Đối chiếu tổng hợp không đồng nghĩa đã xác minh từng bản ghi. Việc đọc cấu trúc file PBIX không thay thế kiểm thử tương tác trực tiếp trong Power BI Desktop.

## 2. Test 7.1 — LEFT JOIN Validation (Kiểm chứng nối bảng)

**Join (Phép nối):** `dbo.olist_orders LEFT JOIN dbo.v_olist_order_items_clean ON order_id`

| Metric (Chỉ tiêu) | Expected (Dự kiến) | Observed (Ghi nhận) | Result (Kết quả) |
|---|---:|---:|---|
| Joined Rows (Số dòng sau JOIN) | 113.425 | 113.425 | PASS |
| Distinct Orders (Đơn duy nhất) | 99.441 | 99.441 | PASS |
| Item Rows (Dòng sản phẩm) | 112.650 | 112.650 | PASS |
| Orders Without Items (Đơn không có Items) | 775 | 775 | PASS |

**Reconciliation (Đối soát):** `112.650 + 775 = 113.425`. Toàn bộ 99.441 đơn vẫn được giữ sau LEFT JOIN; không dùng `COUNT(*)` sau JOIN như số đơn hàng nếu một đơn có nhiều Items.

**SQL Reference:** `sql/olist_analysis.sql` — mục 5.1.

## 3. Test 7.2 — Monetary Reconciliation (Đối soát giá trị tiền)

Nguồn: `data/raw/olist_order_items_dataset.csv` và `dbo.v_olist_order_items_clean`.

| Measure (Chỉ tiêu, toàn bộ Items) | Original CSV (CSV gốc) | SQL Clean View (View chuẩn hóa) | Result |
|---|---:|---:|---|
| Item Rows (Số dòng) | 112.650 | 112.650 | PASS |
| Total Item Value (Tổng giá trị hàng hóa) | 13.591.643,70 BRL | 13.591.643,70 BRL | PASS |
| Total Freight Value (Tổng phí vận chuyển) | 2.251.909,54 BRL | 2.251.909,54 BRL | PASS |

**Decision (Quyết định):** Sử dụng Clean View cho mọi phép tính tiền; giữ nguyên bảng SQL đã nhập để truy vết.

**Limitation (Giới hạn):** Đối chiếu về số dòng và **tổng tiền**; chưa kiểm chứng từng dòng dữ liệu.

**SQL Reference:** `sql/olist_analysis.sql` — mục 1A.1–1A.3 và 5.2.

## 4. Test 7.3 — KPI Reconciliation (Đối chiếu chỉ số SQL – Power BI)

Các giá trị dưới đây áp dụng cho **toàn kỳ, khi không có bộ lọc đang chọn**:

| KPI (Chỉ số) | SQL / Source Check (Kiểm tra nguồn) | Power BI (Đã ghi nhận) | Result |
|---|---:|---:|---|
| Total Orders (Tổng đơn) | 99.441 | 99.441 | PASS |
| Total Item Value — Delivered (Giá trị hàng hóa của đơn đã giao) | 13.221.498,11 BRL | 13.221.498,11 BRL | PASS |
| Eligible Delivered Orders (Đơn đủ điều kiện đánh giá trễ) | 96.470 | 96.470 | PASS |
| Late Orders (Đơn giao trễ) | 6.534 | 6.534 | PASS |
| Late Delivery Rate (Tỷ lệ giao trễ) | 6,77% | 6,77% | PASS |

**Rules (Quy tắc):**
- `Total Orders` gồm mọi trạng thái đơn, đếm `DISTINCT order_id`.
- `Total Item Value` chỉ tính `SUM(price)` từ Clean View cho đơn `delivered`, không gồm `freight_value`, không gọi là doanh thu kế toán.
- `Late Delivery Rate` = 6.534 / 96.470 = 6,7731%, hiển thị **6,77%**; trễ khi ngày thực nhận sau ngày dự kiến, bỏ qua phần giờ.

### Trend Check (Đối chiếu theo tháng)

Hai biểu đồ xu hướng dùng **tháng đặt hàng** (`order_purchase_timestamp`), tập trung vào **01/2017–08/2018**; KPI Card phía trên của báo cáo được ghi nhãn theo **toàn kỳ dữ liệu**.

| Month (Tháng) | Metric (Chỉ tiêu) | SQL / CSV | Power BI (Đã ghi nhận) | Result |
|---|---|---:|---:|---|
| 11/2017 | Total Orders (Tổng đơn) | 7.544 | 7.544 | PASS |
| 11/2017 | Total Item Value — Delivered | 987.765,37 BRL | 987.765,37 BRL | PASS |

### State Check (Đối chiếu theo bang)

Phân tích giao trễ theo bang dùng toàn kỳ. Đã kiểm tra các mốc:

| State (Bang) | Eligible Orders (Đơn đủ điều kiện) | Late Orders (Đơn trễ) | Late Rate (Tỷ lệ trễ) |
|---|---:|---:|---:|
| AL | 397 | 85 | 21,41% |
| MA | 717 | 125 | 17,43% |
| CE | 1.279 | 176 | 13,76% |
| BA | 3.256 | 396 | 12,16% |
| RJ | 12.350 | **1.495** | **12,11%** |
| SP | 40.494 | **1.820** | **4,49%** |

Tổng cộng **27 bang**, **96.470 đơn đủ điều kiện** và **6.534 đơn giao trễ**. Các mốc AL, SP và số đơn trễ RJ đã được kiểm tra trên biểu đồ Power BI trong quá trình xây dựng.

**SQL Reference:** `sql/olist_analysis.sql` — mục 2.1–2.4.

## 5. Dashboard Artifact Check (Kiểm tra file báo cáo)

- File PBIX chứa **2 trang**: `Order Overview` (Tổng quan đơn hàng) và `Delivery Performance` (Hiệu quả giao hàng).
- Trang tổng quan gồm **3 Card và 2 Line Chart (Biểu đồ đường)**.
- Trang giao hàng gồm **3 Card và 2 Bar Chart (Biểu đồ thanh ngang)**.
- Báo cáo có bố cục và các thành phần lưu trong PBIX. Tuy nhiên, **không thể kết luận từ cấu trúc file rằng mọi Cross-filter (Lọc chéo), Tooltip (Chú giải khi rê chuột) hay tương tác đã được thử thành công**. Cần giữ kết quả kiểm thử thao tác thực tế nếu muốn xác nhận các tính năng này một cách độc lập.

## 6. Overall Status (Trạng thái chung)

**PASS for recorded core validations (Đạt các đối chiếu cốt lõi đã ghi nhận):** JOIN, tổng tiền đã chuẩn hóa, KPI toàn kỳ, mốc tháng 11/2017 và các mốc theo bang đều khớp.

**Remaining evidence (Bằng chứng chưa kèm trong ZIP):** Chưa có ảnh xuất riêng từ hai trang Dashboard và bảng kết quả kiểm thử tương tác của Work. Đây là phần tài liệu bàn giao cho GitHub, **không phải kết luận rằng các KPI đang sai**.
