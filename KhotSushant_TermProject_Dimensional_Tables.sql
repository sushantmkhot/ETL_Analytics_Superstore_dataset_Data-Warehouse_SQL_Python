
/*
Below Tables Schema is for Dimensional Data Warehousing
*/
-- DROP DATABASE Superstore

-- Create the Superstore Database
--CREATE DATABASE Superstore
--go

use Superstore;

-- drop table Staging_Table

-- STAGING Table for storing all our data in one Table to further distribute to different FACT and Dimension Tables
CREATE TABLE Staging_Table(
Row_ID int IDENTITY(1,1),
Order_ID varchar(20),
Order_dt date,
Ship_dt date,
Ship_Mode varchar(20),
Customer_ID varchar(20),
Customer_Name varchar(100),
Segment varchar(20),
Country varchar(32),
City varchar(32),
State varchar(32),
Zip_Code varchar(10),
Region varchar(10),
Product_ID varchar(32),
Category varchar(32),
Subcategory varchar(32),
Product_Name varchar(255),
Sales numeric(8,2),
CONSTRAINT Superstore_RowId_PK PRIMARY KEY (Row_ID));

-- SELECT * FROM Staging_Table

/*
Dimension Tables
*/

-- Product Dimension
CREATE TABLE DIM_PRODUCT(
Product_DIM_ID int IDENTITY(1,1) NOT NULL,
Product_ID varchar(32) NOT NULL,
Product_Name varchar(255) NOT NULL,
Active_Flag varchar(1) DEFAULT 'Y' NOT NULL,
Effective_dt date DEFAULT GETDATE() NOT NULL,
Expiry_dt date,
CONSTRAINT DIM_Product_DIM_ID_PK PRIMARY KEY (Product_DIM_ID));

-- Orders Dimension
CREATE TABLE DIM_ORDERS(
Order_ID varchar(20) NOT NULL,
Order_Date date NOT NULL,
Ship_Date date NOT NULL,
Ship_Mode_Type varchar(20) NOT NULL,
CONSTRAINT DIM_Order_ID_PK PRIMARY KEY (Order_ID));

-- Customer Dimension
CREATE TABLE DIM_CUSTOMER(
Customer_ID varchar(20) NOT NULL,
Customer_Name varchar(100) NOT NULL,
Segment_Name varchar(20) NOT NULL,
CONSTRAINT DIM_Customer_ID_PK PRIMARY KEY (Customer_ID));

-- Date Dimension
CREATE TABLE DIM_DATE(
Date_ID date NOT NULL,
Date_Year numeric(4) NOT NULL,
Date_Month numeric(2) NOT NULL,
CONSTRAINT DIM_Date_ID_PK PRIMARY KEY (Date_ID));

-- Location Dimension
CREATE TABLE DIM_LOCATION(
Location_ID int IDENTITY(1,1) NOT NULL,
Region varchar(10) NOT NULL,
Country varchar(32) NOT NULL,
State varchar(32) NOT NULL,
City varchar(32) NOT NULL,
ZIPCode varchar(10) NOT NULL,
CONSTRAINT DIM_Location_ID_PK PRIMARY KEY (Location_ID));

-- Sub_Category Dimension
CREATE TABLE DIM_SUBCATEGORY(
SubCategory_ID int IDENTITY(1,1),
SubCategory_Name varchar(32) NOT NULL,
CONSTRAINT DIM_SubCategory_ID_PK PRIMARY KEY (SubCategory_ID));


/*
FACT Tables
*/

-- Product_Sales_Cumulative Fact table
CREATE TABLE FACT_Product_Sales_Cuml(
Product_DIM_ID int NOT NULL,
Location_ID int NOT NULL,
Total_Product_Sales_Loc numeric(8,2) NOT NULL,
CONSTRAINT FACT_Product_Sales_Cuml_Product_Loc_ID_PK PRIMARY KEY (Product_DIM_ID, Location_ID));

-- Customer_Order_Cumulative Fact table
CREATE TABLE FACT_Customer_Order_Cuml(
Customer_ID varchar(20) NOT NULL,
Date_ID int NOT NULL,
Customer_Segment varchar(20) NOT NULL,
Total_Orders_Year_Customer int NOT NULL,
CONSTRAINT FACT_Customer_Order_Cuml_Customer_Date_ID_PK PRIMARY KEY (Customer_ID, Date_ID));

-- Order_Location Cumulative Fact table
CREATE TABLE FACT_Order_Loc_Cuml(
Order_ID varchar(20) NOT NULL,
Location_ID int NOT NULL,
Diff_Days_Ship_Order_Loc int NOT NULL,
CONSTRAINT FACT_Order_Loc_Cuml_Order_Loc_ID_PK PRIMARY KEY (Order_ID, Location_ID));

-- Location_Sales_Cumulative Fact table
CREATE TABLE FACT_Loc_Sales_Cuml(
Location_ID int NOT NULL,
Date_ID varchar(10) NOT NULL,
Avg_Sales_Loc_Month_Year numeric(8,2) NOT NULL,
Total_Orders_Loc_Month_Year int NOT NULL,
CONSTRAINT FACT_Loc_Sales_Cuml_Loc_Date_ID_PK PRIMARY KEY (Location_ID, Date_ID));

-- Year_Sales_Cumulative Fact table
CREATE TABLE FACT_Year_Sales_Cuml(
Date_ID int NOT NULL,
Total_Sales_Year numeric(8,2) NOT NULL,
CONSTRAINT FACT_Year_Sales_Cuml_Date_ID_PK PRIMARY KEY (Date_ID));

-- SubCategory_Sales_Cumulative Fact table
CREATE TABLE FACT_Subcategory_Sales_Cuml(
SubCategory_ID int NOT NULL,
Date_ID int NOT NULL,
Total_SubCategory_Sales_Year numeric(8,2) NOT NULL,
CONSTRAINT FACT_Subcategory_Sales_Cuml_SubCategory_Date_ID_PK PRIMARY KEY (SubCategory_ID, Date_ID));
