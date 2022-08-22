--3. Video/Quiz: First Subquery
/*
Subqueries, or inner queries allow for filtering of results using results of a query
Good formatting for subqueries is to properly indent subqueries to differentiate easily
*/

SELECT channel, AVG(chan_event_count)
FROM (SELECT channel, DATE_TRUNC('d', occurred_at),
	  COUNT(*) AS chan_event_count
	  FROM web_events
	  GROUP BY 1,2
	  ORDER BY 3 DESC -- Make sure to check multiple rows with same #occurrences
	  ) AS subq
GROUP BY channel
ORDER BY 2 DESC;

--6. Video: More on Subqueries
/*
Subqueries can be used inside a query, specifically anywhere where you can use table
data, column, or individual values. Especially useful in CASE statements (WHEN clause),
WHERE, and JOIN parts of the query. Most logic operators will work with subqueries
that return 1 value, except for IN, which works with a multi-value return (table or col return)
Don't alias when writing a subquery in a conditional statement, since the subquery
is treated as a single value instead of a table. If using IN in the logical statement,
we'd need to alias since we're dealing with multiple values in the returned subquery
*/

--7. Quiz: More on Subqueries
SELECT AVG(standard_qty) AS avg_std_qty,
	   AVG(poster_qty) AS avg_poster_qty,
	   AVG(gloss_qty) AS avg_gloss_qty,
	   SUM(total_amt_usd) AS total_spent_month1
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	  (SELECT DATE_TRUNC('month', MIN(occurred_at)) -- Extract earliest date's month
	   FROM orders);
/*	  AND
	  DATE_TRUNC('year', occurred_at) = (SELECT DATE_TRUNC('year', MIN(occurred_at))
	                                  FROM orders) */
-- Second logical statement unnecessary because initial one stores YYYY-MM-00 00:00:00
-- Note how we did the MIN is around occurred_at not DATE_TRUNC. This is to get
-- earliest date in database, not earliest month of the year available (January)

--9. Quiz: Subquery Mania

-- Q1

/*
I used the same subquery in the first sub-sub-query and in the second
sub-query (after outer JOIN). First, I extracted highest $ in each region
in the first table (srep_r_money_3) then joined it with initial subquery as the
second table (srep_r_money_2). As a result, I have a 4-row table of highest
regional earnings inner joined with a table that has associated srep names.
*/
SELECT srep_r_money_2.srep_name, srep_r_money_3.r_name, srep_r_money_3.r_max_genereted 
FROM (SELECT srep_r_money_1.r_name r_name,
	  MAX(srep_r_money_1.total_generated) r_max_genereted
	  FROM (SELECT srep.name srep_name, r.name r_name,
	 		SUM(o.total_amt_usd) total_generated
	 		FROM sales_reps srep
	 		JOIN accounts acc
			 ON acc.sales_rep_id = srep.id
			 JOIN orders o
			 ON o.account_id = acc.id
			 JOIN region r
			 ON r.id = srep.region_id
			 GROUP BY r_name, srep_name) srep_r_money_1
	 GROUP BY srep_r_money_1.r_name) srep_r_money_3
JOIN
	(SELECT srep.name srep_name, r.name r_name,
	 SUM(o.total_amt_usd) total_generated
	 FROM sales_reps srep
	 JOIN accounts acc
	 ON acc.sales_rep_id = srep.id
	 JOIN orders o
	 ON o.account_id = acc.id
	 JOIN region r
	 ON r.id = srep.region_id
	 GROUP BY r_name, srep_name) srep_r_money_2
ON srep_r_money_3.r_max_genereted = srep_r_money_2.total_generated
ORDER BY srep_r_money_3.r_max_genereted DESC;

-- Q2

-- Getting the region's id, name, and total number of counts in the inner JOIN
SELECT t2.r_id r_id, t2.r_name r_name, COUNT(*) num_orders
-- Subquery shows top earning region
FROM (
	SELECT t1.r_id r_id, t1.r_name r_name
	-- Sub-subquery returns region and regional earnings from most to least earned
	FROM (SELECT r.id r_id, r.name r_name,
		  SUM(o.total_amt_usd) total_generated
		  FROM sales_reps srep
		  JOIN accounts acc
		  ON acc.sales_rep_id = srep.id
		  JOIN orders o
		  ON o.account_id = acc.id
		  JOIN region r
		  ON r.id = srep.region_id
		  GROUP BY r_name, r_id
		  ORDER BY total_generated DESC) AS t1
	-- Only showing top earning region
	LIMIT 1) AS t2
-- Couple of JOINs to link the region with corresponding orders to allow for counting :)
JOIN sales_reps srep
ON srep.region_id = t2.r_id
JOIN accounts acc
ON acc.sales_rep_id = srep.id
JOIN orders o
ON o.account_id = acc.id
GROUP BY r_id, r_name;

-- Q3

SELECT COUNT(*) desired_amt
FROM    (
		-- Finding total_qty purchased over lifetime for each company
		SELECT acc.name acc_name, SUM(o.total) total_qty
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_name
		ORDER BY total_qty DESC
		) AS t1
		
