-- 1. Video: Intro to Window Functions
/*
Window functions allow comparison of multiple rows without using a JOIN.
We can create a running total or determine whether a row is greater in value than
the previous, then classify it as necessary.
*/

-- 2. Window Functions 1
/*
To create a running total of sales for P&P, the following query can be run:

SELECT standard_qty,
	   SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

Breaking the query down, we can note:
It starts with a standard aggregation function, SUM().
Including OVER designates it as a window function.
Order rows by date they occurred_at.
Overall, we can read it as: SUM over all standard_qty OVER/across all rows leading
up to a given row, in ORDER BY occurred_at.

Things to note:
Window functions start with an aggregation function, then comes the OVER keyword
which designates it as a window function, then we could include the window
as an ORDER BY statement (or a PARTITION BY as we'll see next).

To separate the running totals for each month, we can partition the window monthly
using a DATE_TRUNC():

SELECT standard_qty,
	   DATE_TRUNC('month', occurred_at) AS month,
	   SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

Now we have a running total across every month, i.e. it resets every new month.
The reason we have the ORDER BY statement in the window is to keep the running sum
rather than have the running_total column be the SUM() of all values in each entry's
corresponding month:

SELECT standard_qty,
	   DATE_TRUNC('month', occurred_at) AS month,
	   SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at)) AS running_total
FROM orders;

The window is the ordered set of data over which all calculations are made.
(NOTE:) We can't use window functions and standard aggregations in the same
query because window functions can't be put into the GROUP BY clause.
*/

SELECT standard_qty,
	   SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

SELECT standard_qty,
	   DATE_TRUNC('month', occurred_at) AS month,
	   SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

SELECT standard_qty,
	   DATE_TRUNC('month', occurred_at) AS month,
	   SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at)) AS running_total
FROM orders;

-- 3. Quiz: Window Functions 1

SELECT standard_amt_usd,
	   SUM(standard_amt_usd) OVER (ORDER BY occurred_at) running_total
FROM orders;

-- 5. Quiz: Window Functions 2

SELECT standard_amt_usd,
	   DATE_TRUNC('year', occurred_at) yr,
	   SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) running_total
FROM orders;
/*
For more info on PARTITION BY: https://stackoverflow.com/questions/561836/oracle-partition-by-keyword
*/

-- 7. Video: ROW_NUMBER, RANK, 
/*
Easiest place to use window functions is with functions that just count rather
than aggregate.
ROW_NUMBER() displays the # of a given row within the defined window. It starts
at 1 then increments in accordance to the window (ORDER BY usually). ROW_NUMBER()
takes no argument. i.e.: SELECT ROW_NUMBER() OVER (ORDER BY ...) AS row_num FROM ...
(NOTE:) Ordering by ID might make the row_num column identical to the id column,
so it's usually more insightful to order by other columns in the window.
RANK() gives 2 rows with the same value in the window the same rank, thus are
given the same numbers in row_num, whereas ROW_NUMBER() will give 2 separate
entries in the same partition a different number regardless of whether they hold
the same information or not.
DENSE_RANK() will give consecutive different entries consecutive different numbers,
whereas RANK() will assign the first different entry its row number, i.e.:
DENSE_RANK() results in (1, 1, 2, 2, 3, 4, 5), whereas RANK() results in
(1, 1, 3, 3, 5, 6, 7)
*/

SELECT id,
	   account_id,
	   occurred_at,
	   ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY occurred_at) row_num
FROM orders;

-- Basically the same as the above
SELECT id,
	   account_id,
	   occurred_at,
	   RANK() OVER (PARTITION BY account_id ORDER BY occurred_at) row_num
FROM orders;

-- By changing occurred_at to monthly, we can see how RANK() works differently
SELECT id,
	   account_id,
	   DATE_TRUNC('month', occurred_at),
	   RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) row_num
FROM orders;
SELECT id, -- Contrast the above with this
	   account_id,
	   DATE_TRUNC('month', occurred_at),
	   ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) row_num
FROM orders;

-- Contrast RANK() above with DENSE_RANK() below
SELECT id,
	   account_id,
	   DATE_TRUNC('month', occurred_at),
	   DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) row_num
FROM orders;

-- 8. Quiz: ROW_NUMBER() and RANK()

SELECT id, account_id, total,
	   RANK() OVER (PARTITION BY account_id ORDER BY total DESC) total_rank
FROM orders;

