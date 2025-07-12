---Dealing with Type 2 Changes

---Checking for changes i  price 

--Step 1: Change 1 of the prices 


 ---Adding date valid from and valid until to the Status column to DS and DW
    ALTER TABLE Product_Dimension
    ADD DVF DATE , ADD DVU DATE , CurrentStatus CHAR(1);

    UPDATE Product_Dimension SET DVF = "2013-01-01"
    UPDATE Product_Dimension SET CurrentStatus = 'C'
    UPDATE Product_Dimension SET DVU = '2040-01-01'

--DW
ALTER TABLE Product_Dimension
    ADD DVF DATE , ADD DVU DATE , ADD CurrentStatus CHAR(1); 

    UPDATE chimagr_ZAGIMORE_DW.Product_Dimension SET DVF = "2013-01-01";
    UPDATE chimagr_ZAGIMORE_DW.Product_Dimension SET CurrentStatus = 'C';
    UPDATE chimagr_ZAGIMORE_DW.Product_Dimension SET DVU = '2040-01-01';

UPDATE `product` SET `productprice` = '200.00' WHERE `product`.`productid` = '1X2';


CREATE TABLE  IPD AS 
SELECT 
    p.productid, 
FROM 
    chimagr_ZAGIMORE.product AS p,
    Product_Dimension AS pd,
    chimagr_ZAGIMORE.category AS c,
    chimagr_ZAGIMORE.vendor AS v
WHERE 
    pd.ProductId = p.ProductId
    AND c.categoryid = p.categoryid
    AND p.vendorid = v.vendorid
    AND pd.ProductType = 'Sales'
    AND ProductSalesPrice <> productprice

---Changing the DVU of the Products that changed their price 


UPDATE Product_Dimension  SET DVU = Date(NOW()) - INTERVAL 1 DAY, CurrentStatus = 'N'
WHERE ProductId IN (SELECT * FROM IPD);

-------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ProductDimension(ProductName,ProductID,ProductSalesPrice, CategoryName,VendorID,VendorName,CategoryID,ProductType, ExtractionTimestamp, PDLoaded,DVF,DVU,CurrentStatus)
SELECT p.productname,p.productid, p.productprice, c.categoryname,v.vendorid,v.vendorname,c.categoryid, 'Sales',NOW(),FALSE, NOW(),'2040-01-01','C'
FROM chimagr_ZAGIMORE.product AS p , chimagr_ZAGIMORE.category AS c , chimagr_ZAGIMORE.vendor AS v
WHERE c.categoryid=p.categoryid and p.vendorid = v.vendorid
AND p.productid in (
    SELECT * from IPD
 );




 INSERT INTO Product_Dimension(ProductName,ProductID,ProductSalesPrice, CategoryName,VendorID,VendorName,CategoryID,ProductType, ExtractionTimestamp, PDLoaded,DVF,DVU,CurrentStatus)
SELECT p.productname,p.productid, p.productprice, c.categoryname,v.vendorid,v.vendorname,c.categoryid, 'Sales',NOW(),FALSE, NOW(),'2040-01-01','C'
FROM chimagr_ZAGIMORE.product AS p , chimagr_ZAGIMORE.category AS c , chimagr_ZAGIMORE.vendor AS v
WHERE c.categoryid=p.categoryid and p.vendorid = v.vendorid
AND p.productid IN (
    SELECT * from IPD
 );





REPLACE INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental,VendorId, Vendorname, categoryID, Categoryname, ProductType,DVF,DVU,CurrentStatus)
SELECT ProductKey, ProductId, Productname, ProductSalesPrice,ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType
from Product_Dimension
WHERE PDLoaded=False;

REPLACE INTO chimagr_ZAGIMORE_DW.Product_Dimension(ProductKey, ProductID, ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID, CategoryName, ProductType, DVF, DVU, CurrentStatus)
SELECT ProductKey, ProductID, ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID, CategoryName, ProductType, DVF, DVU, CurrentStatus
FROM Product_Dimension

UPDATE Product_Dimension
SET PDLoaded=TRUE;


UPDATE `product` SET `productname` = 'Solar Charger' WHERE `product`.`productid` = '1X3';
UPDATE `product` SET `productprice` = '44.00' WHERE `product`.`productid` = '1Z1';
UPDATE `product` SET `vendorid` = 'WL' WHERE `product`.`productid` = '4X2';


