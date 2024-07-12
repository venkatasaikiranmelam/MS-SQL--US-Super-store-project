USE [US Superstore]
GO

--------------------------------------Data Tansformation------------------------------------------------------
ALTER TABLE	[US Superstore].[dbo].[US superstore data] Drop column Row_ID;     ------------- Order_Date and Ship_Date variable should include only dates so time has to omitted. 
ALTER TABLE	[US Superstore].[dbo].[US superstore data] Drop column Order_ID;
ALTER TABLE	[US Superstore].[dbo].[US superstore data] Drop column Customer_ID;
ALTER TABLE	[US Superstore].[dbo].[US superstore data] Drop column Product_ID;

ALTER TABLE	[US Superstore].[dbo].[US superstore data] ALTER column order_date DATE;
ALTER TABLE	[US Superstore].[dbo].[US superstore data] ALTER column Ship_date DATE;

----------------------------DROP FACTSTORE----------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FactStore]') AND type in (N'U'))
DROP TABLE [dbo].[FactStore]
GO
----------------------------DROP dim Tables---------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimLocation]') AND type in (N'U'))
DROP TABLE [dbo].[dimLocation]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimOrder]') AND type in (N'U'))
DROP TABLE [dbo].[dimOrder]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimShip]') AND type in (N'U'))
DROP TABLE [dbo].[dimShip]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimShipMode]') AND type in (N'U'))
DROP TABLE [dbo].[dimShipMode]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimCustomer]') AND type in (N'U'))
DROP TABLE [dbo].[dimCustomer]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimCategory]') AND type in (N'U'))
DROP TABLE [dbo].[dimCategory]
GO
-------------------------------------Drop temp Tables------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Loc_table]') AND type in (N'U'))
DROP TABLE [dbo].[Loc_table]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Date_of_Order]') AND type in (N'U'))
DROP TABLE [dbo].[Date_of_Order]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Date_of_Ship]') AND type in (N'U'))
DROP TABLE [dbo].[Date_of_Ship]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MODE]') AND type in (N'U'))
DROP TABLE [dbo].[MODE]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customer]') AND type in (N'U'))
DROP TABLE [dbo].[Customer]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Category1]') AND type in (N'U'))
DROP TABLE [dbo].[Category1]
GO

---------------------------------------------------------------------------------------------
----dimLocation
---------------------------------------------------------------------------------------------


CREATE TABLE Loc_table(
[City][nvarchar](50) NULL,
[State][nvarchar](50) NULL,
[Region][nvarchar](50) NULL,
[Postal_code][int] NULL
);
INSERT INTO Loc_table(City,State,Region,Postal_Code)
SELECT City,State,Region,Postal_Code FROM [US Superstore].[dbo].[US superstore data]
GROUP BY City,State,Region,Postal_Code;

ALTER TABLE Loc_table ADD Location_ID int identity(1,1);
SELECT * FROM Loc_table ORDER BY Location_ID;


CREATE TABLE dimLocation(
Location_ID int not null,
[City][nvarchar](50) NULL,
[State][nvarchar](50) NULL,
[Region][nvarchar](50) NULL,
[Postal_code][int] NULL,
PRIMARY KEY (Location_ID)
);

INSERT INTO dimLocation(Location_ID,City,State,Region,Postal_Code)
SELECT Location_ID,City,State,Region,Postal_Code FROM Loc_table
;

select * from dimLocation

---------------------------------------------------------------------------------------------------------------
----dimOrder
---------------------------------------------------------------------------------------------------------------

CREATE TABLE Date_of_Order(Order_date date);
INSERT INTO Date_of_Order(Order_date) SELECT DISTINCT(Order_date) FROM [US Superstore].[dbo].[US superstore data];
ALTER TABLE Date_of_Order add Date_id int identity(1,1);
CREATE TABLE dimOrder(
	Date_id int,
	Order_Date date,
	Year_Order int,
	Month_Order int,
	Day_Order int,
PRIMARY KEY(Date_id)
);
INSERT INTO dimOrder(Date_id, Order_Date, Year_Order, Month_Order, Day_Order)
SELECT Date_id, Order_Date, Year(Order_date), Month(Order_date), Day(Order_date)
FROM Date_of_Order
;
select * from dimOrder

