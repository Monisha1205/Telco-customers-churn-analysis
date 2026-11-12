-- created db
Create Database telco_churn;

USE Telco_churn;

SHOW DATABASES;


CREATE TABLE telco_customers (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(30),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn VARCHAR(5)
);

SHOW TABLES;

DESCRIBE telco_customers;

SET GLOBAL local_infile = 1;

SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE
'D:/Customer churn analytics/Dataset/Telco_Customer_Churn_Cleaned.csv'
INTO TABLE telco_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT count(*) FROM telco_customers;

SELECT *
FROM telco_customers
LIMIT 10;

SELECT customerID, COUNT(*) AS duplicate_count
FROM telco_customers
GROUP BY customerID
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    SUM(customerID IS NULL) AS null_customerID,
    SUM(gender IS NULL) AS null_gender,
    SUM(tenure IS NULL) AS null_tenure,
    SUM(MonthlyCharges IS NULL) AS null_monthlycharges,
    SUM(TotalCharges IS NULL) AS null_totalcharges,
    SUM(Churn IS NULL) AS null_churn
FROM telco_customers;

SELECT Churn, COUNT(*) AS customer_count
FROM telco_customers
GROUP BY Churn;

SELECT *
FROM telco_customers
WHERE tenure < 0 OR tenure > 72;

-- Total number of customers
SELECT
    COUNT(*) AS total_customers
FROM telco_customers;

-- Churned and retained customers

SELECT
    Churn,
    COUNT(*) AS customer_count
FROM telco_customers
GROUP BY Churn;


-- Calculate churn percentage

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_percentage
FROM telco_customers;

-- Revenue analysis
-- Total monthly revenue

SELECT
    ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue
FROM telco_customers;


-- Average monthly charges
SELECT
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customers;

-- Revenue comparison between churned and retained customers
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customers
GROUP BY Churn;

-- Churn by contract type

SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate
FROM telco_customers
GROUP BY Contract
ORDER BY churn_rate DESC;


-- Churn by tenure groups
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    SUM(CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END) AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY tenure_group
ORDER BY MIN(tenure);

-- Compare all three factors
SELECT
    Contract,
    InternetService,
    COUNT(*) AS total_customers,

    SUM(CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END) AS churned_customers,

    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS churn_rate

FROM telco_customers
GROUP BY Contract, InternetService
ORDER BY churn_rate DESC;

-- Customer segmentation using CASE WHEN

SELECT
    customerID,
    MonthlyCharges,
    CASE
        WHEN MonthlyCharges < 35 THEN 'Low Charges'
        WHEN MonthlyCharges BETWEEN 35 AND 70 THEN 'Medium Charges'
        ELSE 'High Charges'
    END AS customer_segment,
    Churn
FROM telco_customers
LIMIT 20;

 
-- Find customers paying above average monthly charges

SELECT
    customerID,
    MonthlyCharges,
    Contract,
    Churn
FROM telco_customers
WHERE MonthlyCharges > (
    SELECT AVG(MonthlyCharges)
    FROM telco_customers
)
ORDER BY MonthlyCharges DESC;

-- Find customers with above-average total charges
SELECT
    customerID,
    tenure,
    TotalCharges,
    Churn
FROM telco_customers
WHERE TotalCharges > (
    SELECT AVG(TotalCharges)
    FROM telco_customers
)
ORDER BY TotalCharges DESC
LIMIT 20;


