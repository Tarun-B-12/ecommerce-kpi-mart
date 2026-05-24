-- ============================================
-- Staging: Customers
-- Source: raw.raw_customers
-- Purpose: Rename columns, filter null customer IDs
-- One row per customer ID (not unique customer, use customer_unique_id for that)
-- ============================================

with source as (
    select * from raw.raw_customers
),

renamed as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix  as zip_code,
        customer_city             as city,
        customer_state            as state
    from source
    where customer_id is not null
)

select * from renamed