SELECT p.productid
FROM chimagr_ZAGIMORE.product as p,
     chimagr_ZAGIMORE.vendor as v,
     chimagr_ZAGIMORE.category as c,
     chimagr_ZAGIMORE_DS.Product_Dimension as pd
WHERE c.categoryid = p.categoryid
  AND p.vendorid = v.vendorid
  AND pd.ProductID = p.productid
  AND pd.ProductType = 'Sales'
  AND (p.productprice != pd.ProductSalesPrice OR p.productname != pd.ProductName)
  AND pd.CurrentStatus = 'C';


DROP TABLE IF EXISTS IPD;
CREATE TABLE IPD AS
SELECT p.productid
FROM chimagr_ZAGIMORE.product as p, chimagr_ZAGIMORE.vendor as v, chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE_ds.Product_Dimension as pd
WHERE c.categoryid = p.categoryid  
and p.vendorid = v.vendorid
and pd.ProductID = p.productid
and pd.ProductType = 'Sales'
And (p.productprice!= pd.ProductSalesPrice OR p.productname != pd.ProductName OR p.vendorid != pd.vendorid)
AND pd.CurrentStatus = 'C';


---Changing the DateValidUntil of the products in the ProductDimenstion whose Price has changed
UPDATE Product_Dimension
SET DVU = DATE(NOW()) - INTERVAL 1 DAY, CurrentStatus = 'N'
WHERE productid IN (SELECT * FROM IPD);




ALTER TABLE Customer_Dimension 
ADD DVF DATE , ADD DVU DATE , ADD CurrentStatus CHAR(1);

ALTER TABLE Store_Dimension 
ADD DVF DATE , ADD DVU DATE , ADD CurrentStatus CHAR(1);

UPDATE Customer_Dimension SET DVF = "2013-01-01";
UPDATE Customer_Dimension SET CurrentStatus = 'C';
UPDATE Customer_Dimension SET DVU = '2040-01-01';

UPDATE Store_Dimension SET DVF = "2013-01-01";
UPDATE Store_Dimension SET CurrentStatus = 'C';
UPDATE Store_Dimension SET DVU = '2040-01-01';



UPDATE `rentalProducts` SET `productpricedaily` = '28.00', `productpriceweekly` = '80.00' WHERE `rentalProducts`.`productid` = '2X2';
UPDATE `rentalProducts` SET `productpriceweekly` = '100.00' WHERE `rentalProducts`.`productid` = '2Z2';
UPDATE `rentalProducts` SET `productpricedaily` = '10.00' WHERE `rentalProducts`.`productid` = '5X5';
UPDATE `product` SET `productname` = 'Power', `productprice` = '40.00' WHERE `product`.`productid` = '8X8';


DROP TABLE IF EXISTS IPD;
CREATE TABLE IPD AS
SELECT p.productid
FROM chimagr_ZAGIMORE.product as p, chimagr_ZAGIMORE.vendor as v, chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE_ds.Product_Dimension as pd
WHERE c.categoryid = p.categoryid  
and p.vendorid = v.vendorid
and pd.ProductID = p.productid
and pd.ProductType = 'Sales'
And (p.productprice!= pd.ProductSalesPrice OR p.productname != pd.ProductName OR p.vendorid != pd.vendorid)
AND pd.CurrentStatus = 'C';


INSERT INTO IPD(productid)
SELECT r.productid
FROM chimagr_ZAGIMORE.rentalProducts as r, chimagr_ZAGIMORE.vendor as v, chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE_ds.Product_Dimension as pd
WHERE c.categoryid = r.categoryid  
and r.vendorid = v.vendorid
and pd.ProductID = r.productid
and pd.ProductType = 'Rental'
And (r.productpricedaily != pd.ProductDailyRentalPrice OR r.productname != pd.ProductName OR r.vendorid != pd.vendorid OR r.productpriceweekly != pd.ProductWeeklyRentalPrice)
AND pd.CurrentStatus = 'C';



---Creating procedure for product dimension

CREATE PROCEDURE Product_Refresh()
 BEGIN

INSERT INTO Product_Dimension(ProductID, ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID,CategoryName, ProductType, ExtractionTimestamp, PDLoaded, ProductType,DateValidFrom,DateValidUntil,CurrentStatus )
SELECT p.productid, p.productname, p.productprice, v.vendorid,v.vendorname, c.categoryid, c.categoryname, 'Sales', NOW(), FALSE, NOW(), "2040-01-01", 'C'
FROM josea_zagimore.product as p, josea_zagimore.vendor as v, josea_zagimore.category as c
WHERE c.categoryid = p.categoryid  
and p.vendorid = v.vendorid
AND p.productid NOT IN (Select productid FROM Product_Dimension WHERE ProductType = 'Sales');

