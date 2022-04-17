/*


Portfolio Project for Cleaning Data


*/

-- To check the entire data in the dataset

Select * 
from dbo.Housing

-- The SaleDate Column has time appended to it which serves no purpose

-- Query to standardize SaleDate column by creating a new SaleDateConverted column 

Select SaleDate, CONVERT(DATE, SaleDate) 
from Housing

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE Housing
Set SaleDateConverted = CONVERT(DATE, SaleDate) 

-- Filling up the null values in Property Address Column

Select PropertyAddress 
from Housing
where PropertyAddress is NULL

Select * 
From Housing 
where PropertyAddress is NULL

      -- Populate the null values with help of corresponding ParcelID's

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Housing a
JOIN Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing a
JOIN Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


-- Dividing the PropertyAddress column into individual columns for Street_Address, Address_City using SUBSTRING()

Select *
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From Housing

ALTER TABLE Housing
ADD Property_Address Nvarchar(255)
ALTER TABLE Housing
ADD Property_City Nvarchar(255)


UPDATE Housing
SET Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

UPDATE Housing
SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select * 
From Housing

-- Splitting the OwnerAddress into 3 columns for Address,City and State using PARSENAME()

Select PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State_name,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City_name,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address_name
from Housing

ALTER TABLE HOUSING
ADD Owner_Address_name nvarchar(255)

ALTER TABLE HOUSING
ADD Owner_City_name nvarchar(255)

ALTER TABLE HOUSING
ADD Owner_State_name nvarchar(255)


UPDATE Housing
SET Owner_Address_name = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE Housing
SET Owner_City_name = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE Housing
SET Owner_State_name = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Cleaning up SoldAsVacantColumn to make it consistent i.e Replace Y/N to Yes/No

Select DISTINCT(SoldAsVacant)  
From Housing
		-- It is found that there are 4 rows Y, N , Yes, No

	-- Using Case Statement, it can be fixed

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
From Housing

UPDATE Housing
Set SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 

-- Remove the duplicates using ROW_NUMBER()

WITH DuplicateCTE AS(
Select *, 
Row_number() OVER(Partition By ParcelID,
								PropertyAddress,
								SaleDate,
								SalePrice,
								LegalReference,
								OwnerName
								Order by UniqueID) row_num
From Housing
)
DELETE
from DuplicateCTE
where row_num > 1


-- Remove the columns that are needed anymore

Select * 
from Housing

ALTER TABLE Housing
DROP Column SaleDate, PropertyAddress, OwnerAddress


     







