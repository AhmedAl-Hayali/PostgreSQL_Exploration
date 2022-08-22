--1. Video: Intro to Aggregation
/*
COUNT counts how many rows are in a particular column
SUM adds all values in a particular column
MIN and MAX return lowest & highest values in a particular column
AVERAGE calculates the average of all the values in a particular column
*/

--2. Video: Intro to NULLs
/*
NULL is a datatype, specifying that no data exists. They are often ignored in agg. functions
*/

--3. Video: NULLs and Aggregation
/*
When finding NULLs using a WHERE clause, write IS NULL rather than = NULL, since
NULL is a property of the data, not a value.
NULLs are encountered when doing LEFT or RIGHT JOINs and some rows aren't matched, 
or simply when data is missing from the database.
*/

--4/5. Video: COUNT/COUNT & NULLs
/*
We can COUNT the number of rows in a table using: SELECT COUNT(*) FROM table;
Similarly, we can use: SELECT COUNT(table.column) FROM table;
These two are not always equivalent. They are not equivalent when table.column
has NULL data. As a result, if COUNT(table.column) differs (less than) from
COUNT(*), we can be sure that "table.column" has NULL cells.
COUNT can be used with any column, as it just returns the number of non-NULL rows,
which is not the case for all aggregation functions.
*/

--6. Video: SUM
/*
We can find the sum of (aggregate) a __numeric__ column using: SELECT SUM(table.col)
SUM treats NULLs as 0s, so we don't need to worry about them. However,
SUM will not work with non-numeric columns, as it makes no sense.
For row-wise aggregation, use arithmetic operators SELECT (col1+col2+...) FROM table
*/

--7. Quiz: SUM

SELECT SUM(poster_qty) AS total_poster_qty
FROM orders;

SELECT SUM(standard_qty) AS total_std_qty
FROM orders;

SELECT SUM(total_amt_usd) AS total_sales_usd
FROM orders;

SELECT standard_amt_usd + gloss_amt_usd AS total_std_gloss_usd
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS unit_std_usd
FROM orders;

--9. Video: MIN & MAX
/*
We can find the largest and smallest values in a column using MAX and MIN respectively.
They will both ignore NULL data, and they can work on columns with __any data type__,
returning earliest/latest data, lowest/highest #, string/char with starting letter closest
to A/Z, depending on whether using MIN/MAX respectively.
*/

--10. Video: AVG
/*
The AVG function returns the mean of all non-NULL data values. If we want to
find the average, and consider NULL as 0, we can use SUM()/COUNT() AS mean, but
this isn't usually a good idea since it assumes NULL values are truly 0, not missing.
*/

--11. Quiz: MIN, MAX, & AVG

SELECT MIN(occurred_at) AS earliest_order
FROM orders;

SELECT occurred_at AS earliest_order_no_agg_func
FROM orders
ORDER BY occurred_at --sort from oldest to newest
LIMIT 1; --only show first row

SELECT MAX(occurred_at) AS latest_web_event
FROM web_events;

SELECT occurred_at AS latest_web_event_no_agg_func
FROM web_events
ORDER BY occurred_at DESC --sort from newest to oldest
LIMIT 1; --only show first row

SELECT AVG(standard_amt_usd) AS std_avg_usd, 
	   AVG(gloss_amt_usd) AS gloss_avg_usd, 
	   AVG(poster_amt_usd) AS poster_avg_usd,
	   AVG(standard_qty) AS std_avg_qty,
	   AVG(gloss_qty) AS gloss_avg_qty,
	   AVG(poster_qty) AS poster_avg_qty
FROM orders;

--Incorrect attempt at finding median of total usd spent:
/*
SELECT MEDIAN(total_usd)
FROM orders;
*/

--Instructor's implementation:
/*
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
*/
/*
This isn't ideal because we'd need to tweak the numbers in the sub-query LIMIT
to either (number of orders)/2 + 1 if it's even, or (number of orders) if it's odd
Also, if it's odd, the query final LIMIT would be 1 not 2
*/

--13. Video: GROUP BY
/*
We can create segments that can be independently aggregated from one another
using GROUP BY, i.e. aggregate over different accounts vs aggregate over
entire dataset.
GROUP BY goes between WHERE clause and the ORDER BY clause, if they are present.
(NOTE): Any column in the SELECT statement not within an aggregator function
__must__ be in the GROUP BY clause.
(TIP): SQL evaluates aggregations __before__ the LIMIT clause. If we don't group by
columns, we get a 1-row result, but if we group by a column with enough distinct
values to exceed the LIMIT, the aggregates will be calculated, then the remaining
rows will be truncated, not from the calculation, but from the result.
*/

