-- TRANSACTION LEVEL ANALYSIS

USE retail_transaction_data_1;

-- WHAT IS THE DISTRIBUTION OF PAYMENT METHODS (E.G., CASH VS OTHERS IF PRESENT)?
WITH payment_distribution_cte AS (
	SELECT
		PaymentMethod,
		COUNT(*) AS total_transactions
	FROM dbo.retail_data
	GROUP BY PaymentMethod
), total_transactions_cte AS (
	SELECT
		SUM(total_transactions) AS total_count
	FROM payment_distribution_cte
)
SELECT 
	p.PaymentMethod,
	p.total_transactions,
	CAST(p.total_transactions AS FLOAT) / t.total_count * 100 AS total_percent
FROM payment_distribution_cte p
CROSS JOIN total_transactions_cte t
ORDER BY p.total_transactions DESC;
-- OBSERVATION: EVERY PAYMENT METHOD IS EQUALY DISTRIBUTED.

-- HOW DOES TRANSACTION VARY FROM STORE LOCATION?
SELECT
	StoreLocation,
	ROUND(SUM(TotalAmount), 2) AS total_sales
FROM dbo.retail_data
GROUP BY StoreLocation
ORDER BY total_sales DESC;

-- WHAT IS THE PEAK TIME (HOUR/DAY/MONTH) FOR TRANSACTIONS IN DIFFERENT STORE LOCATIONS?
WITH transaction_cte AS (
	SELECT
		StoreLocation,
		DATEPART(HOUR, TransactionDateUpdated) AS trans_hour,
		DATEPART(DAY, TransactionDateUpdated) AS trans_day,
		DATEPART(MONTH, TransactionDateUpdated) AS trans_month
	FROM dbo.retail_data
	GROUP BY StoreLocation, TransactionDateUpdated
),
hourly_sales_cte AS (
	SELECT
		StoreLocation,
		trans_hour,
		COUNT(*) AS hourly_sales,
		ROW_NUMBER() OVER (PARTITION BY StoreLocation ORDER BY COUNT(*) DESC) AS rn_hour
	FROM transaction_cte
	GROUP BY StoreLocation, trans_hour
),
daily_sales_cte AS (
	SELECT
		StoreLocation,
		trans_day,
		COUNT(*) AS daily_sales,
		ROW_NUMBER() OVER (PARTITION BY StoreLocation ORDER BY COUNT(*) DESC) AS rn_day
	FROM transaction_cte
	GROUP BY StoreLocation, trans_day
),
monthly_sales_cte AS (
	SELECT
		StoreLocation,
		trans_month,
		COUNT(*) AS monthly_sales,
		ROW_NUMBER() OVER (PARTITION BY StoreLocation ORDER BY COUNT(*) DESC) AS rn_month
	FROM transaction_cte
	GROUP BY StoreLocation, trans_month
)
SELECT
	h.StoreLocation,
	h.trans_hour AS peak_hour,
	d.trans_day AS peak_day,
	m.trans_month AS peak_month
FROM hourly_sales_cte h
JOIN daily_sales_cte d ON h.StoreLocation = d.StoreLocation
JOIN monthly_sales_cte m ON  d.StoreLocation = m.StoreLocation
WHERE h.rn_hour = 1 AND rn_day = 1 AND rn_month = 1;