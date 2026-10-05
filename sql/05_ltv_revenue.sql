-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 05_ltv_revenue.sql
-- Description: Realized LTV by segment and retention scenario
-- =================================================================

DROP VIEW IF EXISTS analytics.ltv_by_segment;

CREATE VIEW analytics.ltv_by_segment AS
WITH features AS (
    SELECT 
        'contract' AS feature, 
        contract_type AS value, 
        is_churned, 
        monthly_charges,
        total_charges
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'payment_method', 
        payment_method, 
        is_churned, 
        monthly_charges,
        total_charges
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'internet_service', 
        internet_service, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'tech_support', 
        tech_support, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'online_security', 
        online_security, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'online_backup', 
        online_backup, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'device_protection', 
        device_protection, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'multiple_lines', 
        multiple_lines, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'streaming_tv', 
        streaming_tv, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'streaming_movies', 
        streaming_movies, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'gender', 
        gender, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'senior_citizen', 
        CASE WHEN senior_citizen THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'partner', 
        CASE WHEN partner THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'dependents', 
        CASE WHEN dependents THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'phone_service', 
        CASE WHEN phone_service THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges,
        total_charges 
    FROM analytics.dim_saas_customers
    UNION ALL SELECT 
        'paperless_billing', 
        CASE WHEN paperless_billing THEN 'Yes' ELSE 'No' END, 
        is_churned, 
        monthly_charges,
        total_charges 
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
        monthly_charges,
        total_charges
    FROM analytics.dim_saas_customers
),
segment_stats AS (
    SELECT
        feature,
        value,
        COUNT(*) AS customers,
        AVG(total_charges) AS avg_ltv,
        SUM(monthly_charges) FILTER (WHERE NOT is_churned)::NUMERIC AS active_mrr
    FROM features
    GROUP BY feature, value
)
SELECT
    feature,
    value,
    customers,
    ROUND(avg_ltv, 2) AS avg_ltv,
    ROUND(active_mrr, 2) AS active_mrr
FROM segment_stats;

SELECT 
    feature,
    value,
    customers,
    avg_ltv,
    active_mrr
FROM analytics.ltv_by_segment
ORDER BY feature, avg_ltv DESC;

DROP VIEW IF EXISTS analytics.retention_scenario;

CREATE VIEW analytics.retention_scenario AS 
WITH at_risk AS (
    SELECT
        COUNT(*) FILTER (WHERE NOT is_churned AND contract_type = 'Month-to-month') AS at_risk_customers,
        SUM(monthly_charges) FILTER (WHERE NOT is_churned AND contract_type = 'Month-to-month') AS at_risk_mrr,
        SUM(monthly_charges) FILTER (WHERE NOT is_churned) AS active_mrr_total
    FROM analytics.dim_saas_customers
),
scenario AS (
    SELECT
        a.at_risk_customers,
        a.at_risk_mrr,
        a.active_mrr_total,
        s.retention_pct,
        ROUND(a.at_risk_mrr * s.retention_pct / 100, 2) AS saved_monthly_revenue,
        (a.at_risk_mrr / NULLIF(a.active_mrr_total, 0)) * 100 AS at_risk_share_pct
    FROM at_risk a
    CROSS JOIN (VALUES (10), (20), (30)) AS s(retention_pct)
)
SELECT 
    at_risk_customers,
    at_risk_mrr,
    active_mrr_total,
    ROUND(at_risk_share_pct, 2) AS at_risk_share_pct,
    ROUND(retention_pct, 2) AS retention_pct,
    ROUND(saved_monthly_revenue, 2) AS saved_monthly_revenue,
    ROUND(saved_monthly_revenue * 12, 2) AS saved_annual_revenue
FROM scenario;

SELECT
    at_risk_customers,
    at_risk_mrr,
    active_mrr_total,
    at_risk_share_pct,
    retention_pct,
    saved_monthly_revenue,
    saved_annual_revenue
FROM analytics.retention_scenario
ORDER BY retention_pct;