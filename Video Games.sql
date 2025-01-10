SELECT *
FROM Video_Games$;

---1. WHAT IS THE TOTAL GLOBAL SALES FOR EACH GENRE
SELECT 
	Genre, ROUND(SUM(Global_Sales),2) AS TotalGlobalSales
FROM Video_Games$
GROUP BY Genre
ORDER BY TotalGlobalSales DESC;

---2. HOW MANY VIDEO GAMES HAD ABOVE THE AVERAGE USER SCORE AND COUNT 
SELECT COUNT(NAME)
FROM Video_Games$
WHERE User_Score >
				(SELECT AVG(User_Score)
				 FROM Video_Games$)
	AND User_Count > 
					(SELECT AVG(User_Count)
					FROM Video_Games$);

---3. WHAT ARE THE TOP 3 VIDEOGAMES IN EACH GENRE BY USER COUNT
WITH RankedVideoGames AS (
	SELECT 
		Name AS VideoGame, Genre, User_Count, ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY User_Count DESC) AS ranks
	FROM Video_Games$
)
SELECT VideoGame, Genre
FROM RankedVideoGames
WHERE ranks IN (1,2,3);

---4. HOW DOES VIDEO GAMES CRITIC SCORES INFLUENCES THE GLOBAL SALES 
SELECT ROUND(SUM(Global_Sales),2) AS TotalSales,
CASE 
	WHEN Critic_Score < 50 THEN 'Low Critic'
	ELSE 'High Critic'
END AS Critic
FROM Video_Games$
GROUP BY 
	CASE 
		WHEN Critic_Score < 50 THEN 'Low Critic'
		ELSE 'High Critic'
	END;

---5. WHAT IS THE MOST PREFERRED GAMING PLATFORM FOR EACH GENRE
WITH VideoGamesPlatform AS (
	SELECT 
		Genre, Platform, User_Count, ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY User_Count DESC) AS ranks
	FROM Video_Games$
)
SELECT Genre, Platform
FROM VideoGamesPlatform
WHERE ranks = 1;

---6. WHICH DEVELOPER PRODUCED THE MOST GAMES
SELECT Developer, COUNT(Name) AS NoOfVideoGames
FROM Video_Games$
GROUP BY Developer
ORDER BY NoOfVideoGames DESC;

---7. YEARLY ANALYSIS OF VIDEOGAMES DEVELOPED AND ITS SALES
SELECT Year_of_Release, COUNT(Name) AS NoOfVideoGames, ROUND(SUM(Global_Sales), 2) AS TotalSales
FROM Video_Games$
GROUP BY Year_of_Release
ORDER BY NoOfVideoGames DESC, TotalSales DESC;

---8. WHAT IS THE MOST PLAYED VIDEO GAMES BY RATINGS
WITH Ratings AS (
	SELECT 
		Rating, Name, User_Count, ROW_NUMBER() OVER (PARTITION BY Rating ORDER BY User_Count DESC) AS ranks
	FROM Video_Games$
)
SELECT Rating, Name
FROM Ratings
WHERE ranks = 1;