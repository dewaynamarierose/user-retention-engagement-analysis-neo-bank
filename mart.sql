/* MART MODEL */
-- In this modeling layer, we will create a mart model that combines the intermediate user lifecycle data with the intermediate user daily activity data to analyze customer risk and retention
/* 
BUSINESS QUESTION:
What makes customers stay at Neo-Bank, and how can we keep them active?

WHAT ARE WE TRYING TO FIND OUT?

What do customers who have stopped using Neo-Bank have in common?
Do customers at risk of leaving show similar behaviors?

We will investigate three questions:

1. Are customers on the free plan more likely to be at risk or to stop using Neo-Bank than customers on paid plans?

2. Did customers who are now at risk or churned use Neo-Bank less frequently during their first 30 days?

3. Were these customers more likely to use only one banking service during their first 30 days?

WHY DOES THIS MATTER?

We want to identify behaviors associated with customers becoming
inactive, so Neo-Bank can decide where to focus its efforts to keep customers using the bank

WHO ARE WE STUDYING?

Customers who joined Neo-Bank between January 1 and December 31, 2018

We look at transactions from January 1, 2018 through April 30, 2019

April is our last complete month of transaction data
May is excluded because incomplete data could make customer
activity appear lower than it actually was

WHAT COUNTS AS CUSTOMER ACTIVITY?

A transaction must:
- Be COMPLETED
- Be worth more than $0.01
- Be a card payment, transfer, top-up, exchange, or ATM transaction

HOW DO WE CLASSIFY CUSTOMERS?

Active:
Made a valid transaction within the last 30 days (0–29 days inactive)

At Risk:
Has not made a valid transaction for 30–89 days

Inactive / Churned:
Has not made a valid transaction for 90 days or more

Never Active:
Has never made a valid transaction

Customer status is measured as of April 30, 2019

The 30-day at-risk threshold is our proposed early warning rule
It is not a prediction that a customer will definitely leave

WHAT WILL THIS VIEW SHOW?

One row per customer, including:
- Their subscription plan
- Whether they are active, at risk, churned, or never active
- How often they used Neo-Bank during their first 30 days
- How many different banking services they used during that period
*/

CREATE OR REPLACE TABLE `neo-bank-project-509212.mart.mart_customer_risk_analysis` AS

-- STEP 1: Find when each customer first and last used Neo-Bank
WITH last_activity AS (
  SELECT
    users.user_id
    ,users.plan
    ,users.is_paid_plan
    ,DATE_TRUNC(users.signup_day, MONTH) AS signup_month
    /* First and last transactions */
    -- The first transaction tells us when a customer started using Neo-Bank
    -- The last transaction tells us when they most recently used it
    ,MIN(daily_activity.transaction_date) AS first_transaction_date
    ,MAX(daily_activity.transaction_date) AS last_transaction_date

    /* How long has each customer been inactive? */
    -- Count the days between their last valid transactionand April 30, 2019
    -- Using the same date for everyone makes comparisons consistent
    ,DATE_DIFF(
      DATE '2019-04-30'
      ,MAX(daily_activity.transaction_date)
      ,DAY
    ) AS days_without_a_transaction


  FROM `neo-bank-project-509212.staging.stg_users` AS users

  LEFT JOIN `neo-bank-project-509212.intermediate.int_user_daily_activity` AS daily_activity
    ON users.user_id = daily_activity.user_id
    AND daily_activity.transaction_date BETWEEN DATE '2018-01-01' AND DATE '2019-04-30'

  -- Keep customers who never made a valid transaction
  -- This allows us to identify the Never Active group
  WHERE users.signup_day BETWEEN DATE '2018-01-01' AND DATE '2018-12-31'
  GROUP BY 1,2,3,4
)

