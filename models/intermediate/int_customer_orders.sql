-- ============================================
-- Intermediate: Customer Orders
-- Purpose: Build customer-level order history and behavior metrics
-- Joins orders to customers and calculates RFM-style aggregations
-- One row per unique customer
-- Note: customer_unique_id is the true customer identifier.
-- Multiple customer_id rows can map to the same customer_unique_id.
-- Customers with no delivered orders receive a segment of 'No Orders'.
-- ============================================

with customers as (
    select distinct on (customer_unique_id)
        customer_unique_id,
        city,
        state
    from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('int_orders_enriched') }}
    where order_status = 'delivered'
),

customer_orders as (
    select
        c.customer_unique_id,
        c.city,
        c.state,

        -- order counts
        count(o.order_id)                           as total_orders,
        coalesce(sum(o.gross_revenue), 0)           as total_gross_revenue,
        coalesce(sum(o.total_freight), 0)           as total_freight_paid,
        round(coalesce(avg(o.gross_revenue), 0), 2) as avg_order_value,

        -- recency and frequency
        min(o.order_purchased_at)                   as first_order_date,
        max(o.order_purchased_at)                   as last_order_date,
        datediff('day',
            min(o.order_purchased_at),
            max(o.order_purchased_at))              as customer_lifespan_days,

        -- delivery experience
        round(coalesce(avg(o.days_to_deliver), 0), 1)   as avg_days_to_deliver,
        sum(case when o.is_late_delivery then 1
            else 0 end)                             as late_deliveries,

        -- customer segment
        case
            when count(o.order_id) = 0 then 'No Orders'
            when count(o.order_id) = 1 then 'One-Time Buyer'
            when count(o.order_id) between 2 and 3 then 'Repeat Buyer'
            when count(o.order_id) > 3 then 'Loyal Buyer'
        end                                         as customer_segment

    from customers c
    left join orders o on c.customer_unique_id = o.customer_id
    group by
        c.customer_unique_id,
        c.city,
        c.state
)

select * from customer_orders