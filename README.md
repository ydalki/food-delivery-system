# 🍔 Food Delivery System — MIS236 Database Project

A relational database design and implementation project for a food delivery platform, built for the MIS236 Database Management Systems course.

---

## 📌 Project Overview

This project models a real-world food delivery system covering customers, restaurants, menus, orders, delivery drivers, and payments. The goal was to design a normalized relational schema, implement it in MySQL, and demonstrate analytical querying capabilities.

**Team Members:**
- İlgin Pak
- Samet Kaan Karakaçan
- Yaren Dalkıran
- Elif Hilal Kürtçüoğlu

---

## 🛠️ Technologies Used

- **Database:** MySQL 8.0
- **Design Tool:** ER Diagram (see `ER-diagram.pdf`)
- **Language:** SQL (DDL + DML + Views)

---

## 🗂️ Repository Structure

```
MIS236-Food-Delivery-System/
├── README.md
├── schema.sql                                              ← Full database: tables, inserts, queries, view
├── Relational Mapping of Online Food Delivery System.jpeg  ← Relational mapping diagram
├── ER-diagram.pdf                                          ← Entity-Relationship diagram
├── presentation-1.pdf                                      ← Project presentation slides
└── presentation-2.pdf                                      ← Project presentation slides
```

---

## 🔗 Relational Mapping

> Full diagram: `Relational Mapping of Online Food Delivery System.jpeg`

Primary keys are **underlined**. Foreign keys are marked with `- - -` (dashed underline).

### Strong Entities

```
CUSTOMER         (Customer_ID, first_name, last_name, Email, Phone)

RESTAURANT       (Restaurant_ID, Restaurant_name, address_id- - -)

MENU_ITEM        (ITEM_ID, Name, Description, Price, Restaurant_ID- - -)

ADDRESS          (address_id, country, full_address, postal_code, city)

PAYMENT_METHOD   (method_id, method_name)

ORDER_STATUS     (status_id, status_state)

DELIVERY_DRIVER  (driver_id, driver_name)
```

### Weak Entities

```
FOOD_ORDER       (Food_Order_ID, Delivery_fee, requested_deliverytime,
                  driver_rating, Restaurant_Rating, Total_Amount, order_date_time,
                  Customer_ID- - -,  driver_id- - -,  status_id- - -,  Restaurant_ID- - -)

PAYMENT          (Payment_ID- - -,  Food_Order_ID- - -,  method_id- - -,
                  payment_time, amount, payment_status)

CUSTOMER_ADDRESS (Customer_ID, address_id)

ORDER_MENU_ITEM  (Food_Order_ID, ITEM_ID, order_item_id- - -,  quantity_ordered)
```

### M:N Relationships

| Name | Associative Table | Attributes |
|---|---|---|
| **Has** | CUSTOMER_ADDRESS | `Customer_ID`, `address_id` |
| **Includes** | ORDER_MENU_ITEM | `order_item_id`, `ITEM_ID` |

### Relationship Summary

| Relationship | Cardinality | How It's Mapped |
|---|---|---|
| CUSTOMER — ADDRESS | M:N | `CUSTOMER_ADDRESS` bridge table |
| RESTAURANT — ADDRESS | N:1 | `address_id` FK in RESTAURANT |
| RESTAURANT — MENU_ITEM | 1:N | `Restaurant_ID` FK in MENU_ITEM |
| CUSTOMER — FOOD_ORDER | 1:N | `Customer_ID` FK in FOOD_ORDER |
| DELIVERY_DRIVER — FOOD_ORDER | 1:N | `driver_id` FK in FOOD_ORDER (nullable) |
| ORDER_STATUS — FOOD_ORDER | 1:N | `status_id` FK in FOOD_ORDER |
| RESTAURANT — FOOD_ORDER | 1:N | `Restaurant_ID` FK in FOOD_ORDER |
| FOOD_ORDER — PAYMENT | 1:1 | `Food_Order_ID` FK in PAYMENT (UNIQUE) |
| PAYMENT_METHOD — PAYMENT | 1:N | `method_id` FK in PAYMENT |
| FOOD_ORDER — MENU_ITEM | M:N | `ORDER_MENU_ITEM` bridge table |

---

## 🗃️ Database Schema

The database (`FoodDeliveryDB`) contains **11 tables**:

| Table | Type | Description |
|---|---|---|
| `CUSTOMER` | Strong Entity | Customer personal info and contact details |
| `ADDRESS` | Strong Entity | Centralized address records |
| `RESTAURANT` | Strong Entity | Restaurant names and locations |
| `MENU_ITEM` | Strong Entity | Food items with prices per restaurant |
| `PAYMENT_METHOD` | Strong Entity | Accepted payment types (Cash, Credit Card, etc.) |
| `ORDER_STATUS` | Strong Entity | Order lifecycle states (Pending → Delivered) |
| `DELIVERY_DRIVER` | Strong Entity | Driver profiles |
| `FOOD_ORDER` | Weak Entity | Central transaction table linking all entities |
| `PAYMENT` | Weak Entity | Payment records per order |
| `CUSTOMER_ADDRESS` | M:N Bridge | Customers ↔ multiple addresses |
| `ORDER_MENU_ITEM` | M:N Bridge | Orders ↔ menu items with quantities |

---

## 📐 Normalization

The schema follows **3NF (Third Normal Form)**:
- All non-key attributes are fully dependent on the primary key (2NF)
- No transitive dependencies exist (3NF)
- Many-to-many relationships are resolved via dedicated bridge tables (`CUSTOMER_ADDRESS`, `ORDER_MENU_ITEM`)

---

## 🔍 Sample Queries

The `schema.sql` file includes **10 analytical queries**:

1. Find all customers in İstanbul (multi-table JOIN)
2. Menu items sorted by price (ORDER BY)
3. Total order count and average transaction value (Aggregate Functions)
4. High-revenue restaurants with total sales > 500 TL (GROUP BY + HAVING)
5. Orders with customer names and delivery status (JOIN)
6. Full logistics report: restaurant, driver, payment method (Multi-table JOIN)
7. Premium menu items above average price (Scalar Subquery)
8. Loyal customers with at least one delivered order (Nested Subquery)
9. Driver performance including idle drivers (LEFT OUTER JOIN)
10. `Sales_Monitoring_View` — real-time sales summary (CREATE VIEW)

---

## 🚀 How to Run

1. Make sure you have **MySQL 8.0+** installed.
2. Open your MySQL client (Workbench, DBeaver, or terminal).
3. Run the script:

```sql
SOURCE schema.sql;
```

Or via command line:

```bash
mysql -u root -p < schema.sql
```

4. The database `FoodDeliveryDB` will be created with all tables, sample data, and queries.

---

## 📊 ER Diagram

See [`ER-diagram.pdf`](./ER-diagram.pdf) for the full entity-relationship diagram.

---

## 📄 License

This project was created for academic purposes as part of the MIS236 course.
