--		Case Study #1 - Danny's Dinner

/*
						Introduction
Danny seriously loves Japanese food so in the beginning of 2021, 
he decides to embark upon a risky venture and opens up a cute little 
restaurant that sells his 3 favourite foods:

1. sushi,
2. curry
3. ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay 
afloat - the restaurant has captured some very basic data from their
few months of operation but have no idea how to use their data to help 
them run the business.
*/



/*
						Problem Statement
Danny wants to use the data to answer a few simple questions about his
customers, especially about their visiting patterns, 
how much money they’ve spent and also 
which menu items are their favourite. 
Having this deeper connection with his customers will help him deliver 
a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should 
expand the existing customer loyalty program -
additionally he needs help to generate some basic datasets so his team
can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to
privacy issues - but he hopes that these examples are enough for you to
write fully functioning SQL queries to help him answer his questions!
*/





--						CASE STUDY QUESTIONS
--Question 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(price) AS [total amount]
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id;

-- ANS
-- Customer A spent $76, customer B $74$, customer C $36.





--Question 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_days_count
FROM sales
GROUP BY customer_id;

-- ANS
-- customer A has made 4 day visits, customer B 6 day visits, customer C 2 day visits. 





--Question 3. What was the first item from the menu purchased by each customer?
WITH first_sale_cte AS
(
 SELECT customer_id, order_date, product_name,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
 FROM sales s
 JOIN menu m
  ON s.product_id = m.product_id
)
SELECT customer_id, product_name,order_date
FROM first_sale_cte
WHERE rank = 1
GROUP BY customer_id, product_name, order_date;

/* ANS
Customer A buys curry & sushi on the first day of purchase.
Customer B buys curry on the first day of purchase.
Customer C buys ramen on the first day of purchase.
*/

--OR

/*
This method will only give one item. Use it when you have DATETIME or
DATETIME2 data that offers high precision.
In our case, we have DATE data. A customer may have bought many items on the 
first day. We are however not sure which item is purchased first. 
Stick to example 1.
*/
WITH initial_purchase_cte AS
(
SELECT customer_id, product_name, order_date,
	FIRST_VALUE(product_name)
	OVER(PARTITION BY customer_id ORDER BY order_date) AS first_item
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
)
SELECT customer_id, first_item
FROM initial_purchase_cte
GROUP BY customer_id, first_item;





--Question 4. What is the most purchased item on the menu and
-- how many times was it purchased by all customers?
SELECT TOP 1 product_name,
	COUNT(s.product_id) AS number_of_purchases
FROM menu m
INNER JOIN sales s
	ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY Number_of_Purchases DESC;

--ANS
-- The most purchased product is ramen. Bought 8 times.





--Question 5. Which item was the most popular for each customer?
WITH pop_item_cte AS
(
 SELECT s.customer_id, m.product_name, 
  COUNT(m.product_id) AS order_count,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY COUNT(s.customer_id) DESC) AS rank
FROM menu AS m
JOIN sales AS s
 ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM pop_item_cte 
WHERE rank = 1;

/*ANS
Customer A purchased ramen most frequently - 3 times,
Customer B purchased sushi, curry and ramen twice each,
Customer C purchased ramen thrice. 
*/





--Question 6. Which item was purchased first by the customer after they became a member?
WITH first_mem_purchase_cte AS
(
SELECT s.customer_id, join_date, order_date, product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS rank
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
LEFT JOIN members mm
	ON mm.customer_id = s.customer_id
WHERE order_date >= join_date
)
SELECT customer_id, join_date, order_date, Product_name
FROM first_mem_purchase_cte
WHERE rank = 1;

--ANS
-- customer A purchased curry while customer B sushi after membership.





--Question 7. Which item was purchased just before the customer became a member?
WITH prior_membership_cte AS
(
SELECT s.customer_id, join_date, order_date, product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS rank
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
LEFT JOIN members mm
	ON mm.customer_id = s.customer_id
WHERE order_date < join_date
)
SELECT customer_id, join_date, order_date, Product_name
FROM prior_membership_cte
WHERE rank = 1;

