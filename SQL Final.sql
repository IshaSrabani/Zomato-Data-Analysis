-- 2. Build a Calendar Table using the Columns Datekey_Opening ( Which has Dates from Minimum Dates and Maximum Dates)
 -- Add all the below Columns in the Calendar Table using the Formulas.
  -- A.Year
  -- B.Monthno
  -- C.Monthfullname
 --  D.Quarter(Q1,Q2,Q3,Q4)
 --  E. YearMonth ( YYYY-MMM)
 --  F. Weekdayno
  -- G.Weekdayname
 --  H.FinancialMOnth ( April = FM1, May= FM2  …. March = FM12)
 --  I. Financial Quarter ( Quarters based on Financial Month FQ-1 . FQ-2..)
 -- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE calendar (
    DateKey DATE PRIMARY KEY,
    Year INT,
    MonthNo INT,
    MonthFullName VARCHAR(20),
    Quarter VARCHAR(5),
    YearMonth VARCHAR(10),
    WeekdayNo INT,
    WeekdayName VARCHAR(20),
    FinancialMonth VARCHAR(10),
    FinancialQuarter VARCHAR(10)
);

DESCRIBE calendar;
UPDATE calendar
SET 
    Year = YEAR(DateKey),
    MonthNo = MONTH(DateKey),
    MonthFullName = MONTHNAME(DateKey),
    Quarter = CONCAT('Q', QUARTER(DateKey)),
    YearMonth = DATE_FORMAT(DateKey, '%Y-%m'),
    WeekdayNo = DAYOFWEEK(DateKey),   -- Sunday=1 … Saturday=7
    WeekdayName = DAYNAME(DateKey),
    FinancialMonth = CASE 
                        WHEN MONTH(DateKey) >= 4 THEN CONCAT('FM-', MONTH(DateKey)-3)
                        ELSE CONCAT('FM-', MONTH(DateKey)+9)
                     END,
    FinancialQuarter = CASE 
                          WHEN MONTH(DateKey) BETWEEN 4 AND 6 THEN 'FQ-1'
                          WHEN MONTH(DateKey) BETWEEN 7 AND 9 THEN 'FQ-2'
                          WHEN MONTH(DateKey) BETWEEN 10 AND 12 THEN 'FQ-3'
                          ELSE 'FQ-4'
                       END;

SELECT * FROM calendar LIMIT 20;
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Step 1: Populate Derived Columns
UPDATE Calendar
SET 
    Year = YEAR(DateKey),                                         -- A. Year
    MonthNo = MONTH(DateKey),                                     -- B. MonthNo
    MonthFullName = MONTHNAME(DateKey),                           -- C. MonthFullName
    Quarter = CONCAT('Q', QUARTER(DateKey)),                      -- D. Quarter
    YearMonth = DATE_FORMAT(DateKey, '%Y-%b'),                    -- E. YearMonth (YYYY-MMM)
    WeekdayNo = DAYOFWEEK(DateKey),                               -- F. WeekdayNo (1=Sunday,...7=Saturday)
    WeekdayName = DAYNAME(DateKey),                               -- G. WeekdayName
    FinancialMonth = CONCAT('FM', ((MONTH(DateKey) + 9) % 12) + 1),  -- H. FinancialMonth (Apr=FM1,...,Mar=FM12)
    FinancialQuarter = CONCAT('FQ-', 
                      ((QUARTER(DATE_ADD(DateKey, INTERVAL -3 MONTH)) + 3 - 1) % 4) + 1); -- I. FinancialQuarter
                      
-- Step 2: Verify
SELECT * FROM Calendar LIMIT 15;

-- Q3 Convert the Average cost for 2 column into USD dollars 
-- (currently the Average cost for 2 in local currencies
SELECT 
RestaurantName,
City,
Average_Cost_for_two,
CONCAT(ROUND(Average_cost_for_two * 0.012, 2), '%') AS Avg_Cost_USD_Percentage
FROM zomato_data;

-- Q4 Find the Numbers of Resturants based on City and Country.
SELECT 
Countrycode,
City,
COUNT(*) AS Number_of_Restaurants
FROM zomato_data
GROUP BY Countrycode, City
ORDER BY Countrycode, City;
    
-- Q5 Numbers of Resturants opening based on Year , Quarter , Month
ALTER TABLE zomato_data
ADD COLUMN Opening_Date DATE;
UPDATE zomato_data
SET Opening_Date = STR_TO_DATE(CONCAT(year_opening, '-', Month_opening, '-', Day_opening), '%Y-%m-%d');

SELECT
EXTRACT(YEAR FROM Opening_Date) AS Year,
EXTRACT(QUARTER FROM Opening_Date) AS Quarter,
EXTRACT(MONTH FROM Opening_Date) AS Month,
COUNT(*) AS Number_of_Restaurants
FROM zomato_data
GROUP BY EXTRACT(YEAR FROM Opening_Date),EXTRACT(QUARTER FROM Opening_Date),EXTRACT(MONTH FROM Opening_Date)
ORDER BY Year, Quarter, Month;

-- 6. Count of Resturants based on Average Ratings
SELECT Rating AS Avg_Rating, 
       COUNT(*) AS Restaurant_Count
FROM zomato_data
GROUP BY Rating
ORDER BY Avg_Rating DESC
LIMIT 1000;

-- 7. Create buckets based on Average Price of reasonable size
-- and find out how many resturants falls in each buckets
SELECT 
    CASE
        WHEN Average_Cost_for_two BETWEEN 0 AND 500 THEN '0-500'
        WHEN Average_Cost_for_two BETWEEN 501 AND 1000 THEN '501-1000'
        WHEN Average_Cost_for_two BETWEEN 1001 AND 2000 THEN '1001-2000'
        WHEN Average_Cost_for_two BETWEEN 2001 AND 4000 THEN '2001-4000'
        WHEN Average_Cost_for_two > 4000 THEN '4000+'
    END AS Price_Bucket,
    COUNT(*) AS Restaurant_Count
FROM zomato_data
WHERE Average_Cost_for_two IS NOT NULL
GROUP BY Price_Bucket
ORDER BY Price_Bucket;

-- 8.Percentage of Resturants based on "Has_Table_booking"
SELECT 
    Has_Table_booking,
    COUNT(*) AS Total_Restaurants,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_data)),2) AS Percentage
FROM zomato_data
GROUP BY Has_Table_booking;

-- 9.Percentage of Resturants based on "Has_Online_delivery"
SELECT 
    Has_Online_delivery,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_data) AS percentage
FROM zomato_data
GROUP BY Has_Online_delivery;

-- 10. Develop Charts based on Cusines, City, Ratings
-- ( Candidate have to think about new KPI to analyse)
SELECT 
    Cuisines,
    COUNT(*) AS total_restaurants
FROM zomato_data
GROUP BY Cuisines
ORDER BY total_restaurants DESC
LIMIT 10;
