-- 1. Video: Intro to Advanced SQL
/*
Cover advanced joins and quick-running queries (even over huge databases).
Most of the topics covered here are going to be edge cases, so they aren't crucial
daily-use tools, but they're still useful.
*/

-- 2. Text: FULL OUTER JOIN
/*
INNER JOINs give a result where the rows are matched between tables.
LEFT JOINs give results including the INNER JOIN, but also adding any unmatched rows
from the 'left' table (table in the FROM clause), if any.
RIGHT JOINs do the same as LEFT JOINs, but with the 'right' table (table in the JOIN
clause).
When we want to include __all__ rows, i.e. matched rows + unmatched rows from both
tables, we can use a FULL OUTER JOINs (FULL JOINs). FULL OUTER JOINs are used commonly when
joining tables with a timestamp, and each of the tables have timestamps not present
in the other, thus including all data with the different timestamps would be most
representative of the available data. FULL JOINs are commonly used with aggregations
to understand the amount of overlap between 2 tables.
If we want to only return unmatched rows, we can use a FULL OUTER JOIN, but add a
WHERE table1.col IS NULL OR table2.col IS NULL, thus all of the columns with NULLs
would appear, whereas others (matched rows, in the INNER JOIN) would vanish.
*/

-- 3. Quiz: FULL OUTER JOIN

SELECT COUNT(1) - COUNT(srep.name) AS num_nulls
FROM accounts acc
FULL OUTER JOIN sales_reps srep
ON acc.sales_rep_id = srep.id;

-- 5. Video: JOINs with Comparison Operators
/*
We can use an inequality join to compare row entries in 1 column to corresponding
row entries in another, thus filtering results as we join them, rather than filtering
in the WHERE clause, which runs after the JOIN, and may leave some NULLs.
When writing an inequality JOIN, we usually have an equality as well in the
ON clause, then write AND condition1 (comparison operator) condition2, i.e.
SELECT *
FROM tbl1
RIGHT JOIN tbl2
ON tbl1.col1 = tbl2.col1
AND tbl1.col2 >= tbl2. col2 -- This is the additional filter to the JOIN statement
-- We don't need to filter using WHERE here because the JOIN with inequality does it.
(NOTE:) Results are less predictable when using a JOIN with inequalities. i.e. 
ON tbl1.col1 = tbl2.col1 -- This is predictable, since we know how this result __SHOULD__ look like.
AND tbl1.col2 >= tbl2. col2 -- This is not so predictable, since we dk how this __SHOULD__ look like
Double-check query logic and ensure desired output is produced. Always check edge
cases!
*/

-- Example Query:

-- Select order id, date, and all associated web events
SELECT o.id, o.occurred_at order_date, events.*
FROM orders o
-- Output all matched rows + unmatched order rows
LEFT JOIN web_events events
-- Regular ON equality
ON events.account_id = o.account_id
-- Filtering with a JOIN inequality to ensure that web event happened before first order date
AND events.occurred_at < o.occurred_at
-- Filtering order date to only show month of when first order happened
WHERE DATE_TRUNC('month', o.occurred_at) = 
	-- Nice little subquery without alias; returns month of earliest order
	(SELECT DATE_TRUNC('month', MIN(o.occurred_at)) FROM orders o)
ORDER BY o.account_id, order_date;

-- 6. Quiz: JOINs with Comparison Operators
/*
Comparison operators don't only work on date times and/or numbers, they also
work on strings.
*/

SELECT acc.name acc_name, acc.primary_poc, srep.name srep_name
FROM accounts acc
LEFT JOIN sales_reps srep
ON srep.id = acc.sales_rep_id
AND acc.primary_poc < srep.name; -- primary_poc comes before srep.name alphabetically
/*
Stack Overflow answer discussing comparison operators with strings:
https://stackoverflow.com/questions/26080187/sql-string-comparison-greater-than-and-less-than-operators/26080240#26080240
*/

-- 8. Video: Self JOINs
/*
Joining a table onto itself is commonly used when 2 events occur consecutively, i.e.
finding which accounts made an order within 28 days of another order. Example below
Date & time functions + opeartors, we used INTERVAL below:
https://www.postgresql.org/docs/8.2/functions-datetime.html
*/

