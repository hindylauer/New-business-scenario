-- Bikeshop business scenario implementation using a single table
-- Schema, constraints, sample data, and reporting queries for SQL Server

IF DB_ID('BikeSales') IS NOT NULL
    DROP DATABASE BikeSales;
GO

CREATE DATABASE BikeSales;
GO

USE BikeSales;
GO

DROP TABLE IF EXISTS dbo.BikeSales;
GO

CREATE TABLE dbo.BikeSales (
    BikeSalesID INT NOT NULL IDENTITY(1, 1)
        CONSTRAINT PK_BikeSales PRIMARY KEY,
    CustomerFirstName VARCHAR(50) NOT NULL
        CONSTRAINT CK_BikeSales_CustomerFirstName_NotBlank CHECK (CustomerFirstName <> ''),
    CustomerLastName VARCHAR(50) NOT NULL
        CONSTRAINT CK_BikeSales_CustomerLastName_NotBlank CHECK (CustomerLastName <> ''),
    StreetAddress VARCHAR(100) NOT NULL
        CONSTRAINT CK_BikeSales_StreetAddress_NotBlank CHECK (StreetAddress <> ''),
    City VARCHAR(50) NOT NULL
        CONSTRAINT CK_BikeSales_City_NotBlank CHECK (City <> ''),
    CustomerState CHAR(2) NOT NULL
        CONSTRAINT CK_BikeSales_CustomerState_NotBlank CHECK (CustomerState <> ''),
        CONSTRAINT CK_BikeSales_CustomerState_Format CHECK (CustomerState LIKE '[A-Z][A-Z]'),
    PostalCode CHAR(5) NOT NULL
        CONSTRAINT CK_BikeSales_PostalCode_NotBlank CHECK (PostalCode <> ''),
        CONSTRAINT CK_BikeSales_PostalCode_Format CHECK (PostalCode LIKE '[0-9][0-9][0-9][0-9][0-9]'),
    CustomerPhoneNumber VARCHAR(15) NOT NULL
        CONSTRAINT CK_BikeSales_CustomerPhoneNumber_NotBlank CHECK (CustomerPhoneNumber <> ''),
        CONSTRAINT CK_BikeSales_CustomerPhoneNumber_Format CHECK (CustomerPhoneNumber NOT LIKE '%[^0-9-]%'),
    CompanyName VARCHAR(100) NOT NULL
        CONSTRAINT CK_BikeSales_CompanyName_NotBlank CHECK (CompanyName <> ''),
    BikeSize VARCHAR(10) NOT NULL
        CONSTRAINT CK_BikeSales_BikeSize_NotBlank CHECK (BikeSize <> ''),
    BikeColor VARCHAR(50) NOT NULL
        CONSTRAINT CK_BikeSales_BikeColor_NotBlank CHECK (BikeColor <> ''),
    PurchaseDate DATE NOT NULL
        CONSTRAINT CK_BikeSales_PurchaseDate_Min CHECK (PurchaseDate >= '2022-03-01'),
    SaleDate DATE NOT NULL
        CONSTRAINT CK_BikeSales_SaleDate_Min CHECK (SaleDate >= '2022-06-01'),
        CONSTRAINT CK_BikeSales_SaleDate_AfterPurchase CHECK (SaleDate >= PurchaseDate),
    Season VARCHAR(10) NOT NULL
        CONSTRAINT CK_BikeSales_Season_NotBlank CHECK (Season <> ''),
        CONSTRAINT CK_BikeSales_Season_Allowed CHECK (Season IN ('Spring', 'Summer', 'Fall', 'Winter')),
        CONSTRAINT CK_BikeSales_Season_MatchesSale CHECK (
            (Season = 'Spring' AND DATEPART(MONTH, SaleDate) BETWEEN 3 AND 5) OR
            (Season = 'Summer' AND DATEPART(MONTH, SaleDate) BETWEEN 6 AND 8) OR
            (Season = 'Fall' AND DATEPART(MONTH, SaleDate) BETWEEN 9 AND 11) OR
            (Season = 'Winter' AND (DATEPART(MONTH, SaleDate) = 12 OR DATEPART(MONTH, SaleDate) BETWEEN 1 AND 2))
        ),
    PurchasePrice DECIMAL(8, 2) NOT NULL
        CONSTRAINT CK_BikeSales_PurchasePrice_Positive CHECK (PurchasePrice > 0),
    SalePrice DECIMAL(8, 2) NOT NULL
        CONSTRAINT CK_BikeSales_SalePrice_Positive CHECK (SalePrice > 0),
        CONSTRAINT CK_BikeSales_SalePrice_Cap CHECK (SalePrice <= 3000),
    BikeStatus VARCHAR(10) NOT NULL
        CONSTRAINT CK_BikeSales_BikeStatus_NotBlank CHECK (BikeStatus <> ''),
        CONSTRAINT CK_BikeSales_BikeStatus_Allowed CHECK (BikeStatus IN ('New', 'Used')),
    BikeCondition VARCHAR(20) NULL
        CONSTRAINT CK_BikeSales_BikeCondition_NotBlank CHECK (BikeCondition IS NULL OR BikeCondition <> ''),
        CONSTRAINT CK_BikeSales_BikeCondition_Allowed CHECK (BikeCondition IS NULL OR BikeCondition IN ('Perfect', 'Minor Fixup', 'Major Fixup', 'Restoration')),
        CONSTRAINT CK_BikeSales_BikeCondition_Requirement CHECK ((BikeStatus = 'Used' AND BikeCondition IS NOT NULL) OR (BikeStatus = 'New' AND BikeCondition IS NULL))
);
GO

