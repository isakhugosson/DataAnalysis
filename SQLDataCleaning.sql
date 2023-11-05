/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM isakdb.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select Saledate, CONVERT(Date,SaleDate)
FROM isakdb.dbo.NashvilleHousing

Select SaledateConverted, CONVERT(Date,SaleDate)
FROM isakdb.dbo.NashvilleHousing

UPDATE isakdb.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE isakdb.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM isakdb.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM isakdb.dbo.NashvilleHousing a 
JOIN isakdb.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM isakdb.dbo.NashvilleHousing a 
JOIN isakdb.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM isakdb.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM isakdb.dbo.NashvilleHousing

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE isakdb.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE isakdb.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))





SELECT OwnerAddress
FROM isakdb.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM isakdb.dbo.NashvilleHousing

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE isakdb.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE isakdb.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE isakdb.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE isakdb.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



----------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM isakdb.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM isakdb.dbo.NashvilleHousing


UPDATE isakdb.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM isakdb.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE *
FROM RowNumCTE
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
FROM isakdb.dbo.NashvilleHousing

ALTER TABLE isakdb.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


