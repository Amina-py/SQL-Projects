SELECT *
FROM Churn_Modelling;

---1. ARE THERE MORE CHURNED CUSTOMERS
SELECT Exited, COUNT(Exited)
FROM Churn_Modelling
GROUP BY Exited;

---2. WHICH CUSTOMER DEMOGRAPHICS ARE MOST LIKELY TO CHURN BASED ON GEOGRAPHY AND GENDER
WITH Cus_Demograph AS (
	SELECT Geography, Gender, SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned
	FROM Churn_Modelling
	GROUP BY Geography, Gender
),
Ranks_Demograph AS (
	SELECT Geography, Gender, Churned, ROW_NUMBER() OVER (PARTITION BY GEOGRAPHY ORDER BY Churned DESC) AS Ranks
	FROM Cus_Demograph
)
SELECT Geography, Gender
FROM Ranks_Demograph
WHERE Ranks = 1;

---3. WHICH CUSTOMER DEMOGRAPHICS ARE MOST LIKELY TO CHURN BASED ON GENDER AND AGE
WITH Cust_Demograph AS (
	SELECT Gender,
		CASE WHEN Age BETWEEN 18 AND 30 THEN 'Young Adult'
			 WHEN  Age BETWEEN 31 AND 55 THEN 'Adults'
			 ELSE 'Seniors'
		END AS 'Age Group',
		SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS 'Churned'
	FROM Churn_Modelling
	GROUP BY Gender, 
		CASE WHEN Age BETWEEN 18 AND 30 THEN 'Young Adult'
			 WHEN  Age BETWEEN 31 AND 55 THEN 'Adults'
			 ELSE 'Seniors'
		END
),
Ranked_Demograph AS (
	SELECT Gender, [Age Group], Churned, ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY Churned DESC) AS Ranks
	FROM Cust_Demograph
)
SELECT Gender, [Age Group]
FROM Ranked_Demograph
WHERE Ranks = 1;

--4.HOW DOES CUSTOMERS SALARIES AND BALANCES INFLUENCES CHURNING
WITH Sal_Bal_Customers AS (
	SELECT
		CASE WHEN Balance = 0 THEN 'No Balance'
			 WHEN Balance BETWEEN 1 AND 100000 THEN 'Low Balance'
			 ELSE 'High Balance'
		END AS 'Balance Group',
		CASE WHEN EstimatedSalary < 50000 THEN 'Low Salary'
			 WHEN EstimatedSalary < 100000 THEN 'Moderate Salary'
			 ELSE 'High Salary'
		END AS 'Salary Group',
		SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned
	FROM Churn_Modelling
	GROUP BY 
		CASE WHEN Balance = 0 THEN 'No Balance'
			 WHEN Balance BETWEEN 1 AND 100000 THEN 'Low Balance'
			 ELSE 'High Balance'
		END,
		CASE WHEN EstimatedSalary < 50000 THEN 'Low Salary'
			 WHEN EstimatedSalary < 100000 THEN 'Moderate Salary'
			 ELSE 'High Salary'
		END
),
Ranking AS (
	SELECT [Balance Group], [Salary Group], Churned, RANK() OVER (ORDER BY Churned DESC) AS Ranks
	FROM Sal_Bal_Customers
)
SELECT [Balance Group], [Salary Group], Churned
FROM Ranking
WHERE Ranks < 6;

---5. DOES HIGH CREDIT SCORE INFLUENCES INCREASE IN CHURN RATE
SELECT 
	CASE WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor Credit'
		 WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair Credit'
		 WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good Credit'
		 WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good Credit'
		 ELSE 'Excellent Credit'
	END AS 'CreditScore Group',
	SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned
FROM Churn_Modelling
GROUP BY 
	CASE WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor Credit'
		 WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair Credit'
		 WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good Credit'
		 WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good Credit'
		 ELSE 'Excellent Credit'
	END
ORDER BY Churned DESC;

---6. ARE THERE HIGHER CHURN RATES FROM NEW CUSTOMERS THAN OLD CUSTOMERS
SELECT 
	CASE WHEN Tenure BETWEEN 0 AND 2 THEN 'New Customers'
		 ELSE 'Old Customers'
	END AS 'Tenure Group', 
	SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned
FROM Churn_Modelling
GROUP BY 
	CASE WHEN Tenure BETWEEN 0 AND 2 THEN 'New Customers'
		 ELSE 'Old Customers'
	END;

---7. HOW DOES THE CUSTOMER BANK ACTIVITY INFLUENCE CHURNING RATES
WITH Cust_Activ AS (
	SELECT NumOfProducts, IsActiveMember, SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned
	FROM Churn_Modelling
	GROUP BY NumOfProducts, IsActiveMember
),
Rankings AS (
	SELECT NumOfProducts, IsActiveMember,Churned, ROW_NUMBER() OVER (PARTITION BY IsActiveMember ORDER BY Churned DESC) AS Ranks
	FROM Cust_Activ
)
SELECT IsActiveMember, NumOfProducts, Churned
FROM Rankings
WHERE Ranks < 3;