--CREATE DATABASE Superstore
--go

use Superstore;

/*
Below TablesSchema are for Normalization of the database
*/

-- Sub_Category
CREATE TABLE Sub_Category(
Sub_Category_ID int IDENTITY(1,1) NOT NULL,
Sub_Category_Name varchar(32) NOT NULL,
CONSTRAINT Sub_Category_Sub_Category_ID_PK PRIMARY KEY (Sub_Category_ID));

-- Product_Cat
CREATE TABLE Product_Cat(
Category_ID int IDENTITY(1,1) NOT NULL,
Sub_Category_ID int NOT NULL,
Category_Name varchar(32) NOT NULL,
CONSTRAINT Product_Cat_Category_ID_PK PRIMARY KEY (Category_ID),
CONSTRAINT Product_Cat_SubCategory_ID_FK FOREIGN KEY (Sub_Category_ID) REFERENCES Sub_Category(Sub_Category_ID));

-- Product
CREATE TABLE Product(
Product_ID varchar(32) NOT NULL,
Product_Name varchar(255) NOT NULL,
Category_ID int NOT NULL,
CONSTRAINT Product_Product_ID_PK PRIMARY KEY (Product_ID),
CONSTRAINT Product_Category_ID_FK FOREIGN KEY (Category_ID) REFERENCES Product_Cat(Category_ID));

-- Customer_Segment
CREATE TABLE Customer_Segment(
Segment_ID int IDENTITY(1,1) NOT NULL,
Segment varchar(20) NOT NULL,
CONSTRAINT Customer_Segment_Segment_ID_PK PRIMARY KEY (Segment_ID));

-- Customer
CREATE TABLE Customer(
Customer_ID varchar(20) NOT NULL,
Customer_Name varchar(100) NOT NULL,
Segment_ID int NOT NULL,
CONSTRAINT Customer_Customer_ID_PK PRIMARY KEY (Customer_ID),
CONSTRAINT Customer_Segment_ID_FK FOREIGN KEY (Segment_ID) REFERENCES Customer_Segment(Segment_ID));

-- Shipping_Mode
CREATE TABLE Shipping_Mode(
Ship_Mode_ID int IDENTITY(1,1) NOT NULL,
Ship_Mode_Type varchar(20) NOT NULL,
CONSTRAINT Shipping_Mode_Ship_Mode_ID_PK PRIMARY KEY (Ship_Mode_ID));

-- Region
CREATE TABLE Region(
Region_ID int IDENTITY(1,1) NOT NULL,
Region varchar(10) NOT NULL,
CONSTRAINT Region_Region_ID_PK PRIMARY KEY (Region_ID));

-- Country
CREATE TABLE Country(
Country_ID int IDENTITY(1,1) NOT NULL,
Country varchar(32) NOT NULL,
CONSTRAINT Country_Country_ID_PK PRIMARY KEY (Country_ID));

-- State
CREATE TABLE State(
State_ID int IDENTITY(1,1) NOT NULL,
State varchar(32) NOT NULL,
CONSTRAINT State_State_ID_PK PRIMARY KEY (State_ID));

-- City
CREATE TABLE City(
City_ID int IDENTITY(1,1) NOT NULL,
City varchar(32) NOT NULL,
CONSTRAINT City_City_ID_PK PRIMARY KEY (City_ID));

-- ZIPCode
CREATE TABLE ZIPCode(
ZIPCode_ID int IDENTITY(1,1) NOT NULL,
Zip_Code varchar(10) NOT NULL,
Region_ID int NOT NULL,
Country_ID int NOT NULL,
State_ID int NOT NULL,
City_ID int NOT NULL,
CONSTRAINT ZIPCode_ZIPCode_ID_PK PRIMARY KEY (ZIPCode_ID),
CONSTRAINT ZIPCode_Region_ID_FK FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID),
CONSTRAINT ZIPCode_Country_ID_FK FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID),
CONSTRAINT ZIPCode_State_ID_FK FOREIGN KEY (State_ID) REFERENCES State(State_ID),
CONSTRAINT ZIPCode_City_ID_FK FOREIGN KEY (City_ID) REFERENCES City(City_ID));

-- Orders
CREATE TABLE Orders(
Order_ID varchar(20) NOT NULL,
Order_Date date NOT NULL,
Ship_Date date NOT NULL,
Sales numeric(8,2) NOT NULL,
Customer_ID varchar(20) NOT NULL,
Product_ID varchar(32) NOT NULL,
ZipCode_ID int NOT NULL,
Ship_Mode_ID int NOT NULL,
CONSTRAINT Orders_Order_ID_PK PRIMARY KEY (Order_ID),
CONSTRAINT Orders_Customer_ID_FK FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
CONSTRAINT Orders_Product_ID_FK FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
CONSTRAINT Orders_ZipCode_ID_FK FOREIGN KEY (ZipCode_ID) REFERENCES ZipCode(ZipCode_ID),
CONSTRAINT Orders_Ship_Mode_ID_FK FOREIGN KEY (Ship_Mode_ID) REFERENCES Shipping_Mode(Ship_Mode_ID));

