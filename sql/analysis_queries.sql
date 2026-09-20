-- ==============================================================================
-- SuperStore Sales Analytics - SQL Verification & Exploratory Queries
-- Author: Shivam Raut
-- Purpose: Validate Power BI measures and perform backend data exploration.
-- ==============================================================================

-- 1. Executive Summary KPIs: Total Sales, Total Profit, Total Units & Avg Delivery Days
SELECT 
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(AVG(DATEDIFF(day, Order_Date, Ship_Date)), 2) AS Avg_Delivery_Days
FROM Orders;

-- 2. Sales Distribution by Payment Mode (Validating Donut Chart)
SELECT 
    Payment_Mode,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(100.0 * SUM(Sales) / SUM(SUM(Sales)) OVER(), 2) AS Sales_Percentage
FROM Orders
GROUP BY Payment_Mode
ORDER BY Total_Sales DESC;

-- 3. Sales Breakdown by Customer Segment
SELECT 
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(100.0 * SUM(Sales) / SUM(SUM(Sales)) OVER(), 2) AS Segment_Share_Pct
FROM Orders
GROUP BY Segment
ORDER BY Total_Sales DESC;

-- 4. Fulfillment Logistics by Shipping Mode
SELECT 
    Ship_Mode,
    SUM(Quantity) AS Total_Units_Shipped,
    ROUND(AVG(DATEDIFF(day, Order_Date, Ship_Date)), 2) AS Avg_Lead_Time_Days
FROM Orders
GROUP BY Ship_Mode
ORDER BY Total_Units_Shipped DESC;

-- 5. Product Category & Sub-Category Performance
SELECT 
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS Profit_Margin_Pct
FROM Orders
GROUP BY Category, Sub_Category
ORDER BY Category, Total_Sales DESC;

-- 6. Top 10 States by Sales Volume (Matches Page 2 Bar Chart)
SELECT TOP 10
    State,
    ROUND(MAX(Sales), 2) AS Max_Single_Sale,
    ROUND(SUM(Sales), 2) AS Total_State_Sales
FROM Orders
GROUP BY State
ORDER BY Total_State_Sales DESC;

-- 7. Monthly Year-over-Year (YoY) Sales Comparison
WITH MonthlyAgg AS (
    SELECT 
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,
        DATENAME(month, Order_Date) AS Month_Name,
        SUM(Sales) AS Monthly_Sales
    FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
)
SELECT 
    m2020.Order_Month,
    m2020.Month_Name,
    ROUND(m2019.Monthly_Sales, 2) AS Sales_2019,
    ROUND(m2020.Monthly_Sales, 2) AS Sales_2020,
    ROUND(((m2020.Monthly_Sales - m2019.Monthly_Sales) / NULLIF(m2019.Monthly_Sales, 0)) * 100, 2) AS YoY_Growth_Pct
FROM MonthlyAgg m2020
LEFT JOIN MonthlyAgg m2019 
    ON m2020.Order_Month = m2019.Order_Month 
    AND m2019.Order_Year = 2019
WHERE m2020.Order_Year = 2020
ORDER BY m2020.Order_Month;
