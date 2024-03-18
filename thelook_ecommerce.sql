
CREATE DATABASE THELOOK_ECOMMERCE
USE THELOOK_ECOMMERCE

SELECT *  FROM USERS
SELECT COUNT(ID)  FROM USERS

--Check null count
SELECT
COUNT(CASE WHEN id IS NULL THEN 1 END) AS id_null_count,
COUNT(CASE WHEN first_name IS NULL THEN 1 END) AS firstname_null_count,
COUNT(CASE WHEN gender IS NULL THEN 1 END) AS gender_null_count,
COUNT(CASE WHEN age IS NULL THEN 1 END) age_null_count,
COUNT(CASE WHEN country IS NULL THEN 1 END) AS country_null_count,
COUNT(CASE WHEN city IS NULL THEN 1 END) AS city_null_count,
COUNT(CASE WHEN state IS NULL THEN 1 END) AS state_null_count,
COUNT(CASE WHEN email IS NULL THEN 1 END) email_null_count,
COUNT(CASE WHEN traffic_source IS NULL THEN 1 END) AS traffic_source_null_count,
COUNT(CASE WHEN created_at IS NULL THEN 1 END) AS created_at_null_count
FROM users



--Check Duplicates
SELECT id, first_name, last_name, email, age, gender, created_at, count(*)
FROM users
GROUP BY id, first_name, last_name, email, age, gender, created_at
HAVING COUNT(*)>1

SELECT min(created_at) from users
SELECT max(created_at) from users

SELECT max(returned_at) from orders

--cHECK IF ID IS A UNIQUE IDENTIFIER
SELECT id, COUNT(id) 
FROM users
GROUP BY id
HAVING COUNT(id)>1

--Join first_name and last_name together
ALTER TABLE users
ADD full_name nvarchar(50)
UPDATE users
SET full_name = CONCAT(first_name,' ', last_name)



select full_name, email, age, state, country, count(*) as count
from users
group by full_name, email, age, state, country
order by count desc

--check age column for outliers
SELECT MIN(age) as youngest, MAX(age) as oldest
FROM users

--check country column for errors
SELECT DISTINCT(country)
FROM users

--España and spain are the same, change all instances of España to spain
UPDATE USERS
SET country = CASE WHEN country = 'España'
then 'Spain'
ELSE country
END

--check traffic_source column for errors
select distinct(traffic_source)
FROM users

---timeframe of user creation
SELECT MIN(created_at) MAX(created_at) AS 
FROM users

--update created at column to date format
UPDATE users
SET created_at = REPLACE(created_at, 'UTC', '')
WHERE created_at LIKE '%UTC';

UPDATE users
SET created_at = CONVERT(DATE, (SUBSTRING(created_at, 1, CHARINDEX(' ', created_at) - 1)))

--create a new column age_group from age column

select min(age), max(age) from users

ALTER TABLE users
ADD age_group nvarchar(50)

UPDATE users
SET age_group =
    CASE 
        WHEN age <= 14 THEN 'children'
        WHEN age > 14 AND age <= 24 THEN 'youth'
        WHEN age > 24 AND age <= 65 THEN 'adult'
        ELSE 'senior'
    END;

SELECT DISTINCT age_group
FROM users

---2. PRODUCTS TABLE

--COUNT DISTINCT VALUES
SELECT COUNT(id) as no_of_products, 
COUNT(DISTINCT name) as name_count, 
COUNT(DISTINCT category) as category_count, COUNT(DISTINCT brand) as brand_count, COUNT(DISTINCT department) as department_count
FROM products

--check null count

SELECT
COUNT(CASE WHEN id IS NULL THEN 1 END) AS id_null_count,
COUNT(CASE WHEN cost IS NULL THEN 1 END) AS cost_null_count,
COUNT(CASE WHEN category IS NULL THEN 1 END) AS category_null_count,
COUNT(CASE WHEN name IS NULL THEN 1 END) name_null_count,
COUNT(CASE WHEN brand IS NULL THEN 1 END) AS brand_null_count,
COUNT(CASE WHEN retail_price IS NULL THEN 1 END) AS retail_price_null_count,
COUNT(CASE WHEN department IS NULL THEN 1 END) AS sku_null_count,
COUNT(CASE WHEN sku IS NULL THEN 1 END) email_null_count,
COUNT(CASE WHEN distribution_center_id IS NULL THEN 1 END) AS distribution_center_id_null_count
FROM products

