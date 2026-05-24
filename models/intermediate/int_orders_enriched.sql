-- ============================================
-- Intermediate: Orders Enriched
-- Purpose: Join orders to order items and payments
-- Calculates order-level revenue, freight, and payment details
-- One row per order
-- ============================================

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select
        order_id,
        count(order_item_id)            as total_items,
        sum(item_price)                 as gross_revenue,
        sum(freight_value)              as total_freight
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments as (
    select
        order_id,
        sum(payment_value)              as total_payment_value,
        count(distinct payment_type)    as payment_type_count,
        max(payment_type)               as primary_payment_type,
        max(payment_installments)       as max_installments
    from {{ ref('stg_order_payments') }}
    group by order_id
),

enriched as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchased_at,
        o.order_approved_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,

        -- order items metrics
        coalesce(i.total_items, 0)          as total_items,
        coalesce(i.gross_revenue, 0)        as gross_revenue,
        coalesce(i.total_freight, 0)        as total_freight,

        -- payment metrics
        coalesce(p.total_payment_value, 0)  as total_payment_value,
        p.primary_payment_type,
        coalesce(p.max_installments, 1)     as max_installments,

        -- derived fields
        case
            when o.order_delivered_customer_at > o.order_estimated_delivery_at
            then true
            else false
        end                                 as is_late_delivery,

        datediff('day',
            o.order_purchased_at,
            o.order_delivered_customer_at)  as days_to_deliver

    from orders o
    left join order_items i on o.order_id = i.order_id
    left join payments p on o.order_id = p.order_id
)

select * from enriched