INSERT INTO Product_Dimension (ProductId, Productname, ProductDailyRentalPrice, ProductWeeklyRentalPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded,DateValidFrom,DateValidUntil,CurrentStatus)
SELECT p.productid, p.productname , p.productpricedaily, p.productpriceweekly, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Rental', NOW(), FALSE,NOW(), "2040-01-01", 'C'
FROM  josea_zagimore.rentalProducts as p , josea_zagimore.category as c, josea_zagimore.vendor as v 
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid
AND p.vendorid = v.vendorid
AND p.productid NOT IN (Select productid FROM Product_Dimension Where ProductType = 'Rental');

INSERT INTO josea_zagimore_dw.Product_Dimension(ProductKey, ProductID, ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID,CategoryName, ProductType,DateValidFrom,DateValidUntil,CurrentStatus)
SELECT ProductKey, ProductID, ProductName, ProductSalesPrice, VendorID, VendorName, CategoryID,CategoryName, ProductType,DateValidFrom,DateValidUntil,CurrentStatus
FROM Product_Dimension
WHERE PDLoaded = False;

UPDATE Product_Dimension
SET PDLoaded = TRUE;

END


-------------------------------------------------------------------------------------------------------------------------------------------


BEGIN

INSERT INTO Store_Dimension(StoreID,StoreZip,RegionID, RegionName, ExtractionTimeStamp, Sloaded, DVF, DVU, CurrentStatus)
SELECT s.storeid, s.storezip, s.regionid, r.regionname, NOW(), FALSE, NOW(), "2040-01-01"
FROM chimagr_ZAGIMORE.store AS s, chimagr_ZAGIMORE.region AS r
WHERE s.regionid = r.regionid
AND s.storeID NOT IN (SELECT storeid FROM Store_Dimension);

INSERT INTO chimagr_ZAGIMORE_DW.Store_Dimension(StoreKey,StoreID,StoreZip,RegionID, RegionName)
SELECT StoreKey,StoreID,StoreZip,RegionID, RegionName
FROM Store_Dimension
WHERE Sloaded = FALSE;

UPDATE Store_Dimension
SET Sloaded=TRUE;

END


-------------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN

    -- Insert Sales Products
    INSERT INTO Product_Dimension (ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoadedDVF, DVU, CurrentStatus)
    SELECT p.productid, p.productname, p.productprice, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Sales', NOW(), FALSE
    FROM chimagr_ZAGIMORE.product AS p
    JOIN chimagr_ZAGIMORE.category AS c ON c.categoryid = p.categoryid
    JOIN chimagr_ZAGIMORE.vendor AS v ON p.vendorid = v.vendorid
    WHERE p.productid NOT IN (
        SELECT ProductId FROM Product_Dimension WHERE ProductType = 'Sales'
    );

    INSERT INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType)
    SELECT ProductKey, ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType
    FROM Product_Dimension
    WHERE PDLoaded = FALSE;

    UPDATE Product_Dimension 
    SET PDLoaded = TRUE;

    -- Insert Rental Products
    INSERT INTO Product_Dimension (ProductId, Productname, ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoadedDVF, DVU, CurrentStatus)
    SELECT p.productid, p.productname, p.productpricedaily, p.productpriceweekly, v.vendorid, v.vendorname, c.categoryid, c.categoryname, 'Rental', NOW(), FALSE
    FROM chimagr_ZAGIMORE.rentalProducts AS p
    JOIN chimagr_ZAGIMORE.category AS c ON c.categoryid = p.categoryid
    JOIN chimagr_ZAGIMORE.vendor AS v ON p.vendorid = v.vendorid
    WHERE p.productid NOT IN (
        SELECT ProductId FROM Product_Dimension WHERE ProductType = 'Rental'
    );

    INSERT INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType)
    SELECT ProductKey, ProductId, Productname, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType
    FROM Product_Dimension
    WHERE PDLoaded = FALSE;

    UPDATE Product_Dimension
    SET PDLoaded = TRUE;

END

-------------------------------------------------------------

INSERT INTO store (`storeid`, `storezip`, `regionid`) VALUES("S18","54037",'N');

