-- Cleaning Data SQL Queries

Select * 
From Triii.dbo.housing

-- Standardize Date Format
Select SaleDateNew, CONVERT(date,SaleDate) 
From Triii.dbo.housing

update housing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE housing
Add SaleDateNew date;

Update housing
Set SaleDateNew = CONVERT(Date,SaleDate)


-- Populate Property Address data


Select * 
From Triii.dbo.housing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Triii.dbo.housing a
JOIN Triii.dbo.housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Triii.dbo.housing a
JOIN Triii.dbo.housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-- Breaking out Address into Individiual Columns (Address, City, State)

--Splitting PropetyAddress
Select PropertyAddress
From Triii.dbo.housing
order by ParcelID 

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) As Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
From Triii.dbo.housing
order by ParcelID 

ALTER TABLE housing
Add PropertyNewAddress Nvarchar(255);

Update housing
Set PropertyNewAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE housing
Add City Nvarchar(255);

Update housing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--Splitting OwnerAddress

Select OwnerAddress
From Triii.dbo.housing
order by ParcelID 

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From Triii.dbo.housing
order by ParcelID 


ALTER TABLE housing
Add OwnerNewAddress Nvarchar(255);

Update housing
Set OwnerNewAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE housing
Add OwnerCity Nvarchar(255);

Update housing
Set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE housing
Add OwnerState Nvarchar(255);

Update housing
Set OwnerState = PARSENAME(Replace(OwnerAddress,',','.'), 1)


Select *
From Triii.dbo.housing
order by ParcelID 


-- Change Y and N to Yes and No in "Sold as Vacant" column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Triii.dbo.housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'Y' Then 'Yes'
		 Else SoldAsVacant
		 End
From Triii.dbo.housing

Update housing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'NO'
						Else SoldAsVacant
						End


--Remove Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 order by UniqueID
				 ) row_num

From Triii.dbo.housing
--Order  by ParcelID
)
DELETE 
From RowNumCTE
Where row_num >1


-- Delete Unused Columns

Select *
From Triii.dbo.housing
order by ParcelID


Alter Table Triii.dbo.housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

EXEC sp_rename 'Triii.dbo.housing.City' , 'PropertyCity', 'COLUMN'


