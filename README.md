# NashvilleHousing
 

## x. Import Data into mySQL
Download the raw .xlsx file and convert to .csv
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
 
 
 
 
 
## x. Data Cleaning

### Standardize Date Format
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

Change format from mm dd, yyyy to yyyy-mm-dd
 ``` sql
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');
 ```
Change datatype from varchar to date
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

 ### Populate Property Address Data
 ``` sql
SELECT PropertyAddress
FROM housing
WHERE PropertyAddress IS NULL
LIMIT 10;
 ```
#### Output
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

### Separare Address into Individual Columns (Address, City, State)
 ``` sql
SELECT PropertyAddress
FROM housing;
 ```
Extract data up to and not including the comma in the PropertyAddress column:
 ``` sql
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address
FROM housing;
 ```
Extract the part of the string after the comma:
 ``` sql
SELECT 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as City
FROM housing;
 ```
 
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

SELECT *
FROM housing;
 ```

