-- ============================================
-- Staging: Sellers
-- Source: raw.raw_sellers
-- Purpose: Rename columns, filter null seller IDs
-- One row per seller
-- ============================================

with source as (
    select * from raw.raw_sellers
),

renamed as (
    select
        seller_id,
        seller_zip_code_prefix  as zip_code,
        seller_city             as city,
        seller_state            as state
    from source
    where seller_id is not null
)

select * from renamed