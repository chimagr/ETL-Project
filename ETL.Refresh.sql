ALTER TABLE Revenue ADD COLUMN ExtractionTimeStamp TIMESTAMP, 
ALTER TABLE Revenue ADD COLUMN f_loaded boolean 

UPDATE Revenue
SET ExtractionTimeStamp= NOW() - INTERVAL 10 DAY

UPDATE Revenue
SET f_loaded = TRUE

INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`) 
VALUES ('ABC', '1-2-333', 'S2', '2025-03-25');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) 
VALUES ('1X2', 'ABC', '2'), ('1X1', 'ABC', '5');

--Extracting new sales facts
DROP TABLE IntermediateFact;
CREATE TABLE IntermediateFact AS
SELECT sv.noofitems as UnitSold , p.productprice * sv.noofitems as RevenueGenerated , 'Sales' as RevenueType , sv.tid as TID , p.productid as ProductId , c.customerid as CustomerId , s.storeid as StoreId , st.tdate as FullDate  
FROM chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.soldvia sv , chimagr_ZAGIMORE.customer as c , chimagr_ZAGIMORE.store as s , chimagr_ZAGIMORE.salestransaction as st
WHERE sv.productid = p.productid 
AND sv.tid = st.tid
AND st.customerid = c.customerid 
AND s.storeid = st.storeid
AND st.tid = sv.tid
AND st.tdate > (SELECT MAX(DATE(ExtractionTimeStamp)) FROM Revenue);

--Adding new daily rental facts 
INSERT INTO IntermediateFactTable (UnitSold, RevenueGenerated,
RevenueType, TID, productId, customerId, storeId, fullDate)
SELECT 0, r.productpricedaily * rv.duration , "RentalDaily", rv.tid,
r.productid, c.customerid, s.storeid, rt.tdate
FROM chimagr_ZAGIMORE.rentalProducts r, chimagr_ZAGIMORE.rentvia rv,
chimagr_ZAGIMORE.customer c, chimagr_ZAGIMORE.store s,
chimagr_ZAGIMORE.rentaltransaction rt
WHERE rv.productid = r.productid
AND rv.tid=rt.tid
AND c.customerid=rt.customerid
AND s.storeid = rt.storeid
AND rv.rentaltype= 'D'
AND rt.tdate > (SELECT MAX(DATE(ExtractionTimestamp))
FROM Revenue);

--Adding new weekly rental facts
INSERT INTO IntermediateFactTable (UnitSold, RevenueGenerated,
RevenueType, TID, productId, customerId, storeId, fullDate)
SELECT 0, r.productpriceweekly * rv.duration AS RevenueGenerated,
"RentalWeekly" AS RevenueType, rv.tid
AS TID, r.productid AS produtId, c.customerid AS customerId, s.storeid
AS storeId, rt.tdate AS fullDate
FROM chimagr_ZAGIMORE.rentalProducts r, chimagr_ZAGIMORE.rentvia rv,
chimagr_ZAGIMORE.customer c, chimagr_ZAGIMORE.store s,
chimagr_ZAGIMORE.rentaltransaction rt
WHERE rv.productid = r.productid
AND rv.tid=rt.tid
AND c.customerid=rt.customerid
AND s.storeid = rt.storeid
AND rv.rentaltype= 'W'
AND rt.tdate > (SELECT MAX(DATE(ExtractionTimestamp))
FROM Revenue);

INSERT INTO Revenue (UnitSolds, RevenueGenerated,RevenueType, TID,
CustomerKey,StoreKey, ProductKey, Calendar_Key, ExtractionTimestamp, f_loaded )
SELECT i.UnitSold , i.RevenueGenerated , i.RevenueType,
i.TID, cd.CustomerKey , sd.StoreKey , pd.ProductKey ,
cad.Calendar_Key,NOW(), FALSE
FROM IntermediateFactTable as i , Customer_Dimension as cd,
Store_Dimension as sd, Product_Dimension as pd, Calendar_Dimension as cad
WHERE i.CustomerId = cd.CustomerId
AND sd.StoreId = i.StoreId
AND pd.ProductId = i.ProductId
AND cad.FullDate = i.FullDate
AND LEFT(pd.ProductType, 1) = LEFT (i.RevenueType, 1);

--Adding new 
INSERT INTO chimagr_ZAGIMORE_DW.Revenue
(Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,  
RevenueType, StoreKey, TID, UnitSolds)
SELECT Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,  
RevenueType, StoreKey, TID, UnitSolds
FROM Revenue
WHERE f_loaded = 0;
UPDATE Revenue 
SET f_loaded = True 
WHERE f_loaded = False

ALTER TABLE IntermediateFactTable
MODIFY RevenueType VARCHAR(25);


INSERT INTO chimagr_ZAGIMORE_DW.Revenue
(Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,
RevenueType, StoreKey, TID, UnitSolds)
SELECT Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,
RevenueType, StoreKey, TID, UnitSolds
FROM Revenue
WHERE f_loaded = 0;

INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('CDE', '1-2-333', 'S10', '2025-03-26');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('1X1', 'CDE', '4'), ('1X2', 'CDE', '3');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) VALUES ('CDE', '1-2-333', 'S2', '2025-03-26');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) VALUES ('2X4', 'CDE', '2'), ('3X2', 'CDE', '6');


INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`)
VALUES ('CDE', '6-7-888', 'S4', '2025-03-26');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) 
VALUES ('1X3', 'CDE', '6');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) 
VALUES ('1X2', 'CDE', '3');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) 
VALUES ('FGH', '3-4-555', 'S7', '2025-03-26');

INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) 
VALUES ('1X1', 'FGH', 'D', '5');

INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) 
VALUES ('2X2', 'FGH', 'W', '6');



INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`)
VALUES ('BBC', '7-8-999', 'S4', '2025-03-27');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) 
VALUES ('1X3', 'BBC', '6');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`) 
VALUES ('1X2', 'BBC', '3');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`) 
VALUES ('BBB', '3-4-555', 'S7', '2025-03-27');

INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) 
VALUES ('1X1', 'BBB', 'D', '5');

INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`) 
VALUES ('2X2', 'BBB', 'W', '6');

CREATE PROCEDURE Daily_Regular_Fact_Refresh()
BEGIN

DROP TABLE IntermediateFact;
CREATE TABLE IntermediateFact AS
SELECT sv.noofitems as UnitSold , p.productprice * sv.noofitems as RevenueGenerated , 'Sales' as RevenueType , sv.tid as TID , p.productid as ProductId , c.customerid as CustomerId , s.storeid as StoreId , st.tdate as FullDate  
FROM chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.soldvia sv , chimagr_ZAGIMORE.customer as c , chimagr_ZAGIMORE.store as s , chimagr_ZAGIMORE.salestransaction as st
WHERE sv.productid = p.productid 
AND sv.tid = st.tid
AND st.customerid = c.customerid 
AND s.storeid = st.storeid
AND st.tid = sv.tid
AND st.tdate > (SELECT MAX(DATE(ExtractionTimeStamp)) FROM Revenue);

ALTER TABLE IntermediateFact
MODIFY RevenueType VARCHAR(25);

INSERT INTO IntermediateFact (UnitSold, RevenueGenerated,
RevenueType, TID, productId, customerId, storeId, fullDate)
SELECT 0, r.productpricedaily * rv.duration , "RentalDaily", rv.tid,
r.productid, c.customerid, s.storeid, rt.tdate
FROM chimagr_ZAGIMORE.rentalProducts r, chimagr_ZAGIMORE.rentvia rv,
chimagr_ZAGIMORE.customer c, chimagr_ZAGIMORE.store s,
chimagr_ZAGIMORE.rentaltransaction rt
WHERE rv.productid = r.productid
AND rv.tid=rt.tid
AND c.customerid=rt.customerid
AND s.storeid = rt.storeid
AND rv.rentaltype= 'D'
AND rt.tdate > (SELECT MAX(DATE(ExtractionTimestamp))
FROM Revenue);

INSERT INTO IntermediateFact (UnitSold, RevenueGenerated,
RevenueType, TID, productId, customerId, storeId, fullDate)
SELECT 0, r.productpriceweekly * rv.duration AS RevenueGenerated,
"RentalWeekly" AS RevenueType, rv.tid
AS TID, r.productid AS produtId, c.customerid AS customerId, s.storeid
AS storeId, rt.tdate AS fullDate
FROM chimagr_ZAGIMORE.rentalProducts r, chimagr_ZAGIMORE.rentvia rv,
chimagr_ZAGIMORE.customer c, chimagr_ZAGIMORE.store s,
chimagr_ZAGIMORE.rentaltransaction rt
WHERE rv.productid = r.productid
AND rv.tid=rt.tid
AND c.customerid=rt.customerid
AND s.storeid = rt.storeid
AND rv.rentaltype= 'W'
AND rt.tdate > (SELECT MAX(DATE(ExtractionTimestamp))
FROM Revenue);