-- Sample data --------------------------------------------------------------

INSERT INTO BikeSales (
    CustomerFirstName, CustomerLastName, StreetAddress, City, CustomerState,
    PostalCode, CustomerPhoneNumber, CompanyName, BikeSize, BikeColor,
    PurchaseDate, SaleDate, Season, PurchasePrice, SalePrice,
    BikeStatus, BikeCondition
)
SELECT 'Shmuel', 'Bitton', '4 Sparrow Drive', 'Spring Valley', 'NY', '10977', '845-425-9501', 'Schwinn', '24"', 'Black', '2022-07-20', '2022-09-15', 'Summer', 110.00, 220.00, 'New', NULL UNION ALL
SELECT 'Jack', 'Sullivan', '1889 Fifty Second Street', 'Brooklyn', 'NY', '11218', '718-350-4401', 'Trek', '24"', 'Gray', '2023-01-26', '2023-05-11', 'Spring', 150.00, 250.00, 'New', NULL UNION ALL
SELECT 'Rochel', 'Cohen', '95 Francis Place', 'Spring Valley', 'NY', '10977', '845-371-2052', 'Huffy', '16"', 'Pink', '2023-03-13', '2023-06-18', 'Spring', 30.00, 85.00, 'New', NULL UNION ALL
SELECT 'Meir', 'Stern', '7 Bluejay Street', 'Spring Valley', 'NY', '10977', '845-426-9806', 'Razor', '20"', 'Slate', '2023-08-06', '2023-10-26', 'Fall', 17.00, 61.00, 'Used', 'Restoration' UNION ALL
SELECT 'Yehuda', 'Gluck', '11 Parness Rd. #3', 'South Fallsburg', 'NY', '12733', '845-434-4011', 'Kent', '26"', 'Black', '2024-01-08', '2024-02-19', 'Winter', 120.00, 250.00, 'New', NULL UNION ALL
SELECT 'Gedallia', 'Gold', '2036 Park Avenue', 'Lakewood', 'NJ', '08701', '732-930-6402', 'Trek', '20"', 'Blue', '2022-05-12', '2024-02-07', 'Winter', 105.00, 200.00, 'Used', 'Minor Fixup' UNION ALL
SELECT 'Binyomin', 'Shapiro', '66 Carlton Road', 'Monsey', 'NY', '10952', '845-356-9027', 'Schwinn', '26"', 'Gray', '2022-04-22', '2024-01-09', 'Winter', 150.00, 135.00, 'Used', 'Perfect' UNION ALL
SELECT 'Malka', 'Fischer', '80 Twin Avenue', 'Spring Valley', 'NY', '10977', '845-425-9002', 'Malibu', '18"', 'Pink', '2022-12-04', '2023-06-23', 'Summer', 90.00, 120.00, 'New', NULL UNION ALL
SELECT 'Yonason', 'Katz', '1470 E 26th Street', 'Brooklyn', 'NY', '11223', '718-376-2658', 'Huffy', '20"', 'Blue', '2023-06-14', '2023-08-03', 'Summer', 76.00, 130.00, 'New', NULL UNION ALL
SELECT 'Bracha', 'Smith', '25 North Rigaud Road', 'Spring Valley', 'NY', '10977', '845-352-1099', 'Razor', '24"', 'Slate', '2023-05-18', '2023-07-22', 'Summer', 167.00, 220.00, 'New', NULL UNION ALL
SELECT 'Moshe', 'Weiss', '25 Old Nyack Turnpike', 'Monsey', 'NY', '10952', '845-356-9423', 'Kent', '24"', 'Black', '2022-12-13', '2023-08-16', 'Summer', 103.00, 195.00, 'Used', 'Minor Fixup' UNION ALL
SELECT 'Yehuda', 'Jacobs', '1650 Lexington Avenue', 'Lakewood', 'NJ', '08701', '732-930-8054', 'Schwinn', '20"', 'Blue', '2022-04-09', '2022-07-20', 'Summer', 42.00, 98.00, 'Used', 'Major Fixup';
GO

