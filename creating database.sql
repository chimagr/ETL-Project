
--------------------------------------------------------------------CREATING DATABASE---------------------------------------------------------------
CREATE DATABASE HHSourceDB;


USE HHSourceDB;



CREATE TABLE INDIVIDUAL (
    Id INT PRIMARY KEY,
    Iname NVARCHAR(100),
    Isex CHAR(1)
);


CREATE TABLE EMPLOYEE (
    Eid INT PRIMARY KEY,
    Ename NVARCHAR(100),
    Esex CHAR(1),
    Mid INT
);


CREATE TABLE LOCATION (
    Lid INT PRIMARY KEY,
    Lname NVARCHAR(100),
    Address NVARCHAR(255)
);


CREATE TABLE VOLUNTEER (
    Vid INT PRIMARY KEY,
    Vname NVARCHAR(100),
    Vsex CHAR(1)
);


CREATE TABLE PHONE (
    PDid INT PRIMARY KEY,
    Date DATE,
    Amount INT,
    Vid INT,
    Iid INT
);


CREATE TABLE MAIL (
    MDid INT PRIMARY KEY,
    Date DATE,
    Amount INT,
    Eid INT,
    Iid INT
);


CREATE TABLE CALLING (
    Cid INT PRIMARY KEY,
    Vid INT,
    Iid INT
);


CREATE TABLE WRITING (
    Wid INT PRIMARY KEY,
    Eid INT,
    Iid INT
);

----------------------------------------------------------------LOADING THE DATA--------------------------------------------------------------

INSERT INTO INDIVIDUAL (Id, Iname, Isex)
VALUES
    (111, 'Joe', 'M'),
    (222, 'Tina', 'F');

INSERT INTO LOCATION (Lid, Lname, Address)
VALUES
    (1, 'HO', '123 Oak St'),
    (2, 'Branch1', '67 Pine St');

INSERT INTO EMPLOYEE (Eid, Ename, Esex, Lid)
VALUES
    ('E11', 'Bob', 'M', 1),
    ('E22', 'Mary', 'F', 2);

INSERT INTO VOLUNTEER (Vid, Vname, Vsex, Lid)
VALUES
    ('V11', 'Fred', 'M', 1),
    ('V22', 'Linda', 'F', 2);

INSERT INTO PHONE (PDid, Date, Amount, Vid, Iid)
VALUES
    (1, '2001-01-02', 100, 'V11', 111),
    (2, '2001-01-02', 200, 'V22', 222);

INSERT INTO MAIL (MDid, Date, Amount, Eid, Iid)
VALUES
    (1, '2001-01-02', 400, 'E22', 111),
    (2, '2001-01-03', 500, 'E11', 222);

INSERT INTO CALLING (Cid, Vid, Iid)
VALUES
    (1, 'V11', 111),
    (2, 'V22', 222);


INSERT INTO WRITING (Wid, Eid, Iid)
VALUES
    (1, 'E11', 111),
    (2, 'E22', 222);


-------------------------------------------------------CREATING THE DATASTAGING-----------------------------------------------------------------

CREATE DATABASE HHDataStagingDB
USE HHDataStagingDB;


-- Create the Calendar dimension table
CREATE TABLE Calendar (
    CalendarKey INT PRIMARY KEY, 
    Day INT NOT NULL,          
    Month INT NOT NULL,         
    Year INT NOT NULL            
);


-- Create the Donors dimension table
CREATE TABLE Donors (
    DonorKey INT PRIMARY KEY,   
    DonorName VARCHAR(100) NOT NULL, 
    DonorSex CHAR(1) NOT NULL    
);

-- Create the Fundraisers dimension table
CREATE TABLE Fundraisers (
    FRKey INT PRIMARY KEY,                   -- Primary key for the table
    FRLocationKey INT,                       -- Key for the location
    FundraiserID VARCHAR(50) NOT NULL,       -- Fundraiser ID (length 50 specified)
    FundraiserName VARCHAR(100) NOT NULL,    -- Name of the fundraiser (length 100)
    FundraiserSex CHAR(1) NOT NULL,          -- Gender ('M' or 'F')
    FRLocationAddress VARCHAR(255) NOT NULL, -- Address of the fundraiser (length 255)
    FundraiserType VARCHAR(50) NOT NULL      -- Type of fundraiser (e.g., 'Phone', 'Event', etc.)
);

-- Create the Revenue fact table
CREATE TABLE RevenueFactTable (
    TID INT PRIMARY KEY,                    
    CalendarKey INT NOT NULL,              
    FundraisersKey INT NOT NULL,            
    DonorKey INT NOT NULL,                  
    DonationType VARCHAR(50) NOT NULL,     
    DollarsDonated DECIMAL(18, 2) NOT NULL, 

    -- Define foreign key constraints
    CONSTRAINT FK_Revenue_Calendar FOREIGN KEY (CalendarKey) REFERENCES Calendar(CalendarKey),
    CONSTRAINT FK_Revenue_Fundraisers FOREIGN KEY (FundraisersKey) REFERENCES Fundraisers(FRKey),
    CONSTRAINT FK_Revenue_Donors FOREIGN KEY (DonorKey) REFERENCES Donors(DonorKey)
);

