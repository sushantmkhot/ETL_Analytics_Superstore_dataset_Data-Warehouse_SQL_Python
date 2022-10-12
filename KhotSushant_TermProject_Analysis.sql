use Superstore;


/*
Business Questions:
1. What are the TOP 3 most Popular Products in terms of Sales and at which Location?
2. Which Product Sub-category is the most popular?
3. Which Location has the maximum Average Sales and in which Month-Year?
4. Which are the TOP 5 Cities with Highest number of Orders placed?
5. Which Customer has the most Orders? What is their Segment?
6. Which Shipping Mode is most requested by the Customers?
7. What is the Maximum delay between Order and Ship Date? How many cities have this maximum delay?
8. Which Year had the most Sales?
*/


-- 1. What are the TOP 3 most Popular Products in terms of Sales and at which Location?
SELECT TOP 3 DP.Product_ID, 
			 DP.Product_Name, 
			 DL.City, 
			 DL.State, 
			 DL.ZIPCode, 
			 FP.Total_Product_Sales_Loc AS Total_Sales_$
FROM FACT_Product_Sales_Cuml FP
JOIN DIM_PRODUCT DP
ON FP.Product_DIM_ID = DP.Product_DIM_ID
JOIN DIM_LOCATION DL
ON FP.Location_ID = DL.Location_ID
ORDER BY FP.Total_Product_Sales_Loc desc


-- 2. Which Product Sub-category is the most popular?
SELECT TOP 3 DS.SubCategory_Name, 
	   SUM(FS.Total_SubCategory_Sales_Year) AS Total_Sales_$
FROM FACT_Subcategory_Sales_Cuml FS
JOIN DIM_SUBCATEGORY DS
ON FS.SubCategory_ID = DS.SubCategory_ID
GROUP BY DS.SubCategory_Name
ORDER BY SUM(FS.Total_SubCategory_Sales_Year) desc


-- 3. Which Location has the maximum Average Sales and in which Month-Year?
SELECT TOP 3 DL.City,
	   DL.State,
	   DL.Region,
	   DL.Country,
	   DL.ZIPCode,
	   FL.Date_ID AS Month_Year,
	   FL.Avg_Sales_Loc_Month_Year AS Avg_Sales_$
FROM FACT_Loc_Sales_Cuml FL
JOIN DIM_LOCATION DL
ON FL.Location_ID = DL.Location_ID
ORDER BY FL.Avg_Sales_Loc_Month_Year desc


-- 4. Which are the TOP 5 Cities with Highest number of Orders placed?
SELECT TOP 5 DL.City,
	   DL.State,
	   SUM(FL.Total_Orders_Loc_Month_Year) AS Total_Orders
FROM FACT_Loc_Sales_Cuml FL
JOIN DIM_LOCATION DL
ON FL.Location_ID = DL.Location_ID
GROUP BY DL.City,
		 DL.State
ORDER BY SUM(FL.Total_Orders_Loc_Month_Year) desc


-- 5. Which Customer has the most Orders? What is their Segment?
SELECT TOP 3 FC.Customer_ID,
	   DC.Customer_Name,
	   FC.Customer_Segment,
	   SUM(FC.Total_Orders_Year_Customer) AS Total_Orders
FROM FACT_Customer_Order_Cuml FC
JOIN DIM_CUSTOMER DC
ON FC.Customer_ID = DC.Customer_ID
GROUP BY FC.Customer_ID,
	   DC.Customer_Name,
	   FC.Customer_Segment
ORDER BY SUM(FC.Total_Orders_Year_Customer) desc


-- 6. Which Shipping Mode is most requested by the Customers?
SELECT Ship_Mode_Type,
	   COUNT(DISTINCT(Order_ID)) AS Total_Times_Requested
FROM DIM_ORDERS
GROUP BY Ship_Mode_Type
ORDER BY COUNT(DISTINCT(Order_ID)) desc

-- 7. What is the Maximum delay between Order and Ship Date? How many cities have this maximum delay?
SELECT COUNT(DISTINCT(DL.City)) AS Num_of_Cities,
	   MAX(FO.Diff_Days_Ship_Order_Loc) AS Maximum_Delay_in_Days
FROM FACT_Order_Loc_Cuml FO
JOIN DIM_LOCATION DL
ON FO.Location_ID = DL.Location_ID
ORDER BY MAX(FO.Diff_Days_Ship_Order_Loc) desc


-- 8. Which Year had the most Sales?
SELECT Date_ID AS Year,
	   Total_Sales_Year AS Total_Sales_$
FROM FACT_Year_Sales_Cuml
ORDER BY Total_Sales_Year desc

