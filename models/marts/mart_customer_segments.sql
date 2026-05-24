-- ============================================
-- Mart: Customer Segments
-- Purpose: Customer-level KPIs and segmentation for business reporting
-- Built on top of int_customer_orders
-- One row per unique customer
-- ============================================

with customer_orders as (
    select * from {{ ref('int_customer_orders') }}
),

segmented as (
    select
        customer_unique_id,
        city,
        state,
        customer_segment,

        total_orders,
        total_gross_revenue,
        total_freight_paid,
        avg_order_value,

        first_order_date,
        last_order_date,
        customer_lifespan_days,

        avg_days_to_deliver,
        late_deliveries,

        -- derived metrics
        round(
            case
                when total_orders > 0
                then cast(late_deliveries as decimal) / total_orders * 100
                else 0
            end, 2
        )                                       as late_delivery_rate_pct,

        case
            when total_gross_revenue >= 1000 then 'High Value'
            when total_gross_revenue >= 300  then 'Mid Value'
            else 'Low Value'
        end                                     as revenue_tier

    from customer_orders
)

select * from segmented