INSERT INTO Revenue (UnitSolds, RevenueGenerated,RevenueType, TID,
CustomerKey,StoreKey, ProductKey, Calendar_Key, ExtractionTimestamp, f_loaded )
SELECT i.UnitSold , i.RevenueGenerated , i.RevenueType,
i.TID, cd.CustomerKey , sd.StoreKey , pd.ProductKey ,
cad.Calendar_Key,NOW(), FALSE
FROM IntermediateFact as i , Customer_Dimension as cd,
Store_Dimension as sd, Product_Dimension as pd, Calendar_Dimension as cad
WHERE i.CustomerId = cd.CustomerId
AND sd.StoreId = i.StoreId
AND pd.ProductId = i.ProductId
AND cad.FullDate = i.FullDate
AND LEFT(pd.ProductType, 1) = LEFT (i.RevenueType, 1);

INSERT INTO chimagr_ZAGIMORE_DW.Revenue
(Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,
RevenueType, StoreKey, TID, UnitSolds)
SELECT Calendar_Key, CustomerKey, ProductKey, RevenueGenerated,
RevenueType, StoreKey, TID, UnitSolds
FROM Revenue
WHERE f_loaded = 0;


UPDATE Revenue 
SET f_loaded = True 
WHERE f_loaded = False;



END 


UPDATE Revenue
SET ExtractionTimestamp = ExtractionTimestamp + INTERVAL 1 DAY
WHERE Calendar_Key = 4468 


---Daily Refresh f Prodiuct Dimension 
ALTER TABLE Product_Dimension 
ADD ExtractionTimeStamp TIMESTAMP
ADD PDLoaded BOOLEAN;

UPDATE Product_Dimension 
SET ExtractionTimeStamp = NOW() - INTERVAL 20 DAY;

UPDATE Product_Dimension 
SET PDLoaded = TRUE

INSERT INTO `product` (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) 
VALUES ('1Z1', 'Bottle', '34', 'OA', 'CY');




INSERT INTO Product_Dimension (ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded)
SELECT p.productid, p.productname , p.productprice, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Sales', NOW(), False
FROM  chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v 
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid
AND p.productid not in (
    SELECT ProductId FROM Product_Dimension FROM Product_Dimension WHERE ProductType = 'Sales'
);

INSERT INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType)
SELECT ProductKey, ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType
FROM Product_Dimension
WHERE PDLoaded = FALSE;

UPDATE Product_Dimension 
SET PDLoaded = True;

INSERT INTO `rentalProducts` (`productid`, `productname`, `vendorid`, `categoryid`, `productpricedaily`, `productpriceweekly`) 
VALUES ('F1', 'Ferrari', 'OA', 'EL', '50', '200');

INSERT INTO Product_Dimension (ProductId, Productname, ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded)
SELECT p.productid, p.productname , p.productpricedaily, p.productpriceweekly, v.vendorid, v.vendorname ,c.categoryid, c.categoryname , 'Rental', NOW(), False
FROM  chimagr_ZAGIMORE.rentalProducts as p , chimagr_ZAGIMORE.category as c, chimagr_ZAGIMORE.vendor as v 
WHERE c.categoryid = p.categoryid and p.vendorid = v.vendorid 
AND p.productid not in (
    SELECT ProductId FROM Product_Dimension WHERE ProductType = 'Rental'
)

INSERT INTO chimagr_ZAGIMORE_DW.Product_Dimension (ProductKey, ProductId, Productname, ProductSalesPrice, ProductDailyRentalPrice, ProductWeeklyRental,VendorId, Vendorname, categoryID, Categoryname, ProductType)
SELECT ProductKey, ProductId, Productname, ProductSalesPrice,ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType
from Product_Dimension
WHERE PDLoaded=False;

UPDATE Product_Dimension
SET PDLoaded=True;



--Create procedure for refreshing product dimension
DELIMITER //

CREATE PROCEDURE DailyProductRefresh()
BEGIN

    -- Insert Sales Products
    INSERT INTO Product_Dimension (ProductId, Productname, ProductSalesPrice, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded)
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
    INSERT INTO Product_Dimension (ProductId, Productname, ProductDailyRentalPrice, ProductWeeklyRental, VendorId, Vendorname, categoryID, Categoryname, ProductType, ExtractionTimestamp, PDLoaded)
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

END //

DELIMITER ;


INSERT INTO `product` (`productid`, `productname`, `productprice`, `vendorid`, `categoryid`) 
VALUES ('222', 'Coffee', '34', 'OA', 'CY');
INSERT INTO `rentalProducts` (`productid`, `productname`, `vendorid`, `categoryid`, `productpricedaily`, `productpriceweekly`) 
VALUES ('222', 'Coffee', 'OA', 'EL', '50', '200');