-- Reporting Queries -------------------------------------------------------

-- 1) Local vs out-of-town customers
SELECT
    CustomerLocation = CASE WHEN City = 'Spring Valley' AND CustomerState = 'NY' THEN 'Local' ELSE 'Out-of-Town' END,
    CustomerCount = COUNT(*)
FROM BikeSales
GROUP BY CASE WHEN City = 'Spring Valley' AND CustomerState = 'NY' THEN 'Local' ELSE 'Out-of-Town' END
ORDER BY CustomerLocation;
GO

-- 2) Number of bikes sold per season
SELECT
    Season,
    BikesSold = COUNT(*)
FROM BikeSales
GROUP BY Season
ORDER BY Season;
GO

-- 3) Days in store statistics and total profit
SELECT
    AverageDaysInStore = AVG(DATEDIFF(DAY, PurchaseDate, SaleDate) * 1.0),
    MinimumDaysInStore = MIN(DATEDIFF(DAY, PurchaseDate, SaleDate)),
    MaximumDaysInStore = MAX(DATEDIFF(DAY, PurchaseDate, SaleDate)),
    TotalProfit = SUM(SalePrice - PurchasePrice)
FROM BikeSales;
GO

-- 4) Profit per sale with customer and bike company details
SELECT
    CustomerName = CONCAT(CustomerFirstName, ' ', CustomerLastName),
    CompanyName,
    PurchasePrice,
    SalePrice,
    Profit = SalePrice - PurchasePrice,
    BikeStatus
FROM BikeSales
ORDER BY SaleDate;
GO

-- 5) Most popular bike company by sales count
SELECT TOP 1
    CompanyName,
    TimesSold = COUNT(*)
FROM BikeSales
GROUP BY CompanyName
ORDER BY TimesSold DESC, CompanyName;
GO

-- Maintenance Queries -----------------------------------------------------

-- Example: update a customer's phone number when they provide new contact details
-- UPDATE BikeSales
-- SET CustomerPhoneNumber = '000-000-0000'
-- WHERE CustomerFirstName = 'CustomerFirst' AND CustomerLastName = 'CustomerLast';

-- Example: adjust the sale price of a bike (still protected by the price cap constraint)
-- UPDATE BikeSales
-- SET SalePrice = 275.00
-- WHERE BikeSalesID = 1;

-- Example: record the condition of a used bike that was missing that information
-- UPDATE BikeSales
-- SET BikeCondition = 'Minor Fixup'
-- WHERE BikeSalesID = 2 AND BikeStatus = 'Used';
GO
