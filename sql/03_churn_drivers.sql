-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 03_churn_drivers.sql
-- Description: Diagnostic report of churn drivers across customer features
-- =================================================================

DROP VIEW IF EXISTS analytics.churn_drivers;

CREATE VIEW analytics.churn_drivers AS
WITH features AS (
    SELECT 
        'contract' AS feature, 
        contract_type AS value, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'payment_method', 
        payment_method, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'internet_service', 
        internet_service, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'tech_support', 
        tech_support, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'online_security', 
        online_security, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'online_backup', 
        online_backup, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'device_protection', 
        device_protection, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'multiple_lines', 
        multiple_lines, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'streaming_tv', 
        streaming_tv, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'streaming_movies', 
        streaming_movies, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'gender', 
        gender, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'senior_citizen', 
        CASE WHEN senior_citizen THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'partner', 
        CASE WHEN partner THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'dependents', 
        CASE WHEN dependents THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'phone_service', 
        CASE WHEN phone_service THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'paperless_billing', 
        CASE WHEN paperless_billing THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'tenure_band',
        CASE
            WHEN tenure_months <= 6 THEN '0-6 Months'
            WHEN tenure_months <= 12 THEN '7-12 Months'
            WHEN tenure_months <= 24 THEN '13-24 Months'
            WHEN tenure_months <= 36 THEN '25-36 Months'
            WHEN tenure_months <= 48 THEN '37-48 Months'
            ELSE '> 48 Months'
        END,
        is_churned, 
        monthly_charges
    FROM analytics.dim_saas_customers
),
feature_aggregates AS (
    SELECT
        feature,
        value,
        COUNT(*) AS customer_count,
        COUNT(*) FILTER (WHERE is_churned) AS churned_count,
        SUM(monthly_charges) FILTER (WHERE NOT is_churned)::NUMERIC AS active_mrr
    FROM features
    GROUP BY feature, value
),
feature_metrics AS (
    SELECT
        feature,
        value,
        customer_count,
        churned_count,
        active_mrr,
        (churned_count::NUMERIC / NULLIF(customer_count, 0)) * 100 AS churn_rate_pct,
        (SUM(churned_count::NUMERIC) OVER () / NULLIF(SUM(customer_count) OVER (), 0)) * 100 AS overall_churn_rate_pct
    FROM feature_aggregates
),
lift_metrics AS (
    SELECT
        feature,
        value,
        customer_count,
        churned_count,
        active_mrr,
        churn_rate_pct,
        churn_rate_pct / NULLIF(overall_churn_rate_pct, 0) AS lift
    FROM feature_metrics
)
SELECT
    feature,
    value,
    customer_count AS customers,
    churned_count AS churned,
    ROUND(churn_rate_pct, 2) AS churn_rate_pct,
    ROUND(lift, 2) AS lift,
    ROUND(active_mrr, 2) AS active_mrr
FROM lift_metrics;

SELECT feature, value, customers, churned, churn_rate_pct, lift, active_mrr
FROM analytics.churn_drivers
ORDER BY feature, lift DESC;