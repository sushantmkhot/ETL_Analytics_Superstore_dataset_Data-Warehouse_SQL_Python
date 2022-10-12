# -*- coding: utf-8 -*-
"""
Sushant Khot
Class: MET CS 779 - Advanced Database Management
Date: 02/17/2022
MET CS 779 Term Project:
Topic: ETL and Analytics of a SuperStore Dataset into Dimensional Data Warehouse using Python
"""

# Import Libraries
import os
import pyodbc
import pandas as pd
from datetime import datetime
import math


# Code to load the dataset using Relative Path
here = os.path.abspath(__file__)  # Relative Path code
input_dir = os.path.abspath(os.path.join(here, os.pardir))
superstore_dataset = os.path.join(input_dir, 'SuperStore_dataset.csv')
# superstore_dataset = "C:\\Users\\sushk\\Downloads\\BU\\MET CS 779\\Term Project\\KhotSushant_TermProject\\test.csv"


try:
    ss_df = pd.read_csv(superstore_dataset)

except Exception as e:
    print(e)
    print('failed to read Super Store data into Data Frame')


# COnnection to SQL Server
conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=ARNAVDESKTOP;'
                      'Database=Superstore;'
                      'Trusted_Connection=yes;')


# Create a cursor for SQL code execution
cursor = conn.cursor()

# We can exclude the 1st "Row ID" column as it is set as an Identity column in the Staging Table
ss_df = ss_df.iloc[:, 1:]

# Check if any columns in the dataframe have blank values
print(ss_df.isnull().any())

# We can see that the Postal Code / ZIPCode column has blank values. 
# We will handle this while inserting data in the Staging Table.

# We see that the date values have "-" and "/" as separators randomly. The date format in the csv is dd-mm-yyyy OR dd/mm/yyyy
# We will make the format consistent by replacing "/" with "-"
ss_df['Order Date'] = ss_df['Order Date'].str.replace('/','-')
ss_df['Ship Date'] = ss_df['Ship Date'].str.replace('/','-')

# Truncate the Staging Table in case we re-run this script multiple times on the same csv to avoid duplication of records.
cursor.execute('TRUNCATE TABLE dbo.Staging_Table')


# Insert DataFrame records one by one into the Staging table.
for i,row in ss_df.iterrows():
    
    # Store the row values in a Python List
    val_list = list(row)
            
    # Convert the string values to Date
    val_list[1] = datetime.strptime(val_list[1], '%d-%m-%Y')
    val_list[2] = datetime.strptime(val_list[2], '%d-%m-%Y')
    
    # Check if ZIPCode value (val_list[10]) is blank then add a default ZIPCode = 99999
    if math.isnan(val_list[10]):
        val_list[10] = 99999
    
    
    # Create the INSERT statement and execute it via the cursor connection
    # sql = "INSERT INTO dbo.Staging_ss ('" +cols + "') VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    sql = "INSERT INTO dbo.Staging_Table VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    cursor.execute(sql, val_list)


# The below code will take care of inconsitent Product Names that I found in the dataset.
# This will replace all inconsistent Product names with one of the values from the list of assigned Product Names.
# For e.g. I saw that there were 32 Product IDs which had more than 1 Product Name assigned.
cursor.execute('SELECT Product_ID FROM Staging_Table GROUP BY Product_ID HAVING COUNT(DISTINCT(Product_Name)) > 1')
prod_ID = cursor.fetchall()

for prdID in prod_ID:
    cursor.execute("SELECT TOP 1 Product_Name FROM Staging_Table WHERE Product_ID = '" + str(prdID[0]) + "'")
    prod_Name = cursor.fetchone()
    update_sql = "UPDATE Staging_Table SET Product_Name = ? WHERE Product_ID = ?"
    cursor.execute(update_sql, [str(prod_Name[0]), str(prdID[0])])


# Commit and close the connection
conn.commit()
cursor.close()
conn.close()





