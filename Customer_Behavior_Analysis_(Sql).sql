use customer_behavior;

-- Understand revenue contribution by gender
SELECT 
    gender, 
    SUM(purchase_amount) AS revenue
FROM customer_behavior
GROUP BY gender;

-- Identify customers who used discounts but still spent above average
SELECT 
    customer_id, 
    purchase_amount 
FROM customer_behavior 
WHERE 
    discount_applied = 'Yes' 
    AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer_behavior);
    
    -- Find highest-rated products for inventory optimization (MySQL)
SELECT
  item_purchased,
  ROUND(AVG(CAST(review_rating AS DECIMAL(10,2))), 2) AS `Average Product Rating`
FROM customer_behavior
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS DECIMAL(10,2))) DESC
LIMIT 5;
-- Compare average spend between Standard and Express shipping
SELECT 
    shipping_type, 
    ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer_behavior
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Determine if subscribers spend more
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behavior
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Identify products frequently purchased with discounts
SELECT 
    item_purchased,
    ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_rate
FROM customer_behavior
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Segment customers into New, Returning, and Loyal
WITH customer_type AS (
    SELECT 
        customer_id, 
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_behavior
)
SELECT 
    customer_segment,
    COUNT(*) AS "Number of Customers" 
FROM customer_type 
GROUP BY customer_segment;

-- Use window functions for advanced analytics
WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer_behavior
    GROUP BY category, item_purchased
)
SELECT 
    item_rank,
    category, 
    item_purchased, 
    total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Analyze if repeat buyers tend to subscribe
SELECT 
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer_behavior
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Identify most valuable age segments
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;












