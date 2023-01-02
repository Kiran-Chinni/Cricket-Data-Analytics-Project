USE [Cricket_Data_Analytics]
GO


--Importing t20_wc_player_info.json File


DECLARE @json varchar(max)
SELECT @json = BULKCOLUMN
FROM openrowset(BULK 'C:\Users\Public\Kiran Personal\Domain\DATA Engineering\1 Power BI Projects\Codebasic-Cricket Data Analytics Project\Resources For SQL Analysis\t20_wc_player_info.json', SINGLE_CLOB) import
INSERT INTO [dbo].[dim_players]
SELECT * FROM openjson(@json)
WITH
(
[name] varchar(225),
[team] varchar(225),
[battingStyle] varchar(225),
[bowlingStyle] varchar(225),
[playingRole] varchar(225),
[description] varchar(225)
)


--Creating dim_players Table From Imported t20_wc_player_info.json File


CREATE TABLE dim_players
(
[name] varchar(225),
[team] varchar(225),
[battingStyle] varchar(225),
[bowlingStyle] varchar(225),
[playingRole] varchar(225),
[description] varchar(225)
)

SELECT * FROM [dbo].[dim_players]

--Removing Unwanted and Special Characters

UPDATE [dbo].[dim_players]
SET [name] = SUBSTRING([name], 1, 
CASE WHEN
CHARINDEX('â€', [name], 1) = 0 THEN LEN([name])
ELSE CHARINDEX('â€', [name], 1)-1 END)

UPDATE [dbo].[dim_players]
SET [name] = SUBSTRING([name], 1, 
CASE WHEN
CHARINDEX('(c)', [name], 1) = 0 THEN LEN([name])
ELSE CHARINDEX('(c)', [name], 1)-1 END)


--Removing Duplicates


WITH rowNumCTE
AS
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY Name ORDER BY Name) rowNo
FROM [dbo].[dim_players]
)
DELETE FROM rowNumCTE
Where rowNo >1


--Importing t20_wc_match_results.json File

DECLARE @json varchar(max)

SELECT @json = BULKCOLUMN 
FROM OPENROWSET(BULK 'C:\Users\Public\Kiran Personal\Domain\DATA Engineering\1 Power BI Projects\Codebasic-Cricket Data Analytics Project\Resources For SQL Analysis\t20_wc_match_results.json', SINGLE_CLOB) import

INSERT INTO dim_match
SELECT * FROM openjson(@json)
WITH
(
team1 varchar(225),
team2 varchar(225), 
winner varchar(225),
margin varchar(225),
ground varchar(225),
matchDate DATE,
scorecard varchar(225) 
)


--Creating dim_match Table From Imported t20_wc_match_results.json File

CREATE TABLE dim_match
(
team1 varchar(225),
team2 varchar(225), 
winner varchar(225),
margin varchar(225),
ground varchar(225),
matchDate DATE,
scorecard varchar(225) 
)

SELECT * FROM dim_match


---Rename column scorecard to matchid

EXEC sp_rename 'dim_match.scorecard', 'matchid'


---Adding new column stage to dim_match


DECLARE @date date
SET @date = '10-22-2022'

SELECT *, 
CASE 
WHEN CAST(matchDate AS date) < CAST(@date AS date) THEN 'Qualifier'
ELSE 'Super_12' END AS stage
FROM dim_match

ALTER TABLE dim_match
ADD stage nvarchar(25)


DECLARE @date date
SET @date = '10-22-2022'

UPDATE dim_match
SET stage = CASE 
WHEN CAST(matchDate AS date) < CAST(@date AS date) THEN 'Qualifier'
ELSE 'Super_12' END
FROM dim_match


SELECT * FROM dim_match


--Importing t20_wc_batting_summary and t20_wc_bowling_summary excel Files

SELECT * FROM [dbo].[fact_batting]
SELECT * FROM [dbo].[fact_bowling]


-- Creating out column with refernce to dismissal column

SELECT match, batsmanName, dismissal,
CASE
WHEN LEN(dismissal) > 0 THEN '1' ELSE '0'
END AS out
FROM [dbo].[fact_batting] 


ALTER TABLE [dbo].[fact_batting]
ADD out int


