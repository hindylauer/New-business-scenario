-- Bikeshop business scenario implementation using a single table
-- Schema, constraints, sample data, and reporting queries

-- Clean up in case the script is re-run
DROP TABLE IF EXISTS bike_sales CASCADE;

-- Table capturing every sale along with denormalized customer and bike details
CREATE TABLE bike_sales (
    sale_id             SERIAL PRIMARY KEY,
    customer_first_name VARCHAR(100) NOT NULL,
    customer_last_name  VARCHAR(100) NOT NULL,
    street_address      VARCHAR(200) NOT NULL,
    city                VARCHAR(100) NOT NULL,
    state               CHAR(2) NOT NULL,
    postal_code         CHAR(5) NOT NULL,
    phone_number        VARCHAR(15) NOT NULL,
    company_name        VARCHAR(100) NOT NULL,
    bike_size           VARCHAR(10) NOT NULL,
    bike_color          VARCHAR(50) NOT NULL,
    purchase_date       DATE NOT NULL,
    sale_date           DATE NOT NULL,
    season              VARCHAR(10) NOT NULL,
    purchase_price      NUMERIC(8, 2) NOT NULL,
    sale_price          NUMERIC(8, 2) NOT NULL,
    bike_status         VARCHAR(10) NOT NULL,
    bike_condition      VARCHAR(20),
    CONSTRAINT uq_bike_sales_phone UNIQUE (phone_number, sale_date),
    CONSTRAINT chk_bike_sales_state CHECK (state ~ '^[A-Z]{2}$'),
    CONSTRAINT chk_bike_sales_postal CHECK (postal_code ~ '^[0-9]{5}$'),
    CONSTRAINT chk_bike_sales_phone CHECK (phone_number ~ '^[0-9\-]+$'),
    CONSTRAINT chk_bike_sales_season CHECK (season IN ('Spring', 'Summer', 'Fall', 'Winter')),
    CONSTRAINT chk_bike_sales_status CHECK (bike_status IN ('New', 'Used')),
    CONSTRAINT chk_bike_sales_condition_allowed CHECK (
        bike_condition IS NULL OR bike_condition IN ('Perfect', 'Minor Fixup', 'Major Fixup', 'Restoration')
    ),
    CONSTRAINT chk_bike_sales_condition_requirement CHECK (
        (bike_status = 'Used' AND bike_condition IS NOT NULL) OR
        (bike_status = 'New' AND bike_condition IS NULL)
    ),
    CONSTRAINT chk_bike_sales_purchase_positive CHECK (purchase_price > 0),
    CONSTRAINT chk_bike_sales_sale_positive CHECK (sale_price > 0),
    CONSTRAINT chk_bike_sales_sale_price_cap CHECK (sale_price <= 3000),
    CONSTRAINT chk_bike_sales_purchase_date CHECK (purchase_date >= DATE '2022-03-01'),
    CONSTRAINT chk_bike_sales_sale_date CHECK (sale_date >= DATE '2022-06-01'),
    CONSTRAINT chk_bike_sales_sale_after_purchase CHECK (sale_date >= purchase_date),
    CONSTRAINT chk_bike_sales_season_matches_sale CHECK (
        (season = 'Spring' AND EXTRACT(MONTH FROM sale_date) BETWEEN 3 AND 5) OR
        (season = 'Summer' AND EXTRACT(MONTH FROM sale_date) BETWEEN 6 AND 8) OR
        (season = 'Fall' AND EXTRACT(MONTH FROM sale_date) BETWEEN 9 AND 11) OR
        (season = 'Winter' AND (EXTRACT(MONTH FROM sale_date) = 12 OR EXTRACT(MONTH FROM sale_date) BETWEEN 1 AND 2))
    )
);

-- Sample data --------------------------------------------------------------

