# Olist — Insights & Recommendations (Phát hiện và đề xuất)

## Business Question 1: Order Volume Trend (Xu hướng số lượng đơn hàng)

**KPI (Chỉ số):** Total Orders (Tổng số đơn hàng)

**Time Basis (Mốc thời gian):** `order_purchase_timestamp` — Thời điểm đặt hàng.

### Findings (Các phát hiện)

- Tổng cộng có **99.441 đơn hàng**, tổng hợp theo 25 tháng có phát sinh bản ghi.
- Trong năm 2017, số lượng đơn hàng nhìn chung tăng nhưng có biến động giữa các tháng.
- **Tháng 11/2017 có 7.544 đơn**, cao nhất trong toàn bộ dữ liệu.
- Từ tháng 01/2018 đến tháng 08/2018, số đơn hàng hàng tháng dao động từ **6.167 đến 7.269 đơn**.

### Limitations (Giới hạn)

- Một số tháng đầu và cuối bộ dữ liệu có rất ít bản ghi.
- Khi đánh giá xu hướng chính, ưu tiên khoảng thời gian **01/2017–08/2018**.
- Không kết luận nguyên nhân tăng hoặc giảm đơn hàng khi chưa có dữ liệu bổ sung.

### Recommendation (Đề xuất)

Ưu tiên điều tra nguyên nhân lượng đơn tăng cao trong tháng 11/2017 và xem xét nhu cầu chuẩn bị năng lực vận hành cho các giai đoạn có lượng đơn lớn.

Đây là khuyến nghị dựa trên dữ liệu lịch sử, chưa phải tác động kinh doanh đã được chứng minh.

### SQL Reference (Truy vấn tham chiếu)

`sql/olist_analysis.sql` — mục 2.2.

## Business Question 2: Total Item Value by Month (Tổng giá trị hàng hóa theo tháng)

**KPI (Chỉ số):** Total Item Value (Tổng giá trị hàng hóa).

**Scope (Phạm vi):** Chỉ tính các đơn đã giao (`delivered`), nhóm theo tháng đặt hàng.

### Findings (Các phát hiện)

- Có **96.478 đơn đã giao**, với tổng giá trị hàng hóa **13.221.498,11 BRL**.
- Tháng **11/2017** có tổng giá trị hàng hóa cao nhất: **987.765,37 BRL**, từ 7.289 đơn đã giao.
- Tháng **05/2018** có 6.749 đơn đã giao, tổng giá trị hàng hóa đạt **977.544,69 BRL**.
- Giá trị hàng hóa trung bình trên mỗi đơn đã giao đạt **135,51 BRL** trong tháng 11/2017 và **144,84 BRL** trong tháng 05/2018.

### Insight (Phát hiện có ý nghĩa)

Số lượng đơn hàng không phản ánh đầy đủ biến động giá trị hàng hóa. Tháng 05/2018 có ít đơn đã giao hơn tháng 11/2017, nhưng tổng giá trị hàng hóa gần tương đương nhờ giá trị trung bình trên mỗi đơn cao hơn.

### Recommendation (Đề xuất)

Nên theo dõi đồng thời ba chỉ số:

- Số đơn đã giao.
- Tổng giá trị hàng hóa.
- Giá trị hàng hóa trung bình mỗi đơn.

Có thể phân tích thêm số dòng sản phẩm trên mỗi đơn để tìm hiểu sự khác biệt.

### Limitations (Giới hạn)

- Không tính phí vận chuyển.
- Không đồng nhất tổng giá trị hàng hóa với doanh thu kế toán hay lợi nhuận.
- Không kết luận nguyên nhân biến động nếu chưa có bằng chứng bổ sung.
- Các tháng ở rìa bộ dữ liệu có ít bản ghi nên cần thận trọng khi so sánh.

### SQL Reference (Truy vấn tham chiếu)

`sql/olist_analysis.sql` — mục 2.3.

## Business Question 3: Late Delivery Rate (Tỷ lệ giao hàng trễ)

**KPI (Chỉ số):** Late Delivery Rate (Tỷ lệ giao hàng trễ).

### Results (Kết quả)

- Delivered Orders (Đơn đã giao): **96.478**.
- Eligible Delivered Orders (Đơn đủ điều kiện): **96.470**.
- Late Orders (Đơn giao trễ): **6.534**.
- Late Delivery Rate (Tỷ lệ giao trễ): **6,77%**.

