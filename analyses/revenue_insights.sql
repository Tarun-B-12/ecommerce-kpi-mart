-- ============================================
-- Revenue Insights
-- Business Questions answered from the mart layer
-- Run these queries directly in DuckDB or any SQL client
-- ============================================


-- 1. What are the top 10 revenue months?
select
    order_month,
    sum(total_orders)       as total_orders,
    round(sum(gross_revenue), 2) as gross_revenue,
    round(avg(avg_order_value), 2) as avg_order_value
from main.mart_revenue_summary
group by order_month
order by gross_revenue desc
limit 10;


-- 2. What is the monthly late delivery rate trend?
select
    order_month,
    sum(total_orders)           as total_orders,
    sum(late_deliveries)        as late_deliveries,
    round(
        sum(late_deliveries) * 100.0 / nullif(sum(delivered_orders), 0)
    , 2)                        as late_delivery_rate_pct
from main.mart_revenue_summary
group by order_month
order by order_month;


-- 3. What is the customer segment breakdown?
select
    customer_segment,
    count(customer_unique_id)           as total_customers,
    round(avg(total_gross_revenue), 2)  as avg_revenue_per_customer,
    round(avg(avg_order_value), 2)      as avg_order_value
from main.mart_customer_segments
group by customer_segment
order by total_customers desc;


-- 4. What is the revenue tier breakdown?
select
    revenue_tier,
    count(customer_unique_id)           as total_customers,
    round(sum(total_gross_revenue), 2)  as total_revenue
from main.mart_customer_segments
group by revenue_tier
order by total_revenue desc;


-- 5. Who are the top 10 sellers by revenue?
select
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_item_price,
    avg_review_score,
    late_delivery_rate_pct
from main.mart_seller_performance
order by total_revenue desc
limit 10;


-- 6. Which states have the most sellers?
select
    seller_state,
    count(seller_id)                as total_sellers,
    round(sum(total_revenue), 2)    as total_revenue,
    round(avg(avg_review_score), 2) as avg_review_score
from main.mart_seller_performance
group by seller_state
order by total_sellers desc
limit 10;


-- 7. What is the payment method mix?
select
    order_month,
    sum(credit_card_orders)     as credit_card_orders,
    sum(boleto_orders)          as boleto_orders,
    sum(voucher_orders)         as voucher_orders,
    sum(total_orders)           as total_orders
from main.mart_revenue_summary
group by order_month
order by order_month;