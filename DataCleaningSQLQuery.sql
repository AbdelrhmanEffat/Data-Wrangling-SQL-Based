/*

Cleaning Data in SQL Queries

*/

select *
from NashvilleHousing


------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

--update NashvilleHousing
--set SaleDate = convert(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

-------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from NashvilleHousing
-- where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitedAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



Alter Table NashvilleHousing
Add PropertySplitedCity Nvarchar(255);

update NashvilleHousing
set PropertySplitedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select *
from NashvilleHousing



select OwnerAddress
from NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- >> Parsename index 1 == -1 in python
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitedAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitedAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



Alter Table NashvilleHousing
Add OwnerSplitedCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitedCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



Alter Table NashvilleHousing
Add OwnerSplitedState Nvarchar(255);

update NashvilleHousing
set OwnerSplitedState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



select *
from NashvilleHousing

--------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in 'Sold as Vacant'


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2



select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
End
from NashvilleHousing


Update NashvilleHousing
set SoldAsVacant =
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
End


--------------------------------------------------------------------------------------


-- Removing Duplicates


With RowNumCTE as(
select *,
ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
from NashvilleHousing
--order by ParcelID
)
--DELETE
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from NashvilleHousing


Alter Table NashvilleHousing
DROP Column OwnerAddress, PropertyAddress, TaxDistrict

Alter Table NashvilleHousing
DROP Column SaleDate