### Insight (Phát hiện có ý nghĩa)

Trong 96.470 đơn `delivered` có đủ hai mốc ngày, **6,77%** được giao sau ngày dự kiến. Đây là chỉ số giao trễ theo **ngày lịch**, không coi việc giao muộn vài giờ trong cùng ngày là trễ. Phân tích theo bang ở Câu hỏi 4 cho thấy mức độ giao trễ khác biệt đáng kể giữa các khu vực.

### Recommendation (Đề xuất)

Theo dõi đồng thời **Late Delivery Rate (Tỷ lệ giao trễ)** và **Late Orders (Số đơn giao trễ)** theo bang; ưu tiên kiểm tra các khu vực có cả tỷ lệ cao hơn mức chung và số đơn trễ đáng chú ý. Đề xuất triển khai cụ thể ở Câu hỏi 4.

### Limitations (Giới hạn)

- Loại **8 đơn thiếu ngày giao thực tế khỏi mẫu số KPI**; không xóa khỏi dữ liệu hay khỏi những KPI khác.
- Có **23 đơn** có thứ tự mốc giao vận bất thường đã ghi nhận trong `docs/data_quality_report.md`.
- Không khẳng định nguyên nhân gây trễ nếu chưa có dữ liệu chứng minh.

### SQL Reference (Truy vấn tham chiếu)

`sql/olist_analysis.sql` — mục 1.3, 1.13 và 2.1.

## Business Question 4: Late Delivery Rate by State (Tỷ lệ giao trễ theo bang)

### Results (Kết quả)

- Tổng số bang được phân tích: 27
- Đơn đủ điều kiện: 96.470
- Đơn giao trễ: 6.534
- Tỷ lệ giao trễ chung: 6,77%

Các bang đáng chú ý:

| Bang | Đơn đủ điều kiện | Đơn trễ | Tỷ lệ |
|---|---:|---:|---:|
| AL | 397 | 85 | 21,41% |
| MA | 717 | 125 | 17,43% |
| CE | 1.279 | 176 | 13,76% |
| BA | 3.256 | 396 | 12,16% |
| RJ | 12.350 | 1.495 | 12,11% |
| SP | 40.494 | 1.820 | 4,49% |

### Insights (Phát hiện có ý nghĩa)

- **AL** có tỷ lệ trễ cao nhất **21,41%**, nhưng chỉ có **397 đơn đủ điều kiện**; cần xét thêm quy mô mẫu.
- **RJ** có **1.495/12.350 đơn trễ (12,11%)**, tỷ lệ cao khoảng **2,69 lần** SP (4,49%).
- **SP** có **số đơn trễ lớn nhất (1.820)** nhưng tỷ lệ chỉ **4,49%** trên **40.494 đơn đủ điều kiện**.
- **RJ, BA và CE** là nhóm đáng ưu tiên điều tra do tỷ lệ đều cao hơn mức chung **6,77%** và có số đơn trễ đáng chú ý. Đây là **ưu tiên tìm hiểu**, không phải bằng chứng rằng các bang này gây ra sự cố.

### Recommendations (Đề xuất)

- **Investigate (Điều tra):** Ưu tiên rà soát các đơn giao trễ tới **RJ, BA và CE**; phân tích thêm người bán, đơn vị giao nhận hoặc thời gian xử lý nếu có nguồn dữ liệu phù hợp.
- **Monitor (Theo dõi):** Theo dõi riêng **AL và MA** do tỷ lệ trễ cao nhưng quy mô nhỏ hơn.
- **Validate Causes (Xác minh nguyên nhân):** Chỉ kết luận nguyên nhân sau khi có bằng chứng bổ sung; dữ liệu hiện tại chưa đủ chứng minh vấn đề nằm ở tuyến đường, người bán hoặc hãng vận chuyển.

### Limitations (Giới hạn)

- Dữ liệu phản ánh lịch sử Olist, không dùng để khẳng định hiệu quả vận hành hiện nay.
- Bang có ít đơn có thể có tỷ lệ dao động mạnh; nên đọc tỷ lệ cùng quy mô mẫu.
- Chưa xác định được nguyên nhân giao trễ.
- Tỷ lệ dựa trên ngày giao thực tế so với ngày dự kiến theo **ngày lịch**, không xét giờ.

### SQL Reference (Truy vấn tham chiếu)

`sql/olist_analysis.sql` — mục 2.4.
