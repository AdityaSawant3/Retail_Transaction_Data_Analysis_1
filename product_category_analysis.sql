-- PRODUCT AND CATEGORY PERFORMANCE.

USE retail_transaction_data_1;

-- WHICH PRODUCT CATEGORY HAS THE HIGHEST AVERAGE DISCOUNT APPLIED?
WITH product_category_cte AS (
	SELECT 
		ProductCategory,
		ROUND(AVG(DiscountApplied), 2) AS avg_sales
	FROM dbo.retail_data
	GROUP BY ProductCategory
)
SELECT 
	ProductCategory, avg_sales
FROM product_category_cte
ORDER BY avg_sales DESC;

-- WHAT IS THE TOTAL QUANTITY SOLD BY PRODUCT AND BY PRODUCT CATEGORY?
SELECT 
	ProductCategory,
	ProductID,
	SUM(Quantity) AS total_quantity_sold
FROM dbo.retail_data
GROUP BY ProductCategory, ProductID
ORDER BY total_quantity_sold DESC

-- ARE THERE SEASONAL TRENDS IN THE SALES OF PARTICULAR CATEGORIES?
SELECT
	YEAR(TransactionDateUpdated) AS year,
	ProductCategory,
	DATEPART(QUARTER, TransactionDateUpdated) AS quarter,
	SUM(Quantity) AS total_quantity_sold
FROM dbo.retail_data
GROUP BY 
	YEAR(TransactionDateUpdated), 
	ProductCategory, 
	DATEPART(QUARTER, TransactionDateUpdated)
ORDER BY YEAR(TransactionDateUpdated), ProductCategory;