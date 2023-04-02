-- Unused code

### Standardize Date Format
-- Remove commas,
SELECT REPLACE(SaleDate,',','') AS SaleDate
FROM housing;

SELECT STR_TO_DATE('May 1 2013','%M %d %Y');






