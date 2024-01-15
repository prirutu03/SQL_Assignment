select * from AmazonSaleData

///1. Number of Orders, Total Order Amount, Average Order Value by SKU.///
SELECT SKU,
       COUNT(orderID) AS Number_of_Orders,
       SUM(Amount) AS Total_Order_Amount,
       AVG(Amount) AS Average_Order_Value
FROM AmazonSaleData
GROUP BY SKU;

///2. Assuming south, north and central regions of India, 
the top 3 categories that are sold in each regions by the total order value.///
WITH StateRegionMapping AS (
    SELECT
        CASE
            -- South Region
            WHEN ship_state IN ('ANDAMAN & NICOBAR', 'ANDHRA PRADESH', 'ARUNACHAL PRADESH', 'ASSAM', 'Goa', 'KERALA', 'LAKSHADWEEP', 'MIZORAM', 'PUDUCHERRY', 'TELANGANA', 'TRIPURA') THEN 'South'
            
            -- North Region
            WHEN ship_state IN ('CHANDIGARH', 'DELHI', 'HARYANA', 'HIMACHAL PRADESH', 'JAMMU & KASHMIR', 'PUNJAB', 'UTTAR PRADESH', 'UTTARAKHAND') THEN 'North'
            
            -- Central Region
            WHEN ship_state IN ('CHHATTISGARH', 'DADRA AND NAGAR', 'GUJARAT', 'MAHARASHTRA', 'MADHYA PRADESH', 'RAJASTHAN') THEN 'Central'
            
            -- Assign 'Other' region to the remaining states
            ELSE 'Other'
        END AS Region,
        Category,
        Amount
    FROM AmazonSaleData
    WHERE ship_country = 'In'  -- Consider only Indian states
)
, RegionCategorySales AS (
    SELECT
        Region,
        Category,
        SUM(Amount) AS Total_Order_Value,
        RANK() OVER (PARTITION BY Region ORDER BY SUM(Amount) DESC) AS Category_Rank
    FROM StateRegionMapping
    GROUP BY Region, Category
)
SELECT
    Region,
    Category,
    Total_Order_Value
FROM RegionCategorySales
WHERE Region IN ('South', 'North', 'Central') AND Category_Rank <= 3;

///3. Number of Orders and Total Order Amount by date, day of week and month.///
SELECT 
    Date,
    DAYNAME(Date) AS Day_of_Week,
    MONTHNAME(Date) AS Month,
    COUNT(orderID) AS Number_of_Orders,
    SUM(Amount) AS Total_Order_Amount
FROM AmazonSaleData
GROUP BY Date, Day_of_Week, Month;
