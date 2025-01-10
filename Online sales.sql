---CHECKING THE ENTIRE DATASET
SELECT	*
FROM online_sales_dataset$;

DELETE
FROM online_sales_dataset$
WHERE Quantity < 0;---DROPPING THE NEGATIVE VALUES IN THE QUANTITY COLUMN

---CREATING A REVENUE COLUMN
ALTER TABLE 
	online_sales_dataset$
ADD Revenue AS 
	((Quantity * UnitPrice * (1 - Discount)) + ShippingCost);

---SALES ANALYSIS
----1. WHAT IS THE TOTAL REVENUE BY YEAR 
SELECT 
	YEAR(InvoiceDate) AS SalesYear, ROUND(SUM(Revenue), 2) AS TotalRevenue
FROM online_sales_dataset$
GROUP BY YEAR(InvoiceDate)
ORDER BY TotalRevenue DESC;

---2. WHICH MONTH GENERATED THE HIGHEST AND LOWEST REVENUE
WITH MonthRenevenue AS (  ---FINDING THE TOTAL REVENUE MADE IN EACH MONTH
	SELECT 
		DATENAME(MONTH, InvoiceDate) AS SalesMonth, ROUND(SUM(Revenue), 2) AS TotalRevenue
	FROM online_sales_dataset$
	GROUP BY DATENAME(MONTH, InvoiceDate)
), 
Ranking AS (  ---SORTING THE REVENUE BY ITS ROW NUMBER
	SELECT 
		SalesMonth, TotalRevenue, ROW_NUMBER() OVER (ORDER BY TotalRevenue DESC) AS Ranks
	FROM MonthRenevenue
)
SELECT 
	SalesMonth, TotalRevenue
FROM Ranking
WHERE Ranks IN (1, 12)
ORDER BY Ranks;

---3. WHAT IS THE AVERAGE ORDER VALUE OVER TIME
---AVERAGE ORDER VALUE BY DAY
SELECT 
	CAST(InvoiceDate AS DATE) AS OrderDay,
	COUNT(InvoiceNo) AS TotalOrders,
	ROUND(SUM(Revenue), 2) AS TotalSales,
	SUM(Quantity) AS TotalQuantities,
	ROUND(AVG(Revenue), 2) AS Avg_Order_Value
FROM online_sales_dataset$
GROUP BY CAST(InvoiceDate AS DATE)
ORDER BY OrderDay;

---AVERAGE ORDER VALUE BY MONTH
SELECT 
	FORMAT(InvoiceDate, 'yyyy-MM') AS OrderMonth,
	COUNT(InvoiceNo) AS TotalOrders,
	ROUND(SUM(Revenue), 2) AS TotalSales,
	SUM(Quantity) AS TotalQuantities,
	ROUND(AVG(Revenue), 2) AS Avg_Order_Value
FROM online_sales_dataset$
GROUP BY FORMAT(InvoiceDate, 'yyyy-MM')
ORDER BY OrderMonth;

----4. WHAT ARE THE REVENUES GENERATED FROM EACH CATEGORY AND WHICH PERFORMED BETTER AND LEAST
SELECT
	Category, ROUND(SUM(Revenue), 2) AS TotalRevenue, RANK() OVER (ORDER BY ROUND(SUM(Revenue), 2) DESC) AS Ranks
FROM online_sales_dataset$
GROUP BY Category;

---5. WHO ARE THE TOP PERFORMING SALES CHANNELS OR REGIONS
SELECT
	SalesChannel, ROUND(SUM(Revenue), 2) AS TotalSales
FROM online_sales_dataset$
GROUP BY SalesChannel
ORDER BY TotalSales DESC;

---TOP 3 PERFORMING COUNTRIES
SELECT
	TOP 3 Country, ROUND(SUM(Revenue), 2) AS TotalSales
FROM online_sales_dataset$
GROUP BY Country
ORDER BY TotalSales DESC;

---6. HOW DOES DISCOUNT AFFECT SALES VOLUME AND REVENUE
SELECT
	SUM(Quantity) AS SalesVolume, ROUND(SUM(Revenue),2) AS TotalSales, COUNT(DISTINCT InvoiceNo) AS TotalOrders,
	CASE
		WHEN Discount = 0 THEN 'No Discount'
		WHEN Discount BETWEEN 0.01 AND 0.25 THEN '1-25%'
		WHEN Discount BETWEEN 0.26 AND 0.5 THEN '26-50%'
		ELSE 'Above 50%'
	END AS DiscountRange
FROM online_sales_dataset$
GROUP BY 
	CASE
		WHEN Discount = 0 THEN 'No Discount'
		WHEN Discount BETWEEN 0.01 AND 0.25 THEN '1-25%'
		WHEN Discount BETWEEN 0.26 AND 0.5 THEN '26-50%'
		ELSE 'Above 50%'
	END 
ORDER BY DiscountRange;

