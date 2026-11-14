/* INTERMEDIATE MODEL */
-- In this modeling layer, we will create an intermediate model that combines the staged user data with the staged transaction data to analyze user lifecycle and engagement
/* VIEW TO BE CREATED: int_user_lifecycle */
/* TABLES TO USE: 
      -- `neo-bank-project-509212.staging.stg_users`

      -- `neo-bank-project-509212.staging.stg_transactions`
      */


/* HOW SHOULD INTERMEDIATE USER LIFECYCLE TABLE LOOK LIKE NOW BASED ON ALL FINDINGS? */
--  Only COMPLETED transactions are considered valid activity
-- Include CARD_PAYMENT, TRANSFER, TOPUP, EXCHANGE, and ATM
--  Transaction amount must be greater than $0.01
--  Include users who have never made a valid transaction

CREATE OR REPLACE VIEW `neo-bank-project-509212.intermediate.int_user_lifecycle` AS(
SELECT
  users.user_id
  ,users.signup_date
  ,users.signup_day
  ,users.cohort_month
    /*USING FIRST AND MOST RECENT VALID TRANSACTION DATES*/
  ,MIN(transactions.created_date) AS first_transaction_at
  ,MAX(transactions.created_date) AS last_transaction_at
    /*FIRST FUNDING DATE (includes TOPUP or an inbound TRANSFER)*/
  ,MIN(IF(transactions.transactions_type = 'TOPUP'OR (transactions.transactions_type = 'TRANSFER'AND transactions.direction = 'INBOUND'),transactions.created_date, NULL)) AS first_funding_at
    /*FIRST CARD PAYMENT DATE (only outbound CARD_PAYMENT transactions are included and returns NULL if the user has never made a card payment*/
  ,MIN(IF(transactions.transactions_type = 'CARD_PAYMENT'AND transactions.direction = 'OUTBOUND',transactions.created_date, NULL)) AS first_card_payment_at
    /*DAYS BETWEEN SIGNUP AND FIRST TRANSACTION*/
  ,DATE_DIFF(DATE(MIN(transactions.created_date)),users.signup_day,DAY) AS days_to_first_transaction
    /*HOURS BETWEEN SIGNUP AND FIRST ACTIVITY*/
  ,TIMESTAMP_DIFF(MIN(transactions.created_date),users.signup_date,HOUR) AS hours_to_first_transaction
    /*FLAGGING USERS WHO HAVE COMPLETED AT LEAST ONE VALID TRANSACTION*/
  ,MIN(transactions.created_date) IS NOT NULL AS has_transacted
FROM `neo-bank-project-509212.staging.stg_users` AS users
LEFT JOIN `neo-bank-project-509212.staging.stg_transactions` AS transactions 
ON users.user_id = transactions.user_id
  AND transactions.transactions_state = "COMPLETED"
  AND transactions.transactions_type IN ("CARD_PAYMENT","TRANSFER","TOPUP","EXCHANGE","ATM")
  AND transactions.amount_usd > 0.01
GROUP BY users.user_id, users.signup_date, users.signup_day, users.cohort_month
)
;

/* DATA QUALITY CHECK IF EVERYTHING WAS DONE CORRECTLY */
/*TOTAL AND UNIQUE USERS SHOULD MATCH SAME AMOUNT FROM stg_users*/
SELECT
  COUNT(*) AS total_users
  ,COUNT(DISTINCT user_id) AS unique_users
  ,COUNTIF(has_transacted = FALSE) AS never_transacted
FROM `neo-bank-project-509212.intermediate.int_user_lifecycle`
;

/*YES, ALL GOOD! */
