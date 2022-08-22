/*
49. Text: Recap & Looking Ahead
(GOOD RESOURCE FOR COLLECTING INFORMATION FOR RECAPPING LATER!)
*/

-- 19. Quiz: ORDER BY single condition
/*
Key notes:
	Every statement (correct SQL piece of code) has to start with "SELECT"
	Keywords (SELECT, FROM, ORDER BY, LIMIT) all should be capitalized to differentiate keywords from query lingo
	Try to separate lines with different keywords to make code more readable
	End queries with a semicolon
*/
/*
Tips:
SELECT (column name(s)) (use * to extract all columns, i.e.: SELECT * FROM orders LIMIT 10;)
FROM (table name)
ORDER BY (column to use as order ascending-wise) (adding DESC to the end makes it descending)
LIMIT (first x rows to be displayed, shows all rows if x > number of rows)

SELECT goes first
FROM usually comes next
ORDER BY comes after them, but before limit
LIMIT is often the last statement
*/

SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

-- 22. Quiz: ORDER BY multiple cond's
/*
ORDER BY col1, col2 DESC (Sorts first by
col1, then within repeating content of col1, 
it sorts decsending over contents of col2)
(NOTE:) If col1 items are unique, it may appear
that col2 is not impacting the secondary sort condition.
*/

SELECT id, account_id, total_amt_usd --Show these columns
FROM orders --from this table
ORDER BY account_id, total_amt_usd DESC; --First sort (asc) by acc_id then desc by $

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;

/*
Q: Compare the results of these two queries above. How are the results different when
you switch the column you sort on first?
A: Since the first one has repeating id's, we sort by most expensive to least expensive
purchases of 1 customer; second one has basically unique $ spent, so it's essentially
just sorted in descending order by amount of money spent on the particular purchase
*/

--25. Quiz: WHERE with numerics
/*
WHERE argument (comparison operator) value (allows for comparisons, essentially a filter for results)
WHERE comes after "from", but before "order by"
list of comparison operators, separated by commas: >, <, >=, <=, =, !=
*/

SELECT * --Extract all col's
FROM orders --from this table
WHERE gloss_amt_usd >= 1000 --filter to only show this much spent
LIMIT 5; --show only first 5 rows that meet criteria

SELECT *
FROM orders
WHERE total_amt_usd < 500 --filter to only show less than this much spent
LIMIT 10;

--28. Quiz: WHERE with non-numerics
/*
(WHERE with non-numeric data):
WHERE arg (comparison operator) 'value' (same as WHERE above, but non-numeric dtypes)
(Don't forget to put the 'value' in single quotations, otherwise it's interpreted as a col)
(We'll later see the following operators: LIKE, NOT, IN).
*/

SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil'; --filtering to make sure name parameter is exactly 'Exxon Mobil'.
-- I'm not sure whether the value in '' is case-sensitive or insensitive

-- 31. Quiz: Arithmetic ops
/*
Creating a new column that is a "combination"/function of existing columns is a derived/"calculated"/"computed" column.
When you make a derived column, give it an "alias" or name using the keyword AS, 
but make sure derived column names follow normal standards (no capitals, spaces, and descriptive).
The derived column is only temporary, and exists only during the time you query it, disappearing next query.
We can use normal arithmetic operators: +, -, *, /
FOLLOW BEDMAS/PEMDAS!
*/

SELECT id, account_id, standard_amt_usd/standard_qty AS std_unit_price_usd
--Line above makes a derived column as the 3rd col and gives it a descriptive name
FROM orders
LIMIT 10;

SELECT id, account_id, (poster_amt_usd)/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS pct_rev_from_poster
FROM orders
LIMIT 10;

--33. Intro to Logic Operators
/*
A few logical operators:
1. LIKE (similar to using WHERE val = arg, but you don't know EXACTLY what you're looking for)
2. IN (basically WHERE val = arg, but for multiple args)
3. NOT (used as NOT IN or NOT LIKE to remove a certain condition)
4. AND & BETWEEN allow combination of operations where all combined conditions must be true
(Note: idk if AND & BETWEEN is 1 statement, or AND is a statement, same with BETWEEN, and &)
5. OR allows combination of operations where at least 1 of the combined conditions is/are true
*/

--35. Quiz: LIKE
/*
LIKE is useful for working with non-numerics, often text.
LIKE is used in conjuction with WHERE, i.e. WHERE arg LIKE 'something'
LIKE often used with wildcard characters (like %, which allows any number of
characters to be to either the left or right of what preceeds or succeeds it. i.e. next example)
LIKE operator needs single quotes to pass. Also, searching for 'T' is different from searching for 't'.
*/

SELECT name
FROM accounts
WHERE name LIKE 'C%'; --starts with 'C'

SELECT name
FROM accounts
WHERE name LIKE '%one%'; --has 'one' anywhere

SELECT name
FROM accounts
WHERE name LIKE '%s'; --ends with 's'

--38. Quiz: IN
/*
IN useful for working w/ both numeric and text dtypes
IN allows for use of = operator w/ multiple conditions (multiple items of a column) i.e. (i, j, k, l, ...) in brackets
IN is a cleaner way of expressing some operations that can be performed with OR (coming up later)
*/
/*
TIP:
In most SQL environments, use of single or double quotation marks is permitted, but sometimes
required to use double quotations if an apostrophe is included within arg, i.e. "Lowe's"
In some environments, the apostrophe can be simulated by 2 single quotes, i.e. 'Lowe''s'
*/

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');

--41. Quiz: NOT
/*
NOT is useful when working with IN and LIKE to get the results which do not match the condition
*/

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords');

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%'; --do not start with 'C'

SELECT name
FROM accounts
WHERE name NOT LIKE '%one%'; --does not have 'one' anywhere

SELECT name
FROM accounts
WHERE name NOT LIKE '%s'; --do not end with 's'

--44. Quiz: AND and BETWEEN
/*
AND operator is used inside WHERE statement to filter multiple criteria (use multiple logical clauses/statements in one query)
AND operator can link as many logical statements (include LIKE, IN, NOT) as needed, or even arithmetic operators (+,*,-,/)
Unlike python, we cannot do val1 <= arg < val2, but must instead do val1 <= arg AND arg < val2, or arg BETWEEN val1 AND val2
BETWEEN can be used to replace AND sometimes, i.e. using same feature (column) for different parts of AND statement
(NOTE:) BETWEEN operator includes endpoints
(NOTE:) BETWEEN includes date endpoints at 00:00:00 (midnight)
*/

SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s'; --all company names that end with 's' but don't start with 'C'

SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29; --BETWEEN operator is endpoint-inclusive

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01 00:00:00' AND '2016-12-31 23:59:59' --displaying all data in 2016
--Could do the second condition as occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

--47. Quiz: OR
/*
OR is an inclusive 'or' operator
Does what you expect it to do... it's an inclusive 'or' operator, use parentheses when needed
*/

SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

SELECT *
FROM orders
WHERE (standard_qty = 0) AND ((gloss_qty > 1000) OR (poster_qty > 1000));

SELECT primary_poc
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') AND (((primary_poc LIKE '%ana%') OR (primary_poc LIKE '%Ana%')) AND (primary_poc NOT LIKE '%eana%'));
--Note: question was ambiguous with the final "and," so I didn't program it exactly as intended but it got the job done
/*
Here's the quiz solution with good formatting:
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') 
           AND primary_poc NOT LIKE '%eana%');
*/

/*
49. Text: Recap & Looking Ahead
(GOOD RESOURCE FOR COLLECTING INFORMATION FOR RECAPPING LATER!)
*/