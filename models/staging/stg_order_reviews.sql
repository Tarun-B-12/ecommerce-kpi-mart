-- ============================================
-- Staging: Order Reviews
-- Source: raw.raw_order_reviews
-- Purpose: Rename columns, cast data types, and filter nulls
-- One row per review linked to an order
-- ============================================

with source as (
    select * from raw.raw_order_reviews
),

renamed as (
    select
        review_id,
        order_id,
        cast(review_score as int)                    as review_score,
        review_comment_title                         as comment_title,
        review_comment_message                       as comment_message,
        cast(review_creation_date as timestamp)      as review_created_at,
        cast(review_answer_timestamp as timestamp)   as review_answered_at
    from source
    where order_id is not null
)

select * from renamed