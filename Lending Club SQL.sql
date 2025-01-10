---VIEWING THE ENTIRE DATASET
SELECT *
FROM LendingData;

---LOAN STATUS DISTRIBUTION
SELECT loan_status, COUNT(loan_status)
FROM LendingData
GROUP BY loan_status;

---RESEARCH QUESTIONS
---1. WHICH BORROWER'S PROFILES POSES THE HIGHEST RISK DEFAULT
WITH BorrowerProfile AS (
	SELECT emp_title, emp_length, home_ownership, SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults
	FROM LendingData
	GROUP BY emp_title, emp_length, home_ownership
)
SELECT emp_title, emp_length, home_ownership
FROM BorrowerProfile
WHERE Defaults > 100;

---2. HOW DOES LOAN ATTRIBUTES AFFECT DEFAULT LIKELIHOOD
SELECT term, 
	CASE 
		WHEN loan_amnt < 10000 THEN 'Low Loan'
		WHEN loan_amnt < 20000 THEN 'Moderate Loan'
		ELSE 'High Loan'
	END AS LoanAmount,
	SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults
FROM LendingData
GROUP BY term, CASE 
		WHEN loan_amnt < 10000 THEN 'Low Loan'
		WHEN loan_amnt < 20000 THEN 'Moderate Loan'
		ELSE 'High Loan'
	END 
ORDER BY term;

---3. TOP 3 LOAN PURPOSE HAVING THE HIGHEST DEFAULTS IN EACH GRADE
WITH FirstTable AS (
	SELECT grade, purpose, SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults
	FROM LendingData
	GROUP BY grade, purpose
	), 
SecondTable AS (
	SELECT grade, purpose, Defaults, ROW_NUMBER() OVER (PARTITION BY grade ORDER BY Defaults DESC) AS Ranks
	FROM FirstTable
)
SELECT grade, purpose, Defaults
FROM SecondTable
WHERE Ranks IN (1, 2, 3);

---4. THE AVERAGE INTEREST RATES FOR LOANS THAT DEFAULTED COMPARED TO THOSE THAT DIDN'T
SELECT loan_status, AVG(int_rate) AS AvgInterestRate
FROM LendingData
GROUP BY loan_status;

---5. HOW DEFAULT RATES CHANGED OVER TIME
SELECT DATENAME(MONTH, issue_d) AS Issue_Month, COUNT(*) AS TotalLoans,
	SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults,
	CONCAT(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100 / COUNT(*), '%') AS DefaultRate
FROM LendingData
GROUP BY DATENAME(MONTH, issue_d)
ORDER BY Defaults DESC;

---6. DOES DEFAULT RISK INCREASE WITH HIGH NUMBER OF BORROWERS OPEN CREDIT LINE
SELECT open_acc, SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults
FROM LendingData
GROUP BY open_acc
ORDER BY open_acc DESC;

---7. ARE HIGHER DEFAULT RISK ASSOCIATED BASED ON BORROWER'S PUBLIC RECORDS
WITH Records1 AS (
	SELECT pub_rec, pub_rec_bankruptcies, 
		SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Defaults
	FROM LendingData
	GROUP BY pub_rec, pub_rec_bankruptcies
),
Records2 AS (
	SELECT pub_rec, pub_rec_bankruptcies, Defaults,
		ROW_NUMBER() OVER (PARTITION BY pub_rec_bankruptcies ORDER BY Defaults DESC) AS Ranks
	FROM Records1
)
SELECT pub_rec, pub_rec_bankruptcies, Defaults
FROM Records2
WHERE Ranks < 4;