-----------------------------------------------------------------------------------------------------------
----dimShip
-----------------------------------------------------------------------------------------------------------

CREATE TABLE Date_of_Ship(Ship_date date);
INSERT INTO Date_of_Ship(Ship_date) SELECT DISTINCT(Ship_date) FROM [US Superstore].[dbo].[US superstore data];
ALTER TABLE Date_of_Ship add DateShip_id int identity(1,1);

CREATE TABLE dimShip(
	DateShip_id int,
	Ship_Date date,
	Year_Ship int,
	Month_Ship int,
	Day_Ship int,
PRIMARY KEY(DateShip_id)
);

INSERT INTO dimShip(DateShip_id, Ship_Date, Year_Ship, Month_Ship, Day_Ship)
SELECT DateShip_id, Ship_Date, Year(Ship_date), Month(Ship_date), Day(Ship_date)
FROM Date_of_Ship
;
---------------------------------------------------------------------------------------------
----dimShipMode
---------------------------------------------------------------------------------------------


CREATE TABLE MODE([Ship_Mode] [nvarchar] (50));

INSERT INTO MODE(Ship_Mode) 
SELECT Ship_Mode 
FROM [US Superstore].[dbo].[US superstore data]
GROUP BY Ship_Mode;

ALTER TABLE MODE add Ship_Mode_ID int identity(1,1);

SELECT * FROM MODE ORDER BY Ship_Mode_ID; 
CREATE TABLE dimShipMode(
	Ship_Mode_ID int NOT NULL,
	[Ship_Mode] [nvarchar](50) NULL,
    PRIMARY KEY(Ship_Mode_ID)
);
INSERT INTO dimShipMode(Ship_Mode_ID,Ship_Mode)
SELECT Ship_Mode_ID,Ship_Mode
FROM MODE
;

---------------------------------------------------------------------------------------------
----dimCustomer
---------------------------------------------------------------------------------------------


CREATE TABLE Customer (
[Customer_name] [nvarchar] (50) NULL,
[segment] [nvarchar] (50) NULL
);
INSERT INTO Customer(Customer_name,Segment)
SELECT Customer_name,Segment FROM [US Superstore].[dbo].[US superstore data]
GROUP BY Customer_name,Segment
;
ALTER TABLE Customer ADD Customer_ID int identity(1,1);

SELECT * FROM Customer ORDER BY Customer_ID;

CREATE TABLE dimCustomer(
Customer_ID int NOT NULL,
[Customer_name][nvarchar](50) NULL,
[Segment] [nvarchar](50) NULL,
PRIMARY KEY (Customer_ID)
);

INSERT INTO dimCustomer (Customer_ID,Customer_name,Segment)
SELECT Customer_ID,Customer_name,Segment
FROM Customer
;
---------------------------------------------------------------------------------------------
----dimCategory
---------------------------------------------------------------------------------------------

CREATE TABLE Category1 (
[Category] [nvarchar] (50) NULL,
[Sub_Category] [nvarchar] (50) NULL,
[Product_Name] [nvarchar] (150) NULL
);
INSERT INTO Category1(Category,Sub_Category, Product_Name)
SELECT Category,Sub_Category, Product_Name FROM [US Superstore].[dbo].[US superstore data]
GROUP BY Category,Sub_Category, Product_Name
;
ALTER TABLE Category1 ADD Category_ID int identity(1,1);


SELECT * FROM Category1 ORDER BY Category_ID;

CREATE TABLE dimCategory(
Category_ID int NOT NULL,
[Category][nvarchar](50) NULL,
[Sub_Category] [nvarchar](50) NULL,
[Product_name][nvarchar](150) NULL,
PRIMARY KEY (Category_ID)
);

INSERT INTO dimCategory(Category_ID,Category,Sub_Category,Product_name)
SELECT Category_ID,Category,Sub_Category,Product_name
FROM Category1
;

----------------------------------------------------------------------------------------------
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Location_ID INT; 
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Date_ID int;
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Date0_ID int;
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Ship_Mode_ID int; 
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Customer_ID int; 
 --ALTER TABLE [US Superstore].[dbo].[US Superstore data] ADD Category_ID int;
 
