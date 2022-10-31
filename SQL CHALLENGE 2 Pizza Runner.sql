--					CASE STUDY #2 PIZZA RUNNER

/*
						Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide???
(Well according to Wikipedia anyway…)
Danny was scrolling through his Instagram feed when something really caught his eye 
- “80s Retro Styling and Pizza Is The Future!”
Danny was sold on the idea, but he knew that pizza alone was not going to help him
get seed funding to expand his new Pizza Empire - 
so he had one more genius idea to combine with it - 
he was going to Uberize it - and so Pizza Runner was launched!
Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner
Headquarters (otherwise known as Danny’s house) 
and also maxed out his credit card to pay freelance developers to build a
mobile app to accept orders from customers.
*/





/*
					Available Data
Because Danny had a few years of experience as a data scientist - 
he was very aware that data collection was going to be critical for his business’growth.
He has prepared for us an entity relationship diagram of his database design 
but requires further assistance to clean his data and apply some basic calculations
so he can better direct his runners and optimise Pizza Runner’s operations.

Table 1: runners
The runners table shows the registration_date for each new runner.

Table 2: customer_orders
Customer pizza orders are captured in the customer_orders table with 1 row 
for each individual pizza that is part of the order.
The pizza_id relates to the type of pizza which was ordered whilst the 
exclusions are the ingredient_id values which should be removed from the pizza 
and the extras are the ingredient_id values which need to be added to the pizza.
Note that customers can order multiple pizzas in a single order with varying 
exclusions and extras values even if the pizza is the same type!
The exclusions and extras columns will need to be cleaned up before using them in your queries.

Table 3: runner_orders
After each orders are received through the system - they are assigned to a runner 
- however not all orders are fully completed and can be cancelled 
by the restaurant or the customer.
The pickup_time is the timestamp at which the runner arrives at the Pizza Runner
headquarters to pick up the freshly cooked pizzas. 
The distance and duration fields are related to how far and long the runner 
had to travel to deliver the order to the respective customer.
There are some known data issues with this table so be careful when using this 
in your queries - make sure to check the data types for each column in the schema SQL!

Table 4: pizza_names
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

Table 5: pizza_recipes
Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.

Table 6: pizza_toppings
This table contains all of the topping_name values with their corresponding topping_id value
*/





/*
						Case Study Questions
This case study has LOTS of questions - they are broken up by area of focus including:

Pizza Metrics
1. Runner and Customer Experience
2. Ingredient Optimisation
3. Pricing and Ratings
4. Bonus DML Challenges (DML = Data Manipulation Language)

Each of the following case study questions can be answered using a single SQL statement.
Again, there are many questions in this case study -
please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries however - 
you might want to investigate the data,
you may want to do something with some of those null values and data types 
in the customer_orders and runner_orders tables!
*/


--################################################
--				 DATA CLEANING 
--################################################
-- customer_orders
SELECT *
FROM customer_orders;

SELECT order_id, customer_id, pizza_id,
	CASE
		WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ' '
		ELSE exclusions
		END AS exclusions,
	CASE
		WHEN extras IS NULL or extras LIKE 'null' THEN ' '
		ELSE extras
		END AS extras,
	order_time
INTO #customer_orders -- customers temp table.
FROM customer_orders;

SELECT *
FROM #customer_orders


-- runner orders table
SELECT * 
FROM runner_orders;

SELECT order_id, runner_id,
	CASE
		WHEN pickup_time IS NULL OR pickup_time LIKE 'null' THEN ' '
		ELSE pickup_time
		END AS pickup_time,
	CASE 
		WHEN distance IS NULL OR distance LIKE 'null' THEN ' '
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
		ELSE distance
		END AS distance,
	CASE 
		WHEN duration IS NULL OR duration LIKE 'null' THEN ' '
		WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
		ELSE duration
		END AS duration,
	CASE 
		WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ' '
		ELSE cancellation
		END AS cancellation
INTO #runner_orders
FROM runner_orders;


SELECT * 
FROM #runner_orders;

-- Change data types
ALTER TABLE #runner_orders
ALTER COLUMN pickup_time DATETIME;

ALTER TABLE #runner_orders
ALTER COLUMN distance FLOAT;

ALTER TABLE #runner_orders
ALTER COLUMN duration FLOAT;








