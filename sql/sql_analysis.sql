CREATE DATABASE deliverylens;
USE deliverylens;

-- Query 1: Overall Bad Review Rate
SELECT 
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bad_review_rate
FROM reviews;

-- Query 2: Monthly Bad Review Trend
SELECT 
    DATE_FORMAT(review_creation_date, '%Y-%m') AS month,
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bad_review_rate
FROM reviews
WHERE review_creation_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- Query 3: Late Delivery Count
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Query 4: Average Delivery Delay

-- Step 1: Naye date columns add karo
ALTER TABLE orders
ADD COLUMN order_purchase_ts DATETIME,
ADD COLUMN order_delivered_ts DATETIME,
ADD COLUMN order_estimated_ts DATETIME;

-- Step 2: Data convert karke fill karo
UPDATE orders
SET 
    order_purchase_ts = STR_TO_DATE(order_purchase_timestamp, '%d-%m-%y %H:%i'),
    order_delivered_ts = STR_TO_DATE(order_delivered_customer_date, '%d-%m-%y %H:%i'),
    order_estimated_ts = STR_TO_DATE(order_estimated_delivery_date, '%d-%m-%y %H:%i');
    
    -- Step 3: Ab sahi query chalao
SELECT
    ROUND(AVG(DATEDIFF(order_delivered_ts, order_estimated_ts)), 2) AS avg_delay_days,
    ROUND(MAX(DATEDIFF(order_delivered_ts, order_estimated_ts)), 2) AS max_delay_days,
    ROUND(MIN(DATEDIFF(order_delivered_ts, order_estimated_ts)), 2) AS min_delay_days
FROM orders
WHERE order_delivered_ts IS NOT NULL;

-- Query 5: Revenue at Risk
SELECT
    ROUND(SUM(i.price), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN r.review_score <= 2 THEN i.price ELSE 0 END), 2) AS revenue_at_risk,
    ROUND(SUM(CASE WHEN r.review_score <= 2 THEN i.price ELSE 0 END) * 100.0 / SUM(i.price), 2) AS revenue_at_risk_percentage
FROM items i
JOIN reviews r ON i.order_id = r.order_id;
