/*EXPLORATORY DATA ANALYSIS*/
/*
This analysis is based on the raw data provided by Neo-Bank. 
The purpose of this analysis is to understand the data, identify any data quality issues, and provide insights into the customer population and transaction behaviors.
 The analysis covers the following tables: users, transactions, notifications, and devices. 
 Each section includes queries to explore the data, summarize key metrics, and identify any anomalies or patterns that may be relevant for further analysis or decision-making.
 Findings were also cross verified with previous analyses conducted by team members to ensure consistency and accuracy of results.
*/

/* TABLE: users */

/*What is the timespan of our data? */
SELECT
created_date
FROM `neo-bank-project-509212.raw_data.users` 
ORDER BY created_date 
;
-- ANSWER: The data spans from January 1, 2018 to January 3, 2019. This means we have just over a year of data for analysis
--  start: 2018-01-01 08:42:24.799709 UTC
--  end: 2019-01-03 07:34:36.638892 UTC



/*How many columns in this data? */
-- ANSWER: 12 columns

-- HOW MANY ROWS IN THIS DATA? 
SELECT
  COUNT(*) as total_rows
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: 19430


/* Calculating the total number of distinct users */## we have total of 19430 DISTINCT USER - matches with rows
SELECT
  COUNT (DISTINCT user_id) AS nb_of_users
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: We have 19430 distinct users, which matches the total number of rows in the dataset. This indicates that each row represents a unique user

/* What are the birth year types? */
SELECT DISTINCT
  birth_year
FROM `neo-bank-project-509212.raw_data.users` 
ORDER BY birth_year DESC
;
-- ANSWER: The birth years of users range from 1929 to 2001. Seems like a diverse age range among the customer base. This information can be useful for understanding the demographics of bank users and tailoring services or marketing strategies 

/* HOW MANY COUNTRIES DO WE HAVE? */
SELECT DISTINCT
  country
FROM `neo-bank-project-509212.raw_data.users` 
ORDER BY country DESC
;
-- ANSWER: We have 41 countries represented in the dataset, all identified with two-letter abbreviations

/* How many cities do we have? */
SELECT DISTINCT
  city
FROM `neo-bank-project-509212.raw_data.users` 
ORDER BY city DESC
;
-- ANSWER: We have 6049 cities represented in the dataset

/*What are the PLAN TYPES? */
SELECT DISTINCT
  plan
FROM `neo-bank-project-509212.raw_data.users` 
;
-- There are 6 plan types:
-- 1	STANDARD
-- 2	PREMIUM
-- 3	METAL
-- 4	METAL_FREE
-- 5	PREMIUM_OFFER
-- 6	PREMIUM_FREE


/* What are the user_settings_crypto_unlocked TYPES? */
SELECT DISTINCT
  user_settings_crypto_unlocked
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: I see just 0 and 1 so this meaning true or false so whether a users crypto settings are unlocked or not?


/* WHAT ARE THE attributes_notifications_marketing_push AND attributes_notifications_marketing_email TYPES? */
SELECT DISTINCT
  attributes_notifications_marketing_email
  -- attributes_notifications_marketing_push
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: I see just 0.0 and 1.0 so this meaning true or false so whether a users marketing notifications are enabled or not? There are also null values for both columns which means we have missing data for some users

/* What is the total number of contacts? */
SELECT
 SUM(num_contacts) as total_nb_contacts
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER:The total number is 347558 contacts across all users. This indicates that on average, each user has approximately 17.9 contacts (347558 / 19430). This information can be useful for understanding the social connectivity of users and potential referral opportunities

/* What is the total number of referrals? */
SELECT
 SUM(num_referrals) as total_nb_referrals
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: The total number of referrals is 0. Interesting, it could mean that no users have referred others to the bank. Maybe the referral program is not being used or that it may not be effective in encouraging users to refer others

/* What is the total number of successful referrals? */
SELECT
 SUM(num_successful_referrals) as total_nb_successful_referrals
FROM `neo-bank-project-509212.raw_data.users` 
;
-- ANSWER: Also the total nb of successful refferals is 0. Interesting, so no refferals or successful refferals made? 

