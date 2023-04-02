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
Change format from mm dd, yyyy to yyyy-mm-dd
 ``` sql
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');
 ```
Change datatype from varchar to date
 ``` sql
ALTER TABLE housing
MODIFY COLUMN SaleDate date;
 ```
