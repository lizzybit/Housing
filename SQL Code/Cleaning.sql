
SELECT *
FROM housing;
 -------------------------------------------------------------------------------------------------------------------------
### Standardize Date Format

SELECT SaleDate
FROM housing
LIMIT 10;

-- Change format from mm dd, yyyy to yyyy-mm-dd
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d,%Y');

-- Change datatype from varchar to date
ALTER TABLE housing
MODIFY COLUMN SaleDate date;

SELECT SaleDate
FROM housing
LIMIT 10;

 -------------------------------------------------------------------------------------------------------------------------
### Populate Property Address Data
SELECT PropertyAddress
FROM housing
WHERE PropertyAddress IS NULL
LIMIT 10;

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

 -------------------------------------------------------------------------------------------------------------------------
### Separate PropertyAddress into Individual Columns (Address, City)
SELECT PropertyAddress
FROM housing;

-- Extract data up to and not including the comma in the PropertyAddress column
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address
FROM housing
LIMIT 10;

-- Extract the part of the string after the comma
SELECT 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as City
FROM housing
LIMIT 10;

-- Combine:
SELECT
PropertyAddress,
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as City
FROM housing
LIMIT 10;

-- Update table with new data
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

-- Drop the old column that is no longer needed

ALTER TABLE housing
DROP COLUMN PropertyAddress;

 -------------------------------------------------------------------------------------------------------------------------
### Separate OwnerAddress into Individual Columns (Address, City, State)
SELECT OwnerAddress
FROM housing;

SELECT
OwnerAddress,
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM housing
LIMIT 10;

-- Update table with new data
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

SELECT *
FROM housing;

-- Drop the old column that is no longer needed

ALTER TABLE housing
DROP COLUMN OwnerAddress;

 -------------------------------------------------------------------------------------------------------------------------
## Change Y to Yes and N to No in 'Sold as Vacant' Field

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
From housing
Group by 1
order by 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END 
From housing;

UPDATE housing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
;

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
From housing
Group by 1
order by 2;

 -------------------------------------------------------------------------------------------------------------------------
## Remove duplicates

SELECT * FROM housing
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

DELETE FROM housing
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
 -------------------------------------------------------------------------------------------------------------------------
-- Remove Unused Columns
Select *
From housing;

ALTER TABLE housing
DROP COLUMN TaxDistrict, 
DROP COLUMN LegalReference,
DROP COLUMN SaleDate;



