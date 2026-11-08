
USE olist_ecommerce;
GO

-- ============================================
-- 01. DATA PROFILING & DATA QUALITY
-- ============================================

-- 1.1. Kiem tra tong so don hang
SELECT COUNT(*) AS total_orders
FROM dbo.olist_orders;

-- 1.2. Xem 5 dong du lieu mau
SELECT TOP 5 *
FROM dbo.olist_orders;

-- 1.3. Kiem tra so dong, trung lap va trang thai
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CASE
        WHEN order_status = 'delivered'
        THEN 1 ELSE 0
    END) AS delivered_orders,
    SUM(CASE
        WHEN order_status = 'delivered'
         AND order_delivered_customer_date IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
        THEN 1 ELSE 0
    END) AS valid_delivered_orders
FROM dbo.olist_orders;


-- 1.4. Kiem tra bang Order Items
SELECT
    COUNT(*) AS total_item_rows,
    COUNT(DISTINCT order_id) AS orders_with_items
FROM dbo.olist_order_items;


-- 1.5. Kiem tra don hang khong co dong san pham
SELECT
    COUNT(*) AS orders_without_items
FROM dbo.olist_orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.olist_order_items AS i
    WHERE i.order_id = o.order_id
);

-- 1.6. Kiem tra ma don hang trong Items
-- khong ton tai trong Orders
SELECT
    COUNT(DISTINCT i.order_id) AS orphan_order_ids
FROM dbo.olist_order_items AS i
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.olist_orders AS o
    WHERE o.order_id = i.order_id
);

-- 1.7. Kiem tra NULL trong Order Items
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL
        THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_item_id IS NULL
        THEN 1 ELSE 0 END) AS null_order_item_id,
    SUM(CASE WHEN product_id IS NULL
        THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL
        THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN shipping_limit_date IS NULL
        THEN 1 ELSE 0 END) AS null_shipping_date,
    SUM(CASE WHEN price IS NULL
        THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL
        THEN 1 ELSE 0 END) AS null_freight
FROM dbo.olist_order_items;


-- 1.8. Kiem tra trung khoa ghep trong Order Items
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM dbo.olist_order_items
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;

-- 1.9. Kiem tra gia tri bat thuong
-- trong Order Items
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    SUM(CASE WHEN price < 0
        THEN 1 ELSE 0 END) AS negative_price,
    SUM(CASE WHEN price = 0
        THEN 1 ELSE 0 END) AS zero_price,

    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    SUM(CASE WHEN freight_value < 0
        THEN 1 ELSE 0 END) AS negative_freight,
    SUM(CASE WHEN freight_value = 0
        THEN 1 ELSE 0 END) AS zero_freight
FROM dbo.olist_order_items;


-- 1.11. Kiem tra trang thai don hang khong co Items

SELECT
    o.order_status,
    COUNT(*) AS total_orders
FROM dbo.olist_orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.olist_order_items AS i
    WHERE i.order_id = o.order_id
)
GROUP BY o.order_status
ORDER BY total_orders DESC;


-- 1.12. Kiem tra quan he Customers - Orders

-- A. Kiem tra khoa customer_id trong Customers
SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    SUM(CASE WHEN customer_id IS NULL
        THEN 1 ELSE 0 END) AS null_customer_ids
FROM dbo.olist_customers;

-- B. Tim don hang khong khop voi Customers
SELECT
    COUNT(*) AS orders_without_customer
FROM dbo.olist_orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.olist_customers AS c
    WHERE c.customer_id = o.customer_id
);

-- 1.13. Kiem tra ngay giao hang bi thieu
-- Chi xet don da giao (delivered)

SELECT
    COUNT(*) AS delivered_orders,

    SUM(CASE
        WHEN order_delivered_customer_date IS NULL
        THEN 1 ELSE 0
    END) AS missing_actual_date,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NULL
        THEN 1 ELSE 0
    END) AS missing_estimated_date,

    SUM(CASE
        WHEN order_delivered_customer_date IS NULL
          OR order_estimated_delivery_date IS NULL
        THEN 1 ELSE 0
    END) AS excluded_orders,

    SUM(CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND order_estimated_delivery_date IS NOT NULL
        THEN 1 ELSE 0
    END) AS eligible_orders

FROM dbo.olist_orders
WHERE order_status = 'delivered';

-- 1.14. Kiem tra thu tu ngay thang don hang