-- ---------------------------------------------------------------------------------------
/* USER EDA CONFIRMATION ANALYSIS */
/*These are just questions I'd like to look into deeper based on her findings */
/*ABOUT THIS TABLE: In this table, each row represents one unique customer registered with Neo-Bank*/
-- ---------------------------------------------------------------------------------------

/*TABLE: transactions*/

--WHAT IS THE TIMESPAN OF OUR DATA?
SELECT
created_date
FROM `neo-bank-project-509212.raw_data.transactions `
ORDER BY created_date DESC
;
-- ANSWER: The data spans from January 1, 2018 to May 16, 2019. This means we have just over a year of data for analysis. The transactions data covers a longer period than the users data, which may provide insights into user behavior over time
-- start: 2018-01-01 08:51:10.248709 UTC
-- end: 2019-05-16 18:22:16.959896 UTC


-- HOW MANY COLUMNS IN THIS DATA?
-- ANSWER: 12 columns

-- HOW MANY ROWS IN THIS DATA? 
SELECT
  COUNT(*) as total_rows
FROM `neo-bank-project-509212.raw_data.transactions `
-- ANSWER: 2740075
;

-- CALCULATE TOTAL DISTINCT NUMBER OF USERS
SELECT
  COUNT (DISTINCT user_id) AS nb_of_users
FROM `neo-bank-project-509212.raw_data.transactions `
WHERE transactions_state = 'COMPLETED'
;
-- ANSWER: the total nb of DISCTINCT users is 18766 and 18529 customers who completed a transaction

-- CALCULATE TOTAL DISTINCT NUMBER OF TRANSACTION IDS
SELECT
  COUNT (DISTINCT transaction_id) AS nb_of_trans_id
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: the total nb of DISCTINCT transaction ids is 2740075


/*WHAT ARE THE TRANSACTION TYPES?*/
SELECT DISTINCT
  transactions_type
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: there are 10 transaction types 
-- 1 FEE
-- 2	CASHBACK
-- 3	REFUND
-- 4	CARD_PAYMENT
-- 5	TAX
-- 6	TOPUP
-- 7	EXCHANGE
-- 8	TRANSFER
-- 9	CARD_REFUND
-- 10	ATM

/*WHAT ARE THE TRANSACTION CURRENCY TYPES?*/
SELECT DISTINCT
  transactions_currency
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: there are 35 transaction currency types


/*WHAT ARE THE TRANSACTION STATE TYPES?*/
SELECT DISTINCT
  transactions_state
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: there are 6 transaction state types
-- 1	COMPLETED
-- 2	PENDING
-- 3	REVERTED
-- 4	CANCELLED
-- 5	DECLINED
-- 6	FAILED

/*WHAT ARE THE ea_cardholderpresence TYPES?*/
SELECT DISTINCT
  ea_cardholderpresence
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: there are 4 ea_cardholderpresence types, with one type being null
-- 1	null
-- 2	FALSE
-- 3	UNKNOWN
-- 4	TRUE

/*WHAT ARE THE DIRECTION TYPES?*/
SELECT DISTINCT
  direction
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: there are two types; inbound and outbound -- transactions being sent (outbound) and transactions being received (inbound)

/*UNDERSTANDING FLOAT TYPES*/
SELECT
  ea_merchant_mcc
  ,amount_usd
FROM `neo-bank-project-509212.raw_data.transactions `
;
-- ANSWER: amount_usd is the amount of the transaction converted to USD. This allows for easier comparison of transaction amounts across different currencies. The ea_merchant_mcc column represents the merchant category code, which can provide insights into the types of merchants where transactions are occurring

-- --------------------------------------------------------------------------------------
/*TRANSACTION EDA CONFIRMATION ANALYSIS*/
/*
These are just questions I'd like to look into deeper based on his findings
#ABOUT THIS TABLE: In this table, each row represents one transaction record
*/

/* 1. How many unique customers have completed transactions? Ezzat had mentioned before 18529 */
SELECT
 transactions_state
 ,COUNT(DISTINCT user_id) AS nb_of_customers
FROM `neo-bank-project-509212.raw_data.transactions `
GROUP BY 1
ORDER BY 2 DESC
;
-- ANSWER: So I can confirm Ezzat's findings! 18529 unique customers have completed at least one transaction.
--  A customer can appear multiple times in the transactions table but for this query we only count the customer ONCE
-- We still do not know if all 18529 customers are active users

