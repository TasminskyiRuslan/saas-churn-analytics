-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 01_data_cleaning.sql
-- Description: Clean staging data and populate core dim_saas_customers table
-- =================================================================

DROP TABLE IF EXISTS dim_saas_customers;

CREATE TABLE dim_saas_customers (
    customer_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL UNIQUE,
    gender VARCHAR(20) NOT NULL,
    senior_citizen BOOLEAN NOT NULL,
    partner BOOLEAN NOT NULL,
    dependents BOOLEAN NOT NULL,
    tenure_months INTEGER NOT NULL,
    phone_service BOOLEAN NOT NULL,
    multiple_lines VARCHAR(25) NOT NULL,
    internet_service VARCHAR(25) NOT NULL,
    online_security VARCHAR(25) NOT NULL,
    online_backup VARCHAR(25) NOT NULL,
    device_protection VARCHAR(25) NOT NULL,
    tech_support VARCHAR(25) NOT NULL,
    streaming_tv VARCHAR(25) NOT NULL,
    streaming_movies VARCHAR(25) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    paperless_billing BOOLEAN NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    monthly_charges NUMERIC(10, 2) NOT NULL,
    total_charges NUMERIC(10, 2) NOT NULL,
    is_churned BOOLEAN NOT NULL
);

INSERT INTO dim_saas_customers (
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure_months,
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    contract_type,
    paperless_billing,
    payment_method,
    monthly_charges,
    total_charges,
    is_churned
) 
SELECT 
    customerid AS customer_id,
    gender,
    (seniorcitizen = 1) AS senior_citizen,
    (partner = 'Yes') AS partner,
    (dependents = 'Yes') AS dependents,
    tenure AS tenure_months,
    (phoneservice = 'Yes') AS phone_service,
    multiplelines AS multiple_lines,
    internetservice AS internet_service,
    onlinesecurity AS online_security,
    onlinebackup AS online_backup,
    deviceprotection AS device_protection,
    techsupport AS tech_support,
    streamingtv AS streaming_tv,
    streamingmovies AS streaming_movies,
    contract AS contract_type,
    (paperlessbilling = 'Yes') AS paperless_billing,
    paymentmethod AS payment_method,
    monthlycharges AS monthly_charges,
    CASE 
        WHEN TRIM(totalcharges) = '' OR totalcharges IS NULL THEN 0.00
        ELSE CAST(totalcharges AS NUMERIC(10, 2))
    END AS total_charges,
    (churn = 'Yes') AS is_churned
FROM raw_saas_subscriptions
WHERE customerid IS NOT NULL 
    AND monthlycharges >= 0;

CREATE INDEX idx_saas_customers_contract ON dim_saas_customers(contract_type);
CREATE INDEX idx_saas_customers_churn ON dim_saas_customers(is_churned);