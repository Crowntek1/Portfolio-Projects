
select *
from PostfolioProject.dbo.NashvilleHousing
order by 2,3

-- selecting the SaleDate column

select SaleDate 
from PostfolioProject..NashvilleHousing

--standardizing the SaleDate format
select SaleDate, Convert(Date, SaleDate)
from PostfolioProject..NashvilleHousing


Update NashvilleHousing
set SaleDate = Convert(Date, SaleDate)
from PostfolioProject..NashvilleHousing  -- not working

Alter Table NashvilleHousing
add SaleDateConverted Date


Update NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)
from PostfolioProject..NashvilleHousing

select SaleDateConverted, Convert(Date, SaleDate)
from PostfolioProject..NashvilleHousing

-- populate PropertyAddress data
select PropertyAddress
from PostfolioProject..NashvilleHousing

--checking for where PropertyAddress is null
select PropertyAddress
from PostfolioProject..NashvilleHousing
where PropertyAddress is null

select *
from PostfolioProject..NashvilleHousing
where PropertyAddress is null

select *
from PostfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--joining the table to itself by ParcelID and uniqueId

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from PostfolioProject..NashvilleHousing a
Join PostfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null 

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) 
from PostfolioProject..NashvilleHousing a
Join PostfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null 


--breaking out address into individual columns (address, city, state)
select PropertyAddress
from PostfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)) as address
from PostfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address
from PostfolioProject..NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as address
from PostfolioProject..NashvilleHousing


Alter Table NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)
from PostfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))
from PostfolioProject..NashvilleHousing

select *
from PostfolioProject..NashvilleHousing

select
parsename(OwnerAddress, 1)
from PostfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.'), 3), 
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PostfolioProject..NashvilleHousing


Alter Table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)
from PostfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)
from PostfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)
from PostfolioProject..NashvilleHousing


--change Y and N to Yes and No in the SoldAsVacant column
-- firstly check for occurances of N, No, Y, and Yes
select distinct(SoldAsVacant), count(SoldAsVacant)
from PostfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

-- using case statement to change all N and Y to NO and Yes respectively
select SoldAsVacant
,case when SoldAsVacant = 'N' then 'No'
      when SoldAsVacant = 'Y' then 'Yes'
	  else SoldAsVacant
	  end
from PostfolioProject..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
      when SoldAsVacant = 'Y' then 'Yes'
	  else SoldAsVacant
	  end


--confirm the update
select distinct(SoldAsVacant), count(SoldAsVacant)
from PostfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

--remove duplicate


with RowNumCTE as (
select*,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalesPrice,
				 SalesDate,
				 LegalPreference
				 order by
				 UniqueID
				 )row_num
from PostfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

--deleting unused columns
select *
from PostfolioProject..NashvilleHousing

Alter Table PostfolioProject..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PostfolioProject..NashvilleHousing
Drop column SaleDate