-- 2. How many customers completed only one transaction vs multiple transactions? Because we still don't know if all 18529 customers are active users

/* we will first make with statement to count the number of transactions then count from there */

WITH customer_transactions AS (
  SELECT
    user_id
    ,COUNT(DISTINCT transaction_id) AS nb_transactions
  FROM `neo-bank-project-509212.raw_data.transactions `
  WHERE transactions_state = 'COMPLETED'
  GROUP BY 1
)
SELECT
  COUNTIF(nb_transactions = 1) AS one_transaction
  ,COUNTIF(nb_transactions > 1) AS multiple_transactions
FROM customer_transactions
;

-- ANSWER: So out of the 18529 customers, 803 made only one transaction and 17726 made more than one
-- To know the percentage to make it more clear I will do the following

SELECT
  ROUND(803/ 18529 * 100,2) AS one_transaction
  ,ROUND(17726 / 18529 * 100,2) AS multiple_transactions
;
-- ANSWER: So 4% of customers completed only one transaction and 95% of customers completed more than one transaction. This indicates that the majority of customers are engaging with the bank and making multiple transactions, which is a positive sign for customer retention and engagement
-- another thing we don't know is if they actually made these transactions over a time period of more than a day 

/* 3. How many customers made transactions on one day vs multiple days?*/
WITH customer_daily_transactions AS (
  SELECT
    user_id
    ,COUNT(DISTINCT DATE(created_date)) AS nb_of_days
  FROM `neo-bank-project-509212.raw_data.transactions `
  WHERE transactions_state = 'COMPLETED'
  GROUP BY 1
)
SELECT
  COUNTIF(nb_of_days = 1) AS one_day
  ,COUNTIF(nb_of_days > 1) AS multiple_days
FROM customer_daily_transactions
;
-- ANSWER: So 1370 customers made completed transactions on only one day and 17159 customers made completed transactions on multiple days

-- To know the percentage to make it more clear I will do the following
SELECT
  ROUND(1370/ 18529 * 100,2) AS one_day
  ,ROUND(17159 / 18529 * 100,2) AS multiple_days
;
-- ANSWER: So 92% make completed transactions on multiple days which means most customers used Neo-Bank on different days

/* 4. How many customers completed transactions in one month versus multiple months? This will help us understand if customer used our bank accross diffrent months */

WITH customer_monthly_transactions AS (
  SELECT
    user_id
    ,COUNT(DISTINCT FORMAT_TIMESTAMP('%Y-%m', created_date)) AS nb_of_months
  FROM `neo-bank-project-509212.raw_data.transactions `
  WHERE transactions_state = 'COMPLETED'
  GROUP BY 1
)
SELECT
  COUNTIF(nb_of_months = 1) AS one_months
  ,COUNTIF(nb_of_months > 1) AS multiple_months
FROM customer_monthly_transactions
;
## To know the percentage to make it more clear I will do the following
SELECT
  ROUND(1960/ 18529 * 100,2) AS one_month
  ,ROUND(16569 / 18529 * 100,2) AS multiple_months
;

-- ANSWER: So 1960 (10%) customers made transactions in only one month vs 89% of customers who transacted in multiple months
--  this does not mean though consistent activity from customers 

/* 5. What are the most common COMPLETED transaction types? */
SELECT
  transactions_type
  ,COUNT(DISTINCT user_id) AS nb_of_customers
  ,COUNT(*) AS nb_of_transactions
FROM `neo-bank-project-509212.raw_data.transactions `
WHERE transactions_state = "COMPLETED"
GROUP BY 1
ORDER BY 2 DESC
;
--ANSWER: TOPUP is the transaction type used the most by customers 18054 which means most customers have added money to their Neo-Bank accounts.
-- ## However, CARD_PAYMENT is the most frequent activity with 1257461 payments(transactions) made by 15092 customers
-- ## TRANSFER is also common, used by 12,990 customers
-- ## This means customers use Neo-Bank for everyday spending not just adding money or transferring funds. Some transactions, like fees, taxes and cashback, may happen automatically, so they shouldn't necessarily count as active user engagement

