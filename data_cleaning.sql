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



alter table nashvillehousing
add split_address varchar(255);

update nashvillehousing
set split_address = SPLIT_PART(propertyaddress, ',', 1);


alter table nashvillehousing
add split_city varchar(255);

update nashvillehousing
set split_city = SPLIT_PART(propertyaddress, ',', 2);

select 
	SPLIT_PART(owneraddress,',',3) as split_state_owner,
	SPLIT_PART(owneraddress,',',2) as split_city_owner,
	SPLIT_PART(owneraddress,',',1) as split_address_owner
from 
	nashvillehousing;


alter table nashvillehousing
add split_state_owner varchar(255);

update nashvillehousing
set split_state_owner = SPLIT_PART(owneraddress,',',3);

alter table nashvillehousing
add split_city_owner varchar(255);

update nashvillehousin  g
set split_city_owner = SPLIT_PART(owneraddress,',',2);

alter table nashvillehousing
add split_address_owner varchar(255);

update nashvillehousing
set split_address_owner = SPLIT_PART(owneraddress,',',1);


-- Change y and n to yes and no in "Sold as Vacant" column

select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvillehousing
group by 1
order by 2 


update nashvillehousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
			 			when soldasvacant = 'N' then 'No'
	    	 			else soldasvacant
	     				end;
						


-- Remove duplicates using window functions and subqueries


ALTER TABLE nashvillehousing ADD COLUMN row_num NUMERIC;

UPDATE nashvillehousing
SET row_num = subquery.row_num
FROM (
  SELECT uniqueid, ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, legalreference ORDER BY uniqueid) AS row_num
  FROM nashvillehousing
) AS subquery
WHERE nashvillehousing.uniqueid = subquery.uniqueid;

delete
from nashvillehousing
where row_num > 1