SELECT o1.id o1_id, o1.account_id o1_acc_id, o1.occurred_at o1_date,
	   o2.id o2_id, o2.account_id o2_acc_id, o2.occurred_at o2_date
FROM orders o1
LEFT JOIN orders o2 -- Demo LEFT JOINs here, but idk why since self joining means all rows are matched?
ON o1.account_id = o2.account_id -- Why not o1.id = o2.id?
AND o2.occurred_at > o1.occurred_at -- o2 occurrs after o1
AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days' -- o2 occurrs no later than 28 days after o1
ORDER BY o1.account_id, o1.occurred_at;

-- 9. Quiz: Self JOINs

-- Altered version query above, but interval analysis for web_events table instead
SELECT we1.id we1_id, we1.account_id we1_acc_id, we1.occurred_at we1_date, we1.channel we1_channel,
	   we2.id we2_id, we2.account_id we2_acc_id, we2.occurred_at we2_date, we2.channel we2_channel
FROM web_events we1
LEFT JOIN web_events we2
ON we1.account_id = we2.account_id
AND we2.occurred_at > we1.occurred_at
AND we2.occurred_at <= we1.occurred_at + INTERVAL '1 day'
ORDER BY we2.account_id, we1.occurred_at;
-- Note for future: course solution switched we1 and we2, their we1 is my we2, their we2 is my we1.

-- 11. Video: UNION
/*

****************************************************************************
*** Generally, it's more likely to use UNION ALL than UNION in practice. ***
****************************************************************************

JOINs allow us to display results from different tables side-by-side, whereas UNION allows for vertical stacking
in the same resulting field/column of the output.

Use Case:
UNION operator combines the results of multiple (2+) SELECT statements, removing duplicate rows among
the several SELECTs.
Each SELECT within the UNION must have the same number of fields/columns in the result sets with similar dtypes.
i.e. if you query 'name_example' in first SELECT and again in second SELECT, but the columns are inherently different
as they come from different tables, they UNION would only make sense if they had the same dtype.
(NOTE:) If columns from different tables describe the same data but have different names (i.e. company_id & supplier_id),
the columns can be aliased to produce a more coherent result (i.e. ID_Value).
UNION is commonly used when pulling together distinct values of specific columns scattered across multiple tables,
i.e. Pull together all production parts required for manufacturing several cars, where car details are stored in
tables.
UNION can also be used to add an aggregation to the bottom of a column, i.e. the sum of the record above.

Details:
All SELECT statements within the UNION must have the same number of expressions. i.e. Do not extract 1 column from
a table then attempt to UNION 2 columns from another table, it'll result in an error.
Corresponding expressions must have the same dtype in the SELECT statements, i.e.
expression1 must be the same dtype in all SELECTs that reference it.
UNION ... removes duplicate rows, UNION ALL does not remove duplicate rows.
Different SELECT statements are written in the UNION, so we can pre-treat the tables in the separate SELECTs using
filters (WHERE clauses most often).
We can use UNIONs in subqueries (or CTE, i.e. WITH ... AS ...), then perform operations on that subquery, allowing
for use of aggregation or window functions, ordering, filtering using WHERE, and all other functions that I do not know.

Learn more: https://www.techonthenet.com/sql/union.php
*/

-- 12. Quiz: UNION

-- Q1 - Appending Data via UNION
SELECT *
  FROM accounts

 UNION ALL

SELECT *
  FROM accounts;

-- Q2 - Pretreating Tables before UNIONs
SELECT *
  FROM accounts
 WHERE name = 'Walmart'

 UNION ALL

SELECT *
  FROM accounts
 WHERE name = 'Disney';

-- Q3 - Performing Operations on a Combined Dataset
WITH double_accounts AS -- Duplicating query from first question and putting into CTE
		(
		SELECT *
		  FROM accounts

		 UNION ALL

		SELECT *
		  FROM accounts
		)

SELECT name, COUNT(*)
  FROM double_accounts
GROUP BY name;

