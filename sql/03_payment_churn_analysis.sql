-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 03_payment_churn_analysis.sql
-- Description: Business metrics and churn rate analysis by payment method
-- =================================================================

DROP TABLE IF EXISTS saas_payment_churn_analysis;

CREATE TABLE saas_payment_churn_analysis AS 
WITH payment_metrics AS (
    SELECT 
        payment_method,
        COUNT(customer_id) AS total_customers,
        COUNT(customer_id) FILTER(WHERE NOT is_churned) AS active_customers,
        COUNT(customer_id) FILTER(WHERE is_churned) AS churned_customers,
        SUM(monthly_charges) AS total_mrr,
        SUM(monthly_charges) FILTER(WHERE NOT is_churned) AS active_mrr,
        SUM(monthly_charges) FILTER(WHERE is_churned) AS lost_mrr,
        AVG(tenure_months) AS avg_tenure_months
    FROM dim_saas_customers
    GROUP BY payment_method
), 
payment_churn_rates AS (
    SELECT 
        payment_method,
        total_customers,
        active_customers,
        churned_customers,
        (churned_customers::NUMERIC / NULLIF(total_customers, 0)) * 100 AS churn_rate_pct,
        total_mrr,
        active_mrr,
        lost_mrr,
        (lost_mrr / NULLIF(total_mrr, 0)) * 100 AS lost_mrr_pct,
        (active_mrr / NULLIF(active_customers, 0)) AS arpu,
        avg_tenure_months
    FROM payment_metrics
)
SELECT
    payment_method,
    total_customers,
    active_customers,
    churned_customers,
    ROUND(churn_rate_pct::NUMERIC, 2) AS churn_rate_pct,
    ROUND(total_mrr::NUMERIC, 2) AS total_mrr,
    ROUND(active_mrr::NUMERIC, 2) AS active_mrr,
    ROUND(lost_mrr::NUMERIC, 2) AS lost_mrr,
    ROUND(lost_mrr_pct::NUMERIC, 2) AS lost_mrr_pct,
    ROUND(arpu::NUMERIC, 2) AS arpu,
    ROUND(avg_tenure_months::NUMERIC, 1) AS avg_tenure_months
FROM payment_churn_rates;

SELECT 
    payment_method,
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
FROM saas_payment_churn_analysis
ORDER BY churn_rate_pct DESC;