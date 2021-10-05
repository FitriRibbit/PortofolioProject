/* Cleaning Data in SQL Queries */

SELECT *
FROM PortofolioProject.dbo.NashHousing

-- Standarize data format
SELECT SaleDateConverted , CONVERT(Date, SaleDate)
FROM PortofolioProject.dbo.NashHousing

UPDATE NashHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortofolioProject.dbo.NashHousing 
Add SaleDateConverted Date;

UPDATE PortofolioProject.dbo.NashHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Adress Data 
SELECT *
FROM PortofolioProject.dbo.NashHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT n.ParcelID, n.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (n.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject.dbo.NashHousing n
JOIN PortofolioProject.dbo.NashHousing b
	ON n.ParcelID = b.ParcelID
	AND n.[UniqueID] <> b.[UniqueID]
WHERE n.PropertyAddress is NULL

SELECT n.ParcelID, n.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (n.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject.dbo.NashHousing n
JOIN PortofolioProject.dbo.NashHousing b
	ON n.ParcelID = b.ParcelID
	AND n.[UniqueID] <> b.[UniqueID]
WHERE n.PropertyAddress is NOT NULL

UPDATE n
SET PropertyAddress = ISNULL (n.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject.dbo.NashHousing n
JOIN PortofolioProject.dbo.NashHousing b
	ON n.ParcelID = b.ParcelID
	AND n.[UniqueID] <> b.[UniqueID]
WHERE n.PropertyAddress is NULL



-- Breaking out address into individual colums (Address, City and State)
SELECT PropertyAddress
FROM PortofolioProject.dbo.NashHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
--CHARINDEX(',', PropertyAddress) 
FROM PortofolioProject.dbo.NashHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortofolioProject.dbo.NashHousing

ALTER TABLE PortofolioProject.dbo.NashHousing 
Add PropertySplitAddress NVarchar(255);

UPDATE PortofolioProject.dbo.NashHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortofolioProject.dbo.NashHousing 
Add PropertySplitCity NVarchar(255);

UPDATE PortofolioProject.dbo.NashHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT *
FROM PortofolioProject.dbo.NashHousing


SELECT OwnerAddress
FROM PortofolioProject.dbo.NashHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE (OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE (OwnerAddress,',', '.'),1)
FROM PortofolioProject.dbo.NashHousing


ALTER TABLE PortofolioProject.dbo.NashHousing 
Add OwnerSplitAddress NVarchar(255);

UPDATE PortofolioProject.dbo.NashHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE (OwnerAddress,',', '.'),3) 

ALTER TABLE PortofolioProject.dbo.NashHousing 
Add OwnerSplitCity NVarchar(255);

UPDATE PortofolioProject.dbo.NashHousing
SET OwnerSplitCity =  PARSENAME(REPLACE (OwnerAddress,',', '.'),2) 

ALTER TABLE PortofolioProject.dbo.NashHousing 
Add OwnerSplitState NVarchar(255);

UPDATE PortofolioProject.dbo.NashHousing
SET OwnerSplitState =  PARSENAME(REPLACE (OwnerAddress,',', '.'),1) 


SELECT *
FROM PortofolioProject.dbo.NashHousing


-- Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT Distinct(SoldAsVacant), COUNT (SoldAsVacant)
FROM PortofolioProject.dbo.NashHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortofolioProject.dbo.NashHousing


UPDATE PortofolioProject.dbo.NashHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Remove Duplicate 
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) Row_Num
FROM PortofolioProject.dbo.NashHousing
--ORDER BY ParcelID
)


SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress


-- Delete Unused Column 

SELECT *
FROM PortofolioProject.dbo.NashHousing

ALTER TABLE PortofolioProject.dbo.NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortofolioProject.dbo.NashHousing
DROP COLUMN SaleDate

