/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate) 
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add  SaleDateConverted Date;
 
Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate) 

-- Population Property Address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On  a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On  a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking down Address into Individual Columns (Address,City & State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress2 Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress2 = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity1 Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity1 = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState1 Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState1= PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
 Case When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End
From PortfolioProject..NashVilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End


--Remove Duplicates
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By UniqueID
	) Row_num
From PortfolioProject..NashVilleHousing
)

Select *
From RowNumCTE
Where Row_num > 1
Order By PropertyAddress

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By UniqueID
	) Row_num
From PortfolioProject..NashVilleHousing
)

Delete
From RowNumCTE
Where Row_num > 1


--Delete Unused Columns

Select *
From PortfolioProject..NashVilleHousing

Alter Table PortfolioProject..NashVilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate


Alter Table PortfolioProject..NashVilleHousing
Drop column SaleDate