---7. ARE THERE PRODUCTS THAT ARE PERFORMING BETTER WITHOUT DISCOUNT
SELECT
	Category, ROUND(SUM(Revenue),2) AS TotalSales,
	CASE
		WHEN Discount > 0 THEN 'Discounted'
		ELSE 'No Discount'
	END AS DiscountRange
FROM online_sales_dataset$
GROUP BY Category,
	CASE
		WHEN Discount > 0 THEN 'Discounted'
		ELSE 'No Discount'
	END 
ORDER BY Category, TotalSales DESC;

---CUSTOMER BEHAVIOR ANALYSIS
----1. WHAT IS THE COUNT OF THE MOST VALUABLE CUSTOMERS BY RFM
WITH RFM AS (
	SELECT
		CustomerID, DATEDIFF(DAY, MAX(InvoiceDate), '2025-09-05') AS Recency,
		COUNT(InvoiceNo) AS Frequency, SUM(Revenue) AS Monetary
	FROM online_sales_dataset$
	WHERE CustomerID IS NOT NULL
	GROUP BY CustomerID
),
RFM_Scored AS(
	SELECT
		CustomerID, Recency, Frequency, Monetary,
		NTILE(4) OVER (ORDER BY Recency ASC) AS RecencyScore,
		NTILE(4) OVER (ORDER BY Frequency DESC) AS FrequencyScore,
		NTILE(4) OVER (ORDER BY Monetary DESC) AS MonetaryScore
	FROM RFM
), SUM_RFM AS (
	SELECT
		CustomerID, Recency, Frequency, Monetary,
		(RecencyScore + FrequencyScore + MonetaryScore) AS TotalRFM
	FROM RFM_Scored
),
Rankings AS (
	SELECT
		CustomerID, Recency, Frequency, Monetary, TotalRFM,
		RANK() OVER (ORDER BY TotalRFM DESC) AS Ranks
	FROM SUM_RFM
)
SELECT
	COUNT(CustomerID) AS No_Of_Valuable_Customers	
FROM Rankings
WHERE Ranks = 1;

---2. HOW CAN CUSTOMERS BE GROUPED BASED ON PURCHASING BEHAVIOR
WITH Spendings AS (
	SELECT 
		CustomerID, 
		CASE
			WHEN AVG(Revenue) < 1000 THEN 'Low Spender'
			WHEN AVG(Revenue) BETWEEN 1000 AND 2000 THEN 'Moderate Spender'
			ELSE 'High Spender'
		END AS 'Purchasing Behavior'
	FROM online_sales_dataset$
	GROUP BY CustomerID
)
SELECT 
	[Purchasing Behavior], COUNT([Purchasing Behavior]) AS Frequency
FROM Spendings
GROUP BY [Purchasing Behavior];
	
---3. WHAT IS THE MOST PREFERRED MODE OF PAYMENT
SELECT 
	PaymentMethod, COUNT(PaymentMethod) AS Frequency
FROM online_sales_dataset$
GROUP BY PaymentMethod
ORDER BY Frequency DESC;

----ORDER MANAGEMENT ANALYSIS
----1. WHICH PRODUCT CATEGORY RECEIVES THE MOST ORDERS
SELECT 
	Category, COUNT(DISTINCT InvoiceNo) AS No_Of_Orders
FROM online_sales_dataset$
GROUP BY Category
ORDER BY No_Of_Orders DESC;

---2. WHAT IS THE MOST RECEIVED ORDER PRIORITY AND ITS TOP 2 CATEGORIES
WITH Most_OrderPriority AS (
	SELECT 
		TOP 1 OrderPriority, COUNT(OrderPriority) AS Frequency
	FROM online_sales_dataset$
	GROUP BY OrderPriority
	ORDER BY Frequency DESC
), 
Categories AS (
	SELECT 
		OrderPriority, Category, COUNT(Category) AS Frequency
	FROM online_sales_dataset$
	GROUP BY OrderPriority, Category
)
SELECT 
	TOP 2 m.OrderPriority, c.Category
FROM Categories AS c
JOIN Most_OrderPriority AS m
ON c.OrderPriority = m.OrderPriority
ORDER BY c.Frequency DESC;

---3. ARE HIGH SALES PRODUCTS ALSO THE MOST FREQUENTLY RETURNED GOODS
SELECT 
	Description, ROUND(SUM(Revenue), 2) AS TotalSales, COUNT(ReturnStatus) AS Returned_count
FROM online_sales_dataset$
WHERE ReturnStatus = 'Returned'
GROUP BY Description
ORDER BY TotalSales DESC, Returned_count DESC;

---4. WHAT IS THE MOST PREFERRED SHIPMENT PROVIDER
SELECT
	ShipmentProvider, COUNT(ShipmentProvider) AS Frequency
FROM online_sales_dataset$
GROUP BY ShipmentProvider
ORDER BY Frequency DESC;