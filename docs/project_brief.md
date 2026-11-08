# E-commerce Order & Delivery Performance Analysis (Phân tích đơn hàng và hiệu quả giao hàng thương mại điện tử)

## 1. Domain (Lĩnh vực)

E-commerce & Logistics (Thương mại điện tử và vận chuyển hàng hóa).

## 2. Stakeholder (Người sử dụng kết quả phân tích)

E-commerce Operations Manager (Quản lý vận hành sàn thương mại điện tử).

Đây là **vai trò giả định** để xây dựng bài toán phân tích, không phải khách hàng thực tế của dự án.

## 3. Business Problem (Vấn đề kinh doanh)

Analyze historical order data to evaluate order trends, item value and delivery performance.

(Phân tích dữ liệu đơn hàng trong quá khứ để đánh giá xu hướng đặt hàng, giá trị hàng hóa và hiệu quả giao hàng.)

**Mục đích:** Giúp người quản lý nhận biết những vấn đề đáng chú ý trong hoạt động bán hàng và giao vận.

## 4. Objectives (Mục tiêu phân tích)

- Evaluate order volume trends (Đánh giá xu hướng số lượng đơn hàng).
- Analyze total item value over time (Phân tích tổng giá trị hàng hóa theo thời gian).
- Measure late-delivery performance (Đánh giá tình hình giao hàng trễ).
- Identify customer states requiring attention (Xác định những bang/khu vực khách hàng cần được chú ý về giao hàng).

## 5. Business Questions (Các câu hỏi kinh doanh)

**Question 1:** How does order volume change over time?

(Số lượng đơn hàng thay đổi như thế nào theo thời gian?)

**Question 2:** How does total item value change by month?

(Tổng giá trị hàng hóa thay đổi như thế nào theo từng tháng?)

**Question 3:** What percentage of eligible delivered orders were delivered late?

(Bao nhiêu phần trăm đơn hàng đã giao, có đủ dữ liệu ngày giao dự kiến và ngày giao thực tế, bị giao trễ?)

**Question 4:** Which customer states have higher late-delivery rates?

(Những bang/khu vực khách hàng nào có tỷ lệ giao hàng trễ cao hơn?)

## 6. Scope (Phạm vi dự án)

**Dataset (Bộ dữ liệu):** Olist Brazilian E-Commerce (Dữ liệu thương mại điện tử Olist tại Brazil).

**Time Period (Khoảng thời gian):** Các đơn có thời điểm đặt hàng từ **04/09/2016 đến 17/10/2018**. Xu hướng theo tháng trên Dashboard tập trung **01/2017–08/2018**; Card KPI tổng kỳ vẫn tính toàn bộ dữ liệu theo định nghĩa của chỉ số.

**Tables (Các bảng dữ liệu) sử dụng:**

- `olist_orders` — Thông tin đơn hàng.
- `olist_order_items` — Chi tiết sản phẩm trong đơn hàng.
- `olist_customers` — Thông tin khách hàng.

**Transformation (Bước chuẩn hóa):** Sử dụng `dbo.v_olist_order_items_clean` để khắc phục sai hệ số 100 của hai cột tiền trong SQL nhập ban đầu. Dữ liệu CSV gốc không thay đổi.

**Tools (Công cụ):**

- SQL Server — Hệ quản trị cơ sở dữ liệu.
- SSMS — Phần mềm viết và chạy câu lệnh SQL.
- Power BI — Công cụ xây dựng báo cáo và biểu đồ tương tác.

**Dashboard Structure (Cấu trúc Dashboard):**

- `Order Overview` (Tổng quan đơn hàng): 3 KPI Card và 2 biểu đồ xu hướng theo tháng.
- `Delivery Performance` (Hiệu quả giao hàng): 3 KPI Card và 2 biểu đồ theo bang.

**Limitations (Giới hạn):**

- `SUM(price)` là tổng giá trị hàng hóa, không mặc định là doanh thu kế toán hoặc lợi nhuận.
- Không đưa ra kết luận về quan hệ nguyên nhân – kết quả khi chưa có bằng chứng phù hợp.
- Chưa phân tích đánh giá sao, thanh toán hoặc lợi nhuận trong phiên bản đầu tiên.

## 7. Deliverables (Các sản phẩm cần bàn giao)

- SQL Analysis Script (File chứa các câu SQL phân tích).
- Data Dictionary (Từ điển mô tả dữ liệu).
- KPI Dictionary (Tài liệu định nghĩa chỉ số đo lường).
- Data Quality Report (Báo cáo chất lượng dữ liệu).
- Validation Report (Báo cáo kiểm chứng kết quả).
- Power BI Dashboard (Bảng điều khiển phân tích trên Power BI).
- Insights & Recommendations (Các phát hiện và đề xuất từ dữ liệu).
- GitHub README (Tài liệu giới thiệu dự án trên GitHub).

## 8. Definition of Done (Tiêu chí để coi dự án hoàn thành)

- Trả lời được bốn câu hỏi kinh doanh bằng số liệu.
- Các chỉ số quan trọng có công thức rõ ràng và đã được kiểm chứng.
- Những vấn đề chất lượng dữ liệu được ghi nhận và giải thích.
- Kết quả trên SQL và Power BI nhất quán.
- Có thể trình bày và giải thích dự án khi phỏng vấn thực tập.