INSERT INTO store (`storeid`, `storezip`, `regionid`) VALUES("S19","60402","I");

INSERT INTO store (`storeid`, `storezip`, `regionid`) VALUES('S21',"46001","C");





-------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Changing the price of 3 products 
UPDATE `product` SET `productprice` = '35.00' WHERE `product`.`productid` = '3X1';

---Finding which rows in product dimension have changed price and make a temporary table with product ids 
CREATE TABLE IPD as 
SELECT p.productid
FROM chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v , chimagr_ZAGIMORE_DS.Product_Dimension as pd 
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid AND pd.ProductID = p.productid AND pd.ProductType = 'Sales' 
AND p.productprice != pd.ProductSalesPrice;

--- updating dvu and currentstatus for corresponding rows whose prices are changed.
UPDATE Product_Dimension 
SET dvu = NOW() - INTERVAL 1 Day , currentstatus = 'N'
Where ProductType = 'Sales' AND ProductID IN (SELECT * FROM IPD);

INSERT INTO Product_Dimension (ProductId, Productname, ProductSalesPrice , VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded,dvf , dvu , currentstatus)
SELECT p.productid, p.productname , p.productprice, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Sales', NOW(), False ,NOW(),'2040-01-01','C' 
FROM  chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid
AND p.productid  in (SELECT * FROM IPD);

----Add new columns to dataware database product dimension table.
Alter TABLE chimagr_ZAGIMORE_DW.Product_Dimension
ADD DVF date , 
ADD DVF date , 
ADD CurrentStatus Char(1);

Update chimagr_ZAGIMORE_DW.Product_Dimension SET dvf = '2013-01-01' , currentstatus = 'C';
Update chimagr_ZAGIMORE_DW.Product_Dimension SET dvu = '2040-01-01';

Replace INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental,VendorId, Vendorname, categoryID, Categoryname, ProductType , dvf , dvu , currentstatus)
SELECT ProductKey, ProductId, Productname, ProductSalesPrice,ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType , dvf , dvu , currentstatus
from Product_Dimension; 

UPDATE Product_Dimension SET PDLoaded = 1 WHERE PDLoaded = 0;

---------------------------------------------------------------------------------------------------------------------


UPDATE `rentalProducts` SET `productpricedaily` = '20.00' WHERE `rentalProducts`.`productid` = '2X2';
UPDATE `rentalProducts` SET `productpricedaily` = '25.00' WHERE `rentalProducts`.`productid` = '5X5';
UPDATE `product` SET `productprice` = '40.00' WHERE `product`.`productid` = '222';

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UPDATE `customer` SET `customerzip` = '60138' WHERE `customer`.`customerid` = '1-2-333';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN
DROP TABLE IF EXISTS CPD;

CREATE TABLE CPD AS
SELECT c.customerid, c.customername, c.customerzip, NOW() AS ExtractionTimeStamp, FALSE AS Cloaded, NOW() AS DVF, '2040-01-01' AS DVU, 'C' AS CurrentStatus
FROM chimagr_ZAGIMORE.customer c, chimagr_ZAGIMORE_DS.Customer_Dimension cd
WHERE (c.customername != cd.CName OR c.customerzip != cd.CZip)
AND c.customerid = cd.CustomerId
AND cd.CurrentStatus = 'C';

UPDATE Customer_Dimension cd, CPD
SET cd.dvu = NOW() - INTERVAL 1 DAY, cd.CurrentStatus = 'N'
WHERE cd.CustomerId = CPD.CustomerId AND cd.CurrentStatus = 'C';

INSERT INTO Customer_Dimension(customerid, CName, CZip, ExtractionTimeStamp, Cloaded, DVF, DVU, CurrentStatus)
SELECT customerid, customername, customerzip, ExtractionTimeStamp, Cloaded, DVF, DVU, CurrentStatus
FROM CPD;

ALTER TABLE chimagr_ZAGIMORE_DW.Revenue 
DROP FOREIGN KEY Revenue_ibfk_1;

ALTER TABLE chimagr_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
DROP FOREIGN KEY One_Way_Revenue_Agg_By_Product_Cat_ibfk_2;

REPLACE INTO chimagr_ZAGIMORE_DW.Customer_Dimension (CustomerKey, customerid, CName, CZip, DVF, DVU, CurrentStatus)
SELECT CustomerKey, Customerid, CName, CZip, DVF, DVU, CurrentStatus
FROM Customer_Dimension;