-- 15. Video/Quiz: Performance Tuning 1
/*
To make a query run faster, the number of calculations to be performed must be reduced.

Ways we can control performance:
Table size - Accessing multiple tables with millions of rows will hinder performance greatly;
Performing a JOIN on two tables such that the resulting row count is substantially large, the
query is likely to be slow; Aggregations can heavily influence run-time. Combining multiple rows
for a result requires more computation than only retrieving them. Additionally, COUNT DISTINCT takes
more time than a regular COUNT because it must check __all__ rows against one another for duplicate values.

Ways we cannot control performance:
When working in a team, more queries are likely to run concurrently on a single database. As expected,
multiple queries running at the same time on a single database will slow down performance, and even more so
if other queries are of the slow types mentioned in the paragraph above.
Different databases are optimized for different tasks, i.e. pgsql is optimized for reading and writing, whereas
redshift is optimized for fast aggregations.

(NOTE:) Filtering data to only include required results can drastically increase performance.
i.e. When working with time-series data, using a smaller time window will make the query run quicker than otherwise.
We can always perform exploratory analysis on a subset of the data, then remove the limitation to the subset and
run the query over the entire dataset when adequate. However, aggregations work differently, as aggregations are executed
before LIMITs are, therefore introducing a 'LIMIT n' statement will not improve performance. To combat this, we can run
the aggregation on a subset, which can be done using a subquery (or CTE) with a LIMIT statement.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! PUT THE LIMIT IN THE SUBQUERY NOT THE OUTER QUERY TO IMPROVE PERFORMANCE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Remove the LIMIT statement within the subquery when executing the final query after performing exploratory analysis.
*/

-- Example query, can be improved:
SELECT *
  FROM orders;

-- Rather than getting back everything, we can shrink the time window, resulting in a faster query:
SELECT *
  FROM orders
WHERE occurred_at >= '2016-01-01'
  AND occurred_at < '2016-07-01';

-- If we perform an aggregation, not even a LIMIT can speed things up dramatically, as the aggregation runs first:
SELECT account_id, SUM(poster_qty) sum_poster_qty
  FROM orders
 WHERE occurred_at >= '2016-01-01'
   AND occurred_at < '2016-07-01'
 GROUP BY 1
 LIMIT 10;
 
-- To speed up queries with aggregations, we can do our exploratory work with a limited subquery:
SELECT account_id, SUM(poster_qty) sum_poster_qty
  FROM (SELECT * FROM orders LIMIT 100) o -- Put the LIMIT in the subquery to improve performance
  										  -- This is because we're shrinking the table size :).
 WHERE occurred_at >= '2016-01-01'
   AND occurred_at < '2016-07-01'
 GROUP BY 1;
/* Before running query for final results, make sure to remove the inner LIMIT inside the subquery,
   or remove the subquery in its entirety. */

-- 16. Video: Performance Tuning 2
/*

Ways we can control performance:
Reducing the number of rows that are evaluated during a JOIN. As we want to reduce the amount of data
at the point where it is executed early, table sizes can be reduced before JOINing them. In general, a 
performance increase can be obtained by aggregating prior to JOINing, though it must be logical to do so,
as it would otherwise provide unexpected results. Prioritize accuracy of results over performance.
*/

-- Example query, can be improved:
SELECT accounts.name,
	   COUNT(*) web_events
  FROM accounts
  JOIN web_events events -- web_events has 9073 rows which are JOINed, so we should look into tuning performance.
    ON events.account_id = accounts.id
 GROUP BY 1
 ORDER BY 2 DESC;

-- Improved query:
SELECT accounts.name,
	   we_tbl.web_events
  FROM accounts
  JOIN
		(
		SELECT account_id,
			   COUNT(*) web_events
		  FROM web_events events
		 GROUP BY 1
		) we_tbl -- This subquery has 351 rows which are being JOINed, quite a big jump from 9073.
    ON we_tbl.account_id = accounts.id
 ORDER BY 2 DESC;

