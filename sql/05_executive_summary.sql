-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 05_executive_summary.sql
-- Description: Executive summary — aggregate KPIs across all customers
-- =================================================================

DROP VIEW IF EXISTS analytics.executive_summary;

CREATE VIEW analytics.executive_summary AS
WITH global_metrics AS (
    SELECT 
        COUNT(customer_id) AS total_customers,
        COUNT(customer_id) FILTER(WHERE NOT is_churned) AS active_customers,
        COUNT(customer_id) FILTER(WHERE is_churned) AS churned_customers,
        SUM(monthly_charges) AS total_monthly_charges,
        SUM(monthly_charges) FILTER(WHERE NOT is_churned) AS active_mrr,
        SUM(monthly_charges) FILTER(WHERE is_churned) AS churned_monthly_revenue,
        AVG(tenure_months) AS avg_tenure_months
    FROM analytics.dim_saas_customers
), global_kpis AS (
    SELECT 
        total_customers,
        active_customers,
        churned_customers,
        (churned_customers::NUMERIC / NULLIF(total_customers, 0)) * 100 AS churn_rate_pct,
        total_monthly_charges,
        active_mrr,
        churned_monthly_revenue,
        (churned_monthly_revenue / NULLIF(total_monthly_charges, 0)) * 100 AS churned_revenue_pct,
        active_mrr / NULLIF(active_customers, 0) AS arpu,
        avg_tenure_months
    FROM global_metrics
)
SELECT 
    total_customers,
    active_customers,
    churned_customers,
    ROUND(churn_rate_pct, 2) AS churn_rate_pct,
    ROUND(total_monthly_charges, 2) AS total_monthly_charges,
    ROUND(active_mrr, 2) AS active_mrr,
    ROUND(churned_monthly_revenue, 2) AS churned_monthly_revenue,
    ROUND(churned_revenue_pct, 2) AS churned_revenue_pct,
    ROUND(arpu, 2) AS arpu,
    ROUND(avg_tenure_months, 1) AS avg_tenure_months
FROM global_kpis;

SELECT 
    total_customers,
    active_customers,
    churned_customers,
    churn_rate_pct,
    total_monthly_charges,
    active_mrr,
    churned_monthly_revenue,
    churned_revenue_pct,
    arpu,
    avg_tenure_months
FROM analytics.executive_summary;

COMMENT ON VIEW analytics.executive_summary IS 'Executive KPIs across all customers, entire observation window';
COMMENT ON COLUMN analytics.executive_summary.churn_rate_pct IS 'Historical customer-level churn rate (%), whole window - NOT a monthly rate';
COMMENT ON COLUMN analytics.executive_summary.active_mrr IS 'Current MRR: monthly charges of active customers';
COMMENT ON COLUMN analytics.executive_summary.churned_monthly_revenue IS 'Monthly charges of churned customers - revenue no longer received, NOT MRR';
COMMENT ON COLUMN analytics.executive_summary.arpu IS 'ARPU = active_mrr / active_customers';