--14. Quiz: GROUP BY

SELECT acc.name AS acc_name, o.occurred_at AS order_date
FROM accounts AS acc
JOIN orders AS o
ON o.account_id = acc.id
ORDER BY order_date
LIMIT 1;

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_usd_spent
FROM accounts AS acc
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY acc_name;

SELECT we.occurred_at AS time_occurred, we.channel, acc.name
FROM web_events AS we
JOIN accounts AS acc
ON acc.id = we.account_id
ORDER BY we.occurred_at DESC
LIMIT 1;

--NO LONGER stuck at 4 :/
SELECT we.channel, COUNT(we.*) --Need to count occurrences then group by channel, EZ unstuck
FROM web_events AS we
GROUP BY we.channel;
SELECT acc.primary_poc, we.occurred_at AS date_occurred
FROM accounts AS acc
JOIN web_events AS we
ON acc.id = we.account_id
ORDER BY we.occurred_at
LIMIT 1;

SELECT acc.name, MIN(o.total_amt_usd) AS smallest_order
FROM accounts AS acc
JOIN orders AS o
ON acc.id = o.account_id
GROUP BY acc.name
ORDER BY smallest_order;

SELECT r.name AS region_name, COUNT(srep.id) AS n_reps --I chose to count only those with an ID
FROM region AS r
JOIN sales_reps AS srep
ON srep.region_id = r.id
GROUP BY r.name
ORDER BY n_reps; --or ORDER BY 2

--16. Video: GROUP BY Part 2 (Multiple columns)
/*
We can GROUP BY multiple columns at once, which is useful when aggregating across multiple segments.
The order of columns in the ORDER BY (col1, col2 DESC, ...) clause matters,
first ordering by col 1, then col2, ...
The order of columns in the GROUP BY clause doesn't matter.
We can use column numbers in the ORDER BY or GROUP BY clauses, i.e. ORDER BY 2
to order by the 2nd column in the resulting query.
*/

SELECT acc.name acc_name, AVG(o.standard_qty) avg_std,
       AVG(o.poster_qty) avg_poster, AVG(o.gloss_qty) avg_gloss
FROM accounts AS acc
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY acc.name;

SELECT acc.name acc_name, AVG(o.standard_amt_usd) avg_std_usd,
       AVG(o.poster_amt_usd) avg_poster_usd, AVG(o.gloss_amt_usd) avg_gloss_usd
FROM accounts AS acc
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY acc.name;

SELECT srep.name srep_name, we.channel, COUNT(*) AS occurrences
FROM sales_reps AS srep
JOIN accounts
ON accounts.sales_rep_id = srep.id
JOIN web_events AS we
ON we.account_id = accounts.id
GROUP BY srep.name, we.channel
ORDER BY occurrences DESC;

SELECT r.name srep_name, we.channel, COUNT(*) AS occurrences
FROM sales_reps AS srep
JOIN accounts
ON accounts.sales_rep_id = srep.id
JOIN web_events AS we
ON we.account_id = accounts.id
JOIN region AS r
ON r.id = srep.region_id
GROUP BY r.name, we.channel
ORDER BY occurrences DESC;

--19. Video: DISTINCT
/*
DISTINCT is always used in SELECT statements, providing unique rows for __all__
columns in the SELECT statement.
Write SELECT DISTINCT col1, col2, col3 FROM table
Don't write SELECT DISTINCT col1, DISTINCT col2, DISTINCT col3 FROM table1
(NOTE:) Using DISTINCT, especially in aggregations, can slow down queries quite a bit
*/

SELECT acc.name acc_name, r.name region_name
FROM accounts acc
JOIN sales_reps srep
ON acc.sales_rep_id = srep.id
JOIN region r
ON r.id = srep.region_id
ORDER BY acc_name; --351 rows whether or not DISTINCT is used ==> no account w/ multiple regions

SELECT acc.name acc_name, srep.name srep_name
FROM accounts acc
JOIN sales_reps srep
ON acc.sales_rep_id = srep.id
ORDER BY srep_name; --Some reps have multiple accounts associated ==> Yes, some reps have multiple acc's

/*
Same solution overall, but here's another implementation by instructor:
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;
*/

--22. Video: HAVING
/*
HAVING is a clean way of filtering a query that's been aggregated (can also be done w/ subquery).
HAVING is the WHERE of elements that are created by an aggregate.
This is useful when aggregating over multiple categories (i.e. you have GROUP BY clause),
as filtering a result with only 1 output (aggregating over entire dataset) is
redundant
HAVING comes after GROUP BY clause, but before ORDER BY
*/

