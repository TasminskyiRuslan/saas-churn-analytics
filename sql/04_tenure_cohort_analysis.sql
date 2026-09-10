DROP TABLE IF EXISTS saas_tenure_cohort_analysis;

CREATE TABLE saas_tenure_cohort_analysis AS
WITH tenure_grouping AS (
    SELECT
        customer_id,
        is_churned,
        monthly_charges,
        tenure_months,
        CASE
            WHEN tenure_months <= 6 THEN '0-6 Months'
            WHEN tenure_months <= 12 THEN '7-12 Months'
            WHEN tenure_months <= 24 THEN '13-24 Months'
            WHEN tenure_months <= 36 THEN '25-36 Months'
            WHEN tenure_months <= 48 THEN '37-48 Months'
            ELSE '> 48 Months'
        END AS tenure_cohort
    FROM dim_saas_customers
),
tenure_metrics AS (
    SELECT
        tenure_cohort,
        COUNT(customer_id) AS total_customers,
        COUNT(customer_id) FILTER(WHERE NOT is_churned) AS active_customers,
        COUNT(customer_id) FILTER(WHERE is_churned) AS churned_customers,
        SUM(monthly_charges) AS total_mrr,
        SUM(monthly_charges) FILTER(WHERE NOT is_churned) AS active_mrr,
        SUM(monthly_charges) FILTER(WHERE is_churned) AS lost_mrr,
        AVG(tenure_months) AS avg_tenure_months
    FROM tenure_grouping
    GROUP BY tenure_cohort
),
tenure_churn_rates AS (
    SELECT
        tenure_cohort,
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
    FROM tenure_metrics
)
SELECT 
    tenure_cohort,
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
FROM tenure_churn_rates;

SELECT 
    tenure_cohort,
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
FROM saas_tenure_cohort_analysis
ORDER BY 
    CASE tenure_cohort
        WHEN '0-6 Months' THEN 1
        WHEN '7-12 Months' THEN 2
        WHEN '13-24 Months' THEN 3
        WHEN '25-36 Months' THEN 4
        WHEN '37-48 Months' THEN 5
        WHEN '> 48 Months' THEN 6
    END ASC;