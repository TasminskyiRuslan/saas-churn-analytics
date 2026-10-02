-- =================================================================
-- Project: SaaS Subscription & Churn Analytics
-- Script: 01_data_quality_input.sql
-- Description: Input assertions on raw staging data (fail before transform)
-- =================================================================

DO $$
DECLARE
    v_count INT;
BEGIN
    -- 1. Row count
    SELECT COUNT(*) INTO v_count FROM staging.raw_saas_subscriptions;
    IF v_count <> 7043 THEN
        RAISE EXCEPTION 'INPUT FAIL: raw rows = %, expected 7043', v_count;
    END IF;

    -- 2. No duplicate customer ids
    SELECT COUNT(*) INTO v_count FROM (
        SELECT customerid FROM staging.raw_saas_subscriptions
        GROUP BY customerid HAVING COUNT(*) > 1
    ) d;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'INPUT FAIL: % duplicate customer ids', v_count;
    END IF;

    -- 3. churn only Yes/No
    SELECT COUNT(*) INTO v_count FROM staging.raw_saas_subscriptions
    WHERE churn IS NULL OR churn NOT IN ('Yes', 'No');
    IF v_count > 0 THEN
        RAISE EXCEPTION 'INPUT FAIL: % rows with unexpected churn value', v_count;
    END IF;

    -- 4. Blank TotalCharges: exactly 11, only for tenure = 0 (new customers)
    SELECT COUNT(*) INTO v_count FROM staging.raw_saas_subscriptions
    WHERE TRIM(totalcharges) = '';
    IF v_count <> 11 THEN
        RAISE EXCEPTION 'INPUT FAIL: blank TotalCharges = %, expected 11', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count FROM staging.raw_saas_subscriptions
    WHERE TRIM(totalcharges) = '' AND tenure <> 0;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'INPUT FAIL: % blank TotalCharges with tenure <> 0', v_count;
    END IF;

    -- 5. Numeric ranges
    SELECT COUNT(*) INTO v_count FROM staging.raw_saas_subscriptions
    WHERE monthlycharges <= 0 OR tenure < 0 OR tenure > 72;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'INPUT FAIL: % rows out of range (charges/tenure)', v_count;
    END IF;

    RAISE NOTICE 'INPUT OK: raw data passed all checks';
END $$;