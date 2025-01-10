---VIEWING ALL ENTIRE DATASET
SELECT * 
FROM creditcard;

---QUESTIONS
---1. WHAT IS THE TOTAL NUMBER OF FRAUDULENT AND NON FRADULENT TRANSACTION
SELECT 
	Class, COUNT(Class) AS Class_Frequency
FROM creditcard
GROUP BY Class;

---2. WHAT IS THE PERCENTAGE OF FRAUDULENT TRANSACTIONS
SELECT 
	(CAST(SUM(CASE WHEN Class = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS Fraud_Percentage
FROM creditcard;

---3. WHAT IS THE PERCENTAGE OF NON-FRAUDULENT TRANSACTIONS
SELECT 
	(CAST(SUM(CASE WHEN Class = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS NonFraud_Percentage
FROM creditcard;

---4. WHAT ARE THE 5 HIGHEST FRAUDULENT AMOUNT
SELECT 
	TOP 5 Amount
FROM creditcard
WHERE Class = 1
ORDER BY Amount DESC;

---5. DESCRIPTIVE SUMMARY OF AMOUNT FOR FRAUDULENT AND NON-FRAUDULENT TRANSACTIONS
SELECT 
	Class, MAX(Amount) AS Max_Amount, MIN(Amount) AS Min_Amount, AVG(Amount) AS Avg_Amount
FROM creditcard
GROUP BY Class;