--Procedure for d
CREATE PROCEDURE LateFactRefresh()
BEGIN 
DROP TABLE IF EXISTS IntermediateFact;
CREATE TABLE IntermediateFact AS
SELECT sv.noofitems as UnitSold , p.productprice * sv.noofitems as RevenueGenerated , 'Sales' as RevenueType , sv.tid as TID , 
p.productid as ProductId , st.customerid as CustomerId , st.storeid as StoreId , st.tdate as FullDate  
FROM chimagr_ZAGIMORE.product as p , chimagr_ZAGIMORE.soldvia sv , chimagr_ZAGIMORE.salestransaction as st
WHERE sv.productid = p.productid 
AND sv.tid = st.tid
AND st.tid NOT IN (
    SELECT TID FROM Revenue
    WHERE RevenueType = 'Sales'
);

ALTER TABLE IntermediateFact
MODIFY RevenueType VARCHAR(25);
INSERT INTO IntermediateFact(UnitSold,RevenueGenerated,RevenueType,TID,ProductId,CustomerId,StoreId,FullDate)
SELECT 0 as UnitSold , r.productpricedaily * rv.duration as RevenueGenerated , 'RentalDaily' as RevenueType , rv.tid as TID , 
r.productid as ProductId , c.customerid as CustomerId , s.storeid as StoreId , rt.tdate as FullDate  
FROM chimagr_ZAGIMORE.rentalProducts as r , chimagr_ZAGIMORE.rentvia rv , chimagr_ZAGIMORE.customer as c , chimagr_ZAGIMORE.store as s , chimagr_ZAGIMORE.rentaltransaction as rt
WHERE rv.productid = r.productid 
AND rv.tid = rt.tid
AND rt.customerid = c.customerid 
AND s.storeid = rt.storeid
AND rv.rentaltype='D'
AND rt.tid NOT IN (
    SELECT TID FROM Revenue
    WHERE  RevenueType LIKE 'R%');
INSERT INTO IntermediateFact(UnitSold,RevenueGenerated,RevenueType,TID,ProductId,CustomerId,StoreId,FullDate)
SELECT 0 as UnitSold , r.productpricedaily * rv.duration as RevenueGenerated , 'RentalWeekly' as RevenueType , rv.tid as TID , 
r.productid as ProductId , c.customerid as CustomerId , s.storeid as StoreId , rt.tdate as FullDate  
FROM chimagr_ZAGIMORE.rentalProducts as r , chimagr_ZAGIMORE.rentvia rv , chimagr_ZAGIMORE.customer as c , chimagr_ZAGIMORE.store as s , chimagr_ZAGIMORE.rentaltransaction as rt
WHERE rv.productid = r.productid 
AND rv.tid = rt.tid
AND rt.customerid = c.customerid 
AND s.storeid = rt.storeid
AND rv.rentaltype='W'
AND rt.tid NOT IN (
    SELECT TID FROM Revenue
    WHERE RevenueType LIKE 'R%'
);
INSERT INTO Revenue (UnitSolds, RevenueGenerated,RevenueType, TID, CustomerKey,StoreKey, ProductKey, Calendar_Key,ExtractionTimestamp,f_loaded )
SELECT i.UnitSold , i.RevenueGenerated , i.RevenueType, i.TID, cd.CustomerKey , sd.StoreKey , pd.ProductKey , cad.Calendar_Key, NOW(), False
FROM IntermediateFact as i , Customer_Dimension as cd, Store_Dimension as sd, Product_Dimension as pd, Calendar_Dimension as cad
WHERE i.CustomerId = cd.CustomerId
AND sd.StoreId = i.StoreId 
AND pd.ProductId = i.ProductId  
AND cad.FullDate = i.FullDate
AND LEFT(pd.ProductType,1)=LEFT(i.RevenueType,1);
INSERT INTO chimagr_ZAGIMORE_DW.Revenue( RevenueGenerated, UnitSolds,RevenueType,TID,CustomerKey,StoreKey,ProductKey,Calendar_Key)
SELECT RevenueGenerated,UnitSolds,RevenueType,TID,CustomerKey,StoreKey,ProductKey,Calendar_Key 
FROM Revenue
WHERE f_loaded=0;

UPDATE Revenue 
SET f_loaded = 1
WHERE f_loaded = 0;

END


INSERT INTO `salestransaction` (`tid`, `customerid`, `storeid`, `tdate`)
VALUES ('NEWST', '6-7-888', 'S4', '2025-03-26');

INSERT INTO `soldvia` (`productid`, `tid`, `noofitems`)
VALUES ('1X3', 'NEWST', '6');

INSERT INTO `rentaltransaction` (`tid`, `customerid`, `storeid`, `tdate`)
VALUES ('NEWRT', '3-4-555', 'S7', '2025-03-26');

INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`)
VALUES ('1X1', 'NEWRT', 'D', '5');
INSERT INTO `rentvia` (`productid`, `tid`, `rentaltype`, `duration`)
VALUES ('2X2', 'NEWRT', 'W', '6');









Rufaro Chimaga
4:14 PM (0 minutes ago)
to me

-- Daily refresh for for STORE DIMENSION
ALTER TABLE Store_Dimension
ADD ExtractionTimeStamp TIMESTAMP, ADD Sloaded BOOLEAN;

UPDATE Store_Dimension
SET Sloaded = True;

UPDATE Store_Dimension
SET ExtractionTimeStamp = NOW() - INTERVAL 20 DAY;

INSERT INTO store(storeid, storezip, regionid) VALUES ('S15','13676','N')
INSERT INTO store(storeid, storezip, regionid) VALUES ('S16','13676','C')

INSERT INTO Store_Dimension(StoreID,StoreZip,RegionID, RegionName, ExtractionTimeStamp, Sloaded)
SELECT s.storeid, s.storezip, s.regionid, r.regionname, NOW(), FALSE
FROM chimagr_ZAGIMORE.store AS s, chimagr_ZAGIMORE.region AS r
WHERE s.regionid = r.regionid
AND s.storeID NOT IN (SELECT storeid FROM Store_Dimension);

INSERT INTO chimagr_ZAGIMORE_DW.Store_Dimension(StoreKey,StoreID,StoreZip,RegionID, RegionName)
SELECT StoreKey,StoreID,StoreZip,RegionID, RegionName
FROM Store_Dimension
WHERE Sloaded = FALSE;

UPDATE Store_Dimension
SET Sloaded=TRUE;


--store dimension refresh procedure

INSERT INTO store(storeid, storezip, regionid) VALUES ('S17','19245','T')
INSERT INTO store(storeid, storezip, regionid) VALUES ('S18','19245','I')

CREATE PROCEDURE Daily_Store_Refresh()
BEGIN

INSERT INTO Store_Dimension(StoreID,StoreZip,RegionID, RegionName, ExtractionTimeStamp, Sloaded)
SELECT s.storeid, s.storezip, s.regionid, r.regionname, NOW(), FALSE
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



---Daily refresh for CUSTOMER DIMENSION
ALTER TABLE Customer_Dimension
ADD ExtractionTimeStamp TIMESTAMP, ADD Cloaded BOOLEAN;

UPDATE Customer_Dimension
SET Cloaded = True;

UPDATE Customer_Dimension
SET ExtractionTimeStamp = NOW() - INTERVAL 20 DAY;

INSERT INTO customer(customerid, customername, customerzip) VALUES ('3-7-999','Golden','13676');
INSERT INTO customer(customerid, customername, customerzip) VALUES ('7-3-666','Knight','13677');


INSERT INTO Customer_Dimension(CustomerID, CName, CZip,ExtractionTimeStamp, Cloaded)
SELECT c.customerid, c.customername, c.customerzip,NOW(), FALSE
FROM chimagr_ZAGIMORE.customer AS c
WHERE c.customerid NOT IN (SELECT customerID FROM chimagr_ZAGIMORE_DS.Customer_Dimension);

insert into chimagr_ZAGIMORE_DW.Customer_Dimension(CustomerKey,CName,CZip,CustomerId) 
select CustomerKey,CName,CZip,CustomerId 
FROM Customer_Dimension
WHERE Cloaded = FALSE;

UPDATE Customer_Dimension
SET Cloaded=TRUE;


--customer dimension refresh procedure

INSERT INTO customer(customerid, customername, customerzip) VALUES ('9-6-666','Connor','13676');
INSERT INTO customer(customerid, customername, customerzip) VALUES ('8-4-777','Bedard','13677');

---Procedure
CREATE PROCEDURE Daily_Customer_Refresh()
BEGIN

INSERT INTO Customer_Dimension(CustomerID, CName, CZip,ExtractionTimeStamp, Cloaded)
SELECT c.customerid, c.customername, c.customerzip,NOW(), FALSE
FROM chimagr_ZAGIMORE.customer AS c
WHERE c.customerid NOT IN (SELECT customerID FROM chimagr_ZAGIMORE_DS.Customer_Dimension);

insert into chimagr_ZAGIMORE_DW.Customer_Dimension(CustomerKey,CName,CZip,CustomerId) 
select CustomerKey,CName,CZip,CustomerId 
FROM Customer_Dimension
WHERE Cloaded = FALSE;

UPDATE Customer_Dimension
SET Cloaded=TRUE;

END