--handle null values in product name
 UPDATE products
 SET name = 'Josie by Natori Intimates'
 where id=12586

  UPDATE products
 SET name = 'Tru-Spec Outerwear'
 where id=24455


--3. ORDERS TABLE

--convert created_at to date format
UPDATE orders
SET created_at = REPLACE(created_at, 'UTC', '')
WHERE created_at LIKE '%UTC';

UPDATE orders
SET created_at = CONVERT(DATE, (SUBSTRING(created_at, 1, CHARINDEX(' ', created_at) - 1)))

--Convert 'returned_at' datatype from nvarchar to date format.
UPDATE orders
SET returned_at = REPLACE(returned_at, 'UTC', '')
WHERE returned_at LIKE '%UTC';

UPDATE orders
SET returned_at = CONVERT(DATE, (SUBSTRING(returned_at, 1, CHARINDEX(' ', returned_at) - 1)))

--
SELECT DISTINCT status
FROM orders

--4. ORDER_ITEMS TABLE

select * from orders

----convert created_at to date format
UPDATE order_items
SET created_at = REPLACE(created_at, 'UTC', '')
WHERE created_at LIKE '%UTC';

UPDATE order_items
SET created_at = CONVERT(DATE, (SUBSTRING(created_at, 1, CHARINDEX(' ', created_at) - 1)))

----Convert 'returned_at' datatype from nvarchar to date format.
UPDATE order_items
SET returned_at = REPLACE(returned_at, 'UTC', '')
WHERE returned_at LIKE '%UTC';

 UPDATE order_items
SET returned_at = CONVERT(DATE, (SUBSTRING(returned_at, 1, CHARINDEX(' ', returned_at) - 1)))

--ANSWERING BUSINESS QUESTIONS

--Total number of users
SELECT COUNT(id) as no_of_users
FROM users

--total number of orders
SELECT COUNT(order_id) as no_of_orders, sum(num_of_item)
FROM orders

--total revenue and quantities sold

SELECT ROUND(SUM(sale_price),2) AS total_revenue, COUNT(id) no_of_products_sold
FROM order_items
WHERE status NOT IN ('Cancelled','Returned')


--check number of users created each year
select year(created_at) as year, count(id) as no_of_users
from users
group by year(created_at)
ORDER BY year

--gender distribution
SELECT gender, count(gender) AS count
FROM users
GROUP BY gender



--country distribution
SELECT country, count(country) AS count
FROM users
GROUP BY country
ORDER BY count DESC

