-- Creating table NashvilleHousing

drop table if exists public.nashvillehousing;

create table public.nashvillehousing (
	UniqueID  numeric,
	ParcelID varchar(255),
	LandUse varchar(255),
	PropertyAddress varchar(255),
	SaleDate date,
	SalePrice numeric,
	LegalReference varchar(255),
	SoldAsVacant varchar(255),
	OwnerName varchar(255),
	OwnerAddress varchar(255),
	Acreage numeric,
	TaxDistrict varchar(255),
	LandValue numeric,
	BuildingValue numeric,
	TotalValue numeric,
	YearBuilt numeric,
	Bedrooms numeric,
	FullBath numeric,
	HalfBath numeric
);

-- Loading CSV file into nashvillehousing table

COPY nashvillehousing
FROM 'C:\Users\tparr\Desktop\Data_Cleaning\Nashville_Housing_Data.csv'
DELIMITER ';'
CSV Header;	

select * 
from nashvillehousing
limit 100;

-- populate address data 


select * 
from nashvillehousing
where propertyaddress is null;


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;


update nashvillehousing
set propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


-- Breaking out Address into individual columns (Address, City, State)

select 
    SPLIT_PART(propertyaddress, ',', 1) AS address1, 
    SPLIT_PART(propertyaddress, ',', 2) AS address2
from 
    nashvillehousing