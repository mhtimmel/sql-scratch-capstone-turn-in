/*** CodeFlix ***/
/* Task1 - Answer: 2 different segments*/
SELECT *
FROM subscriptions
LIMIT 100; 

/* Task2 - Answer: January 2017-March 2017 */
SELECT MIN(subscription_start), MAX(subscription_start)
FROM subscriptions;

/* Task3 - creating months temporary table */
WITH months AS 
(SELECT
	'2017-01-01' AS first_day,
	'2017-01-31' AS last_day
UNION
SELECT
	'2017-02-01' AS first_day,
	'2017-02-28' AS last_day
UNION
SELECT
	'2017-03-01' AS first_day,
	'2017-03-31' AS last_day
),

/* Task4 - creating cross_join temporary table */
cross_join AS
(SELECT subscriptions.*,months.*
FROM subscriptions
CROSS JOIN months),

/* Tasks 5-6 - creating status temporary table, adding is_canceled columns */
status AS
(SELECT 
	id,
	first_day AS month,
	CASE
		WHEN (segment = 87)
			AND (subscription_start < first_day)
 				AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL
        ) THEN 1
		ELSE 0
	END AS is_active_87,
	CASE
		WHEN (segment = 30)
			AND (subscription_start < first_day)
 				AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL
        ) THEN 1
		ELSE 0
	END AS is_active_30,
 	CASE 
 		WHEN (segment = 87)
 			AND (subscription_end BETWEEN first_day AND last_day) THEN 1
 		ELSE 0
	 END AS is_canceled_87,
 	CASE
 		WHEN (segment = 30)
 			AND (subscription_end BETWEEN first_day AND last_day) THEN 1
 		ELSE 0
 	END AS is_canceled_30
	FROM cross_join
),

/* Task 7- creating status_aggregate temporary table */
status_aggregate AS
(SELECT 
 month,
 SUM(is_active_87) AS sum_active_87,
 SUM(is_active_30) AS sum_active_30,
 SUM(is_canceled_87) AS sum_canceled_87,
 SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month)

/* Task8 - calculating churn rate; Answer: segment 30 has a lower churn rate */
SELECT month, 1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87, 1.0 * sum_canceled_30 / sum_active_30 as churn_rate_30
FROM status_aggregate;



/* Task9 - modifying code to support larger number of segments; Answer: see below for updates to status and status_aggregate tables that would achieve this */
WITH...

status AS
(SELECT 
	id,
 	segment,
	first_day AS month,
	CASE
		WHEN (subscription_start < first_day)
 				AND (
        	subscription_end > first_day
        	OR subscription_end IS NULL
        ) THEN 1
		ELSE 0
	END AS is_active,
 	CASE 
 		WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
 		ELSE 0
	 END AS is_canceled
	FROM cross_join
),
status_aggregate AS
(SELECT 
 month,
 segment,
 SUM(is_active) AS sum_active,
 SUM(is_canceled) AS sum_canceled
FROM status
GROUP BY segment, month)
SELECT month, segment, 1.0 * sum_canceled / sum_active AS churn_rate
FROM status_aggregate;  