--traffic source distribution
SELECT traffic_source, count(traffic_source) AS count
FROM users
GROUP BY traffic_source
ORDER BY count DESC

 --no of users
 SELECT COUNT(*) 
 FROM users

 --What are the total sales by month/year?
 SELECT YEAR(created_at) AS YEAR, MONTH(created_at) AS MONTH, ROUND(SUM(sale_price),2) AS TOTAL_SALES, COUNT(id) as QUANTITY_SOLD
 FROM order_items
 WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY YEAR(created_at), MONTH(created_at)
 ORDER BY TOTAL_SALES DESC

 --Which products generate the most revenue?
 SELECT o.product_id, p.name, sum(o.sale_price) AS total_sales
 FROM order_items o
 LEFT JOIN products p
 ON o.product_id=p.id
 WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY o.product_id, p.name
 ORDER BY total_sales DESC

 --What is the average order value?
 SELECT ROUND(AVG(total_sales),2) as avg_sales
 FROM
 (SELECT order_id, SUM(sale_price) as total_sales
 FROM order_items
  WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY order_id) AS sales

 --What is the distribution of customers by location?

 SELECT country, COUNT(country) AS no_of_users
 FROM users
 GROUP BY country
 ORDER BY no_of_users DESC

 --how many users register on the platform yearly and how many of those users are active(i.e made at least one order)


     SELECT u.year, u.registered_users, a.active_users, a.cumulative_active_users
     FROM
     (SELECT YEAR(created_at) AS year, COUNT(id) AS registered_users
     FROM users
     GROUP BY YEAR(created_at)) u
     JOIN
     (SELECT
     YEAR(u.created_at) AS year,
     COUNT(DISTINCT u.id) AS active_users,
     SUM(COUNT(DISTINCT u.id)) OVER (ORDER BY YEAR(u.created_at)) AS cumulative_active_users
     FROM
     users u
     JOIN
     orders o 
	 ON u.id = o.user_id
     GROUP BY YEAR(u.created_at)) a
     ON u.year = a.year;

 --Who are the top 10 spending customers?
 SELECT TOP 10 user_id, full_name, ROUND(SUM(sale_price),2) AS total_spent, count(o.id) as quantity
 FROM order_items o
 LEFT JOIN users u
 ON o.user_id=u.id
 WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY user_id, full_name
 ORDER BY total_spent DESC


 --Number of repeat customers versus one-time purchasers
 
 WITH orderscount_table AS
 (SELECT user_id, count(order_id) as no_of_orders
 FROM orders
 GROUP BY user_id)
 SELECT no_of_orders, COUNT(user_id) AS no_of_customers,
 CAST(COUNT(user_id) * 100.0 / (SELECT COUNT(DISTINCT user_id) FROM orders) AS DECIMAL(10,2)) AS percentage
 FROM orderscount_table
 GROUP BY no_of_orders
 ORDER BY no_of_orders


 --What are the top-selling products overall?

SELECT TOP 10 o.product_id, p.name, p.category, count(o.product_id) AS quantity
 FROM order_items o
 LEFT JOIN products p
 ON o.product_id=p.id
  WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY o.product_id, p.name, p.category
 ORDER BY quantity DESC

 --top 10 most ordered product categories
 SELECT  TOP 10 p.category, count(p.category) as quantity_sold
 FROM order_items o
 LEFT JOIN products p
 ON o.product_id=p.id
 WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY p.category
 ORDER BY quantity_sold DESC

 --Which products category generates the most revenue?

 SELECT p.category, ROUND(sum(sale_price),2) AS total_revenue
 FROM order_items o
 LEFT JOIN products p
 ON o.product_id=p.id
 WHERE status NOT IN ('Cancelled','Returned')
 GROUP BY p.category 
 ORDER BY total_revenue DESC


 --Create User Order History View
 CREATE VIEW user_order_history AS
SELECT
    u.id,
    u.full_name,
    o.order_id,
    oi.product_id,
    p.name,
    o.num_of_item,
    oi.sale_price,
    o.created_at,
	oi.status
FROM
    users u
JOIN
    orders o ON u.id = o.user_id
JOIN
    order_items oi ON o.order_id = oi.id
JOIN
    products p ON oi.product_id = p.id;
 

---active users over time

 SELECT
   YEAR(u.created_at) AS year,
    COUNT(DISTINCT user_id) AS active_users,
    SUM(COUNT(DISTINCT user_id)) OVER (ORDER BY YEAR(u.created_at)) AS cumulative_active_users
FROM
    users u
    join orders o
ON u.id=o.user_id
GROUP BY
   YEAR(u.created_at)

