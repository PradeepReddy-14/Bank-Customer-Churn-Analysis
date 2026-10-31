-- Q2: Top 5 customers by estimated salary
-- who joined in Q4 2019

SELECT
    CustomerId,
    Surname,
    EstimatedSalary,
    `Bank DOJ`
FROM customerinfo
WHERE YEAR(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) = 2019
  AND QUARTER(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) = 4
ORDER BY EstimatedSalary DESC
LIMIT 5;

-- Objective Question 3
-- Average number of products used by customers ,who have a credit card

SELECT
    AVG(NumOfProducts) AS avg_products
FROM bank_churn
WHERE HasCrCard = 1;


-- Objective Question 5
-- Compare average credit score of exited
-- and retained customers

SELECT
    Exited,
    CASE
        WHEN Exited = 1 THEN 'Exited'
        ELSE 'Retained'
    END AS CustomerStatus,
    AVG(CreditScore) AS AvgCreditScore
FROM bank_churn
GROUP BY Exited;


-- Objective Question 6
-- Compare average estimated salary by gender
-- and number of active accounts

SELECT
    g.GenderCategory AS Gender,
    round(AVG(c.EstimatedSalary),2) AS AvgEstimatedSalary,
    SUM(CASE
        WHEN b.IsActiveMember = 1 THEN 1
        ELSE 0
    END) AS ActiveAccounts
FROM customerinfo c
JOIN gender g
    ON c.GenderID = g.GenderID
JOIN bank_churn b
    ON c.CustomerId = b.CustomerId
GROUP BY g.GenderCategory
ORDER BY AvgEstimatedSalary DESC;


-- Objective Question 7
-- Credit-score segments and their exit rates

SELECT
    CASE
        WHEN CreditScore < 580 THEN 'Low'
        WHEN CreditScore < 700 THEN 'Medium'
        ELSE 'High'
    END AS CreditScoreSegment,
    COUNT(*) AS TotalCustomers,
    SUM(Exited = 1) AS ExitedCustomers,
    ROUND(
        100.0 * SUM(Exited = 1) / COUNT(*),
        2
    ) AS ExitRatePercent
FROM bank_churn
GROUP BY CreditScoreSegment
ORDER BY ExitRatePercent DESC;



-- Objective Question 8
-- Geographic region with the most active customers
-- whose tenure is greater than 5 years

SELECT
    g.GeographyLocation AS Geography,
    COUNT(*) AS ActiveCustomers
FROM bank_churn b
JOIN customerinfo c
    ON b.CustomerId = c.CustomerId
JOIN geography g
    ON c.GeographyID = g.GeographyID
WHERE b.IsActiveMember = 1
  AND b.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY ActiveCustomers DESC
LIMIT 1;


-- Objective Question 10
-- Most common number of products among exited customers

SELECT
    NumOfProducts,
    COUNT(*) AS CustomerCount
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY CustomerCount DESC
LIMIT 1;



-- Objective Question 11
-- Number of customers joining each year

SELECT
    YEAR(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoiningYear,
    COUNT(*) AS CustomersJoined
FROM customerinfo
GROUP BY JoiningYear
ORDER BY JoiningYear;

-- Number of customers joining each month across all years

SELECT
    MONTH(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS JoiningMonth,
    MONTHNAME(STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y')) AS MonthName,
    COUNT(*) AS CustomersJoined
FROM customerinfo
GROUP BY JoiningMonth, MonthName
ORDER BY JoiningMonth;


-- Objective Question 15
-- Gender-wise average estimated salary by geography
-- Rank genders within each geography by average salary

WITH GenderIncome AS (
    SELECT
        c.GeographyID,
        g.GenderCategory AS Gender,
        AVG(c.EstimatedSalary) AS AvgIncome
    FROM customerinfo c
    JOIN gender g
        ON c.GenderID = g.GenderID
    GROUP BY
        c.GeographyID,
        g.GenderCategory
)
SELECT
    GeographyID,
    Gender,
    ROUND(AvgIncome, 2) AS AvgIncome,
    RANK() OVER (
        PARTITION BY GeographyID
        ORDER BY AvgIncome DESC
    ) AS IncomeRank
FROM GenderIncome
ORDER BY GeographyID, IncomeRank;


-- Objective Question 16
-- Average tenure of exited customers by age bracket

SELECT
    CASE
        WHEN c.Age BETWEEN 18 AND 29 THEN '18-30'
        WHEN c.Age BETWEEN 30 AND 49 THEN '30-50'
        WHEN c.Age >= 50 THEN '50+'
        ELSE 'Below 18'
    END AS AgeBracket,
    COUNT(*) AS ExitedCustomers,
    ROUND(AVG(b.Tenure), 2) AS AvgTenure
FROM customerinfo c
JOIN bank_churn b
    ON c.CustomerId = b.CustomerId
WHERE b.Exited = 1
GROUP BY AgeBracket
ORDER BY
    CASE AgeBracket
        WHEN '18-30' THEN 1
        WHEN '30-50' THEN 2
        WHEN '50+' THEN 3
        ELSE 4
    END;





/*
Question 23:
Get ExitCategory from ExitCustomers and display it
with Bank_Churn without using JOIN.
*/

SELECT
    b.*,
    (
        SELECT e.ExitCategory
        FROM exitcustomer e
        WHERE e.CustomerId = b.CustomerId
    ) AS ExitCategory
FROM bank_churn b;


/*
Question 25:
Write the query to get the customer IDs, their last name,
and whether they are active or not for customers whose
surname ends with "on".
*/

SELECT
    c.CustomerId,
    c.Surname,
    CASE
        WHEN b.IsActiveMember = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS ActiveStatus
FROM customerinfo c
JOIN bank_churn b
    ON c.CustomerId = b.CustomerId
WHERE c.Surname LIKE '%on';