ALTER TABLE chimagr_ZAGIMORE_DW.Revenue
ADD CONSTRAINT Revenue_ibfk_1
FOREIGN KEY (CustomerKey) REFERENCES chimagr_ZAGIMORE_DW.Customer_Dimension(CustomerKey);

ALTER TABLE chimagr_ZAGIMORE_DW.One_Way_Revenue_Agg_By_Product_Cat
ADD CONSTRAINT One_Way_Revenue_Agg_By_Product_Cat_ibfk_2
FOREIGN KEY (CustomerKey) REFERENCES chimagr_ZAGIMORE_DW.Customer_Dimension(CustomerKey);

UPDATE Customer_Dimension SET Cloaded = 1 WHERE Cloaded = 0;

END






---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN
DROP TABLE IF EXISTS IPD;

CREATE TABLE IPD AS
SELECT p.productid, pd.ProductType
FROM  chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v,chimagr_ZAGIMORE_DS. Product_Dimension AS pd
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid 
AND pd.ProductId= p.ProductId
AND pd.ProductType = 'Sales'
AND( p.productprice != pd.ProductSalesPrice OR p.Productname != pd.Productname OR p.VendorId!= pd.VendorId)
AND pd.CurrentStatus = 'C';

UPDATE Product_Dimension  SET DVU = DATE(NOW()) -INTERVAL 1 DAY, CurrentStatus = 'N'
WHERE ProductId IN (SELECT productid  FROM IPD WHERE ProductType='Sales') AND ProductType = 'Sales';

INSERT INTO IPD (productid,ProductType)
SELECT r.productid, pd.ProductType
FROM  chimagr_ZAGIMORE.rentalProducts as r , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v,chimagr_ZAGIMORE_DS. Product_Dimension AS pd
WHERE c.categoryid = r.categoryid and r.vendorid = v.vendorid 
AND pd.ProductId= r.ProductId
AND pd.ProductType = 'Rental'
AND(  r.productpriceweekly != pd.ProductWeeklyRental OR r.Productname != pd.Productname OR r.VendorId!= pd.VendorId OR r.productpricedaily!= pd.ProductDailyRentalPrice)
AND pd.CurrentStatus = 'C';

UPDATE Product_Dimension  SET DVU = DATE(NOW()) -INTERVAL 1 DAY, CurrentStatus = 'N'
WHERE ProductId IN (SELECT productid FROM IPD WHERE ProductType='Rental') AND ProductType = 'Rental';

INSERT INTO Product_Dimension (ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType,ExtractionTimeStamp, PDLoaded,DVF,DVU,CurrentStatus)
SELECT p.productid, p.productname , p.productprice, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Sales', NOW(), FALSE,NOW(),'2040-01-01','C'
FROM  chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v 
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid 
AND p.productid IN (SELECT productid from IPD WHERE ProductType= 'Sales');

INSERT INTO Product_Dimension (ProductId, Productname,ProductWeeklyRental, ProductDailyRentalPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType,ExtractionTimeStamp, PDLoaded,DVF,DVU,CurrentStatus)
SELECT r.productid, r.productname , r.productpriceweekly, r.productpricedaily, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Rental', NOW(), FALSE,NOW(),'2040-01-01','C'
FROM  chimagr_ZAGIMORE.rentalProducts as r , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v 
WHERE c.categoryid = r.categoryid and r.vendorid = v.vendorid 
AND r.productid IN (SELECT productid from IPD WHERE ProductType= 'Rental');

ALTER TABLE chimagr_ZAGIMORE_DW.Revenue
DROP FOREIGN KEY Revenue_ibfk_3;

REPLACE INTO chimagr_ZAGIMORE_DW.Product_Dimension(ProductKey, Productname, VendorId, Vendorname,Categoryname, CategoryID, ProductId, ProductType,ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental,DVF,DVU,CurrentStatus)
SELECT ProductKey, Productname, VendorId, Vendorname,Categoryname, CategoryID, ProductId,ProductType,ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental,DVF,DVU,CurrentStatus
FROM Product_Dimension;

ALTER TABLE chimagr_ZAGIMORE_DW.Revenue
ADD CONSTRAINT Revenue_ibfk_3
FOREIGN KEY (ProductKey)
REFERENCES chimagr_ZAGIMORE_DW.Product_Dimension(ProductKey);

UPDATE Product_Dimension
SET PDloaded= TRUE 
WHERE PDloaded= FALSE;

END