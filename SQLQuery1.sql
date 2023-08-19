--Getting familiar with the dataset


SELECT TOP 5* FROM BankChurners;
SELECT TOP 5 * FROM BankChurners ORDER BY CustomerID ;

--Creating copy of dataset  for removing unrelevant columns 
-- First checking data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'BankChurners';

CREATE TABLE Bankchurners2 
( CustomerID int,
Churn  nvarchar(50),
Customer_Age tinyint,
Gender nvarchar(50),
Dependent_count tinyint,
Education_Level nvarchar(50),
Marital_Status nvarchar(50),
Income_Category nvarchar(50),
Card_Category nvarchar(50)
)
 --- Inserting selected columns into new table
INSERT INTO Bankchurners2 (CustomerID, Churn, Customer_Age, Gender, Dependent_count, Education_Level, Marital_Status, Income_Category, Card_Category)
SELECT CustomerID, Churn, Customer_Age, Gender, Dependent_count, Education_Level, Marital_Status, Income_Category, Card_Category
FROM BankChurners;

--Cleaning the copied dataset 
-- First checking null values

SELECT 'CustomerID' AS Column_Name, COUNT(*) AS Null_Count FROM Bankchurners2 WHERE CustomerID IS NULL
UNION ALL
SELECT 'Churn' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Churn IS NULL
UNION ALL
SELECT 'Customer_Age' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Customer_Age IS NULL
UNION ALL
SELECT 'Gender' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Gender IS NULL
UNION ALL
SELECT 'Dependent_Count' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Dependent_Count IS NULL
UNION ALL
SELECT 'Education_Level' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Education_Level IS NULL
UNION ALL
SELECT 'Marital_Status' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Marital_Status IS NULL
UNION ALL
SELECT 'Income_Category' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Income_Category IS NULL
UNION ALL
SELECT 'Card_Category' , COUNT(*) AS Null_Count FROM Bankchurners2 WHERE Card_Category IS NULL

--Fortunately we do not have null values

--Checking duplicate values

SELECT *,
COUNT(*) OVER(PARTITION BY  CustomerID ORDER BY CustomerID) AS TotalDuplicates
FROM Bankchurners2

--Fortunately we do not have duplicate  values as well
--Data Exploration-

-- I needed Card_Limit column from the original table for my further anaysis and I used right join



SELECT s2.CustomerID,  s2.Customer_Age, s2.Gender, s2.Dependent_count,s2.Education_Level, s2.Marital_Status,
s2.Income_Category, s2.Card_Category, s1.Credit_Limit AS Card_Limit, s2.Churn
FROM Bankchurners2 s2
RIGHT JOIN Bankchurners s1 ON s1.CustomerID = s2.CustomerID;

---- Calculating average credit limits for each income category

SELECT Income_Category, AVG(Card_Limit) AS Avg_Credit_Limit
FROM (
    SELECT s2.CustomerID,  s2.Customer_Age, s2.Gender, s2.Dependent_count,s2.Education_Level, s2.Marital_Status,
s2.Income_Category, s2.Card_Category, s1.Credit_Limit AS Card_Limit, s2.Churn
FROM Bankchurners2 s2
RIGHT JOIN Bankchurners s1 ON s1.CustomerID = s2.CustomerID)  AS JoinedData 
GROUP BY Income_Category;


-- Calculating churn rates for each income category
SELECT Income_Category, 
       SUM(CASE WHEN Churn = 'Attrited Customer' THEN 1 ELSE 0 END) AS Churn_Count,
       COUNT(*) AS Total_Customers,
       (SUM(CASE WHEN Churn = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM (
   SELECT s2.CustomerID,  s2.Customer_Age, s2.Gender, s2.Dependent_count,s2.Education_Level, s2.Marital_Status,
s2.Income_Category, s2.Card_Category, s1.Credit_Limit AS Card_Limit, s2.Churn
FROM Bankchurners2 s2
RIGHT JOIN Bankchurners s1 ON s1.CustomerID = s2.CustomerID)  AS JoinedData 
GROUP BY Income_Category;
--I used  bar chart  to visually represent the churn rate in PowerBI


-- Calculating the maximum card limit within each group.
SELECT Income_Category, MAX(Card_Limit) AS Max_Card_Limit
FROM (
    SELECT s2.CustomerID, s2.Customer_Age, s2.Gender, s2.Dependent_count, s2.Education_Level,
           s2.Marital_Status, s2.Income_Category, s2.Card_Category, s1.Credit_Limit AS Card_Limit, s2.Churn
    FROM Bankchurners2 s2
    RIGHT JOIN Bankchurners s1 ON s1.CustomerID = s2.CustomerID
) AS JoinedData
GROUP BY Income_Category;