/* 6. Is there transaction data accross all months? Ezzat looked at this earlier but I wanted to confirm */
SELECT
  COUNT(*) AS nb_of_transactions
    ,EXTRACT(YEAR FROM created_date) AS year
    ,EXTRACT(MONTH FROM created_date) AS month
    ,MIN(DATE(created_date)) AS first_date
    ,MAX(DATE(created_date)) AS last_date
FROM `neo-bank-project-509212.raw_data.transactions `
WHERE transactions_state = "COMPLETED"
GROUP BY 2,3
ORDER BY 2,3
;
-- ANSWER:   I see that completed transactions increased over time
--  May 2019 only contains data until May 15
-- Its lower transaction count may be due to incomplete data and we should not use it as a full month

/* 7. Why are most merchant-related columns NULL?*/
/* Ezzat mentioned that many merchant columns contain missing values. I want to understand whether that's because the data is incomplete or because certain transactions don't involve merchants and if its useful for final mart table or not.*/
SELECT
  transactions_type
  ,COUNT(*) AS total_transactions
  ,COUNT(ea_merchant_mcc) AS transactions_with_merchant_category
  ,COUNT(ea_merchant_city) AS transactions_with_merchant_city
  ,COUNT(ea_merchant_country) AS transactions_with_merchant_country
  ,COUNT(ea_cardholderpresence) AS transactions_with_cardholder_presence
FROM `neo-bank-project-509212.raw_data.transactions `
GROUP BY 1
ORDER BY 2 DESC
;
-- ANSWER: Most NULLs are expected because not all transactions involve shops, that is why we see some nulls-- this is expected (NOT DATA ERROR)
--  Card payments and ATM withdrawals have almost all merchant details
-- Transfers, top-ups and exchanges have no merchant details
-- Most card refunds don't record whether the customer was physically present, likely because a refund is money being returned rather than a new purchase (cardholder_presence)

/* DECISION:*/
-- Most NULLs are expected because not all transactions involve shops.
-- Card payments and ATM withdrawals have almost all merchant details.
-- Transfers, top-ups and exchanges have no merchant details.
-- Most card refunds don't record whether the customer was
-- physically present, likely because refunds aren't new purchases.

/* DECISION: */
-- Keep all four merchant columns in staging.
-- Exclude them from intermediate and final mart models.
-- These columns could help explore shopping habits or international spending, but these are outside our current analysis.
-- Our focus is on activation, transaction frequency and retention, which we can measure without merchant details.

-- ---------------------------------------------------------------------------------------

/* TABLE: notifications */

/* WHAT IS THE TIMESPAN OF OUR DATA? */
SELECT
created_date
FROM `neo-bank-project-509212.raw_data.notifications` 
ORDER BY created_date DESC
;
-- ANSWER: The data spans from January 10, 2018 to May 12, 2019. This means we have just over a year of data for analysis. The notifications data covers a longer period than the users data, which may provide insights into user engagement and communication over time
--  start: 2018-01-10 12:09:55.050139 UTC
-- end: 2019-05-12 17:12:14.132130 UTC

-- HOW MANY COLUMNS IN THIS DATA?
-- ANSWER: 5 columns

-- HOW MANY ROWS IN THIS DATA? 
SELECT
  COUNT(*) as total_rows
FROM `neo-bank-project-509212.raw_data.notifications` 
;
-- ANSWER: 121813


-- CALCULATE TOTAL NUMBER OF DISTINCT USERS
SELECT
  COUNT (DISTINCT user_id) AS nb_of_users
FROM `neo-bank-project-509212.raw_data.notifications` 
;
-- ANSWER: The total number of distinct users is 18953

/* WHAT ARE THE REASON TYPES? */
SELECT DISTINCT
  reason
