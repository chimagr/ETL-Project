CREATE TABLE Customer_Dimension
(
  CustomerKey INT AUTO_INCREMENT,
  CName VARCHAR(15) NOT NULL,
  CZip CHAR(5) NOT NULL,
  CustomerId CHAR(7) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE Store_Dimension
(
  StoreKey INT AUTO_INCREMENT,
  StoreId VARCHAR(3) NOT NULL,
  StoreZip CHAR(5) NOT NULL,
  RegioniD CHAR(1) NOT NULL,
  RegionName VARCHAR(25) NOT NULL,
  PRIMARY KEY (StoreKey)
);

CREATE TABLE Product_Dimension
(
  ProductKey INT AUTO_INCREMENT,
  Productname VARCHAR(25) NOT NULL,
  VendorId CHAR(2) NOT NULL,
  Vendorname VARCHAR(25) NOT NULL,
  Categoryname VARCHAR(25) NOT NULL,
  categoryID CHAR(2) NOT NULL,
  ProductSalesPrice Decimal(7,2),
  ProductDailyRentalPrice Decimal(7,2),
  ProductWeeklyRental Decimal(7,2),
  ProductType VARCHAR(10) NOT NULL,
  ProductId Char(3) NOT NULL,
  PRIMARY KEY (ProductKey)
);
CREATE TABLE Calendar_Dimension
(
  Calendar_Key INT AUTO_INCREMENT,
  FullDate DATE NOT NULL,
  MonthYear INT NOT NULL,
  Year INT NOT NULL,
  PRIMARY KEY (Calendar_Key)
);

CREATE TABLE Revenue
(
  RevenueGenerated INT NOT NULL,
  UnitSolds INT NOT NULL,
  RevenueType VARCHAR(20) NOT NULL,
  TID VARCHAR(8) NOT NULL,
  CustomerKey INT NOT NULL,
  StoreKey INT NOT NULL,
  ProductKey INT NOT NULL,
  Calendar_Key INT NOT NULL,
  PRIMARY KEY (RevenueType, TID, CustomerKey, StoreKey, ProductKey, Calendar_Key)
);

---Procedure for populating the Calendar Dimension 
DELIMITER $$

CREATE PROCEDURE populateCalendar()
BEGIN
DECLARE i INT DEFAULT 0;
myloop: LOOP
INSERT INTO Calendar_Dimension(Fulldate)
SELECT DATE_ADD('2013-01-01', INTERVAL i DAY);
SET i=i+1;
IF i=10000 then
LEAVE myloop;
END IF;
END LOOP myloop;
UPDATE Calendar_Dimension
SET MonthYear = MONTH(Fulldate), Year = YEAR(Fulldate);
END;