--Customer and sales distribution by age_group
   SELECT u.age_group, u.no_of_customers,a.sales,a.quantity
   FROM
   (SELECT age_group, COUNT(age_group) AS no_of_customers
   FROM users 
   GROUP BY age_group) u
   JOIN
   (SELECT age_group, count(o.id) as quantity, ROUND(sum(sale_price),2) as sales
   FROM users u
   JOIN order_items o
   ON u.id=o.user_id
    WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY age_group) a
   ON u.age_group=a.age_group
   ORDER BY sales DESC

 
   --Customer and sales distribution by gnder.
   SELECT u.gender, u.no_of_customers,a.sales,a.quantity
   FROM
   (SELECT gender, COUNT(gender) AS no_of_customers
   FROM users 
   GROUP BY gender) u
   JOIN
   (SELECT gender, ROUND(SUM(sale_price),2) AS sales, COUNT(o.id) AS quantity
   FROM users u
   JOIN order_items o
   ON o.user_id=u.id
   WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY gender) a
   ON a.gender=u.gender
   ORDER BY sales DESC

   --Customer and sales distribution by country

   SELECT u.country, u.no_of_customers,a.sales,a.quantity
   FROM
   (SELECT country, COUNT(country) AS no_of_customers
   FROM users 
   GROUP BY country) u
   JOIN
   (SELECT country, ROUND(SUM(sale_price),2) AS sales, COUNT(o.id) AS quantity
   FROM users u
   JOIN order_items o
   ON o.user_id=u.id
   WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY country) a
   ON a.country=u.country
   ORDER BY sales DESC

   --PRODUCT RANKING BASED ON REVENUE

   Select category, count(o.id) as quantity, sum(sale_price) as sales, RANK() OVER (ORDER BY COUNT(o.id))
   FROM order_items o
   JOIN products p
   ON o.product_id=p.id 
   GROUP BY category
  
  --Top 3 most ordered products in each product department and the category they belong to
  SELECT department, name, category, quantity, sales, rank
   FROM
   (SELECT department, name, category, COUNT(name) as quantity, ROUND(sum(sale_price),2) as sales, RANK() OVER (PARTITION BY department ORDER BY COUNT(o.id) DESC) AS RANK
   FROM order_items o
   JOIN products p
   ON o.product_id=p.id 
   WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY department,name, category) sub
   WHERE RANK<=3

   --Highest revenue generating product category in each country

  WITH revenue_rank_table AS
  (SELECT country, category, 
  count(o.id) AS quantity, ROUND(SUM(sale_price),2) AS sales, 
   RANK() OVER (PARTITION BY country ORDER BY SUM(sale_price) desc) as rank
   FROM 
   users u
   JOIN order_items o
   ON u.id=o.user_id
   JOIN PRODUCTS p
   ON p.id=o.product_id
   WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY country, category)
  SELECT country, category, quantity, sales
  FROM revenue_rank_table
  WHERE rank = 1
  ORDER BY sales DESC
   

   --most ordered product category in all countries

     WITH revenue_rank_table AS
  (SELECT country, category, 
  count(o.id) AS quantity, ROUND(SUM(sale_price),2) AS sales, 
   RANK() OVER (PARTITION BY country ORDER BY count(o.id) desc) as rank
   FROM 
   users u
   JOIN order_items o
   ON u.id=o.user_id
   JOIN PRODUCTS p
   ON p.id=o.product_id
   WHERE status NOT IN ('Cancelled','Returned')
   GROUP BY country, category)
  SELECT country, category, quantity, sales
  FROM revenue_rank_table
  WHERE rank = 1
  ORDER BY quantity DESC



--Percentage of products returned in each category.	
	SELECT 
	p.category, 
	count(o.id) as total_orders, 
	count(returned_at) as returned,
	CAST((count(returned_at)*100.0)/count(o.id) AS DECIMAL(10,2)) AS percentage_returned 
	FROM order_items o
	LEFT JOIN products p
	ON p.id=o.product_id
	GROUP BY p.category
	ORDER BY percentage_returned DESC

--Overall status of orders
	SELECT status, COUNT(status) AS count
	FROM orders
	GROUP BY status
	ORDER BY count DESC

	
--Percentage of active users
	SELECT total_users, active_users,((active_users*100)/total_users) AS percentage
	FROM
	(SELECT COUNT(DISTINCT id) AS total_users
	FROM users) AS SUB1,
	(SELECT COUNT(DISTINCT user_id) AS active_users
	FROM orders) AS SUB2

	-- 
	USE THELOOK_ECOMMERCE

	SELECT brand, COUNT(o.id) as quantity_sold, ROUND(sum(retail_price)-sum(cost),2) AS profit
	FROM order_items o
	LEFT JOIN products p
	ON o.product_id=p.id
	WHERE status NOT IN ('Cancelled','Returned')
	GROUP BY brand
	ORDER BY profit