FROM `neo-bank-project-509212.raw_data.notifications` 
;
-- ANSWER: There are 17 reason types for notifications, which indicate the different triggers or events that led to a notification being sent to a user. These reasons can provide insights into user engagement and the effectiveness of different marketing or communication strategies
-- 1	METAL_RESERVE_PLAN
-- 2	REENGAGEMENT_ACTIVE_FUNDS
-- 3	BLACK_FRIDAY
-- 4	LOST_CARD_ORDER
-- 5	FIFTH_PAYMENT_PROMO
-- 6	JOINING_ANNIVERSARY
-- 7	PUMPKIN_PAYMENT_NOTIFICATION
-- 8	PREMIUM_ENGAGEMENT_FEES_SAVED
-- 9	PREMIUM_ENGAGEMENT_INACTIVE_CARD
-- 10	WELCOME_HOME
-- 11	METAL_GAME_START
-- 12	NO_INITIAL_CARD_USE
-- 13	NO_INITIAL_CARD_ORDER
-- 14	ONBOARDING_TIPS_ACTIVATED_USERS
-- 15	ENGAGEMENT_SPLIT_BILL_RESTAURANT
-- 16	MADE_MONEY_REQUEST_NOT_SPLIT_BILL
-- 17	NO_INITIAL_FREE_PROMOPAGE_CARD_ORDER



/* WHAT ARE THE CHANNEL TYPES? */
SELECT DISTINCT
  channel
FROM `neo-bank-project-509212.raw_data.notifications` 
;
-- ANSWER: There are 3 channel types for notifications, which indicate the different methods of communication used to send notifications to users 
-- 1	SMS
-- 2	PUSH
-- 3	EMAIL


-- WHAT ARE THE STATUS TYPES?
## there are two status types:
-- 1	SENT
-- 2	FAILED
SELECT DISTINCT
  status
FROM `neo-bank-project-509212.raw_data.notifications` 
;

-- ---------------------------------------------------------------------------------------

/* TABLE: devices */
/* WHAT IS THE TIMESPAN OF OUR DATA? */
-- ANSWER: no dates here

/* WHAT ARE THE TYPES IN STRING_FIELD_0? */
SELECT DISTINCT
  string_field_0
FROM `neo-bank-project-509212.raw_data.devices` 
;
-- ANSWER: There are 4 types in string_field_0, which represent the brand of phone the user is using. This information can provide insights into the types of devices used by customers and may be relevant for understanding user behavior or preferences
-- 1	Apple
-- 2	brand
-- 3	Android
-- 4	Unknown


/* WHAT ARE THE TYPES IN STRING_FIELD_1? */
SELECT DISTINCT
  string_field_1
FROM `neo-bank-project-509212.raw_data.devices` 
;
-- ANSWER: These are the user ids 

-- HOW MANY DISTINCT USERS IN THIS DATASET?
SELECT
  COUNT (DISTINCT string_field_1) AS nb_of_users
FROM `neo-bank-project-509212.raw_data.devices` 
;
-- ANSWER: There are 19431 distinct users in this dataset

-- ---------------------------------------------------------------------------------------
/* UNDERSTAND OUR DATA */
/* TABLE: USERS */
/* DEWAYNAS PART: UNDERSTAND CUSTOMER POPULATION */

/* 1. Calculate total users and signup trends by year/month.*/
-- Confirmed with Melissa's results
SELECT
  FORMAT_TIMESTAMP('%Y-%m',created_date) AS signup_month
  ,COUNT(DISTINCT user_id) AS users
FROM `neo-bank-project-509212.raw_data.users` 
GROUP BY 1
ORDER BY 1
; 
--  RESULTS: We had mentioned earlier the user's dataset has 19430 registered users. The amount of registered users increased significantly in 2018 with December 2018 with 2419. However, we cannot determine the user pattern going into 2019 as we only have January 2019 here. Worth probably going about data in a different way in terms of aquisition trends?

/* Do we have any DATA LIMITATIONS?: We only have data until Jan 3, 2019 */

/* 2.What are the customer characteristics? Review basic customer characteristics, such as country and plan.*/
--We saw earlier we have 41 countries -- all identified with two letter abbreviation. We should understand how they are distributed

/* 2.1 How are customers distributed across countries? */
SELECT
  country
  ,COUNT(DISTINCT user_id) AS total_users
  ,ROUND(COUNT(*)/19430*100,2) AS percentage
FROM `neo-bank-project-509212.raw_data.users` 
GROUP BY 1
ORDER BY 2 DESC
;
-- ANSWER: The top 5 countries with the highest number of users are GB, PL, FR, IE, and RO. These countries account for a significant portion of the total user base, with GB having the largest share at 32.5%. This information can be useful for understanding the geographic distribution of users and tailoring marketing or service strategies to specific regions
-- country	total_users	percentage
-- 1	GB	    6315	          32.5
-- 2	PL	    2306	          11.87
-- 3	FR	    2110	          10.86
-- 4	IE	    1214	          6.25
-- 5	RO	    1096	          5.64
SELECT