-- 10. Video: Aggregates in Window Functions
/*
We can use standard aggregates (SUM, COUNT, AVG, MIN, MAX) when working with
window functions.
SUM() creates a running total (been over it above)
COUNT() creates a running count (same grouping as running total)
AVG() creates a running average (really just running total divided by running count)
MIN() shows lowest value upto that point in the specified window
MAX() shows the highest value upto that point in the specified window
*/

-- 11. Video: Aggregates in Window Functions

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders;

-- Modified to remove ORDER BY DATE_TRUNC('month', occurred_at)
SELECT id,
       account_id,
       standard_qty,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders;

/*
How removing the ORDER BY clause affects the result:
https://stackoverflow.com/a/41366045
*/

-- 13. Video: Aliases for Multiple Window Functions

/*
More Window Functions (documentation):
https://www.postgresql.org/docs/8.4/functions-window.html

If multiple window functions in the same query operate under the same window,
we can alias the window to avoid repetition in our code.
i.e. instead of writing OVER (PARTITION BY ...) in the query above 6 times,
we can alias it by writing, after the WHERE clause and before the GROUP BY clause,
a WINDOW clause:
WINDOW window_name AS (PARTITION BY ...)
This shortening of the query is shown below:
*/

SELECT id,
       account_id,
       standard_qty,
       DENSE_RANK() OVER main_window AS dense_rank,
       SUM(standard_qty) OVER main_window AS sum_std_qty,
       COUNT(standard_qty) OVER main_window AS count_std_qty,
       AVG(standard_qty) OVER main_window AS avg_std_qty,
       MIN(standard_qty) OVER main_window AS min_std_qty,
       MAX(standard_qty) OVER main_window AS max_std_qty
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at));

-- 14. Quiz: Aliases for Multiple Window Functions

-- Original Query
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders;

-- Modified Query
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

-- 16. Video: Comparing a Row to a Previos Row
/*
If we have an ordered set of data, we can compare consecutive rows (compare a row
to one prior or one following it) using LAG() and LEAD().
LAG(column) returns the column shifted 1 index down, meaning that the first row
is empty then the following rows are 1 index below where they are in the original
column. i.e.
LAG(col) OVER (ORDER BY ...) AS lag
results in 'col' being shifted down 1 entry and being shown in order.
LEAD(column) returns the column shifted 1 index up, meaning that the last row is
empty and the previous rows are 1 index above where they are in the original
column. i.e.
LEAD(col) OVER (ORDER BY ...) AS lead
results in 'col' being shifted up 1 entry and being shown in order.
*/

-- LAG() example - Copied from lesson text
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag, -- Extracts lagging column in ASC order
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference -- Creates lagging difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
      ) sub; -- Subquery extracts total std_qty each account has purchased

-- LEAD() example - Copied from lesson text
SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead, -- Extracts leading column in ASC order
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference -- Creates leading difference
FROM (
	   SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
     ) sub; -- Subquery extracts total std_qty each account has purchased

-- 17. Quiz: Comparing a Row to Previous Row
/*
The LAG() and LEAD() functions are very useful when analyzing time-based data.
*/

SELECT occurred_at,
	   total_sum,
	   LEAD(total_sum) OVER (ORDER BY occurred_at) AS lead,
	   LEAD(total_sum) OVER (ORDER BY occurred_at) - total_sum AS lead_diff
FROM
	(
	SELECT occurred_at,
		   SUM(total_amt_usd) total_sum
	FROM orders
	GROUP BY occurred_at
	) AS tot_sum_by_date;

-- 19/20. Video: Intro to Percentiles/Percentiles
/*
If we want to split our data into n divisions, we can use the NTILE() function
to designate data into n buckets, 4 for quartiles, 5 for quintiles, and 100 for
percentiles.
i.e. NTILE(n) OVER (PARTITION BY col1 ORDER BY col2) AS 'n-tile'
will divide the data in 'col' into n buckets.
(NOTE:) If we're working with few rows (i.e. 5 rows), NTILE(100) will designate
the data into the 1st, 2nd, 3rd, 4th, and 5th percentile rather than 20th,
40th, 60th, 80th, and 100th percentiles as expected. NTILE(n) will allocate n buckets
and designate data into each bucket as necessary. If working with few rows,
make sure n is small to get reasonably interpretable results.
*/

-- 21. Quiz: Percentiles

SELECT account_id, occurred_at, standard_qty,
	   NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id;
-- We add the PARTITION BY clause to list from smallest qty to highest qty in each account_id,
-- otherwise it'd just be unordered data which isn't very insightful.

SELECT account_id, occurred_at, gloss_qty,
	   NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id;

SELECT account_id, occurred_at, total_amt_usd,
	   NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_usd_percentile
FROM orders
ORDER BY account_id;