--23. Quiz: HAVING

SELECT COUNT(*) AS nreps_5plus_accs
FROM (SELECT srep.name srep_name, COUNT(acc.name) AS num_acc_mngd
FROM accounts acc
JOIN sales_reps srep
ON acc.sales_rep_id = srep.id
GROUP BY srep_name
HAVING COUNT(acc.name) > 5
ORDER BY num_acc_mngd) AS _; --34
/*
Subquery looks for sales reps with >= 5 accounts managed, then we count the result
of the subquery and return it as nreps_5plus_accs
*/

SELECT COUNT(*) AS naccs_21plus_orders
FROM (SELECT acc.name AS acc_name, COUNT(o.id) AS num_orders
FROM accounts acc
JOIN orders o
ON o.account_id = acc.id
GROUP BY acc_name
HAVING COUNT(o.id) > 20
ORDER BY num_orders) AS _; --120

SELECT acc.name AS acc_name, COUNT(o.id) AS num_orders
FROM accounts acc
JOIN orders o
ON o.account_id = acc.id
GROUP BY acc_name
HAVING COUNT(o.id) > 20
ORDER BY num_orders DESC; --71, Leucadia National

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS acc
JOIN orders AS o
ON acc.id = o.account_id
GROUP BY acc_name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS acc
JOIN orders AS o
ON acc.id = o.account_id
GROUP BY acc_name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS acc
JOIN orders AS o
ON acc.id = o.account_id
GROUP BY acc_name
ORDER BY total_spent DESC
LIMIT 1; --EOG Resources

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS acc
JOIN orders AS o
ON acc.id = o.account_id
GROUP BY acc_name
ORDER BY total_spent
LIMIT 1; --Nike

/*
SELECT acc.name acc_name, COUNT(we.channel = 'facebook') fb_chnl_count
--Can't do COUNT(we.channel = 'facebook'), doesn't count false as 0 ig (SUM(...) doesn't work either :/)
FROM accounts acc
JOIN web_events we
ON we.account_id = acc.id
GROUP BY acc_name
HAVING COUNT(we.channel = 'facebook') > 6;
*/
SELECT acc.name acc_name, we.channel, COUNT(*) fb_chnl_count 
FROM accounts acc
JOIN web_events we
ON we.account_id = acc.id
GROUP BY acc_name, we.channel
HAVING COUNT(*) > 6 AND we.channel = 'facebook';

/*
SELECT acc.name acc_name, COUNT(we.channel = 'facebook') fb_chnl_count
FROM accounts acc
JOIN web_events we
ON we.account_id = acc.id
GROUP BY acc_name
HAVING COUNT(we.channel = 'facebook') > 6
ORDER BY fb_chnl_count DESC; --Ecolab
*/
SELECT acc.name acc_name, we.channel, COUNT(*) fb_chnl_count 
FROM accounts acc
JOIN web_events we
ON we.account_id = acc.id
WHERE we.channel = 'facebook'
GROUP BY acc_name, we.channel
ORDER BY fb_chnl_count DESC; --Gilead Sciences
-- LIMIT 1 <-- only works if there's no ties, don't do this as the starter

SELECT we.channel, COUNT(we.channel) AS chnl_count
FROM web_events we
GROUP BY we.channel
ORDER BY chnl_count DESC; --Direct
-- LIMIT 1 <-- only works if there's no ties, ...

--26. Video: DATE Functions 2
/*
To truncate a given date or set of dates to a particular part (s, d, m, y, ...),
we can use DATE_TRUNC('[interval]', time_col). See more at:
https://mode.com/blog/date-trunc-sql-timestamp-function-count-on/
To find specific parts of a date, we can use DATE_PART('[part]', time_col). See more at:
https://www.postgresql.org/docs/9.1/functions-datetime.html, Section 9.9.1
*/

--27. Quiz: DATE Functions

SELECT DATE_TRUNC('year', o.occurred_at) yearly_total_sales,
	   SUM(o.total_amt_usd) yearly_sales_usd
FROM orders o
GROUP BY yearly_total_sales
ORDER BY yearly_total_sales;
--Yearly sales in usd growing from year to year, excluding ongoing year (2017)

SELECT DATE_PART('month', o.occurred_at) month_time,
	   SUM(o.total_amt_usd) monthly_sales_usd,
	   COUNT(o.occurred_at) occurrences
FROM orders o
GROUP BY month_time
ORDER BY monthly_sales_usd DESC;
--December has highest total revenue, but also most total orders