/* 2.2 How are customers distributed across plans? */
SELECT
  plan
  ,COUNT(DISTINCT user_id) AS total_users
  ,ROUND(COUNT(*)/19430*100,2) AS percentage
FROM `neo-bank-project-509212.raw_data.users` 
GROUP BY 1
ORDER BY 2 DESC
;
-- ANSWER: Looks like the majority of users use the STANDARD plan, making up 92.6% of the distribution. The plans that make up the smallest distribution are METAL_FREE, PREMIUM_OFFER, and PREMIUM_FREE. This information can be useful for understanding user preferences and tailoring marketing or service strategies to specific plan types
-- 1	STANDARD	17992	92.6
-- 2	PREMIUM	865	4.45
-- 3	METAL	507	2.61
-- 4	METAL_FREE	37	0.19
-- 5	PREMIUM_OFFER	25	0.13
-- 6	PREMIUM_FREE	4	0.02


/* 2.2 How are customers distributed across cities? */
SELECT
  city
  ,COUNT(DISTINCT user_id) AS total_users
  ,ROUND(COUNT(*)/19430*100,2) AS percentage
FROM `neo-bank-project-509212.raw_data.users` 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;
-- ANSWER: Biggest percentages stem from London, Warszawa, and Paris
-- Row	city	total_users	percentage
-- 1	London	    1707	        8.79
-- 2	Warszawa	    414	        2.13
-- 3	Paris	    373	            1.92
-- 4	Dublin	    367	        1.89
-- 5	Vilnius	    319	        1.64
-- 6	Bucharest	    225	        1.16
-- 7	Madrid	    200	        1.03        
-- 8	Bucuresti	    172	        0.89
-- 9	Kraków	    150	        0.77
-- 10	Lisboa	    145	        0.75

/* What are the  DATA QUALITY ISSUES?: */
-- City names are standardized; some names are listed with English and country's native language (mentioned also by Melissa)
  -- for example, Bucharest and Bucuresti
-- We will have to standardize names in cleaning to avoid analysis later on

-- MELISSA RESULT VERIFICATION: in this data, earlier, Melissa reported 1706 users for London and 372 in Paris (difference only in one user but should look into)

/* 3. Check for important fields for missing or duplicate values */

/* 3.1 Are there any missing values? */
SELECT
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS count_nulls_user_id
  ,SUM(CASE WHEN birth_year IS NULL THEN 1 ELSE 0 END) AS count_nulls_birth_year
  ,SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS count_nulls_country
  ,SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS count_nulls_city
  ,SUM(CASE WHEN created_date IS NULL THEN 1 ELSE 0 END) AS count_nulls_created_date
  ,SUM(CASE WHEN user_settings_crypto_unlocked IS NULL THEN 1 ELSE 0 END) AS count_nulls_user_settings_crypto_unlocked
  ,SUM(CASE WHEN plan IS NULL THEN 1 ELSE 0 END) AS count_nulls_plan
  ,SUM(CASE WHEN attributes_notifications_marketing_push IS NULL THEN 1 ELSE 0 END) AS count_nulls_attributes_notifications_marketing_push
  ,SUM(CASE WHEN attributes_notifications_marketing_email IS NULL THEN 1 ELSE 0 END) AS count_nulls_attributes_notifications_marketing_email
  ,SUM(CASE WHEN num_contacts IS NULL THEN 1 ELSE 0 END) AS count_nulls_num_contacts
  ,SUM(CASE WHEN num_referrals IS NULL THEN 1 ELSE 0 END) AS count_nulls_num_referrals
  ,SUM(CASE WHEN num_successful_referrals IS NULL THEN 1 ELSE 0 END) AS count_nulls_num_successful_referrals
FROM `neo-bank-project-509212.raw_data.users`
;
-- ANSWER: There are 6610 in both columns;     
-- attributes_notifications_marketing_push
-- attributes_notifications_marketing_email
-- The rest of the columns have no null values

