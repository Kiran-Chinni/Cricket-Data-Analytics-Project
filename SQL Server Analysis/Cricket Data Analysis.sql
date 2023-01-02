USE [Cricket_Data_Analytics]
GO

SELECT * FROM [dbo].[fact_batting]

---1. Total number of runs scored (by the batsman)

SELECT bat.batsmanName, SUM(bat.runs) AS Total_Runs
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12' 
GROUP BY bat.batsmanName
ORDER BY SUM(runs) DESC


--2. Total number of innings a batsman got a chance to bat

SELECT bat.batsmanName, count(bat.matchid) as Total_Innings_Batted
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12' 
GROUP BY bat.batsmanName
ORDER BY count(bat.matchid) DESC


--3. number of innings batsman got out

SELECT bat.batsmanName, SUM(bat.out) as Total_Innings_Dismissed 
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY SUM(bat.out) DESC


--4. Average runs scored in an innings

SELECT bat.batsmanName, 
CASE
	WHEN SUM(bat.out) = 0  THEN 0
	ELSE CAST(SUM(bat.runs) AS float)/CAST(SUM(bat.out) AS float) 
	END as Batting_Average 
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY CASE
			WHEN SUM(bat.out) = 0  THEN 0
			ELSE CAST(SUM(bat.runs) AS float)/CAST(SUM(bat.out) AS float) 
			END DESC


--5. Total number of balls faced by the batsman

SELECT bat.batsmanName, SUM(bat.balls) as Total_balls_Faced
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY SUM(bat.balls) DESC


--6. No of runs scored per 100 balls 

SELECT bat.batsmanName,
SUM(CAST(bat.runs AS float))/NULLIF(SUM(CAST(bat.balls AS float)), 0) *100 as [Batting_S/R]
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY SUM(CAST(bat.runs AS float))/NULLIF(SUM(CAST(bat.balls AS float)), 0) *100 DESC


--7. Batting position of a player

SELECT bat.batsmanName, AVG(FLOOR(bat.battingPos)) as Batting_Position
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY AVG(FLOOR(bat.battingPos)) ASC


--8. Percentage of runs scored in boundaries by the Batsman

SELECT bat.batsmanName, 
SUM(CAST(bat.fours*4 AS FLOAT) + CAST(bat.sixes*6 AS FLOAT))/NULLIF(CAST(SUM(bat.runs) AS FLOAT), 0) * 100 as [Boundary_%]
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY SUM(CAST(bat.fours*4 AS FLOAT) + CAST(bat.sixes*6 AS FLOAT))/NULLIF(CAST(SUM(bat.runs) AS FLOAT), 0) * 100 DESC


--9. Average balls faced by the batter in an innings

SELECT bat.batsmanName, AVG(bat.balls) as AVG_Balls_Faced
FROM [dbo].[fact_batting] bat
JOIN [dbo].[dim_match] mat
ON bat.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bat.batsmanName
ORDER BY AVG(bat.balls) DESC


SELECT * FROM [dbo].[fact_batting]


--10. Total number of wickets taken by a bowler

SELECT bow.bowlerName, SUM(bow.wickets) as Wickets
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY SUM(bow.wickets) DESC


--11. Total number of balls bowled by the bowler

SELECT bow.bowlerName, SUM(bow.balls) as Balls_Bowled
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY SUM(bow.balls) DESC


--12. Total runs conceded by the bowler

SELECT bow.bowlerName, SUM(bow.runs) as Runs_Conceded
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY SUM(bow.runs) DESC


--13. Average number of runs conceded in an over

SELECT bow.bowlerName, CAST(SUM(bow.runs) AS FLOAT)/CAST(SUM(bow.balls)/6 AS FLOAT) as Bowling_Economy
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY CAST(SUM(bow.runs) AS FLOAT)/CAST(SUM(bow.balls)/6 AS FLOAT) DESC


--14. Number of balls bowled per wicket

SELECT bow.bowlerName, NULLIF(CAST(SUM(bow.balls) AS float), 0)/NULLIF(CAST(SUM(bow.wickets) as float), 0) as Bowling_Strike_Rate
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY NULLIF(CAST(SUM(bow.balls) AS float), 0)/NULLIF(CAST(SUM(bow.wickets) as float), 0) DESC


--15. No. of runs allowed per wicket  

SELECT bow.bowlerName, NULLIF(CAST(SUM(bow.runs) AS float), 0)/NULLIF(CAST(SUM(bow.wickets) as float), 0) as Bowling_Average
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY NULLIF(CAST(SUM(bow.runs) AS float), 0)/NULLIF(CAST(SUM(bow.wickets) as float), 0) DESC


--Total number of innings bowled by a bowler

--WITH vWdistinct
--AS
--(
--SELECT Distinct bow.matchid as Total_Innings_Bowled, bow.bowlerName
--FROM [dbo].[fact_bowling] bow
--JOIN [dbo].[dim_match] mat
--ON bow.matchid = mat.matchid
--WHERE mat.stage = 'super_12'
--GROUP BY bow.bowlerName
--)

--SELECT  bow.bowlerName, COUNT(Total_Innings_Bowled) AS Total_Innings_Bowled 
--FROM vWdistinct
--ORDER BY Total_Innings_Bowled DESC


--17. Percentage of dot balls bowled by a bowler

SELECT bow.bowlerName, (CAST(SUM(bow.zeros) AS float)/CAST(SUM(bow.balls) AS float))*100 as [Dot_Ball_%]
FROM [dbo].[fact_bowling] bow
JOIN [dbo].[dim_match] mat
ON bow.matchid = mat.matchid
WHERE mat.stage = 'super_12'
GROUP BY bow.bowlerName
ORDER BY (CAST(SUM(bow.zeros) AS float)/CAST(SUM(bow.balls) AS float)) DESC


SELECT * FROM [dbo].[fact_bowling]