SELECT
    -- Ngay giao thuc te truoc ngay dat hang
    SUM(CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND order_purchase_timestamp IS NOT NULL
         AND order_delivered_customer_date
             < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS delivered_before_purchase,

    -- Khach nhan hang truoc khi ban giao van chuyen
    SUM(CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND order_delivered_carrier_date IS NOT NULL
         AND order_delivered_customer_date
             < order_delivered_carrier_date
        THEN 1 ELSE 0
    END) AS delivered_before_carrier,

    -- Ngay giao du kien truoc ngay dat hang
    SUM(CASE
        WHEN order_estimated_delivery_date IS NOT NULL
         AND order_purchase_timestamp IS NOT NULL
         AND CAST(order_estimated_delivery_date AS DATE)
             < CAST(order_purchase_timestamp AS DATE)
        THEN 1 ELSE 0
    END) AS estimated_before_purchase

FROM dbo.olist_orders;

-- 1.15. Dieu tra 23 don co thu tu thoi gian giao hang bat thuong
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    DATEDIFF(
        MINUTE,
        order_delivered_customer_date,
        order_delivered_carrier_date
    ) AS minutes_difference
FROM dbo.olist_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date
      < order_delivered_carrier_date
ORDER BY minutes_difference DESC;

-- ============================================
-- 01A. CLEANING & TRANSFORMATION
-- ============================================

-- 1A.1. Tao view chuan hoa gia tien
-- Gia import dang cao gap 100 lan
-- Giu nguyen bang goc de doi soat
GO
CREATE OR ALTER VIEW dbo.v_olist_order_items_clean
AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    CAST(price / 100.0 AS DECIMAL(18,2)) AS price,
    CAST(freight_value / 100.0 AS DECIMAL(18,2))
        AS freight_value
FROM dbo.olist_order_items;
GO

-- 1A.2. Kiem tra mot don hang cu the
SELECT
    order_id,
    order_item_id,
    price,
    freight_value
FROM dbo.v_olist_order_items_clean
WHERE order_id = '00010242fe8c5a6d1ba2dd792cb16214'
  AND order_item_id = 1;

-- 1A.3. Kiem tra gia tri MIN / MAX sau chuyen doi
SELECT
    COUNT(*) AS total_rows,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight
FROM dbo.v_olist_order_items_clean;

-- ============================================
-- 02. ORDER & DELIVERY ANALYSIS
-- ============================================

-- 2.1. Dem so don giao tre theo ngay lich
SELECT
    COUNT(*) AS total_late_orders
FROM dbo.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND CAST(order_delivered_customer_date AS DATE)
      > CAST(order_estimated_delivery_date AS DATE);

-- 2.2. Phan tich so luong don hang theo thang
-- Bao gom tat ca trang thai don hang
SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS order_month,
    COUNT(*) AS total_orders
FROM dbo.olist_orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    )
ORDER BY order_month;

-- 2.3. Phan tich tong gia tri hang hoa
-- theo thang dat hang
-- Chi tinh don da giao (delivered)
SELECT
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp),
        1
    ) AS order_month,
    COUNT(DISTINCT o.order_id)
        AS delivered_orders,
    SUM(i.price)
        AS total_item_value_brl
FROM dbo.olist_orders AS o
INNER JOIN dbo.v_olist_order_items_clean AS i
    ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY
    DATEFROMPARTS(
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp),
        1
    )
ORDER BY order_month;


-- 2.4. Ty le giao hang tre theo bang khach hang
-- Chi tinh don delivered va du hai moc ngay

SELECT
    c.customer_state AS customer_state,

    COUNT(*) AS eligible_orders,

    SUM(CASE
        WHEN CAST(o.order_delivered_customer_date AS DATE)
           > CAST(o.order_estimated_delivery_date AS DATE)
        THEN 1 ELSE 0
    END) AS late_orders,

    CAST(
        100.0 * SUM(CASE
            WHEN CAST(o.order_delivered_customer_date AS DATE)
               > CAST(o.order_estimated_delivery_date AS DATE)
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS late_delivery_rate_pct

FROM dbo.olist_orders AS o

INNER JOIN dbo.olist_customers AS c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY late_delivery_rate_pct DESC;

-- ============================================
-- 03. CUSTOMER ANALYSIS
-- Se bo sung sau
-- ============================================


-- ============================================
-- 04. PRODUCT & SALES ANALYSIS
-- Se bo sung sau
-- ============================================

-- ============================================
-- 05. VALIDATION & RECONCILIATION
-- KIEM CHUNG VA DOI SOAT
-- ============================================

-- 5.1. Kiem tra so dong sau LEFT JOIN
-- Orders voi View Order Items da chuan hoa

SELECT
    COUNT(*) AS joined_rows,

    COUNT(DISTINCT o.order_id) AS distinct_orders,

    COUNT(i.order_id) AS item_rows,

    SUM(CASE
        WHEN i.order_id IS NULL
        THEN 1 ELSE 0
    END) AS orders_without_items

FROM dbo.olist_orders AS o
LEFT JOIN dbo.v_olist_order_items_clean AS i
    ON o.order_id = i.order_id;

-- 5.2. Doi soat tong gia tri tien sau chuan hoa
SELECT
    COUNT(*) AS total_item_rows,
    SUM(price) AS total_item_value,
    SUM(freight_value) AS total_freight_value
FROM dbo.v_olist_order_items_clean;
