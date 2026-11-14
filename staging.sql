/* STAGING MODEL */
-- In this staging model, we will clean and transform the raw user data to prepare it for analysis. 
-- The goal is to create a clean and structured view of the user data that can be used for further analysis and intermediate models

/* VIEW NAME: stg_users */
/* HOW SHOULD STAGED USER TABLE LOOK LIKE NOW BASED ON ALL FINDINGS? */
-- Keep existing age, signup, cohort and plan columns
-- Add country_name; keep original country codes
-- Keep raw city; exclude city_cleaned from our scope
-- Preserve NULL values in marketing opt-in flags
-- Keep original contacts and referral fields
-- Review whether additional customer segments are needed
-- Retain one row per user (19,430 total)

/* STAGING — USERS */

CREATE OR REPLACE VIEW `neo-bank-project-509212.staging.stg_users` AS 

WITH

-- STEP 1: calculate user's estimated age at signup using birth year
age_calculation AS (
  SELECT
    *
    ,EXTRACT(YEAR FROM created_date) - birth_year AS age_at_signup
  FROM `neo-bank-project-509212.raw_data.users`
),

-- STEP 2: group users based on their age at signup
age_group AS (
  SELECT
    *
    ,CASE
      WHEN age_at_signup < 25 THEN 'under 25'
      WHEN age_at_signup BETWEEN 25 AND 34 THEN 'ages 25-34'
      WHEN age_at_signup BETWEEN 35 AND 49 THEN 'ages 35-49'
      WHEN age_at_signup >= 50 THEN 'ages 50 and up'
      ELSE 'age unknown'
    END AS age_signup_group
  FROM age_calculation
)

-- STEP 3: Add country_name; keep original country codes. We will keep original country code fro reference
,country_name_add AS (
  SELECT
    *
    ,CASE country
      WHEN 'AT' THEN 'Austria'
      WHEN 'AU' THEN 'Australia'
      WHEN 'BE' THEN 'Belgium'
      WHEN 'BG' THEN 'Bulgaria'
      WHEN 'CH' THEN 'Switzerland'
      WHEN 'CY' THEN 'Cyprus'
      WHEN 'CZ' THEN 'Czechia'
      WHEN 'DE' THEN 'Germany'
      WHEN 'DK' THEN 'Denmark'
      WHEN 'EE' THEN 'Estonia'
      WHEN 'ES' THEN 'Spain'
      WHEN 'FI' THEN 'Finland'
      WHEN 'FR' THEN 'France'
      WHEN 'GB' THEN 'United Kingdom'
      WHEN 'GF' THEN 'French Guiana'
      WHEN 'GG' THEN 'Guernsey'
      WHEN 'GI' THEN 'Gibraltar'
      WHEN 'GP' THEN 'Guadeloupe'
      WHEN 'GR' THEN 'Greece'
      WHEN 'HR' THEN 'Croatia'
      WHEN 'HU' THEN 'Hungary'
      WHEN 'IE' THEN 'Ireland'
      WHEN 'IM' THEN 'Isle of Man'
      WHEN 'IS' THEN 'Iceland'
      WHEN 'IT' THEN 'Italy'
      WHEN 'JE' THEN 'Jersey'
      WHEN 'LI' THEN 'Liechtenstein'
      WHEN 'LT' THEN 'Lithuania'
      WHEN 'LU' THEN 'Luxembourg'
      WHEN 'LV' THEN 'Latvia'
      WHEN 'MQ' THEN 'Martinique'
      WHEN 'MT' THEN 'Malta'
      WHEN 'NL' THEN 'Netherlands'
      WHEN 'NO' THEN 'Norway'
      WHEN 'PL' THEN 'Poland'
      WHEN 'PT' THEN 'Portugal'
      WHEN 'RE' THEN 'Réunion'
      WHEN 'RO' THEN 'Romania'
      WHEN 'SE' THEN 'Sweden'
      WHEN 'SI' THEN 'Slovenia'
      WHEN 'SK' THEN 'Slovakia'
      ELSE country
    END AS country_name
  FROM age_group
)

-- Step 4: Create signup date fields for cohort and time based analysis and oup users by signup month and starting week
,signup_dates AS (
  SELECT
    *
    ,DATE(created_date) AS sign_up_date
    ,DATE_TRUNC(DATE(created_date), MONTH) AS cohort_month
    ,DATE_TRUNC(DATE(created_date), WEEK(MONDAY)) AS cohort_week
    ,EXTRACT(YEAR FROM created_date) AS signup_year
    ,EXTRACT(ISOWEEK FROM created_date) AS signup_week
    ,FORMAT_DATE('%G-W%V', DATE(created_date)) AS signup_year_week
  FROM country_name_add
)

-- STEP 5: Identify users with a paid subscription plan
-- Only PREMIUM and METAL are classified as paid
,plan_type AS (
  SELECT
    *
    ,CASE
      WHEN plan IN ('PREMIUM', 'METAL') THEN TRUE
      WHEN plan IS NULL THEN NULL
      ELSE FALSE
    END AS is_paid_plan
  FROM signup_dates
)

-- STEP 6: Rename user settings and notification columns
-- Here we will preserve all null values
,user_settings AS (
  SELECT
    *
    ,CAST(user_settings_crypto_unlocked AS BOOL) AS is_crypto_unlocked
    ,attributes_notifications_marketing_push = 1 AS is_push_optin
    ,attributes_notifications_marketing_email = 1 AS is_email_optin
  FROM plan_type
)

-- STEP 7: Select final columns for staging
-- Keep original city, contacts and referral fields
-- Leave additional customer segments mentioned for int models
SELECT
  user_id
  ,created_date AS signup_date
  ,sign_up_date AS signup_day
  ,cohort_month
  ,cohort_week
  ,signup_year
  ,signup_week
  ,signup_year_week
  ,birth_year
  ,age_at_signup
  ,age_signup_group
  ,country
  ,country_name
  ,city
  ,plan
  ,is_paid_plan
  ,is_crypto_unlocked
  ,is_push_optin
  ,is_email_optin
  ,num_contacts
  ,num_referrals
  ,num_successful_referrals
FROM user_settings
;


/* STAGING MODEL DATA QUALITY CHECKS */

/*CHECKING ROW COUNT AND UNIQUENESS */
SELECT
  COUNT(*) AS total_users
  ,COUNT(DISTINCT user_id) AS unique_users
  ,COUNTIF(user_id IS NULL) AS null_user_ids
FROM `neo-bank-project-509212.staging.stg_users`
;

/* CHECK MARKETING NULL VALUES */
SELECT
  COUNTIF(is_push_optin IS NULL) AS null_push
  ,COUNTIF(is_email_optin IS NULL) AS null_email
FROM `neo-bank-project-509212.staging.stg_users`
;