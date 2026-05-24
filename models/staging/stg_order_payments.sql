-- ============================================
-- Staging: Order Payments
-- Source: raw.raw_order_payments
-- Purpose: Rename columns, cast numeric fields, filter null order IDs
-- One row per payment sequence per order (orders can have multiple payments)
-- ============================================

with source as (
    select * from raw.raw_order_payments
),

renamed as (
    select
        order_id,
        cast(payment_sequential as int)        as payment_sequential,
        payment_type,
        cast(payment_installments as int)      as payment_installments,
        cast(payment_value as decimal(10, 2))  as payment_value
    from source
    where order_id is not null
)

select * from renamed