-- View the cleaned temporary tables
SELECT *
FROM #customer_orders
SELECT * 
FROM #runner_orders;

--	A. Pizza Metrics
--Question 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS number_of_orderedPizza
FROM #customer_orders;

-- ANS
-- 14 pizza orders were made.



--Question 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM #customer_orders;

-- ANS
-- There were 10 unique customer orders.



--Question 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM #runner_orders
WHERE distance != 0
GROUP BY runner_id;

--ANS
-- runner_id 1 made 4 successful deliveries, runner_id 2 made 3 successful deliveries,
-- runner_id 3 made 1 successful delivery.





--Question 4. How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(ro.order_id) AS count_delivered_pizza
FROM #runner_orders ro
INNER JOIN #customer_orders co
	ON ro.order_id = co.order_id
INNER JOIN pizza_names pn
	ON co.pizza_id = pn.pizza_id
WHERE distance != 0
GROUP BY pizza_name;

-- ANS
-- 9 Meat Lovers pizza and 3 Vegeterian Pizzas were delivered.



--Question 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, pn.pizza_name, COUNT(co.order_id) AS count_ordered_pizza
FROM #customer_orders co
INNER JOIN pizza_names pn
	ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, pn.pizza_name
ORDER BY co.customer_id;

/*-- ANS
Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizzas.
Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
Customer 104 ordered 3 Meatlovers pizza.
Customer 105 ordered 1 Vegetarian pizza.
*/



-- Question 6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte AS
(
SELECT co.order_id, COUNT(co.pizza_id) AS pizza_count
FROM #customer_orders co
INNER JOIN #runner_orders ro
	ON co.order_id = ro.order_id
WHERE ro.distance != 0
GROUP BY co.order_id
)
SELECT MAX(pizza_count) AS max_pizza_delivered
FROM pizza_count_cte;

-- ANS
-- 3 was the maximum number of pizza delivered in a single order.



-- Question 7.  For each customer, how many delivered pizzas had at least 
-- 1 change and how many had no changes?
SELECT co.customer_id, 
	SUM(CASE
		WHEN co.exclusions <> ' ' OR co.extras <> ' ' THEN 1
		ELSE 0
		END) AS at_least_one_change,
	SUM(CASE
		WHEN co.exclusions = ' ' AND co.extras = ' ' THEN 1
		ELSE 0
		END) AS no_change
FROM #customer_orders co
INNER JOIN #runner_orders ro
	ON co.order_id = ro.order_id
WHERE ro.distance != 0
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- ANS
-- customers 101 and 102 take original pizzas
-- customers 103, 104, 105 prefer exclusions or extras in their pizza.  



-- Quesion 8. How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(CASE
				WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
				ELSE 0
				END) AS pizza_count_with_exclusions_extras
FROM #customer_orders co
INNER JOIN #runner_orders ro
	ON co.order_id = ro.order_id
WHERE ro.distance >= 1
	AND exclusions <> ' '
	AND extras <> ' ';

-- ANS
-- Only one pizza order had both extras and exclusions. 



-- Question 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR, order_time) AS hour_of_day, 
		COUNT(order_id) AS number_of_orders
FROM #customer_orders 
GROUP BY DATEPART(HOUR, order_time)
ORDER BY number_of_orders DESC;

-- ANS
-- Highest orders happened at 13hrs(1.00pm), 18hrs(6.00pm), 21hrs(9.00pm) and 23hrs(11.00pm)
-- Lowest orders at 11hrs(11.00am), 19hrs(7.00pm).



-- Question 10. What was the volume of orders for each day of the week?

SELECT DATENAME(WEEKDAY, order_time) AS day_of_week,
		COUNT(order_id) AS num_of_orders
FROM #customer_orders
GROUP BY DATENAME(WEEKDAY, order_time);

-- ANS
-- Friday - 1 order, Saturday - 5 orders, Thursday 3 orders, Wednesday - 5 orders.











--						B. Runner and Customer Experience
-- Question 1. How many runners signed up for each 1 week period? 
-- (i.e. week starts 2021-01-01)
SELECT DATEPART(WEEK, registration_date) AS registration_week, 
		COUNT(runner_id) AS num_runners_signedup 