INSERT INTO bike_sales (
    customer_first_name, customer_last_name, street_address, city, state,
    postal_code, phone_number, company_name, bike_size, bike_color,
    purchase_date, sale_date, season, purchase_price, sale_price,
    bike_status, bike_condition
) VALUES
    ('Shmuel', 'Bitton', '4 Sparrow Drive', 'Spring Valley', 'NY', '10977', '845-425-9501', 'Schwinn', '24"', 'Black', DATE '2022-07-20', DATE '2022-09-15', 'Summer', 110.00, 220.00, 'New', NULL),
    ('Jack', 'Sullivan', '1889 Fifty Second Street', 'Brooklyn', 'NY', '11218', '718-350-4401', 'Trek', '24"', 'Gray', DATE '2023-01-26', DATE '2023-05-11', 'Spring', 150.00, 250.00, 'New', NULL),
    ('Rochel', 'Cohen', '95 Francis Place', 'Spring Valley', 'NY', '10977', '845-371-2052', 'Huffy', '16"', 'Pink', DATE '2023-03-13', DATE '2023-06-18', 'Spring', 30.00, 85.00, 'New', NULL),
    ('Meir', 'Stern', '7 Bluejay Street', 'Spring Valley', 'NY', '10977', '845-426-9806', 'Razor', '20"', 'Slate', DATE '2023-08-06', DATE '2023-10-26', 'Fall', 17.00, 61.00, 'Used', 'Restoration'),
    ('Yehuda', 'Gluck', '11 Parness Rd. #3', 'South Fallsburg', 'NY', '12733', '845-434-4011', 'Kent', '26"', 'Black', DATE '2024-01-08', DATE '2024-02-19', 'Winter', 120.00, 250.00, 'New', NULL),
    ('Gedallia', 'Gold', '2036 Park Avenue', 'Lakewood', 'NJ', '08701', '732-930-6402', 'Trek', '20"', 'Blue', DATE '2022-05-12', DATE '2024-02-07', 'Winter', 105.00, 200.00, 'Used', 'Minor Fixup'),
    ('Binyomin', 'Shapiro', '66 Carlton Road', 'Monsey', 'NY', '10952', '845-356-9027', 'Schwinn', '26"', 'Gray', DATE '2022-04-22', DATE '2024-01-09', 'Winter', 150.00, 135.00, 'Used', 'Perfect'),
    ('Malka', 'Fischer', '80 Twin Avenue', 'Spring Valley', 'NY', '10977', '845-425-9002', 'Malibu', '18"', 'Pink', DATE '2022-12-04', DATE '2023-06-23', 'Summer', 90.00, 120.00, 'New', NULL),
    ('Yonason', 'Katz', '1470 E 26th Street', 'Brooklyn', 'NY', '11223', '718-376-2658', 'Huffy', '20"', 'Blue', DATE '2023-06-14', DATE '2023-08-03', 'Summer', 76.00, 130.00, 'New', NULL),
    ('Bracha', 'Smith', '25 North Rigaud Road', 'Spring Valley', 'NY', '10977', '845-352-1099', 'Razor', '24"', 'Slate', DATE '2023-05-18', DATE '2023-07-22', 'Summer', 167.00, 220.00, 'New', NULL),
    ('Moshe', 'Weiss', '25 Old Nyack Turnpike', 'Monsey', 'NY', '10952', '845-356-9423', 'Kent', '24"', 'Black', DATE '2022-12-13', DATE '2023-08-16', 'Summer', 103.00, 195.00, 'Used', 'Minor Fixup'),
    ('Yehuda', 'Jacobs', '1650 Lexington Avenue', 'Lakewood', 'NJ', '08701', '732-930-8054', 'Schwinn', '20"', 'Blue', DATE '2022-04-09', DATE '2022-07-20', 'Summer', 42.00, 98.00, 'Used', 'Major Fixup');

-- Reporting Queries -------------------------------------------------------

-- 1) Local vs out-of-town customers
SELECT
    CASE WHEN city = 'Spring Valley' AND state = 'NY' THEN 'Local' ELSE 'Out-of-Town' END AS customer_location,
    COUNT(*) AS customer_count
FROM bike_sales
GROUP BY customer_location
ORDER BY customer_location;

-- 2) Number of bikes sold per season
SELECT
    season,
    COUNT(*) AS bikes_sold
FROM bike_sales
GROUP BY season
ORDER BY season;

-- 3) Days in store statistics and total profit
SELECT
    AVG(sale_date - purchase_date) AS average_days_in_store,
    MIN(sale_date - purchase_date) AS minimum_days_in_store,
    MAX(sale_date - purchase_date) AS maximum_days_in_store,
    SUM(sale_price - purchase_price) AS total_profit
FROM bike_sales;

-- 4) Profit per sale with customer and bike company details
SELECT
    customer_first_name || ' ' || customer_last_name AS customer_name,
    company_name,
    purchase_price,
    sale_price,
    sale_price - purchase_price AS profit,
    bike_status
FROM bike_sales
ORDER BY sale_date;

-- 5) Most popular bike company by sales count
SELECT
    company_name,
    COUNT(*) AS times_sold
FROM bike_sales
GROUP BY company_name
ORDER BY times_sold DESC, company_name
LIMIT 1;

-- Maintenance Queries -----------------------------------------------------

-- Example: update a customer's phone number when they provide new contact details
-- UPDATE bike_sales
-- SET phone_number = '000-000-0000'
-- WHERE customer_first_name = 'CustomerFirst' AND customer_last_name = 'CustomerLast';

-- Example: adjust the sale price of a bike (still protected by the price cap constraint)
-- UPDATE bike_sales
-- SET sale_price = 275.00
-- WHERE sale_id = 1;

-- Example: record the condition of a used bike that was missing that information
-- UPDATE bike_sales
-- SET bike_condition = 'Minor Fixup'
-- WHERE sale_id = 2 AND bike_status = 'Used';
