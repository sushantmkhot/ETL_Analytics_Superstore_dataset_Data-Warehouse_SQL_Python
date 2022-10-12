use Superstore;

-- DROP DATABASE Superstore

-- SELECT * FROM Staging_Table

--DELETE FROM Staging_Table


UPDATE Staging_Table
SET City = 'San Diego'
WHERE Zip_Code = '92024'



/* 
====================================
MERGE Data into the Dimension Tables
====================================
*/

-- PRODUCT Dimension FROM Staging
MERGE INTO DIM_PRODUCT AS tgt
USING (SELECT DISTINCT(Product_ID), Product_Name FROM  Staging_Table) AS src
ON src.Product_ID = tgt.Product_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Product_ID, Product_Name)
	VALUES (src.Product_ID, src.Product_Name)
WHEN MATCHED THEN UPDATE SET
	tgt.Product_ID = src.Product_ID,
	tgt.Product_Name = src.Product_Name;

--DELETE FROM DIM_PRODUCT
-- SELECT * FROM DIM_PRODUCT


-- CUSTOMER Dimension FROM Staging
MERGE INTO DIM_CUSTOMER AS tgt
USING (SELECT DISTINCT(Customer_ID), Customer_Name, Segment FROM  Staging_Table) AS src
ON src.Customer_ID = tgt.Customer_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Customer_ID, Customer_Name, Segment_Name)
	VALUES (src.Customer_ID, src.Customer_Name, src.Segment)
WHEN MATCHED THEN UPDATE SET
	tgt.Customer_ID = src.Customer_ID,
	tgt.Customer_Name = src.Customer_Name,
	tgt.Segment_Name = src.Segment;

--DELETE FROM DIM_CUSTOMER
-- Select * From DIM_CUSTOMER


-- SUBCATEGORY Dimension FROM Staging
MERGE INTO DIM_SUBCATEGORY AS tgt
USING (SELECT DISTINCT(Subcategory) FROM  Staging_Table) AS src
ON src.Subcategory = tgt.SubCategory_Name
WHEN NOT MATCHED BY TARGET THEN
	INSERT (SubCategory_Name)
	VALUES (src.Subcategory)
WHEN MATCHED THEN UPDATE SET
	tgt.SubCategory_Name = src.Subcategory;

--DELETE FROM DIM_SUBCATEGORY
-- Select * From DIM_SUBCATEGORY


-- LOCATION Dimension FROM Staging
MERGE INTO DIM_LOCATION AS tgt
USING (SELECT DISTINCT(Zip_Code), City, State, Country, Region FROM  Staging_Table) AS src
ON src.Zip_Code = tgt.ZIPCode
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ZIPCode, City, State, Country, Region)
	VALUES (src.Zip_Code, src.City, src.State, src.Country, src.Region)
WHEN MATCHED THEN UPDATE SET
	tgt.ZIPCode = src.Zip_Code,
	tgt.City = src.City,
	tgt.State = src.State,
	tgt.Country = src.Country,
	tgt.Region = src.Region;

--DELETE FROM DIM_LOCATION
-- Select * From DIM_LOCATION


-- ORDERS Dimension FROM Staging
MERGE INTO DIM_ORDERS AS tgt
USING (SELECT DISTINCT(Order_ID), Order_dt, Ship_dt, Ship_Mode FROM  Staging_Table) AS src
ON src.Order_ID = tgt.Order_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Order_ID, Order_Date, Ship_Date, Ship_Mode_Type)
	VALUES (src.Order_ID, src.Order_dt, src.Ship_dt, src.Ship_Mode)
WHEN MATCHED THEN UPDATE SET
	tgt.Order_ID = src.Order_ID,
	tgt.Order_Date = src.Order_dt,
	tgt.Ship_Date = src.Ship_dt,
	tgt.Ship_Mode_Type = src.Ship_Mode;

--DELETE FROM DIM_ORDERS
-- Select * From DIM_ORDERS


-- DATE Dimension FROM Staging
MERGE INTO DIM_DATE AS tgt
USING (SELECT Order_dt AS Date_ID, DATEPART(YEAR, Order_dt) AS Date_Year, DATEPART(MONTH, Order_dt) AS Date_Month FROM Staging_Table
	   UNION
	   SELECT Ship_dt AS Date_ID, DATEPART(YEAR, Ship_dt) AS Date_Year, DATEPART(MONTH, Ship_dt) AS Date_Month FROM Staging_Table) AS src