WHERE t1.total_qty >
		(
		-- Largest total_qty purchased over lifetime of company with most std_qty
		SELECT most_std_company.total_qty
		FROM    (
				-- Finding total_qty and total_std_qty for company with most total_std_qty
				SELECT acc.name acc_name, SUM(o.standard_qty) total_std_qty, SUM(o.total) total_qty
				FROM accounts acc
				JOIN orders o
				ON o.account_id = acc.id
				GROUP BY acc_name
				ORDER BY total_std_qty DESC
				LIMIT 1
				) AS most_std_company
		);

-- Q4

-- Displaying channel where web events occurred and how many times they occurred
-- (For the highest paying customer)
SELECT we.channel we_channel, COUNT(*) event_count -- Could add name of customer, not neccessary here
FROM web_events we
JOIN	(
		-- Finding highest paying customer's id, name, and amount spent
		SELECT acc.id acc_id, acc.name acc_name, SUM(o.total_amt_usd) overall_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		LIMIT 1
		) AS highest_paying_customer
ON highest_paying_customer.acc_id = we.account_id
GROUP BY we_channel
ORDER BY event_count DESC; -- Not necessary, but nice to have

-- Q5

-- This was my interpretation, but I'll redo with how they want it 🤷‍♂️
-- Displaying top 10 highest paying customers and their average spending amount per order
SELECT highest_paying_customers.acc_name,
	   highest_paying_customers.avg_spending_usd
FROM	(
		-- Finding highest paying customers' ids, names, and amounts spent (total and avg)
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd,
			   AVG(o.total_amt_usd) avg_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		LIMIT 10
		) AS highest_paying_customers
ORDER BY avg_spending_usd DESC;

-- Displaying top 10 highest paying customers and average of their totals
SELECT AVG(highest_paying_customers.overall_spending_usd) avg_spending_usd
FROM	(
		-- Finding highest paying customers' ids, names, and amounts spent (total and avg)
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd,
			   AVG(o.total_amt_usd) avg_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		LIMIT 10
		) AS highest_paying_customers
ORDER BY avg_spending_usd DESC;

-- Q6

SELECT AVG(overall_and_avg_spending_tbl.avg_spending_usd)
FROM	(
		-- Finding customers' ids, names, and amounts spent (total and avg)
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd,
			   AVG(o.total_amt_usd) avg_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		) AS overall_and_avg_spending_tbl
/* JOIN orders o
ON o.account_id = overall_and_avg_spending_tbl.acc_id */
-- The 2 lines above made the answer too small, so I'm guessing the JOIN truncates some date
WHERE overall_and_avg_spending_tbl.avg_spending_usd > 
		(
		SELECT AVG(o.total_amt_usd)
		FROM orders o
		);
/*
Solution from instructor:
SELECT AVG(avg_amt)
FROM    (
		SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
		FROM orders o
		GROUP BY 1
		HAVING AVG(o.total_amt_usd) >
				(
				SELECT AVG(o.total_amt_usd) avg_all
				FROM orders o
				)
		) temp_table;
*/

--11. Video: WITH
/*
WITH statements are often called Common Table Expressions (CTEs). They serve the
same purpose as a subquery, but are usually easier for future readers to follow.
WITH makes the subquery into a table within the database, which we can access in
the query that follows the WITH statement.
Example code:
WITH (alias) AS
	(
	SELECT ...
	FROM ...
	...
	(some subquery)
	)

SELECT ...
FROM (alias)
...
*/

--12. Text + Quiz: WITH vs. Subquery
/* From 3. Video/Quiz, the following displays channel and average daily uses: */

SELECT we_channel, AVG(event_count) avg_event_count
FROM
		(
		SELECT DATE_TRUNC('day', we.occurred_at) weekday,
			   we.channel we_channel,
			   COUNT(*) event_count
		FROM web_events we
		GROUP BY 1, 2
		) t1
GROUP BY we_channel
ORDER BY 2 DESC;

/* It can be refactored using WITH statement. Put the subquery into the WITH: */
WITH daily_event_count AS
		(
		SELECT DATE_TRUNC('day', we.occurred_at) weekday,
			   we.channel we_channel,
			   COUNT(*) event_count
		FROM web_events we
		GROUP BY 1, 2
		)
SELECT we_channel, AVG(event_count) avg_event_count
FROM daily_event_count
GROUP BY we_channel
ORDER BY 2 DESC;

/* This isn't particularly helpful with one table, but with many tables being
subqueried, different subqueries can be split into different tables separated
by commas in the WITH statement, as shown by the following: */
/*
WITH table1 AS
		(
		SELECT ...
		FROM ...
		...
		), 
	 table2 AS
		(
		SELECT ...
		FROM ...
		...
		), 
	 ...
SELECT ...
FROM ...
JOIN ...
ON ...
...
*/

--13. Quiz: WITH

-- Q1

