-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 05_executive_summary.sql
-- Description: Executive summary — aggregate KPIs across all customers
-- =================================================================

DROP VIEW IF EXISTS saas_executive_summary;

CREATE VIEW saas_executive_summary AS
WITH global_metrics AS (
    SELECT 
        COUNT(customer_id) AS total_customers,
        COUNT(customer_id) FILTER(WHERE NOT is_churned) AS active_customers,
        COUNT(customer_id) FILTER(WHERE is_churned) AS churned_customers,
        SUM(monthly_charges) AS total_mrr,
        SUM(monthly_charges) FILTER(WHERE NOT is_churned) AS active_mrr,
        SUM(monthly_charges) FILTER(WHERE is_churned) AS lost_mrr,
        AVG(tenure_months) AS avg_tenure_months
    FROM dim_saas_customers
), global_kpis AS (
    SELECT 
        total_customers,
        active_customers,
        churned_customers,
        (churned_customers::NUMERIC / NULLIF(total_customers, 0)) * 100 AS churn_rate_pct,
        total_mrr,
        active_mrr,
        lost_mrr,
        (lost_mrr / NULLIF(total_mrr, 0)) * 100 AS lost_mrr_pct,
        active_mrr / NULLIF(active_customers, 0) AS arpu,
        avg_tenure_months
    FROM global_metrics
)
SELECT 
    total_customers,
    active_customers,
    churned_customers,
    ROUND(churn_rate_pct, 2) AS churn_rate_pct,
    ROUND(total_mrr, 2) AS total_mrr,
    ROUND(active_mrr, 2) AS active_mrr,
    ROUND(lost_mrr, 2) AS lost_mrr,
    ROUND(lost_mrr_pct, 2) AS lost_mrr_pct,
    ROUND(arpu, 2) AS arpu,
    ROUND(avg_tenure_months, 1) AS avg_tenure_months
FROM global_kpis;

SELECT 
    total_customers,
    active_customers,
    churned_customers,
    churn_rate_pct,
    total_mrr,
    active_mrr,
    lost_mrr,
    lost_mrr_pct,
    arpu,
    avg_tenure_months
FROM saas_executive_summary;