ON src.Date_ID = tgt.Date_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Date_ID, Date_Year, Date_Month)
	VALUES (src.Date_ID, src.Date_Year, src.Date_Month)
WHEN MATCHED THEN UPDATE SET
	tgt.Date_ID = src.Date_ID,
	tgt.Date_Year = src.Date_Year,
	tgt.Date_Month = src.Date_Month;

--DELETE FROM DIM_DATE
-- Select * From DIM_DATE


/* 
===============================
MERGE Data into the FACT Tables
===============================
*/

-- Product_Sales FACT Table
MERGE INTO FACT_Product_Sales_Cuml AS tgt
USING (SELECT DP.PRODUCT_DIM_ID, DL.Location_ID, SUM(ST.Sales) AS Total_Product_Sales_Loc 
	   FROM Staging_Table ST
	   JOIN DIM_PRODUCT DP
	   ON ST.Product_ID = DP.Product_ID
	   JOIN DIM_LOCATION DL
	   ON ST.Zip_Code = DL.ZIPCode
	   GROUP BY PRODUCT_DIM_ID, DL.Location_ID) AS src
ON (src.PRODUCT_DIM_ID = tgt.PRODUCT_DIM_ID AND
	src.Location_ID = tgt.Location_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (PRODUCT_DIM_ID, Location_ID, Total_Product_Sales_Loc)
	VALUES (src.PRODUCT_DIM_ID, src.Location_ID, src.Total_Product_Sales_Loc)
WHEN MATCHED THEN UPDATE SET
	tgt.PRODUCT_DIM_ID = src.PRODUCT_DIM_ID,
	tgt.Location_ID = src.Location_ID,
	tgt.Total_Product_Sales_Loc = src.Total_Product_Sales_Loc;

--DELETE FROM FACT_Product_Sales_Cuml
-- Select * from FACT_Product_Sales_Cuml


-- Order_Location FACT Table
MERGE INTO FACT_Order_Loc_Cuml AS tgt
USING (SELECT ST.Order_ID, DL.Location_ID, DATEDIFF(DAY, ST.Order_dt, ST.Ship_dt) AS Diff_Days_Ship_Order_Loc 
	   FROM Staging_Table ST
	   JOIN DIM_ORDERS DO
	   ON ST.Order_ID = DO.Order_ID
	   JOIN DIM_LOCATION DL
	   ON ST.Zip_Code = DL.ZIPCode
	   GROUP BY ST.Order_ID, DL.Location_ID, DATEDIFF(DAY, ST.Order_dt, ST.Ship_dt)) AS src
ON (src.Order_ID = tgt.Order_ID AND
	src.Location_ID = tgt.Location_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Order_ID, Location_ID, Diff_Days_Ship_Order_Loc)
	VALUES (src.Order_ID, src.Location_ID, src.Diff_Days_Ship_Order_Loc)
WHEN MATCHED THEN UPDATE SET
	tgt.Order_ID = src.Order_ID,
	tgt.Location_ID = src.Location_ID,
	tgt.Diff_Days_Ship_Order_Loc = src.Diff_Days_Ship_Order_Loc;

--DELETE FROM FACT_Order_Loc_Cuml
-- Select * from FACT_Order_Loc_Cuml


-- Location_Sales FACT Table
MERGE INTO FACT_Loc_Sales_Cuml AS tgt
USING (SELECT DL.Location_ID, (CAST(DATEPART(MONTH, ST.Order_dt) AS VARCHAR) + '-' + CAST(DATEPART(YEAR, ST.Order_dt) AS VARCHAR)) AS Date_ID, AVG(ST.Sales) AS Avg_Sales_Loc_Month_Year, COUNT(DISTINCT(ST.Order_ID)) AS Total_Orders_Loc_Month_Year
	   FROM Staging_Table ST
	   JOIN DIM_LOCATION DL
	   ON ST.Zip_Code = DL.ZIPCode
	   JOIN DIM_DATE DD
	   ON ST.Order_dt = DD.Date_ID
	   GROUP BY DL.Location_ID, DATEPART(MONTH, ST.Order_dt), DATEPART(YEAR, ST.Order_dt)) AS src
ON (src.Location_ID = tgt.Location_ID AND
	src.Date_ID = tgt.Date_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Location_ID, Date_ID, Avg_Sales_Loc_Month_Year, Total_Orders_Loc_Month_Year)
	VALUES (src.Location_ID, src.Date_ID, src.Avg_Sales_Loc_Month_Year, src.Total_Orders_Loc_Month_Year)
WHEN MATCHED THEN UPDATE SET
	tgt.Location_ID = src.Location_ID,
	tgt.Date_ID = src.Date_ID,
	tgt.Avg_Sales_Loc_Month_Year = src.Avg_Sales_Loc_Month_Year,
	tgt.Total_Orders_Loc_Month_Year = src.Total_Orders_Loc_Month_Year;

--DELETE FROM FACT_Loc_Sales_Cuml
-- Select * from FACT_Loc_Sales_Cuml


-- Customer_Order FACT Table
MERGE INTO FACT_Customer_Order_Cuml AS tgt
USING (SELECT ST.Customer_ID, DATEPART(YEAR, DD.Date_ID) AS Date_ID, ST.Segment AS Customer_Segment, COUNT(DISTINCT(ST.Order_ID)) AS Total_Orders_Year_Customer
	   FROM Staging_Table ST
	   JOIN DIM_CUSTOMER DC
	   ON ST.Customer_ID = DC.Customer_ID
	   JOIN DIM_DATE DD
	   ON ST.Order_dt = DD.Date_ID
	   GROUP BY ST.Customer_ID, ST.Segment, DATEPART(YEAR, DD.Date_ID)) AS src
ON (src.Customer_ID = tgt.Customer_ID AND
	src.Date_ID = tgt.Date_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Customer_ID, Date_ID, Customer_Segment, Total_Orders_Year_Customer)
	VALUES (src.Customer_ID, src.Date_ID, src.Customer_Segment, src.Total_Orders_Year_Customer)
WHEN MATCHED THEN UPDATE SET
	tgt.Customer_ID = src.Customer_ID,
	tgt.Date_ID = src.Date_ID,
	tgt.Customer_Segment = src.Customer_Segment,
	tgt.Total_Orders_Year_Customer = src.Total_Orders_Year_Customer;

--DELETE FROM FACT_Customer_Order_Cuml
-- Select * from FACT_Customer_Order_Cuml


-- Year_Sales FACT Table
MERGE INTO FACT_Year_Sales_Cuml AS tgt
USING (SELECT DATEPART(YEAR, ST.Order_dt) AS Date_ID, SUM(ST.Sales) AS Total_Sales_Year
	   FROM Staging_Table ST
	   JOIN DIM_DATE DD
	   ON ST.Order_dt = DD.Date_ID
	   GROUP BY DATEPART(YEAR, ST.Order_dt)) AS src
ON (src.Date_ID = tgt.Date_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Date_ID, Total_Sales_Year)
	VALUES (src.Date_ID, src.Total_Sales_Year)
WHEN MATCHED THEN UPDATE SET
	tgt.Date_ID = src.Date_ID,
	tgt.Total_Sales_Year = src.Total_Sales_Year;

--DELETE FROM FACT_Year_Sales_Cuml
-- Select * from FACT_Year_Sales_Cuml


-- SubCategory_Sales FACT Table
MERGE INTO FACT_SubCategory_Sales_Cuml AS tgt
USING (SELECT DS.SubCategory_ID, DATEPART(YEAR, ST.Order_dt) AS Date_ID, SUM(ST.Sales) AS Total_SubCategory_Sales_Year
	   FROM Staging_Table ST
	   JOIN DIM_SUBCATEGORY DS
	   ON ST.Subcategory = DS.SubCategory_Name
	   JOIN DIM_DATE DD
	   ON ST.Order_dt = DD.Date_ID
	   GROUP BY DS.SubCategory_ID, DATEPART(YEAR, ST.Order_dt)) AS src
ON (src.SubCategory_ID = tgt.SubCategory_ID AND
	src.Date_ID = tgt.Date_ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT (SubCategory_ID, Date_ID, Total_SubCategory_Sales_Year)
	VALUES (src.SubCategory_ID, src.Date_ID, src.Total_SubCategory_Sales_Year)
WHEN MATCHED THEN UPDATE SET
	tgt.SubCategory_ID = src.SubCategory_ID,
	tgt.Date_ID = src.Date_ID,
	tgt.Total_SubCategory_Sales_Year = src.Total_SubCategory_Sales_Year;


--DELETE FROM FACT_SubCategory_Sales_Cuml
-- Select * from FACT_SubCategory_Sales_Cuml

