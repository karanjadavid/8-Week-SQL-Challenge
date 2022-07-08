CREATE DATABASE DannyDinner;
GO
USE DannyDinner;
GO



/* DANNY'S DINNER DATASET*/
DROP TABLE IF EXISTS sales;
GO
CREATE TABLE sales (
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INT
);
GO



DROP TABLE IF EXISTS menu;
GO
CREATE TABLE menu(
	product_id INT,
	product_name VARCHAR(5),
	price INT
);
GO



DROP TABLE IF EXISTS members;
GO
CREATE TABLE members(
	customer_id VARCHAR(1),
	join_date DATE
);
GO



INSERT INTO sales (
	customer_id,
	order_date,
	product_id )
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
GO



INSERT INTO menu(
	product_id,
	product_name,
	price )
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
GO



INSERT INTO members(
	customer_id,
	join_date )
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
GO