SELECT DATE_PART('year', o.occurred_at) year_time,
	   SUM(o.total_amt_usd) yearly_sales_usd,
	   COUNT(o.occurred_at) occurrences,
	   SUM(o.total_amt_usd)/COUNT(o.occurred_at) avg_order_rev --extra, for fun
FROM orders o
GROUP BY year_time
ORDER BY occurrences DESC;
--2016 had the most orders, and it goes down reverse-chrono, except for ongoing yr

SELECT DATE_PART('month', o.occurred_at) month_time,
	   SUM(o.total_amt_usd) monthly_sales_usd,
	   COUNT(o.occurred_at) occurrences,
	   SUM(o.total_amt_usd)/COUNT(o.occurred_at) avg_order_rev --extra, for fun
FROM orders o
GROUP BY month_time
ORDER BY occurrences DESC;
--Yet again, December had most occurrences, and it goes down reverse-chrono. strange

SELECT DATE_TRUNC('month', o.occurred_at) month_time,
	   SUM(o.gloss_amt_usd) total_gloss_month,
	   COUNT(o.occurred_at) occurrences
FROM orders o
JOIN accounts AS acc
ON o.account_id = acc.id
WHERE acc.name = 'Walmart'
GROUP BY month_time
ORDER BY total_gloss_month DESC;
-- May 2016 was when Walmart spent $9,257.64 on gloss paper

--29/30. Video: CASE Statements/CASE & Aggregations
/*
We can make a derived column using a CASE statement, not only arithmetic operations.

The CASE statement is the if-then-else structure of SQL.
It always goes in the SELECT clause.
CASE must include the following: WHEN, THEN, and END. ELSE is optional.
The structure of the CASE statement is:
SELECT col1, col2, ..., 
	   CASE WHEN (arg) (operator) (value) ((other conditions))THEN (val in row)
	   WHEN ...
	   ...
	   ELSE ... END AS (alias)
FROM ...
Any conditional statement can be made between WHEN and THEN, including
stringing ANDs and ORs for complex conditions.
Multiple WHEN statements can be included, as it represents both 'if' and 'elif'.
For catch-all-else, use ELSE.
CASE statements are crucial when handling zerodivisionerror's :]
CASE statements are essentially WHERE statements but when you need multiple
groups rather than only 1.
*/

--31. Quiz: CASE

SELECT o.account_id, o.total_amt_usd tot,
	   CASE WHEN o.total_amt_usd >= 3000 THEN 'Large'
	   ELSE 'Small' END AS order_lvl
FROM orders o; --No need to join accounts table to get id, just use FK :O

SELECT Count(total),
	   CASE WHEN total >= 2000 THEN 'At Least 2000'
	   WHEN total < 2000 AND total >= 1000 THEN 'Between 1000 and 2000'
	   WHEN total < 1000 THEN 'Less than 1000' END AS order_category
FROM orders
GROUP BY order_category;

SELECT acc.name AS acc_name, SUM(o.total_amt_usd) AS total_spending,
	   CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'greater than 200,000'
	   WHEN SUM(o.total_amt_usd) > 100000 AND SUM(o.total_amt_usd) <= 200000 THEN 'Between 100,000 and 200,000'
	   WHEN SUM(o.total_amt_usd) <= 100000 THEN 'Less than 100,000'
	   END AS acc_lvl
FROM orders o
JOIN accounts acc
ON o.account_id = acc.id
GROUP BY acc_name
ORDER BY total_spending DESC;

SELECT acc.id, o.total_amt_usd tot,
	   CASE WHEN o.total_amt_usd >= 3000 THEN 'Large'
	   ELSE 'Small' END AS order_lvl,
	   o.occurred_at
FROM orders o
JOIN accounts acc
ON o.account_id = acc.id
WHERE DATE_TRUNC('year', o.occurred_at) BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY tot DESC;

SELECT srep.name srep_name, COUNT(o.*) AS srep_orders, 
	   CASE WHEN COUNT(o.*) > 200 THEN 'top'
	   ELSE 'not' END AS srep_performance
FROM sales_reps AS srep
JOIN accounts AS acc
ON srep.id = acc.sales_rep_id
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY srep.name --Assumes srep names are unique, otherwise we'd want to break/group by name & id of srep table
ORDER BY srep_orders DESC;

SELECT srep.name srep_name, COUNT(o.*) AS srep_orders,
	   SUM(o.total_amt_usd) AS srep_sales,
	   CASE WHEN COUNT(o.*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
	   WHEN COUNT(o.*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
	   ELSE 'low' END AS srep_performance
FROM sales_reps AS srep
JOIN accounts AS acc
ON srep.id = acc.sales_rep_id
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY srep.name
ORDER BY srep_sales DESC;