-- ANS
-- customer A buys sushi & curry, customer B buys sushi just before membership





--8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,  
	COUNT(DISTINCT m.product_id) AS total_items,
	SUM(price) AS amount_spent
FROM sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
LEFT JOIN members r
	ON r.customer_id = s.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id;

-- ANS
-- customer A buys 2 items at $25, 
-- customer B buys 2 items at $40 before membership.





--9. If each $1 spent equates to 10 points and sushi has a 2x points 
-- multiplier - how many points would each customer have?
WITH product_points_cte AS
(
SELECT *,
	CASE WHEN product_name = 'sushi' THEN price * 10 * 2
	ELSE price * 10
	END AS points
FROM menu 
)
SELECT customer_id, SUM(points) AS customer_points
FROM product_points_cte p
INNER JOIN sales s
	ON s.product_id = p.product_id
GROUP BY customer_id;

-- ANS
-- customer A has 860 points, customer B 940 points, customer C 360 points.





/* 
10. In the first week after a customer joins the program
(including their join date) they earn 2x points on all items,
not just sushi - how many points do customer A and B have at the end of 
January?
*/
WITH dates_cte AS 
(
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM members mm
)
SELECT d.customer_id,
 SUM(CASE
  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
  WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
  ELSE 10 * m.price
  END) AS points
FROM dates_cte AS d
JOIN sales AS s
	ON d.customer_id = s.customer_id
JOIN menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id

/* ANS
Assumptions made:
Before subscription, sushi has 20 points while curry and ramen has 10 points each.
One week after subscription, the same rates are applied. 

customer A has 1370 points while customer B has 820 points. 
*/





--Question 11. Join All The Things. RECREATE the following table.

--------customer_id	order_date	product_name	price	member
--------A			2021-01-01	curry			15			N
--------A			2021-01-01	sushi			10			N
--------A			2021-01-07	curry			15			Y
--------A			2021-01-10	ramen			12			Y
--------A			2021-01-11	ramen			12			Y
--------A			2021-01-11	ramen			12			Y
--------B			2021-01-01	curry			15			N
--------B			2021-01-02	curry			15			N
--------B			2021-01-04	sushi			10			N
--------B			2021-01-11	sushi			10			Y
--------B			2021-01-16	ramen			12			Y
--------B			2021-02-01	ramen			12			Y
--------C			2021-01-01	ramen			12			N
--------C			2021-01-01	ramen			12			N
--------C			2021-01-07	ramen			12			N


SELECT s.customer_id, order_date, product_name, price,
CASE
	WHEN mm.join_date > s.order_date THEN 'N'	
	WHEN mm.join_date <= s.order_date THEN 'Y'
	ELSE 'N'
 END AS member
FROM sales s
LEFT JOIN menu m
 ON s.product_id = m.product_id
LEFT JOIN members mm
 ON s.customer_id = mm.customer_id;


--12. Rank All The Things
/*
Danny also requires further information about the ranking of customer 
products, but he purposely does not need the ranking for non-member 
purchases so he expects null ranking values for the records when customers
are not yet part of the loyalty program.
*/

WITH summary_cte AS 
(
 SELECT s.customer_id, order_date, product_name, price,
  CASE
	WHEN mm.join_date > s.order_date THEN 'N'
	WHEN mm.join_date <= s.order_date THEN 'Y'
  ELSE 'N' END AS member
 FROM sales AS s
 LEFT JOIN menu AS m
  ON s.product_id = m.product_id
 LEFT JOIN members mm
  ON s.customer_id = mm.customer_id
)
SELECT *, 
	CASE
		WHEN member = 'N' then NULL
	ELSE RANK() OVER(PARTITION BY customer_id, 
						member ORDER BY order_date) END AS ranking
FROM summary_cte;









