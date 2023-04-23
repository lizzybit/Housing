<p align = "center">
 <img src="https://user-images.githubusercontent.com/128324837/229577184-6a0a9129-b989-490e-b11d-04fdd2cfec72.jpg" width=70% height=70%>
</p>

# Cleaning Housing Data Using SQL

## Table of Contents
- [1. Background and Motivation](#1-background-and-motivation)
- [2. Data Retrieval](#2-data-retrieval)
- [3. Import Data into mySQL](#3-import-data-into-mysql)
- [4. Data Cleaning](#4-data-cleaning)
  * [4.1 Standardize Date Format](#41-standardize-date-format)
  * [4.2 Populate Property Address Data](#42-populate-property-address-data)
  * [4.3 Separate PropertyAddress into Individual Columns: Address, City](#43-separate-propertyaddress-into-individual-columns)
  * [4.4 Separate OwnerAddress into Individual Columns: Address, City, State](#44-separate-owneraddress-into-individual-columns)
  * [4.5 Change Y to Yes and N to No in SoldAsVacant Field](#45-change-y-to-yes-and-n-to-no-in-soldasvacant-field)
  * [4.7 Remove Dulicates](#47-remove-dulicates)
  * [4.8 Remove Unused Columns](#48-remove-unused-columns)
- [5. Summary/Conclusion](#5-summaryconclusion)


## 1. Background and Motivation
<p align = "justify"> 
Data cleaning is an essential process in preparing data for analysis. SQL is a powerful tool that can be used to achieve this task. In this project, we explore the use of SQL to clean and transform a dataset of house sales. The dataset contains various data quality issues which can impact the accuracy and reliability of the insights derived from the data analysis, making data cleaning a crucial step in the data analysis process.</p>
<p align = "justify"> 
Through the use of SQL queries, we aim to transform the dataset into a format that is suitable for analysis. We will explore various SQL techniques to correct date formats, populate missing data, remove duplicates, and fix other data quality issues. Our focus is on the use of SQL as a data cleaning tool, with the goal of improving the quality of the data and ensuring that it is fit for analysis.</p>
<p align = "justify"> 
The house sales dataset used in this project contains information on various aspects of house sales, such as the sale price, sale date, property address, and more. The dataset is representative of the type of data that organizations collect and analyze to gain insights into their business operations, and the data quality issues present in the dataset are common challenges faced by data analysts.</p>

## 2. Data Retrieval

The dataset used in the project is available at: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
<p align = "justify"> 
The dataset consists of one file that contains information on 20,000 real estate properties, including their addresses, sale prices, number of bedrooms and bathrooms, square footage, year built and other features. </p>
<p align = "justify"> 
It is worth noting that the data in this dataset is publicly available, so there may be limitations to its accuracy or completeness. Additionally, as with any dataset, it's important to carefully review and clean the data before using it for analysis to ensure its quality and reliability.</p>

## 3. Import Data into mySQL
Download the raw .xlsx file and convert to .csv

Create new schema and import csv data:
 ``` sql
 CREATE SCHEMA `nashville_housing`;
 
 CREATE TABLE housing (
	UniqueID integer,
	ParcelID varchar(255),
	LandUse varchar(255),
    PropertyAddress varchar(255),
    SaleDate varchar(255),
    SalePrice integer,
    LegalReference varchar(255),
    SoldAsVacant varchar(255),
    OwnerName varchar(255),
    OwnerAddress varchar(255),
    Acreage integer,
    TaxDistrict varchar(255),
    LandValue integer,
    BuildingValue integer,
    TotalValue integer,
    YearBuilt integer,
    Bedrooms integer,
    FullBath integer,
    HalfBath integer
    );

LOAD DATA LOCAL INFILE '/Users/elizabeth/Documents/GitHub/NashvilleHousing/Nashville Housing Data.csv'
INTO TABLE housing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM housing;
 ```

## 4. Data Cleaning

### 4.1 Standardize Date Format
 ```sql
SELECT SaleDate
FROM housing
LIMIT 10;
 ```
-- Output
| SaleDate           |
| ------------------ |
| April 9, 2013      |
| June 10, 2014      |
| September 26, 2016 |
| January 29, 2016   |
| October 10, 2014   |
| July 16, 2014      |
| August 28, 2014    |
| September 27, 2016 |
| August 14, 2015    |
| August 29, 2014    |

Change format from mm dd, yyyy to yyyy-mm-dd:
 ``` sql
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');
 ```
Change datatype from varchar to date:
 ``` sql
ALTER TABLE housing
MODIFY COLUMN SaleDate date;

SELECT SaleDate
FROM housing
LIMIT 10;
 ```
-- Output
| SaleDate   |
| ---------- |
| 2013-04-09 |
| 2014-06-10 |
| 2016-09-26 |
| 2016-01-29 |
| 2014-10-10 |
| 2014-07-16 |
| 2014-08-28 |
| 2016-09-27 |
| 2015-08-14 |
| 2014-08-29 |

### 4.2 Populate Property Address Data
 ``` sql
SELECT PropertyAddress
FROM housing
WHERE PropertyAddress IS NULL
LIMIT 10;
 ```
-- Output

| PropertyAddress |
| --------------- |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |
| NULL            |

Preform self join:
 ``` sql
SELECT *
FROM housing a
JOIN housing b
ON a.ParcelId = b.ParcelId AND a.UniqueId <> b.UniqueId;
 ```
Update the PropertyAddress column in the housing table with non-NULL values from the same column in another row with the same ParcelId but different UniqueId where PropertyAddress is NULL:
 ``` sql
UPDATE housing a
JOIN housing b
ON a.ParcelId = b.ParcelId AND a.UniqueId <> b.UniqueId
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

SELECT a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b
ON a.ParcelId = b.ParcelId AND a.UniqueId <> b.UniqueId
WHERE a.PropertyAddress IS NULL;
 ```
-- Output
| PropertyAddress |
| --------------- |
|                 |
|                 |
|                 |
|                 |
|                 |
|                 |
|                 |
|                 |
|                 |
|                 |

### 4.3 Separate PropertyAddress into Individual Columns

 ``` sql
SELECT PropertyAddress
FROM housing;
 ```
Extract data up to and not including the comma in the PropertyAddress column:
 ``` sql
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address
FROM housing
LIMIT 10;
 ```

Extract the part of the string after the comma:
 ``` sql
SELECT 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as City
FROM housing
LIMIT 10;
 ```
 Combine:
 ``` sql
SELECT
PropertyAddress,
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as City
FROM housing
LIMIT 10;
 ```
 -- Output
| PropertyAddress                       | Address               | City            |
| ------------------------------------- | --------------------- | --------------- |
| 1808  FOX CHASE DR, GOODLETTSVILLE    | 1808  FOX CHASE DR    |  GOODLETTSVILLE |
| 1832  FOX CHASE DR, GOODLETTSVILLE    | 1832  FOX CHASE DR    |  GOODLETTSVILLE |
| 1864 FOX CHASE  DR, GOODLETTSVILLE    | 1864 FOX CHASE  DR    |  GOODLETTSVILLE |
| 1853  FOX CHASE DR, GOODLETTSVILLE    | 1853  FOX CHASE DR    |  GOODLETTSVILLE |
| 1829  FOX CHASE DR, GOODLETTSVILLE    | 1829  FOX CHASE DR    |  GOODLETTSVILLE |
| 1821  FOX CHASE DR, GOODLETTSVILLE    | 1821  FOX CHASE DR    |  GOODLETTSVILLE |
| 2005  SADIE LN, GOODLETTSVILLE        | 2005  SADIE LN        |  GOODLETTSVILLE |
| 1917 GRACELAND  DR, GOODLETTSVILLE    | 1917 GRACELAND  DR    |  GOODLETTSVILLE |
| 1428  SPRINGFIELD HWY, GOODLETTSVILLE | 1428  SPRINGFIELD HWY |  GOODLETTSVILLE |
| 1420  SPRINGFIELD HWY, GOODLETTSVILLE | 1420  SPRINGFIELD HWY |  GOODLETTSVILLE |

Update table with new data:
 ``` sql
ALTER TABLE housing
Add PropertyAddressSplit varchar(255);

Update housing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE housing
Add PropertyCitySplit varchar(255);

Update housing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));
 ```
Drop the old column that is no longer needed:
 ``` sql
ALTER TABLE housing
DROP COLUMN PropertyAddress;
 ```
 
### 4.4 Separate OwnerAddress into Individual Columns
``` sql
SELECT
OwnerAddress,
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM housing
LIMIT 10;
```
-- Output
| OwnerAddress                              | Address               | City            | State |
| ----------------------------------------- | --------------------- | --------------- | ----- |
| 1808  FOX CHASE DR, GOODLETTSVILLE, TN    | 1808  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 1832  FOX CHASE DR, GOODLETTSVILLE, TN    | 1832  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 1864  FOX CHASE DR, GOODLETTSVILLE, TN    | 1864  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 1853  FOX CHASE DR, GOODLETTSVILLE, TN    | 1853  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 1829  FOX CHASE DR, GOODLETTSVILLE, TN    | 1829  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 1821  FOX CHASE DR, GOODLETTSVILLE, TN    | 1821  FOX CHASE DR    |  GOODLETTSVILLE |  TN   |
| 2005  SADIE LN, GOODLETTSVILLE, TN        | 2005  SADIE LN        |  GOODLETTSVILLE |  TN   |
| 1917  GRACELAND DR, GOODLETTSVILLE, TN    | 1917  GRACELAND DR    |  GOODLETTSVILLE |  TN   |
| 1428  SPRINGFIELD HWY, GOODLETTSVILLE, TN | 1428  SPRINGFIELD HWY |  GOODLETTSVILLE |  TN   |
| 1420  SPRINGFIELD HWY, GOODLETTSVILLE, TN | 1420  SPRINGFIELD HWY |  GOODLETTSVILLE |  TN   |

Update table with new data:
 ``` sql
ALTER TABLE housing
Add OwnerAddressSplit varchar(255);

Update housing
SET OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE housing
Add OwnerCitySplit varchar(255);

Update housing
SET OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE housing
Add OwnerStateSplit varchar(255);

Update housing
SET OwnerStateSplit = SUBSTRING_INDEX(OwnerAddress, ',', -1);
 ```
Drop the old column that is no longer needed:
 ``` sql
ALTER TABLE housing
DROP COLUMN OwnerAddress;
```
### 4.5 Change Y to Yes and N to No in SoldAsVacant Field

``` sql
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
From housing
Group by 1
order by 2;
```
-- Output
| SoldAsVacant | Count(SoldAsVacant) |
| ------------ | ------------------- |
| No           | 52                  |
| N            | 399                 |
| Yes          | 4623                |
| Y            | 51403               |

``` sql
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END 
FROM housing;
```
Update table with cleaned data:
``` sql
UPDATE housing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END;

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
From housing
Group by 1
order by 2;
```
 -- Output
| SoldAsVacant | COUNT(SoldAsVacant) |
| ------------ | ------------------- |
| Yes          | 4675                |
| No           | 51802               |

### 4.7 Remove Dulicates

Find duplicate rows:
``` sql
SELECT * 
FROM housing
WHERE UniqueID NOT IN (
   SELECT UniqueID 
   FROM (
      SELECT *, 
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID, SalePrice, SaleDate, LegalReference 
      ORDER BY UniqueID
   ) AS row_num 
   FROM housing
) AS sub
WHERE row_num = 1
);

SELECT COUNT(*)
FROM housing;
```
Remove duplicate rows:
``` sql
DELETE 
FROM housing
WHERE UniqueID NOT IN (
   SELECT UniqueID 
   FROM (
      SELECT *, 
      ROW_NUMBER() OVER (
      PARTITION BY ParcelID, SalePrice, SaleDate, LegalReference 
      ORDER BY UniqueID
   ) AS row_num 
   FROM housing
) AS sub
WHERE row_num = 1
);

SELECT COUNT(*)
FROM housing;
```

### 4.8 Remove Unused Columns

``` sql
ALTER TABLE housing
DROP COLUMN TaxDistrict, 
DROP COLUMN LegalReference,
DROP COLUMN SaleDate;
```


## 5. Summary/Conclusion
<p align = "justify"> 
In this project, SQL was used to clean and transform a dataset of house sales. The dataset used contained various data quality issues that could impact the accuracy and reliability of the insights derived from the data analysis, making data cleaning a crucial step in the data analysis process. SQL queries were used to transform the dataset into a format suitable for analysis.</p>
<p align = "justify"> 
The house sales dataset used in this project contained information on various aspects of house sales, such as the sale price, sale date, property address, and more. The dataset was representative of the type of data that organizations collect and analyze to gain insights into their business operations and the data quality issues present in the dataset were common challenges faced by data analysts. The cleaning steps involved the standardization of date format, population of missing data, separation of address fields, change in format, and removal of duplicates and unused columns. The process significantly improved the quality of the data, making it suitable for analysis.</p>
