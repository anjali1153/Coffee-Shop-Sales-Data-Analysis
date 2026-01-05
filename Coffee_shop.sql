Create database fusionproject;

select * from `coffee shop`;

rename table `coffee shop` to coffee_shop;
select * from coffee_shop;

Desc coffee_shop;

# Changing data type of transaction_date to date
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_shop SET transaction_date = str_to_date(transaction_date,'%m/%d/%Y');

ALTER TABLE coffee_shop MODIFY transaction_date DATE;

#Alter time column to data data type
ALTER TABLE coffee_shop MODIFY transaction_time time;

# Renaming the  table name `ï»¿transaction_id`
ALTER TABLE coffee_shop CHANGE COLUMN `ï»¿transaction_id`  transaction_id INT;

# Check  NULL values

SELECT 
      SUM(transaction_id IS NULL) AS null_transaction_id,
      SUM(transaction_date IS NULL) AS null_transation_date,
      SUM(transaction_time IS NULL) AS null_transaction_time,
      SUM(transaction_qty IS NULL) AS null_transaction_qty,
      SUM(store_location IS NULL) AS null_store_location,
      SUM(unit_price IS  NULL) AS null_unit_price,
      SUM(product_category IS  NULL) AS null_product_category
from coffee_shop;

# Check Invalid quantities records
SELECT * from coffee_shop WHERE transaction_qty <= 0;

#Checking invalid prices
SELECT * FROM coffee_shop WHERE unit_price <= 0;

# Checking duplicate transaction records

SELECT transaction_id , COUNT(*) AS duplicate_count
FROM coffee_shop
GROUP BY transaction_id 
HAVING COUNT(*) > 1;

# Data Transformation (Derived fields)

-- Create a view with revenue calculation
CREATE VIEW revenue AS 
SELECT 
      transaction_id,transaction_date,transaction_time,transaction_qty,store_id,store_location,product_id,product_category,product_type,
      product_detail,unit_price,
      transaction_qty * unit_price AS revenue
FROM coffee_shop;

SELECT * FROM revenue;


# Add time based attriutes

CREATE VIEW trend_data AS
SELECT
     *,
     HOUR(transaction_time) AS sales_hour,
     DAYNAME(transaction_date) AS sales_day,
     MONTH(transaction_date) AS sales_month,
     YEAR(transaction_date) AS sales_year
FROM revenue;

SELECT * FROM trend_data;

-- ---------------------------------------------------------------
# Exploratory Business Anlaysis Using SQL

# Total revenue
SELECT SUM(revenue)  AS Total_Revenue
FROM revenue;

# 1.Revenue by store location
SELECT store_location , SUM(revenue) As Total_Revenue From Revenue
Group by store_location ORDER BY Total_Revenue DESC;

# 2.Revenue by Product category
SELECT product_category , SUM(revenue) As Total_Revenue From Revenue
Group by product_category ORDER BY Total_Revenue DESC;

# 3. Revenue by product type
SELECT product_type , SUM(revenue) As Total_Revenue From Revenue
Group by product_type ORDER BY Total_Revenue DESC
LIMIT 10;

-- Based on trend data

# 4.  Hourly  sales trend
SELECT sales_hour , SUM(revenue) As hourly_Revenue From trend_data
Group by sales_hour ORDER BY sales_hour ;

# 5. Daily sales trend
SELECT transaction_date, SUM(revenue) As daily_revenue From trend_data
Group by transaction_date ORDER BY transaction_date;

# 6. Monthly sales trend
SELECT sales_year,sales_month , SUM(revenue) As Monthly_Revenue From trend_data
Group by sales_year,sales_month ORDER BY sales_year,sales_month DESC;

# 7. Day wise sales trend
SELECT sales_day, SUM(revenue) As day_revenue From trend_data
Group by sales_day ORDER BY day_revenue DESC;

# 8. Location and day wise sales trend
SELECT store_location,sales_day, SUM(revenue) As day_revenue From trend_data
Group by store_location,sales_day ORDER BY coffee_shopday_revenue DESC;

# To get sales from monday to sunday for month of may --> drastic increase in sales of may
SELECT 
      CASE
         WHEN dayofweek(transaction_date) = 2 THEN 'Monday'
         WHEN dayofweek(transaction_date) = 3 THEN 'Tuesday'
         WHEN dayofweek(transaction_date) = 4 THEN 'Wednesday'
         WHEN dayofweek(transaction_date) = 5 THEN 'Thursday'
         WHEN dayofweek(transaction_date) = 6 THEN 'Friday'
         WHEN dayofweek(transaction_date) = 7 THEN 'Saturday'
         ELSE 'Sunday'
	END AS Day_Of_Week,
    ROUND(SUM(unit_price*transaction_qty)) As Total_Sales
From coffee_shop
WHERE MONTH(transaction_date) = 5 -- ----------------Filtering on may month (MONTH number 5)
GROUP BY
        CASE
		 WHEN dayofweek(transaction_date) = 2 THEN 'Monday'
         WHEN dayofweek(transaction_date) = 3 THEN 'Tuesday'
         WHEN dayofweek(transaction_date) = 4 THEN 'Wednesday'
         WHEN dayofweek(transaction_date) = 5 THEN 'Thursday'
         WHEN dayofweek(transaction_date) = 6 THEN 'Friday'
         WHEN dayofweek(transaction_date) = 7 THEN 'Saturday'
         ELSE 'Sunday'
	END;
          
-- -------------------------------------------------------------------------
-- Core KPI Calculations

# 1. Total orders
SELECT COUNT(distinct(transaction_id)) AS Total_Orders 
FROM coffee_shop;

# 2. Total Revenue
SELECT ROUND(SUM(transaction_qty * unit_price),2) As Total_Revenue
From coffee_shop;

# 3.Average Order Value(AOV)
SELECT ROUND(SUM(transaction_qty * unit_price) / COUNT(distinct transaction_id),2) AS Average_Order_Value
FROM coffee_shop;

# 4. Peak sales hour
SELECT
      HOUR(transaction_time) AS `Hour`,
      ROUND(SUM(transaction_qty * unit_price),2) AS Hourly_Revenue
FROM coffee_shop
GROUP BY `Hour`
ORDER BY  Hourly_Revenue DESC
LIMIT 1;

# Weekday VS Weekend sales 
SELECT 
      CASE 
          WHEN dayofweek(transaction_date) IN (1,7) THEN 'Weekend'
          ELSE 'Weekday'
	  END AS Day_of_week,
      ROUND(SUM(transaction_qty * unit_price),2) As Total_Revenue
FROM coffee_shop
GROUP BY day_of_week;



