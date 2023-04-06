--Cleaning data in SQL

Select *
From [Data Cleaning]..Nashvillehousing 

--Change SaleDate

Select SaleDate2, CONVERT(Date,SaleDate)
From [Data Cleaning]..Nashvillehousing 


ALTER TABLE Nashvillehousing
Add SaleDate2 Date;

update Nashvillehousing 
SET SaleDate2 = CONVERT(Date,SaleDate)


--Populate Property Address Area

Select * 
From [Data Cleaning]..Nashvillehousing 
--where PropertyAddress is null
order by ParcelID 



Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
From [Data Cleaning]..Nashvillehousing AS a
Join [Data Cleaning]..Nashvillehousing AS b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ]  <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning]..Nashvillehousing AS a
Join [Data Cleaning]..Nashvillehousing AS b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ]<> b.[UniqueID ]


--Breaking out the address into individual columns (Address, City, State)

select PropertyAddress 
from [Data Cleaning]..Nashvillehousing 


Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [Data Cleaning]..Nashvillehousing 

ALTER TABLE Nashvillehousing
Add PropertysplitAddress Nvarchar(255);

update Nashvillehousing 
SET PropertysplitAddress = 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashvillehousing
Add PropertysplitCity Nvarchar(255);

update Nashvillehousing 
SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



--splitting OwnerAddress

select OwnerAddress
from [Data Cleaning]..Nashvillehousing 

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), +3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), +2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), +1)
from [Data Cleaning]..Nashvillehousing 

ALTER TABLE Nashvillehousing
Add OwnersplitCity Nvarchar(255);

update Nashvillehousing 
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), +3)

ALTER TABLE Nashvillehousing
Add OwnersplitAddress Nvarchar(255);

update Nashvillehousing 
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), +2)

ALTER TABLE Nashvillehousing
Add OwnersplitState Nvarchar(255);

update Nashvillehousing 
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), +1)



--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Data Cleaning]..Nashvillehousing
group by SoldAsVacant 
Order by 2


Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END
from [Data Cleaning]..Nashvillehousing

update Nashvillehousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END
from [Data Cleaning]..Nashvillehousing


--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
				) row_num
from [Data Cleaning]..Nashvillehousing
)

Delete 
From RowNumCTE
where row_num >1
--order by PropertyAddress



--Delete Unused Columns

Select *
from [Data Cleaning]..Nashvillehousing 

ALTER TABLE [Data Cleaning]..Nashvillehousing 
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE [Data Cleaning]..Nashvillehousing 
DROP COLUMN SaleDate