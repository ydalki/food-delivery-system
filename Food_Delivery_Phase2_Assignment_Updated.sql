-- ============================================================
-- Project: Food Delivery Database Implementation
-- Description: This script implements a relational database for a 
-- food delivery system including entities like customers, orders, 
-- restaurants, and payments with full referential integrity.
-- ============================================================

CREATE DATABASE IF NOT EXISTS FoodDeliveryDB;
USE FoodDeliveryDB;

-- ------------------------------------------------------------
-- PRE-IMPLEMENTATION: Cleanup
-- Description: Disabling foreign key checks to drop existing tables 
-- without conflicts, ensuring a fresh installation.
-- ------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS Sales_Monitoring_View;
DROP TABLE IF EXISTS ORDER_MENU_ITEM, PAYMENT, CUSTOMER_ADDRESS, FOOD_ORDER, 
                   MENU_ITEM, RESTAURANT, ADDRESS, PAYMENT_METHOD, 
                   DELIVERY_DRIVER, ORDER_STATUS, CUSTOMER;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. Table: CUSTOMER
-- Purpose: Stores personal identification and contact details for users.
-- ------------------------------------------------------------
CREATE TABLE CUSTOMER (
    Customer_ID INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- 2. Table: ADDRESS
-- Purpose: Centralized table for geographical locations.
-- ------------------------------------------------------------
CREATE TABLE ADDRESS (
    address_id INT PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    full_address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    city VARCHAR(50) NOT NULL
);

-- ------------------------------------------------------------
-- 3. Table: CUSTOMER_ADDRESS (M:N Bridge Table)
-- Purpose: Links customers to multiple addresses (home, work, etc.).
-- ------------------------------------------------------------
CREATE TABLE CUSTOMER_ADDRESS (
    Customer_ID INT NOT NULL,
    address_id INT NOT NULL,
    PRIMARY KEY (Customer_ID, address_id),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES ADDRESS(address_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. Table: RESTAURANT
-- Purpose: Stores restaurant business names and their physical locations.
-- ------------------------------------------------------------
CREATE TABLE RESTAURANT (
    Restaurant_ID INT PRIMARY KEY,
    Restaurant_name VARCHAR(100) NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES ADDRESS(address_id) ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 5. Table: MENU_ITEM
-- Purpose: Stores the food items available in each restaurant.
-- ------------------------------------------------------------
CREATE TABLE MENU_ITEM (
    ITEM_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0), -- Constraint: Price must be positive
    Restaurant_ID INT NOT NULL,
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANT(Restaurant_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 6. Table: PAYMENT_METHOD
-- Purpose: Catalog of accepted payment types (e.g., Credit Card, Cash).
-- ------------------------------------------------------------
CREATE TABLE PAYMENT_METHOD (
    method_id INT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- 7. Table: DELIVERY_DRIVER
-- Purpose: Profile details for personnel handling the deliveries.
-- ------------------------------------------------------------
CREATE TABLE DELIVERY_DRIVER (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100) NOT NULL
);

-- ------------------------------------------------------------
-- 8. Table: ORDER_STATUS
-- Purpose: Defines the lifecycle of an order (Pending, Delivered, etc.).
-- ------------------------------------------------------------
CREATE TABLE ORDER_STATUS (
    status_id INT PRIMARY KEY,
    status_state VARCHAR(50) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- 9. Table: FOOD_ORDER
-- Purpose: The central transaction table connecting customers, drivers, and restaurants.
-- ------------------------------------------------------------
CREATE TABLE FOOD_ORDER (
    Food_Order_ID INT PRIMARY KEY,
    Delivery_fee DECIMAL(10,2) NOT NULL CHECK (Delivery_fee >= 0),
    requested_deliverytime DATETIME NOT NULL,
    driver_rating DECIMAL(2,1) CHECK (driver_rating BETWEEN 0 AND 5),
    Restaurant_Rating DECIMAL(2,1) CHECK (Restaurant_Rating BETWEEN 0 AND 5),
    Total_Amount DECIMAL(10,2) NOT NULL,
    order_date_time DATETIME NOT NULL,
    Customer_ID INT NOT NULL,
    driver_id INT,
    status_id INT NOT NULL,
    Restaurant_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID),
    FOREIGN KEY (driver_id) REFERENCES DELIVERY_DRIVER(driver_id) ON DELETE SET NULL, -- Driver deletion doesn't delete the order history
    FOREIGN KEY (status_id) REFERENCES ORDER_STATUS(status_id),
    FOREIGN KEY (Restaurant_ID) REFERENCES RESTAURANT(Restaurant_ID)
);

-- ------------------------------------------------------------
-- 10. Table: PAYMENT (Weak Entity)
-- Purpose: Detailed financial records for each successful food order.
-- ------------------------------------------------------------
CREATE TABLE PAYMENT (
    Payment_ID INT PRIMARY KEY,
    Food_Order_ID INT NOT NULL UNIQUE,
    method_id INT NOT NULL,
    payment_time DATETIME NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (Food_Order_ID) REFERENCES FOOD_ORDER(Food_Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (method_id) REFERENCES PAYMENT_METHOD(method_id)
);

-- ------------------------------------------------------------
-- 11. Table: ORDER_MENU_ITEM (M:N Weak Entity)
-- Purpose: Intersection table storing specific quantities of food items per order.
-- ------------------------------------------------------------
CREATE TABLE ORDER_MENU_ITEM (
    order_item_id INT PRIMARY KEY,
    Food_Order_ID INT NOT NULL,
    ITEM_ID INT NOT NULL,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered > 0),
    FOREIGN KEY (Food_Order_ID) REFERENCES FOOD_ORDER(Food_Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (ITEM_ID) REFERENCES MENU_ITEM(ITEM_ID)
);

-- ============================================================
-- DATA POPULATION (INSERT STATEMENTS)
-- ============================================================

-- Customers: Local Turkish test data
INSERT INTO CUSTOMER VALUES 
(1, 'İlgin', 'Pak', 'ilgin@email.com', '05551112233'),
(2, 'Samet Kaan', 'Karakaçan', 'samet@email.com', '05552223344'),
(3, 'Yaren', 'Dalkıran', 'yaren@email.com', '05553334455'),
(4, 'Elif Hilal', 'Kürtçüoğlu', 'elif@email.com', '05554445566'),
(5, 'Jane', 'Doe', 'jane@email.com', '05555556677');

-- Addresses and Bridge entries
INSERT INTO ADDRESS VALUES 
(1, 'Turkey', 'Beşiktaş Cad. No:1', '34353', 'İstanbul'),
(2, 'Turkey', 'Kızılay Meydanı No:10', '06420', 'Ankara'),
(3, 'Turkey', 'Alsancak Boyoz Sokak', '35220', 'İzmir'),
(4, 'Turkey', 'Bursa Nilüfer Bulvarı', '16140', 'Bursa'),
(5, 'Turkey', 'Antalya Lara Plajı', '07160', 'Antalya');

INSERT INTO CUSTOMER_ADDRESS VALUES (1,1), (2,2), (3,3), (4,4), (5,5);

-- Restaurants and their specific Menu Items
INSERT INTO RESTAURANT VALUES 
(1, 'Tahin', 1), (2, 'Dominos', 2), (3, 'Damga Çiğköfte', 3), (4, 'Vaveyla', 4), (5, 'Hot Döner', 5);

INSERT INTO MENU_ITEM VALUES 
(1, 'Falafel Porsiyon', 'Middle Eastern Special', 500.00, 1),
(2, 'Humus', 'Classic Hummus Plate', 300.00, 1),
(3, 'Large Pizza', 'Dominos Super Special', 400.00, 2),
(4, 'French Fries', 'Crispy and Salty', 150.00, 2),
(5, 'Doritos Cigkofte', 'Damga Special Sauce', 120.00, 3),
(6, 'Ayran', 'Cold Turkish Yogurt Drink', 25.00, 3),
(7, 'Souffle', 'Hot Chocolate Lava Cake', 130.00, 4),
(8, 'Profiterole', 'Cream Filled Pastry', 170.00, 4),
(9, 'Chicken Wrap', 'HotDöner Signature Wrap', 200.00, 5),
(10, 'Meat Wrap', 'Beef Antricote Wrap', 350.00, 5);

-- Reference Data: Payment methods, Drivers, and Statuses
INSERT INTO PAYMENT_METHOD VALUES (1, 'Credit Card'), (2, 'Cash'), (3, 'Online'), (4, 'Meal Card'), (5, 'Wallet');
INSERT INTO DELIVERY_DRIVER VALUES (1, 'Ahmet Yılmaz'), (2, 'Mehmet Demir'), (3, 'Caner Şahin'), (4, 'Buse Arkan'), (5, 'Murat Kaya');
INSERT INTO ORDER_STATUS VALUES (1, 'Pending'), (2, 'Preparing'), (3, 'On the Way'), (4, 'Delivered'), (5, 'Cancelled');

-- Transactions: Food Orders and Payments
INSERT INTO FOOD_ORDER VALUES 
(1, 30.00, '2026-05-10 19:00:00', 4.5, 5.0, 830.00, '2026-05-10 18:15:00', 1, 1, 4, 1),
(2, 25.00, '2026-05-10 20:00:00', 4.0, 4.0, 575.00, '2026-05-10 19:20:00', 2, 2, 4, 2),
(3, 15.00, '2026-05-10 21:00:00', NULL, NULL, 160.00, '2026-05-10 20:30:00', 3, 3, 1, 3),
(4, 20.00, '2026-05-10 22:00:00', 5.0, 4.8, 320.00, '2026-05-10 21:15:00', 4, 4, 4, 4),
(5, 35.00, '2026-05-10 15:00:00', 4.2, 4.5, 585.00, '2026-05-10 14:10:00', 5, 5, 4, 5);

INSERT INTO PAYMENT VALUES 
(1, 1, 1, '2026-05-10 18:16:00', 830.00, 'Paid'),
(2, 2, 3, '2026-05-10 19:21:00', 575.00, 'Paid'),
(3, 3, 2, '2026-05-10 20:31:00', 160.00, 'Pending'),
(4, 4, 1, '2026-05-10 21:16:00', 320.00, 'Paid'),
(5, 5, 4, '2026-05-10 14:11:00', 585.00, 'Paid');

INSERT INTO ORDER_MENU_ITEM VALUES (1,1,1,1), (2,1,2,1), (3,2,3,1), (4,2,4,1), (5,3,5,1), (6,3,6,1), (7,4,7,1), (8,4,8,1), (9,5,9,1), (10,5,10,1);

-- ============================================================
-- SECTION B: ANALYTICAL SQL QUERIES
-- ============================================================

-- Query 1: Find all customers residing in Istanbul using a join.
SELECT DISTINCT c.first_name, c.last_name, a.city 
FROM CUSTOMER c
JOIN CUSTOMER_ADDRESS ca ON c.Customer_ID = ca.Customer_ID
JOIN ADDRESS a ON ca.address_id = a.address_id 
WHERE a.city = 'İstanbul';

-- Query 2: Retrieve menu items sorted by price in descending order (Most expensive first).
SELECT Name, Price FROM MENU_ITEM ORDER BY Price DESC;

-- Query 3: Calculate the total order volume and the average transaction value.
SELECT COUNT(*) as TotalOrders, AVG(Total_Amount) as AvgOrderValue 
FROM FOOD_ORDER;

-- Query 4: Identify high-performing restaurants with total sales exceeding 500 TL.
SELECT r.Restaurant_name, SUM(f.Total_Amount) as TotalRevenue 
FROM RESTAURANT r
JOIN FOOD_ORDER f ON r.Restaurant_ID = f.Restaurant_ID 
GROUP BY r.Restaurant_name 
HAVING SUM(f.Total_Amount) > 500;

-- Query 5: Join orders with customer names and their current delivery status.
SELECT f.Food_Order_ID, CONCAT(c.first_name, ' ', c.last_name) as CustomerName, os.status_state 
FROM FOOD_ORDER f
JOIN CUSTOMER c ON f.Customer_ID = c.Customer_ID
JOIN ORDER_STATUS os ON f.status_id = os.status_id;

-- Query 6: Complex multi-table join for a complete order logistics report.
SELECT f.Food_Order_ID, r.Restaurant_name, d.driver_name, pm.method_name, p.payment_status 
FROM FOOD_ORDER f
JOIN RESTAURANT r ON f.Restaurant_ID = r.Restaurant_ID
LEFT JOIN DELIVERY_DRIVER d ON f.driver_id = d.driver_id
JOIN PAYMENT p ON f.Food_Order_ID = p.Food_Order_ID
JOIN PAYMENT_METHOD pm ON p.method_id = pm.method_id;

-- Query 7: Scalar subquery to find premium items priced above the global average.
SELECT Name, Price FROM MENU_ITEM 
WHERE Price > (SELECT AVG(Price) FROM MENU_ITEM);

-- Query 8: Nested query to find loyal customers who have received at least one delivered order.
SELECT first_name, last_name FROM CUSTOMER 
WHERE Customer_ID IN (SELECT Customer_ID FROM FOOD_ORDER WHERE status_id = 4);

-- Query 9: Performance analysis of delivery drivers using a Left Outer Join to include idle drivers.
SELECT d.driver_name, COUNT(f.Food_Order_ID) as OrderCount 
FROM DELIVERY_DRIVER d
LEFT JOIN FOOD_ORDER f ON d.driver_id = f.driver_id 
GROUP BY d.driver_name;

-- Query 10: Permanent View creation for real-time sales summary monitoring.
DROP VIEW IF EXISTS Sales_Monitoring_View;

CREATE VIEW Sales_Monitoring_View AS 
SELECT r.Restaurant_name, f.Total_Amount, f.order_date_time 
FROM FOOD_ORDER f 
JOIN RESTAURANT r ON f.Restaurant_ID = r.Restaurant_ID;

-- Testing the View
SELECT * FROM Sales_Monitoring_View;
