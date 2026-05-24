-- ============================================
-- Mart: Revenue Summary
-- Purpose: Daily and monthly revenue KPIs for business reporting
-- Built on top of int_orders_enriched
-- One row per order purchase date
-- ============================================

with orders as (
    select * from {{ ref('int_orders_enriched') }}
    where order_status != 'canceled'
),

daily_revenue as (
    select
        cast(order_purchased_at as date)        as order_date,
        date_trunc('month', order_purchased_at) as order_month,
        date_part('year', order_purchased_at)   as order_year,

        count(order_id)                         as total_orders,
        sum(gross_revenue)                      as gross_revenue,
        sum(total_freight)                      as total_freight,
        sum(total_payment_value)                as total_payment_value,
        round(avg(gross_revenue), 2)            as avg_order_value,

        -- delivery metrics
        sum(case when order_status = 'delivered'
            then 1 else 0 end)                  as delivered_orders,
        sum(case when is_late_delivery
            then 1 else 0 end)                  as late_deliveries,
        round(avg(days_to_deliver), 1)          as avg_days_to_deliver,

        -- payment mix
        sum(case when primary_payment_type = 'credit_card'
            then 1 else 0 end)                  as credit_card_orders,
        sum(case when primary_payment_type = 'boleto'
            then 1 else 0 end)                  as boleto_orders,
        sum(case when primary_payment_type = 'voucher'
            then 1 else 0 end)                  as voucher_orders

    from orders
    group by
        cast(order_purchased_at as date),
        date_trunc('month', order_purchased_at),
        date_part('year', order_purchased_at)
)

select * from daily_revenue