WITH total_sales_srep AS
		(
		SELECT srep.id srep_id, srep.name srep_name,
			   r.name r_name, SUM(total_amt_usd) total_sales
		FROM sales_reps srep
		JOIN region r
		ON r.id = srep.region_id
		JOIN accounts acc
		ON acc.sales_rep_id = srep.id
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY srep_id, srep_name, r_name
		),
	 highest_earnings_regional AS
		(
		SELECT tss.r_name r_name, MAX(tss.total_sales) r_highest_sales
		FROM total_sales_srep tss
		GROUP BY r_name
		)
SELECT tss.srep_name, tss.total_sales, tss.r_name
FROM total_sales_srep tss
JOIN highest_earnings_regional her
ON her.r_highest_sales = tss.total_sales
ORDER BY tss.total_sales DESC;

-- Q2

WITH largest_sales_region AS
		(
		SELECT r.id r_id, r.name r_name,
			   SUM(o.total_amt_usd) total_generated
		FROM sales_reps srep
		JOIN accounts acc
		ON acc.sales_rep_id = srep.id
		JOIN orders o
		ON o.account_id = acc.id
		JOIN region r
		ON r.id = srep.region_id
		GROUP BY r_name, r_id
		ORDER BY total_generated DESC
		LIMIT 1
		),
	 total_regional_orders AS
	 (
	 SELECT r.id r_id, r.name r_name, COUNT(*) order_count
	 FROM region r
	 JOIN sales_reps srep
	 ON r.id = srep.region_id
	 JOIN accounts acc
	 ON acc.sales_rep_id = srep.id
	 JOIN orders o
	 ON o.account_id = acc.id
	 GROUP BY r_id, r_name
	 )
SELECT lgst_sls_rgn.r_name, ttl_rgn_ord.order_count
FROM largest_sales_region lgst_sls_rgn
JOIN total_regional_orders ttl_rgn_ord
ON lgst_sls_rgn.r_id = ttl_rgn_ord.r_id;

-- Q3

SELECT COUNT(*) desired_amt
FROM    (
		-- Finding total_qty purchased over lifetime for each company
		SELECT acc.name acc_name, SUM(o.total) total_qty
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_name
		ORDER BY total_qty DESC
		) AS t1
		
WHERE t1.total_qty >
		(
		-- Largest total_qty purchased over lifetime of company with most std_qty
		SELECT most_std_company.total_qty
		FROM    (
				-- Finding total_qty and total_std_qty for company with most total_std_qty
				SELECT acc.name acc_name, SUM(o.standard_qty) total_std_qty, SUM(o.total) total_qty
				FROM accounts acc
				JOIN orders o
				ON o.account_id = acc.id
				GROUP BY acc_name
				ORDER BY total_std_qty DESC
				LIMIT 1
				) AS most_std_company
		);
		
WITH acc_order_qtys AS
		(
		SELECT acc.name acc_name, SUM(o.standard_qty) total_std_qty,
			   SUM(o.total) total_qty, acc.id acc_id
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_name, acc_id
		ORDER BY total_qty DESC
		),
	 most_std_orders AS
		(
		SELECT *
		FROM acc_order_qtys
		ORDER BY total_std_qty DESC
		LIMIT 1
		)

SELECT COUNT(*)
FROM acc_order_qtys acc_ord_qtys
WHERE acc_ord_qtys.total_qty > (SELECT total_qty FROM most_std_orders);
-- Still using a subquery, how would I not use a subquery for 2nd argument in WHERE clause?

-- Q4

WITH highest_paying_customer AS
		(
		-- Finding highest paying customer's id, name, and amount spent
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		LIMIT 1
		)
SELECT we.channel we_channel, COUNT(*) event_count
FROM web_events we
JOIN highest_paying_customer
ON highest_paying_customer.acc_id = we.account_id
GROUP BY we_channel
ORDER BY event_count DESC;

-- Q5

WITH ten_highest_paying_customers AS
		(
		-- Finding highest paying customers' id, name, and amount spent
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd DESC
		LIMIT 10
		)
SELECT AVG(thpc.overall_spending_usd) average_spending_per_order
FROM ten_highest_paying_customers thpc;

-- Q6

WITH ttl_avg_spnd_tbl AS
		(
		-- Finding customers' ids, names, and amounts spent (total and avg)
		SELECT acc.id acc_id, acc.name acc_name,
			   SUM(o.total_amt_usd) overall_spending_usd,
			   AVG(o.total_amt_usd) avg_spending_usd
		FROM accounts acc
		JOIN orders o
		ON o.account_id = acc.id
		GROUP BY acc_id, acc_name
		ORDER BY overall_spending_usd 
		),
	avg_order_spending AS 
		(
		SELECT AVG(o.total_amt_usd) avg_spending_usd
		FROM orders o
		)
		
SELECT AVG(tast.avg_spending_usd)
FROM ttl_avg_spnd_tbl tast
WHERE tast.avg_spending_usd > (SELECT AVG(o.total_amt_usd) FROM orders o)

--CTEs (WITH statements) are more computationally efficient