FROM runners
GROUP BY DATEPART(WEEK, registration_date);


 
-- Question2. What was the average time in minutes it took for each runner
-- to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_arrival_cte AS
(
SELECT ro.runner_id, co.order_time, ro.pickup_time, 
		DATEDIFF(MINUTE, co.order_time, ro.pickup_time) As minutes_to_pick
FROM #runner_orders ro
INNER JOIN #customer_orders co
ON co.order_id = ro.order_id
WHERE ro.duration <> 0
)
SELECT runner_id, AVG(minutes_to_pick) AS average_runner_time
FROM runner_arrival_cte
GROUP BY runner_id;



-- Ans
-- runner 1 takes 15 minutes on average
-- runner 2 takes 24 minutes on average
-- runner 3 takes 10 minutes on average





-- Question3 Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH prep_time_cte AS
(
SELECT co.order_id, COUNT(co.pizza_id) AS pizza_orders, co.order_time, ro.pickup_time, 
		DATEDIFF(MINUTE, co.order_time, ro.pickup_time) AS prep_time_minutes
FROM #runner_orders ro
INNER JOIN #customer_orders co
ON co.order_id = ro.order_id
WHERE ro.duration <> 0
GROUP BY co.order_id, co.order_time, ro.pickup_time
)
SELECT pizza_orders, AVG(prep_time_minutes) AS averge_orders_prep_time
FROM prep_time_cte
GROUP BY pizza_orders; 


-- ANS
-- Yes there is a relationship between the number of orders and the time taken to prepare
-- The more the orders, the higher the preparation time. 
-- 1 order takes an average of 12 minutes.
-- 2 orders take an average of 18 minutes while 
-- 3 orders take an average of 30 minutes to prepare.





-- Question4 What was the average distance travelled for each customer?

SELECT co.customer_id, AVG(ro.distance) AS average_customer_distance
FROM #customer_orders co
INNER JOIN #runner_orders ro
ON co.order_id=ro.order_id
WHERE ro.distance != 0
GROUP BY co.customer_id
ORDER BY average_customer_distance;

-- ANS
-- customer_id 104 lives closest to pizza HQ, a 10KM distance. customer_id 102 - 16.73KM
-- customer_id 101 - 20KM, customer_id 103 - 23.4KM, customer_id 105 - 25KM.





-- Question5 What was the difference between the longest and shortest delivery times for all orders?

SELECT (MAX(duration) - MIN(duration)) AS max_minus_min_time
FROM #runner_orders
WHERE duration != 0;





-- Question6 What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT ro.runner_id, co.customer_id, co.order_id, COUNT(co.order_id) AS pizza_count,
		ro.distance, ro.duration, ROUND(ro.distance / ro.duration * 60 , 2) AS avg_speed
FROM #runner_orders ro
INNER JOIN customer_orders co
ON ro.order_id=co.order_id
WHERE distance != 0
GROUP BY ro.runner_id, ro.distance, co.customer_id, co.order_id, ro.duration

-- ANS
-- Runner 1 has an average speed between 40.2KH/HR to 60KM/HR
-- Runner 2 has an average speed between 35.1KM/HR to 93.6KM/HR ~ a huge fluctuation
-- Runner 3 has an average speed of 40KM/HR





-- Question7 What is the successful delivery percentage for each runner?

SELECT runner_id, 
		ROUND(100 * SUM(
						CASE WHEN distance = 0 THEN 0
							ELSE 1
							END) / COUNT(*), 0) AS success_perc
FROM #runner_orders
GROUP BY runner_id;

-- ANS
-- runner 1 has a success rate of 100%
-- runner 2 75%
-- runner 3 50%




/*
						C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
		Meat Lovers
		Meat Lovers - Exclude Beef
		Meat Lovers - Extra Bacon
		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza 
	order from the customer_orders table and add a 2x in front of any relevant ingredients
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/


-- 1. What are the standard ingredients for each pizza?

SELECT TOP 2 pizza_id,  
		CASE WHEN pizza_id = 1 THEN 'Meatlovers' 
			ELSE 'Vegetarian' 
			END AS pizza_name, 
		CASE WHEN pizza_id = 1
			THEN 'Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami' 
			ELSE 'Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes' 
			END AS standard_ingredient
FROM pizza_toppings AS pt
FULL OUTER JOIN pizza_recipes AS pr
ON pt.topping_id = pr.pizza_id



SELECT *
FROM pizza_recipes;
SELECT *
FROM pizza_toppings;
SELECT *
FROM pizza_names