/* STEP 2: Identify which customers are active, at risk, or churned */
,identify_status AS (
  SELECT
    user_id
    ,plan
    ,is_paid_plan
    ,first_transaction_date
    ,last_transaction_date
    ,days_without_a_transaction
    ,signup_month
    /* Identify each customer's activity status */
    -- Group customers based on how long they have gone without making a valid transaction
    ,CASE
      WHEN days_without_a_transaction IS NULL THEN 'never active'
      WHEN days_without_a_transaction >= 90 THEN 'inactive'
      WHEN days_without_a_transaction >= 30 THEN 'at risk'
      ELSE 'active'
    END AS customer_status
   

    /* Separate free and paid customers */
    -- Standard = customers using the free banking plan
    -- Paid = customers with a paid subscription
    -- Other = customers with plans outside these groups
    ,CASE
      WHEN plan = 'STANDARD' THEN 'standard'
      WHEN is_paid_plan THEN 'paid'
      ELSE 'other'
    END AS plan_group
  

    /* Can we measure their full first 30 days? */
    -- We look at the first transaction day and the next 29 days
    -- Only include customers whose full first 30 days are covered by our data when comparing their early activity
    -- Otherwise, some customers would have less time to use Neo-Bank, making their early activity look lower
    ,CASE
      WHEN first_transaction_date IS NOT NULL
        AND DATE_ADD(first_transaction_date, INTERVAL 29 DAY) <= DATE '2019-04-30'
      THEN TRUE
      ELSE FALSE
    END AS has_full_first_30_days

  FROM last_activity
)

/* STEP 3: Find out how often customers used Neo-Bank when they started */
,early_activity AS (
  SELECT
    status.user_id

    /* Number of days customers used Neo-Bank */
    -- Count how many different days each customer made a valid transaction during their first 30 days
    -- WHY?  We want to see whether customers who eventually became inactive were already using Neo-Bank less often early on
    ,COUNT(DISTINCT daily_activity.transaction_date) AS active_days_first_30

  FROM identify_status AS status

  LEFT JOIN `neo-bank-project-509212.intermediate.int_user_daily_activity` AS daily_activity
    ON status.user_id = daily_activity.user_id
    AND daily_activity.transaction_date BETWEEN
      status.first_transaction_date
      AND DATE_ADD(status.first_transaction_date, INTERVAL 29 DAY)

  GROUP BY status.user_id
)

/* STEP 4: Find out how many different banking services customers tried */
,early_services AS (
  SELECT
    status.user_id

   /* Number of banking services used */
    -- Count how many different services each customer used during their first 30 days
    ,COUNT(DISTINCT transactions.transactions_type) AS services_used_first_30

  FROM identify_status AS status

  LEFT JOIN `neo-bank-project-509212.staging.stg_transactions` AS transactions
    ON status.user_id = transactions.user_id
    AND transactions.transaction_date BETWEEN
      status.first_transaction_date
      AND DATE_ADD(status.first_transaction_date, INTERVAL 29 DAY)

    /* Only count the valid transactions agreed for our project */
    AND transactions.transactions_state = 'COMPLETED'
    AND transactions.transactions_type IN (
      'CARD_PAYMENT'
      ,'TRANSFER'
      ,'TOPUP'
      ,'EXCHANGE'
      ,'ATM'
    )
    AND transactions.amount_usd > 0.01

  GROUP BY status.user_id
)

/* STEP 5: Bring customer status and early behavior into one view */
SELECT
  status.user_id
  ,status.plan
  ,status.plan_group
  ,status.customer_status
  ,status.first_transaction_date
  ,status.last_transaction_date
  ,status.days_without_a_transaction
  ,status.has_full_first_30_days
  ,status.signup_month
  /* How often did customers use Neo-Bank when they started? */
  -- Show how many different days they made transactions during their first 30 days
  -- Leave the result blank if we cannot measure the full 30 days
  ,CASE
    WHEN status.has_full_first_30_days
    THEN activity.active_days_first_30
    ELSE NULL
  END AS active_days_first_30

  /* How many different banking services did customers use? */
  -- Count the services they used during their first 30 days
  -- Only include customers whose full 30 days are covered by our data so everyone has the same amount of time to use Neo-Bank
  ,CASE
    WHEN status.has_full_first_30_days
    THEN services.services_used_first_30
    ELSE NULL
  END AS services_used_first_30

  /* Did customers use one service or several? */
  -- Single service = used only one banking service
  -- Multiple services = used two or more banking services
  ,CASE
    WHEN NOT status.has_full_first_30_days THEN NULL
    WHEN services.services_used_first_30 = 1 THEN 'single service'
    WHEN services.services_used_first_30 >= 2 THEN 'multiple services'
    ELSE 'no service recorded'
  END AS service_group_first_30

FROM identify_status AS status

LEFT JOIN early_activity AS activity
  ON status.user_id = activity.user_id