/* 3.1.A Are the missing null values for the previous columns for the same users in each column? */
SELECT
  COUNT(*) AS users_missing_both
FROM `neo-bank-project-509212.raw_data.users`
WHERE attributes_notifications_marketing_push IS NULL
AND attributes_notifications_marketing_email IS NULL
;
-- ANSWER: Yes it is the same number, 6610 so this confirms the null values belong to same users

/* 3.2 Are there any duplicate values? */
SELECT
  user_id
  ,COUNT(*) AS total_records
FROM `neo-bank-project-509212.raw_data.users`
GROUP BY user_id
HAVING COUNT(*) > 1
;
-- ANSWER: There are no duplicate values here

/* 3.3 Are there any unusual or incorrect values? */

/* 3.4 Are there any unusual birth years? */
SELECT
  birth_year
  ,EXTRACT(YEAR FROM created_date) - birth_year AS age_at_signup
FROM `neo-bank-project-509212.raw_data.users`
ORDER BY 2 DESC
;
-- ANSWER: youngest 17
-- ANSWER: oldest 89
-- ANSWER: There doesn't seem to be any weird age but we can also see the number of users by age group in case something is off

/* 3.5 Is there an odd distribution of age in users? */
SELECT
  CASE
    WHEN EXTRACT(YEAR FROM created_date) - birth_year < 25
      THEN 'under 25'
    WHEN EXTRACT(YEAR FROM created_date) - birth_year BETWEEN 25 AND 34
      THEN 'ages 25-34'
    WHEN EXTRACT(YEAR FROM created_date) - birth_year BETWEEN 35 AND 49
      THEN 'ages 35-49'
    WHEN EXTRACT(YEAR FROM created_date) - birth_year >=50
      THEN 'ages 50 and up'
  ELSE 'age unknown'
  END AS age_group
  ,COUNT(*) AS total_users
FROM `neo-bank-project-509212.raw_data.users`
GROUP BY age_group
ORDER BY 2 DESC
;
-- ANSWER: Largest distribution seems to be ages 25-34	with 8001 users the under 25 and 50 and up category are lower than other two. seems distributed like i would imagine for using banking app 

/* 3.5 Are there unusual contact values? */
SELECT
  MIN(num_contacts) AS min_contact_value
  ,MAX(num_contacts) AS max_contact_value
  ,COUNTIF(num_contacts < 0) AS negative_contact_value
FROM `neo-bank-project-509212.raw_data.users`
;
-- ANSWER: The max is 2918 -- seems pretty high amount of contacts; min is 0 and no negative contacts
-- ANSWER: needs further investigation if there is one or more users with this amount of contacts

/* 3.5.A Investigating contact max value */
SELECT
  user_id
  ,num_contacts
FROM `neo-bank-project-509212.raw_data.users`
ORDER BY 2 DESC
;
-- ANSWER: There seem to be users with other high contact amounts
-- 1	user_3610	2918
-- 2	user_14239	1785
-- 3	user_14080	1262
-- 4	user_13418	1071
-- 5	user_17906	807

/* 3.6 Are city names inconsitent? */
-- Earlier we saw city names with different spelling so we should just confirm this to see if they belong to different countries

SELECT
  country
  ,city
  ,COUNT(*) AS total_users
FROM `neo-bank-project-509212.raw_data.users`
GROUP BY 1,2
ORDER BY total_users
;
-- ANSWER: Not only do I see cities with multiple formatting conventions but I also see cities as numbers and cities with city and country abbreviation under city column. This is way to complicated to fix with the amount of time allocated for this project. We should definitely leave this out. Our country column is formatted fine with countries abbreviations all uppercase -- I think we can just instead for cleaning have a column with fully spelled out country

-- ----------------------------------------------------------------------------------------------------------------

/* HOW SHOULD STAGED USER TABLE LOOK LIKE NOW BASED ON ALL FINDINGS? */
-- Keep existing age, signup, cohort and plan columns
-- Add country_name; keep original country codes
-- Keep raw city; exclude city_cleaned from our scope
-- Preserve NULL values in marketing opt-in flags
-- Keep original contacts and referral fields
-- Review whether additional customer segments are needed
-- Retain one row per user (19,430 total)