-- 17. Video: Performance Tuning 3
/*
EXPLAIN can be added before any working query to get a sense for how long it will take. Though not perfectly
accurate, it roughly outlines order of execution relatively well. The cost shown within the query plan of
any command is not to be interpreted exactly as is, but rather as a measure of difference when a computationally
expensive command is altered, to gauge the impact the change has on performance.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~ Note: The cost appears to be constant between runs, so it does seem to be a good way to gauge change in ~~~
~~~ performance between queries after altering computationally expensive commands                           ~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

-- Simple query run with EXPLAIN:
EXPLAIN
SELECT *
  FROM web_events
 WHERE occurred_at >= '2016-01-01'
   AND occurred_at < '2016-02-01'
 LIMIT 100;
 
-- 18. Video: JOINing Subqueries
/*
When displaying multiple aggregations in one result (i.e. for a dashboard), __many__ rows are being calculated,
thus the result is quite slow to compute. To remedy this issue, subqueries can be used to aggregate individual
tables that are JOINed together to achieve the same result with better performance.
*/

-- Example query, can be improved:

-- Finding all metrics in 1 main query:
-- Because we want to find daily results, there are a lot of rows (1059)
SELECT DATE_TRUNC('day', o.occurred_at) date, -- We only care about days, not hours or minutes, etc...
	   -- 3 COUNTs are fairly obvious, but contrast this result with the one below to see why we use DISTINCT
	   COUNT(DISTINCT a.sales_rep_id) active_sreps,
	   COUNT(DISTINCT o.id) orders,
	   COUNT(DISTINCT we.id) web_visits
  FROM accounts a -- 
  JOIN orders o
    ON a.id = o.account_id
  JOIN web_events we
    ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
 GROUP BY 1
 ORDER BY 1 DESC;

-- Same query as example, without DISTINCT in the COUNTs
SELECT DATE_TRUNC('day', o.occurred_at) date,
	   COUNT(a.sales_rep_id) active_sreps,
	   COUNT(o.id) orders,
	   COUNT(we.id) web_visits
  FROM accounts a -- 
  JOIN orders o
    ON a.id = o.account_id
  JOIN web_events we
    -- Because we are JOINing ON dates, there is a multiplicative effect, thus
	-- we have n_distinct_orders*n_distinct_web_visits as our COUNTs
	/*
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	~~~ LOOK INTO THIS MULTIPLICATIVE EFFECT AND WHY IT HAPPENS ~~~
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	*/
    ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
 GROUP BY 1
 ORDER BY 1 DESC;

-- Same query as example, without the COUNTs
-- Note that due to the multiplicative effect, 79,083 (wow) rows were returned
SELECT DATE_TRUNC('day', o.occurred_at) date,
	   a.sales_rep_id active_sreps,
	   o.id orders,
	   we.id web_visits
  FROM accounts a
  JOIN orders o
    ON a.id = o.account_id
  JOIN web_events we
    -- Because we are JOINing ON dates, there is a multiplicative effect, thus
	-- we have n_distinct_orders*n_distinct_web_visits as our COUNTs
    ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
 ORDER BY 1 DESC;

-- Same query as example, executed with CTEs rather than a big chunk of code:
SELECT DATE_TRUNC('day', o.occurred_at) date,
	   COUNT(DISTINCT a.sales_rep_id) active_sreps,
	   COUNT(DISTINCT o.id) orders,
	   COUNT(DISTINCT we.id) web_visits
  FROM accounts a
  JOIN orders o
    ON a.id = o.account_id
  JOIN web_events we
    ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
 GROUP BY 1
 ORDER BY 1 DESC;

-- Modified query from example, written using CTEs (NOT OPERATING AS INTENDED, TROUBLESHOOT!)
WITH active_sreps AS
		(
		SELECT DATE_TRUNC('day', o.occurred_at) date,
			   COUNT(a.sales_rep_id) srep_count
		  FROM accounts a
		  JOIN orders o
			ON o.account_id = a.id
		 GROUP BY 1
		),
	 orders AS
	 	(
		SELECT DATE_TRUNC('day', o.occurred_at) date,
			   COUNT(o.id) o_count
		  FROM orders o
		 GROUP BY 1
		),
	 web_visits AS
	 	(
		SELECT DATE_TRUNC('day', we.occurred_at) date,
			   COUNT(we.id) we_count
		  FROM web_events we
		 GROUP BY 1
		)

SELECT active_sreps.date,
	   active_sreps.srep_count,
	   orders.o_count,
	   web_visits.we_count
  FROM active_sreps
  JOIN orders
    ON orders.date = active_sreps.date
  JOIN web_visits
    ON web_visits.date = orders.date
 ORDER BY 1 DESC;