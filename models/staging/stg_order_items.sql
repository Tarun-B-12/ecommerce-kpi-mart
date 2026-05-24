-- ============================================
-- Staging: Order Items
-- Source: raw.raw_order_items
-- Purpose: Rename columns, cast price and freight values, filter nulls
-- One row per item within an order
-- ============================================

with source as (
    select * from raw.raw_order_items
),

renamed as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_at,
        cast(price as decimal(10, 2))          as item_price,
        cast(freight_value as decimal(10, 2))  as freight_value
    from source
    where order_id is not null
    and product_id is not null
)

select * from renamed