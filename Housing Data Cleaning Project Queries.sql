/*

Cleaning Data in SQL Queries

*/


Select *
From HousingData.dbo.Sheet;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


ALTER TABLE HousingData.dbo.Sheet
Add SaleDateConverted Date;


Update HousingData.dbo.Sheet
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- filling null values in Property Address data because property address does not has to be null


Select *
From HousingData.dbo.Sheet
Where PropertyAddress is null
order by ParcelID


-- here in table many property Address are repeated with parcelID but the uniqueID are unique

Select *
From HousingData.dbo.Sheet
order by ParcelID

 
-- found that in table that the property address having null values are also have a values with the repeated address 


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From HousingData.dbo.Sheet a
JOIN HousingData.dbo.Sheet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData.dbo.Sheet a
JOIN HousingData.dbo.Sheet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData.dbo.Sheet a
JOIN HousingData.dbo.Sheet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Select *
From HousingData.dbo.Sheet
Where PropertyAddress is null
order by ParcelID



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- 1. split property address:

Select PropertyAddress
From HousingData.dbo.Sheet


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From HousingData.dbo.Sheet 


ALTER TABLE HousingData.dbo.Sheet
Add PropertySplitAddress Nvarchar(255);

Update HousingData.dbo.Sheet
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingData.dbo.Sheet
Add PropertySplitCity Nvarchar(255);

Update HousingData.dbo.Sheet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From HousingData.dbo.Sheet



-- 2. Split owner address:


Select OwnerAddress
From HousingData.dbo.Sheet


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingData.dbo.Sheet



ALTER TABLE HousingData.dbo.Sheet
Add OwnerSplitAddress Nvarchar(255);

Update HousingData.dbo.Sheet
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE HousingData.dbo.Sheet
Add OwnerSplitCity Nvarchar(255);

Update HousingData.dbo.Sheet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE HousingData.dbo.Sheet
Add OwnerSplitState Nvarchar(255);

Update HousingData.dbo.Sheet
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From HousingData.dbo.Sheet




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select SoldAsVacant,count(SoldAsVacant)
From HousingData.dbo.Sheet
Group by SoldAsVacant
order by count(SoldAsVacant)




Select SoldAsVacant,
  CASE 
       When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
From HousingData.dbo.Sheet


Update HousingData.dbo.Sheet
SET SoldAsVacant = CASE 
       When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice, 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From HousingData.dbo.Sheet
)
Select *
From RowNumCTE
Where row_num > 1




WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice, 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From HousingData.dbo.Sheet
)
delete
From RowNumCTE
Where row_num > 1



Select *
From HousingData.dbo.Sheet




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From HousingData.dbo.Sheet 


ALTER TABLE HousingData.dbo.Sheet
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
