UPDATE [dbo].[fact_batting]
SET out = CASE
WHEN LEN(dismissal) > 0 THEN '1' ELSE '0'
END


ALTER TABLE [dbo].[fact_batting]
DROP COLUMN dismissal 


--Create VIEW having matchid and match columns as we have to use matchid in othe table

CREATE VIEW vWmatchid
AS
(
SELECT matchid, team1 + ' Vs ' + team2 As match
FROM dim_match
UNION ALL
SELECT matchid, team2 + ' Vs ' + team1 As match
FROM dim_match
)

-- ADD matchid column to fact_batting table

SELECT a.match, b.matchid
FROM fact_batting a
JOIN vWmatchid b
ON a.match = b.match

ALTER TABLE fact_batting
ADD matchid nvarchar(25)

UPDATE a
SET a.matchid = b.matchid
FROM fact_batting a
JOIN vWmatchid b
ON a.match = b.match


--removing unwanted special characters and symbols


SELECT batsmanName, SUBSTRING(batsmanName, 1, 
CASE 
WHEN CHARINDEX('(c)', batsmanName, 1) = 0 THEN LEN(batsmanName) 
ELSE CHARINDEX('(c)', batsmanName, 1)-1 
END )
FROM fact_batting

SELECT batsmanName, SUBSTRING(batsmanName, 1, 
CASE 
WHEN CHARINDEX('†', batsmanName, 1) = 0 THEN LEN(batsmanName) 
ELSE CHARINDEX('†', batsmanName, 1)-1 
END )
FROM fact_batting


UPDATE [dbo].[fact_batting]
SET batsmanName = SUBSTRING(batsmanName, 1, 
CASE 
WHEN CHARINDEX('(c)', batsmanName, 1) = 0 THEN LEN(batsmanName) 
ELSE CHARINDEX('(c)', batsmanName, 1)-1 
END )

UPDATE [dbo].[fact_batting]
SET batsmanName = SUBSTRING(batsmanName, 1, 
CASE 
WHEN CHARINDEX('†', batsmanName, 1) = 0 THEN LEN(batsmanName) 
ELSE CHARINDEX('†', batsmanName, 1)-1 
END )

SELECT * FROM [dbo].[fact_batting]



-- ADD matchid column to fact_bowling table


SELECT * FROM [dbo].[fact_bowling]

SELECT a.match, b.matchid
FROM [dbo].[fact_bowling] a
JOIN [dbo].[vWmatchid] b
ON a.match = b.match

ALTER TABLE [dbo].[fact_bowling]
ADD matchid nvarchar(50)

UPDATE a
SET a.matchid = b.matchid
FROM [dbo].[fact_bowling] a
JOIN [dbo].[vWmatchid] b
ON a.match = b.match


--ADD column having total balls bowled

SELECT overs, LEFT(overs, 
(CASE
WHEN CHARINDEX('.', overs, 1) = 0 THEN overs 
ELSE CHARINDEX('.', overs, 1)-1 END)) AS integerpart, 
RIGHT(overs, 
(CASE
WHEN CHARINDEX('.', overs, 1) = 0 THEN 0
ELSE CHARINDEX('.', overs, 1)-1 END)) AS integerpart
From [dbo].[fact_bowling]

ALTER TABLE [dbo].[fact_bowling]
ADD overs1 int, overs2 int

UPDATE [dbo].[fact_bowling]
SET overs1 = LEFT(overs, 
(CASE
WHEN CHARINDEX('.', overs, 1) = 0 THEN overs 
ELSE CHARINDEX('.', overs, 1)-1 END))
From [dbo].[fact_bowling]

UPDATE [dbo].[fact_bowling]
SET overs2 = RIGHT(overs, 
(CASE
WHEN CHARINDEX('.', overs, 1) = 0 THEN 0
ELSE CHARINDEX('.', overs, 1)-1 END)) 
From [dbo].[fact_bowling]


SELECT overs, overs1 * 6 + overs2 AS balls FROM [dbo].[fact_bowling]

ALTER TABLE [dbo].[fact_bowling]
ADD balls int

UPDATE [dbo].[fact_bowling]
SET balls = overs1 * 6 + overs2 FROM [dbo].[fact_bowling]

SELECT * FROM [dbo].[fact_bowling]