/*

Data Cleaning using SQL

*/

### Standardize Date Format

SELECT SaleDate
FROM housing;

-- Change format from mm dd, yyyy to yyyy-mm-dd
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');

-- Change datatype from varchar to date
ALTER TABLE housing
MODIFY COLUMN SaleDate date;

### Populate Property Address Data
SELECT PropertyAddress
FROM housing
WHERE PropertyAddress IS NULL;

-- Preform self join
SELECT *
FROM housing a
JOIN housing b
ON a.ParcelId = b.ParcelId AND a.UniqueId <> b.UniqueId;

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

 
