
Select * 
From PortofolioProject..NashvilleHousing

-- STANDARIZE DATE FORMAT

Select SaleDate, CONVERT(date, SaleDate)
From PortofolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate) -- it did not work properly

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address

select PropertyAddress
from PortofolioProject..NashvilleHousing
where PropertyAddress is null -- checking NULL

select UniqueID, ParcelID, PropertyAddress
from PortofolioProject..NashvilleHousing
--where PropertyAddress is null 

select a.ParcelID, a.PropertyAddress, b.ParcelID,  b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual column (address, city, state)

select PropertyAddress
from PortofolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 
from PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress date

ALTER TABLE NashvilleHousing
Drop column PropertySplitAddress

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

select OwnerAddress
from PortofolioProject..NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1) 

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortofolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortofolioProject..NashvilleHousing

UPDATE NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortofolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

-- Remove duplicate

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortofolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from PortofolioProject..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1

-- Delete unused columns

Select * 
From PortofolioProject..NashvilleHousing

alter table PortofolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate