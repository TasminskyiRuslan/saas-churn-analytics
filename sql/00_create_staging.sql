-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 00_create_staging.sql
-- Description: Create staging schema and raw table for CSV import
-- =================================================================

DROP TABLE IF EXISTS raw_saas_subscriptions;

CREATE TABLE raw_saas_subscriptions (
    customerid VARCHAR(50),
    gender VARCHAR(20),
    seniorcitizen INT,
    partner VARCHAR(10),
    dependents VARCHAR(10),
    tenure INT,
    phoneservice VARCHAR(10),
    multiplelines VARCHAR(25),
    internetservice VARCHAR(25),
    onlinesecurity VARCHAR(25),
    onlinebackup VARCHAR(25),
    deviceprotection VARCHAR(25),
    techsupport VARCHAR(25),
    streamingtv VARCHAR(25),
    streamingmovies VARCHAR(25),
    contract VARCHAR(25),
    paperlessbilling VARCHAR(10),
    paymentmethod VARCHAR(50),
    monthlycharges NUMERIC(10, 2),
    totalcharges VARCHAR(50),
    churn VARCHAR(10)
);