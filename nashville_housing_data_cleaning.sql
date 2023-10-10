-- Poplate property adress data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM housing as a
join housing as b
    on a.ParcelID = b.ParcelID
    and a."UniqueID " <> b."UniqueID "
WHERE a.PropertyAddress IS NULL;

UPDATE housing AS a
SET PropertyAddress = (
    SELECT b.PropertyAddress
    FROM housing AS b
    WHERE a.ParcelID = b.ParcelID
      AND b.PropertyAddress IS NOT NULL
      AND a.PropertyAddress IS NULL
    LIMIT 1
)
WHERE EXISTS (
    SELECT 1
    FROM housing AS b
    WHERE a.ParcelID = b.ParcelID
      AND b.PropertyAddress IS NOT NULL
      AND a.PropertyAddress IS NULL
);


-- Breaking out address into individual columns (Address, City, State)

SELECT
substring(PropertyAddress, 0, charindex(',', PropertyAddress)) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1,length(PropertyAddress)) as Adress
FROM housing;

ALTER TABLE housing
ADD Property_Split_Address Nvarchar(255);

UPDATE housing
SET Property_Split_Address = substring(PropertyAddress, 0, charindex(',', PropertyAddress));

ALTER TABLE housing
ADD Property_Split_City Nvarchar(255);

UPDATE housing
set Property_Split_City = substring(PropertyAddress, charindex(',', PropertyAddress)+1,length(PropertyAddress));



-- Breaking out OwnerAddress into individual columns (Owner_Split_Address, Owner_Split_City, Owner_Split_State)

ALTER TABLE housing
ADD Owner_Split_Address Nvarchar(255);

UPDATE housing
SET Owner_Split_Address = substring(OwnerAddress, 0, charindex(',', OwnerAddress));

ALTER TABLE housing
ADD Owner_Split_City Nvarchar(255);

UPDATE housing
SET Owner_split_city = SUBSTR(OwnerAddress, CHARINDEX(', ', OwnerAddress) + 2, CHARINDEX(', ', OwnerAddress, CHARINDEX(', ', OwnerAddress) + 1) - CHARINDEX(', ', OwnerAddress) - 2);

ALTER TABLE housing
ADD Owner_Split_State Nvarchar(5);

UPDATE housing
SET Owner_split_state = SUBSTR(OwnerAddress, CHARINDEX(', ', OwnerAddress, CHARINDEX(', ', OwnerAddress) + 1) + 2);



-- Change Y and N to Yes and NO in "Sold as Vacant" field

SELECT distinct SoldAsVacant, count(SoldAsVacant)
FROM housing
group by SoldAsVacant


UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
            END


--Remove duplicates

ALTER TABLE housing ADD COLUMN row_number INTEGER;

UPDATE housing
SET row_number = (
    SELECT row_num
    FROM (
        SELECT
            row_number() over (
                partition by ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
                order by "UniqueID "
            ) AS row_num,
            "UniqueID "
        FROM housing
    ) AS subquery
    WHERE subquery."UniqueID " = housing."UniqueID "
);

DELETE FROM housing
Where row_number = 2;

ALTER TABLE housing
DROP COLUMN row_number


-- Delete unused columns

ALTER TABLE housing
DROP COLUMN TaxDisctrict

ALTER TABLE housing
DROP COLUMN PropertyAddress

ALTER TABLE housing
DROP COLUMN OwnerAddress

ALTER TABLE housing
DROP COLUMN SaleDate
