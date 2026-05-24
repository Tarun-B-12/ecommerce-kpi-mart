-- ============================================
-- Staging: Orders
-- Source: raw.raw_orders
-- Purpose: Rename columns, cast timestamps, filter null order IDs
-- One row per order
-- ============================================

with source as (
    select * from raw.raw_orders
),

renamed as (
    select
        order_id,
        customer_id,
        order_status,
        cast(order_purchase_timestamp as timestamp)       as order_purchased_at,
        cast(order_approved_at as timestamp)              as order_approved_at,
        cast(order_delivered_carrier_date as timestamp)   as order_delivered_carrier_at,
        cast(order_delivered_customer_date as timestamp)  as order_delivered_customer_at,
        cast(order_estimated_delivery_date as timestamp)  as order_estimated_delivery_at
    from source
    where order_id is not null
)

select * from renamed