-- ============================================
-- Mart: Seller Performance
-- Purpose: Seller-level KPIs covering revenue, order volume,
-- delivery performance, and customer satisfaction
-- Built on top of int_orders_enriched and stg_order_reviews
-- One row per seller
-- ============================================

with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('int_orders_enriched') }}
    where order_status = 'delivered'
),

reviews as (
    select
        order_id,
        round(avg(review_score), 2)     as avg_review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

seller_orders as (
    select
        i.seller_id,
        s.city                                  as seller_city,
        s.state                                 as seller_state,

        count(distinct i.order_id)              as total_orders,
        count(i.order_item_id)                  as total_items_sold,
        round(sum(i.item_price), 2)             as total_revenue,
        round(avg(i.item_price), 2)             as avg_item_price,
        round(sum(i.freight_value), 2)          as total_freight_charged,

        -- delivery performance
        round(avg(o.days_to_deliver), 1)        as avg_days_to_deliver,
        sum(case when o.is_late_delivery
            then 1 else 0 end)                  as late_deliveries,
        round(
            case
                when count(distinct i.order_id) > 0
                then cast(sum(case when o.is_late_delivery
                    then 1 else 0 end) as decimal)
                    / count(distinct i.order_id) * 100
                else 0
            end, 2
        )                                       as late_delivery_rate_pct,

        -- satisfaction
        round(avg(r.avg_review_score), 2)       as avg_review_score

    from order_items i
    left join orders o      on i.order_id = o.order_id
    left join reviews r     on i.order_id = r.order_id
    left join sellers s     on i.seller_id = s.seller_id
    group by
        i.seller_id,
        s.city,
        s.state
)

select * from seller_orders