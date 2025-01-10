---VIEWING THE TABLES
SELECT *
FROM pizza_sales$;

---UNIVARIATE ANALYSIS
SELECT order_id, COUNT(order_id) AS Frequency
FROM pizza_sales$
GROUP BY order_id
ORDER BY Frequency DESC;  ---A TOTAL OF 21,350 PIZZA ORDERS WERE MADE AND ORDER_ID 18845 AND 10760 PLACED THE MOST ORDERS

SELECT quantity, COUNT(quantity) AS Frequency
FROM pizza_sales$
GROUP BY quantity
ORDER BY Frequency DESC; ---4 WAS THE MAXIMUM QUANTITY OF PIZZAS ORDERED BUT IT WAS THE LEAST AMOUNT ORDERED

SELECT DATENAME(MONTH, order_date) AS Order_month, COUNT(DATENAME(MONTH, order_date)) AS Frequency
FROM pizza_sales$
GROUP BY DATENAME(MONTH, order_date)
ORDER BY Frequency DESC;  ---JULY HAD THE MOST PIZZA ORDERS BUT IT CAN BE SEEN THAT SIGNIFICANT NUMBER OF ORDERS WERE MADE IN ALL THE MONTHS

SELECT AVG(total_price) AS Avg_total_price
FROM pizza_sales$;  ---AN AVERAGE OF 16.82 THOUSAND WAS MADE IN SALES

SELECT pizza_size, COUNT(pizza_size) AS Frequency
FROM pizza_sales$
GROUP BY pizza_size
ORDER BY Frequency DESC;  ---THERE ARE 5 DIFFERENT PIZZA SIZES WITH LARGE(L) BEING THE MOST ORDERED AND XXL BEING THE LEAST ORDERED

SELECT pizza_category, COUNT(pizza_category) AS Frequency
FROM pizza_sales$
GROUP BY pizza_category
ORDER BY Frequency DESC;  ---CLASSIC WAS THE MOST PREFERRED CATEGORY. IT CAN ALSO BE SEEN THAT EVERY OTHER CATEGORY WAS ALSO SIGNIFICANTLY PREFERRED

SELECT pizza_name, COUNT(pizza_name) AS Frequency
FROM pizza_sales$
GROUP BY pizza_name
ORDER BY Frequency DESC; ---THERE ARE 32 DIFFERENT KINDS OF PIZZA WITH 'THE CLASSIC DELUXE PIZZA' BEING THE MOST ORDERED AND 'THE BRIE CARRE PIZZA' BEING THE LEAST ORDERED

---ANALYSIS
---1. WHAT ARE THE TOP 5 PIZZAS BY SALES AND QUANTITY
SELECT TOP 5 pizza_name, SUM(total_price) AS Total_Sales ,MAX(quantity) AS Max_ordered
FROM pizza_sales$
GROUP BY pizza_name
ORDER BY Total_Sales DESC, Max_ordered DESC;

---2. WHICH MONTH HAD THE MOST SALES AND WHAT WAS IT'S TOP 3 PRODUCT
WITH SALES_MONTH AS ( ---FINDING THE MONTH WITH THE HIGHEST SALES
	SELECT TOP 1 DATENAME(MM, order_date) AS Month_name, ROUND(SUM(total_price), 2) AS Total_sales
	FROM pizza_sales$
	GROUP BY DATENAME(MM, order_date)
	ORDER BY Total_sales DESC
	), 
Rankings AS(  ---FINDING THE TOP 5 PRODUCTS SOLD DURING THAT MONTH
	SELECT DATENAME(MM, order_date) AS Month_name, pizza_name,
		SUM(quantity) AS total_quantities_ordered
	FROM pizza_sales$
	GROUP BY DATENAME(MM, order_date), pizza_name
) 
SELECT TOP 3 r.Month_name, pizza_name, r.total_quantities_ordered
FROM SALES_MONTH AS sm
JOIN Rankings AS r
ON sm.Month_name = r.Month_name
ORDER BY r.total_quantities_ordered DESC;

---3. HOW DOES THE PIZZA SIZE INFLUENCES THE SALES
SELECT pizza_size, COUNT(pizza_size) AS Frequency, ROUND(SUM(total_price), 2) AS Total_sales
FROM pizza_sales$
GROUP BY pizza_size
ORDER BY Total_sales DESC;

---4. WHAT IS THE MOST PREFERRED PIZZA CATEGORY SIZE BY QUANTITY ORDERED
WITH CategorySize AS (
	SELECT pizza_category, pizza_size, SUM(quantity) AS Total_quantity_ordered
	FROM pizza_sales$
	GROUP BY pizza_category, pizza_size
	), 
Ranking AS (
	SELECT pizza_size, pizza_category, Total_quantity_ordered, 
	RANK() OVER (PARTITION BY pizza_size ORDER BY Total_quantity_ordered DESC) AS Ranks
	FROM CategorySize
)
SELECT pizza_size, pizza_category, Total_quantity_ordered, Ranks
FROM Ranking
WHERE Ranks = 1
ORDER BY pizza_size;

---5. WHICH PIZZA CATEGORY MADE MORE THAN 25% OF THE TOTAL REVENUE
SELECT pizza_category, SUM(total_price) AS Total_sales
FROM pizza_sales$
GROUP BY pizza_category
HAVING SUM(total_price) > 0.25 *
							(SELECT SUM(total_price)
							 FROM pizza_sales$);