----------------------------------------------------------------------------------------------

update [US Superstore].[dbo].[US Superstore data]
set [US Superstore].[dbo].[US Superstore data].Category_ID=[US Superstore].[dbo].[dimCategory].Category_ID 
FROM [US Superstore].[dbo].[dimCategory]
WHERE [US Superstore].[dbo].[US Superstore data].Category=[US Superstore].[dbo].[dimCategory].Category 
and [US Superstore].[dbo].[US Superstore data].Sub_Category=[US Superstore].[dbo].[dimCategory].Sub_Category 
and [US Superstore].[dbo].[US Superstore data].Product_Name=[US Superstore].[dbo].[dimCategory].Product_Name

update [US Superstore].[dbo].[US Superstore data]
set [US Superstore].[dbo].[US Superstore data].Customer_ID=[US Superstore].[dbo].[dimCustomer].Customer_ID 
FROM [US Superstore].[dbo].[dimCustomer]
WHERE [US Superstore].[dbo].[US Superstore data].Customer_Name=[US Superstore].[dbo].[dimCustomer].Customer_name 
and [US Superstore].[dbo].[US Superstore data].Segment=[US Superstore].[dbo].[dimCustomer].Segment

update [US Superstore].[dbo].[US Superstore data]
set [US Superstore].[dbo].[US Superstore data].Ship_Mode_ID=[US Superstore].[dbo].[dimShipMode].Ship_Mode_ID 
FROM [US Superstore].[dbo].[dimShipMode]
WHERE [US Superstore].[dbo].[US Superstore data].Ship_Mode=[US Superstore].[dbo].[dimShipMode].Ship_Mode

update [US Superstore].[dbo].[US Superstore data]
set [US Superstore].[dbo].[US Superstore data].Date_ID=[US Superstore].[dbo].[dimOrder].Date_id 
FROM [US Superstore].[dbo].[dimOrder]
WHERE [US Superstore].[dbo].[US Superstore data].Order_Date=[US Superstore].[dbo].[dimOrder].Order_Date


update [US Superstore].[dbo].[US Superstore data]
set [US Superstore].[dbo].[US Superstore data].Location_ID=[US Superstore].[dbo].[dimLocation].Location_ID 
FROM [US Superstore].[dbo].[dimLocation]
WHERE [US Superstore].[dbo].[US Superstore data].City=[US Superstore].[dbo].[dimLocation].City 
and [US superstore].[dbo].[US Superstore data].State=[US Superstore].[dbo].[dimLocation].state 
and [US Superstore].[dbo].[US Superstore data].Region=[US Superstore].[dbo].[dimLocation].Region 
and [US Superstore].[dbo].[US Superstore data].Postal_Code=[US Superstore].[dbo].[dimLocation].Postal_Code
------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
----FactStore
---------------------------------------------------------------------------------------------

Create table FactStore(
location_ID int,
category_ID int,
customer_ID int,
ship_Mode_ID int,
dateOrder_id int,
dateShip_id int, 
profit float, 
Discount float, 
Quantity int,
Sales float,
CONSTRAINT FK_dimLocation_FactStore FOREIGN KEY (location_ID) REFERENCES [dimLocation] (Location_ID),
CONSTRAINT FK_dimCategory_FactStore FOREIGN KEY (category_ID) REFERENCES [dimCategory] (Category_ID),
CONSTRAINT FK_dimCustomer_FactStore FOREIGN KEY (customer_ID) REFERENCES [dimCustomer] (Customer_ID), 
CONSTRAINT FK_dimShipMode_FactStore FOREIGN KEY (ship_Mode_ID) REFERENCES [dimShipMode] (Ship_Mode_ID), 
CONSTRAINT FK_dimOrder_FactStore FOREIGN KEY (dateOrder_id) REFERENCES [dimOrder] (Date_id),
)
insert into FactStore (location_ID, category_ID, customer_ID, ship_Mode_ID, dateOrder_id, profit, Discount, Quantity, Sales) 
select Location_ID,Category_ID,Customer_ID,Ship_Mode_ID,Date_id,Profit,Discount,Quantity,Sales
from [US Superstore].[dbo].[US Superstore data] 



select * from FactStore
select * from [US Superstore data]