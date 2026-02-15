select * from PortfolioProject..NashvilleHousing

--(Standardize date format)
select SaleDateConverted, CONVERT(date,saledate) 
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = CONVERT(date,saledate)


--(Populating Property Address data)
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--Identifying dupliacte data through ParcelID and populating the null Property Address
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--[Breaking out Address into individual columns (Address, City, State)]
select propertyaddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add AddressSplit nvarchar(255)

update NashvilleHousing
set AddressSplit = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add CitySplit nvarchar(255)

update NashvilleHousing
set CitySplit = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from PortfolioProject..NashvilleHousing


--Using simpler way of breaking the Address
select owneraddress from PortfolioProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,--parsename considers only periods, not commas
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerCity nvarchar (255), OwnerState nvarchar (255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

	select * from PortfolioProject..NashvilleHousing



--(Changing Y and N to Yes and No in 'SoldAsVacant' field)
select distinct(soldasvacant)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end 

select soldasvacant from PortfolioProject..NashvilleHousing



--(Remove Duplicates)
select * from PortfolioProject..NashvilleHousing;

with RowNumCTE as (
select *,  
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	order by uniqueID
	) row_num
from PortfolioProject..NashvilleHousing
)
delete from RowNumCTE
where row_num > 1


--(Deleting unused column)

alter table portfolioproject..nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolioproject..nashvillehousing
drop column saledate

select * from PortfolioProject..NashvilleHousing

