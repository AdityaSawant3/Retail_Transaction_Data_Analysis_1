-- SALES AND REVENUE INSIGHT.

USE retail_transaction_data_1;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail_data';

SELECT TOP 10 * FROM dbo.retail_data;

-- WHAT ARE THE TOTAL REVENUE GENERATED OVER TIME (MONTHLY)?
SELECT 
	YEAR(TransactionDateUpdated) AS year,
	MONTH(TransactionDateUpdated) AS month,
	ROUND(SUM(TotalAmount), 2) AS net_revenue
FROM dbo.retail_data
GROUP BY YEAR(TransactionDateUpdated), MONTH(TransactionDateUpdated)
ORDER BY year, month
-- OBSERVATION: SALES TEND TO INCREASE IN 2023 BUT FOR DURING IT'S ENDING IT DECREASES.

-- WHAT ARE THE TOTAL REVENUE GENERATED OVER TIME (QUARTERLY)?
SELECT 
	YEAR(TransactionDateUpdated) AS year,
	DATEPART(QUARTER, TransactionDateUpdated) AS quarter,
	ROUND(SUM(TotalAmount), 2) AS net_revenue
FROM dbo.retail_data
GROUP BY YEAR(TransactionDateUpdated), DATEPART(QUARTER, TransactionDateUpdated)
ORDER BY year, quarter
-- OBSERVATION: SALES INCREASES PER 1-3 QUARTER (2023) BUT DECREASES IN 2 QUARTER (2024).


-- WHICH PRODUCTS CATEGORY GENERATE THE HIGHEST TOTAL SALES REVENUE?
SELECT 
	ProductCategory,
	ROUND(SUM(TotalAmount), 2) AS net_revenue
FROM dbo.retail_data
GROUP BY ProductCategory
ORDER BY net_revenue DESC;
-- OBSERVATION: BOOKS CATEGORY GENERATED HIGHEST REVENUE.

-- WHICH PRODUCTS CATEGORY GENERATE THE HIGHEST TOTAL SALES REVENUE?
SELECT 
	ProductID,
	ROUND(SUM(TotalAmount), 2) AS net_revenue
FROM dbo.retail_data
GROUP BY ProductID
ORDER BY net_revenue DESC;

-- WHAT ARE THE MEDIAN TRANSACTION VALUE ACROSS ALL CATEGORIES.
WITH median_revenue_by_category AS (
	SELECT 
		ProductCategory,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ROUND(TotalAmount, 2)) OVER(PARTITION BY ProductCategory) AS median_revenue,
		ROW_NUMBER() OVER(PARTITION BY ProductCategory ORDER BY ProductCategory) AS rn
	FROM dbo.retail_data
)
SELECT ProductCategory, median_revenue
FROM median_revenue_by_category
WHERE rn = 1
ORDER BY median_revenue DESC
-- OBSERVATION: BASICALLY, THERE IS NOT A HUGE DIFFERENCE BETWEEN EACH CATEGORY MEDIAN VALUES.

-- HOW MUCH REVENUE LOST DUE TO DISCOUNT BY YEAR?
WITH revenue_affected_by_discount_cte AS (
	SELECT
		YEAR(TransactionDateUpdated) AS year,
		ProductCategory,
		TotalAmount AS revenue_without_discount,
		TotalAmount - (DiscountApplied * TotalAmount / 100) AS revenue_with_discount_applied
	FROM dbo.retail_data
)
SELECT 
	year,
	ProductCategory,
	ROUND(SUM(revenue_without_discount), 2) AS net_revenue_without_discount,
	ROUND(SUM(revenue_with_discount_applied), 2) AS net_revenue_with_discount,
	ROUND(SUM(revenue_without_discount) - SUM(revenue_with_discount_applied), 2) AS revenue_lost
FROM revenue_affected_by_discount_cte
GROUP BY year, ProductCategory
ORDER BY revenue_lost DESC;
-- OBSERVATION: ELECTRONICS GETS MORE DISCOUNT IN F.Y.2023. F.Y.2024 DATA IS NOT SUFFICIENT.

-- WHAT ARE THE EFFECT OF DISCOUNTS ON QUANTITY SOLD OR REVENUE?
SELECT 
	CASE
		WHEN ROUND(DiscountApplied,0) <= 0 THEN 'No Discount'
		WHEN ROUND(DiscountApplied,0) BETWEEN 0 AND 5 THEN 'Low Discount (0-5%)'
		WHEN ROUND(DiscountApplied,0) BETWEEN 5 AND 15 THEN 'Medium Discount (5%-15%)'
		WHEN ROUND(DiscountApplied,0) BETWEEN 15 AND 25 THEN 'High Discount (15%-25%)'
		ELSE 'High Discount (>25%)'
	END AS discount_range,
	SUM(Quantity) AS total_quantity
FROM dbo.retail_data
GROUP BY
	CASE
		WHEN ROUND(DiscountApplied,0) <= 0 THEN 'No Discount'
		WHEN ROUND(DiscountApplied,0) BETWEEN 0 AND 5 THEN 'Low Discount (0-5%)'
		WHEN ROUND(DiscountApplied,0) BETWEEN 5 AND 15 THEN 'Medium Discount (5%-15%)'
		WHEN ROUND(DiscountApplied,0) BETWEEN 15 AND 25 THEN 'High Discount (15%-25%)'
		ELSE 'High Discount (>25%)'
	END
ORDER BY total_quantity DESC;
-- OBSERVATION: MOST OF THE QUANTITIES SOLD WITH 5%-15% DISCOUNT.