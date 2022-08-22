/*
PK = Primary Key; usually id.
FK = Foreign Key; refers to PK of another table (usually anotherTable_id).
Relational database implies that we have relationships between the different
tables, meaning that we can have a diverse row-column structure for the
different types of data in various tables to solve many problems.
The reason we might need different tables is because different objects can
exist but have a relation (i.e. orders & accounts for PandP). Accounts are
bound to change over time (domain change, logo change, etc...), whereas
orders can change when they're being set, but not after they've been set, 
as they then become static. These 2 objects operate differently so they
are placed in different tables. If we instead included the accounts
table as additional rows in the orders table, we'd have to change every
row pertaining to an account when that account holder changes their domain, 
name, etc... rather than changing 1 field in the accounts table. (Look at
Database normalization article in reading list or video two's text).
Multi-table structure allows queries to run quicker.
*/

---4. Text + Quiz: JOIN and ON
/*
JOIN allows us to pull data from multiple tables in a single query
ON allows us to combine the table in FROM and JOIN statements using a logical
statement, thus specifying a relationship between the 2 tables.
*/

SELECT orders.* --SELECT all columns from "orders" table
FROM orders
JOIN accounts --JOIN the "accounts" table into the query
ON orders.account_id = accounts.id; --Specify the relationship between the 2 tables.
--ON clause tells the query which column to use to merge the 2 tables together
--"ON statement holds the two columns that get linked across the two tables"

/*
To select individual columns from a specific table referenced in the query, use
the following notation:
SELECT table1.col1, table2.col2, table2.col3(, etc...) (NOTE: table before period before column)
*/

--The following query pulls name and date columns from respective tables
SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON accounts.id = orders.account_id; --(NOTE: is the order of which reference goes first irrelevant?)
--i.e. ^ is the same as orders.account_id = accounts.id?

--The following query pulls ALL columns from both tables
SELECT accounts.*, orders.* --alternatively SELECT *
FROM accounts JOIN orders --alternatively FROM orders JOIN accounts
ON accounts.id = orders.account_id; --alternatively ON orders.account_id = accounts.id

--Exercises:
SELECT *
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

SELECT orders.standard_qty, orders.gloss_qty, orders.poster_qty
		, accounts.website, accounts.primary_poc
FROM orders JOIN accounts
ON accounts.id = orders.account_id;

--7. Text: PK & FK
/*
Primary Key (PK): unique column in 1 table, commonly the 1st column
Foreign Key (FK): column in 1 table, that is a PK in a different table
PK-FK Link: line between PK and FK; crow's foot means FK can appear in multiple rows of its respective
table, and cross/single-line towards PK means it only shows up only once per row in corresponding table
*/

--10. Video: Alias
/*
An alias/alternate name can be given to a table or column using an AS statement, or
putting a space between the table/col then listing the alias name.
*/

--From last example:

SELECT o.standard_qty AS std, o.gloss_qty AS gl, o.poster_qty AS pstr
		, acc.website AS web, acc.primary_poc AS poc --col aliasing
FROM orders AS o JOIN accounts AS acc --table aliasing
ON acc.id = o.account_id;
--Or could be done as: (space, not AS statement)
SELECT o.standard_qty std, o.gloss_qty gl, o.poster_qty pstr
		, acc.website web, acc.primary_poc poc
FROM orders o JOIN accounts acc
ON acc.id = o.account_id;

--11. JOIN Questions Pt. 1

SELECT acc.primary_poc, we.occurred_at, we.channel,
	   acc.name = 'Walmart' AS is_walmart			-- Boolean col, showing "true" if account from Walmart 
FROM web_events we
JOIN accounts acc
ON we.account_id = acc.id
WHERE acc.name = 'Walmart';

SELECT reg.name, srep.name, acc.name
FROM region reg
JOIN sales_reps srep
ON srep.region_id = reg.id
JOIN accounts acc
ON acc.sales_rep_id = srep.id
ORDER BY acc.name;

SELECT reg.name, acc.name,
	   o.standard_amt_usd/(o.total + .001) AS unit_price
FROM orders o
JOIN accounts acc
ON o.account_id = acc.id
JOIN sales_reps srep
ON acc.sales_rep_id = srep.id
JOIN region reg
ON srep.region_id = reg.id;

--14. Video: LEFT and RIGHT JOINs
/*
Inner joins (only returns rows that appear in both tables), which is what we've been doing using JOIN.
Outer joins have at least as many rows as inner joins, with additional ones if there are non-overlapping rows.
In a query, the table in the FROM clause is the left table, and the one in the JOIN clause is the right table.
A LEFT JOIN results in all rows that would be in a normal inner join + additional rows in the left table.
Similarly with a RIGHT JOIN. If there isn't matching info in JOINed tables, some columns will have NULL entries.
NULL data type is discussed next lesson. We usually write LEFT JOINs in the real world, rarely RIGHT JOINs
*/

/*
Note for "different syntax":
INNER JOIN (is the same as) JOIN
LEFT OUTER JOIN (is the same as) LEFT JOIN
RIGHT OUTER JOIN (is the same as) RIGHT JOIN
FULL OUTER JOIN (is the same as) OUTER JOIN
*/

--18. Video: JOINs and Filtering
/*
Logic in the ON clause reduces the rows __before__ combining the tables.
Logic in the WHERE clause occurrs __after__ the JOIN occurs.
Moving logic from the WHERE to the ON clause pre-filters the right table (before the JOIN is executed)
(essentially acting as  WHERE clause that runs before the JOIN rather than after)
and allows for rows with some missing data to be shown, which can later be used in data aggregation.
(SUMMARY: Including logic in the ON clause instead of the WHERE clause filters data
before the JOIN rather than after. Can be thought of joining on an already-filtered table
rather than joining then filtering, which would eliminate some rows).
*/

--19. Quiz: JOIN Questions Pt. 2 (Last Check)

SELECT reg.name AS reg_name, srep.name AS rep_name, acc.name AS acc_name
FROM accounts AS acc
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id AND reg.name = 'Midwest'
ORDER BY acc_name;

--Same as query above, but first name starts with 'S'
SELECT reg.name AS reg_name, srep.name AS rep_name, acc.name AS acc_name
FROM accounts AS acc
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id AND reg.name = 'Midwest' AND srep.name LIKE 'S%'
ORDER BY acc_name;

--Same as query above, but (last) name starts with 'K'
SELECT reg.name AS reg_name, srep.name AS rep_name, acc.name AS acc_name
FROM accounts AS acc
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id AND reg.name = 'Midwest' AND srep.name LIKE '% K%'
ORDER BY acc_name;

SELECT reg.name AS reg_name, acc.name AS acc_name, ord.total_amt_usd/(ord.total + .01) AS unit_price
FROM accounts AS acc
JOIN orders AS ord
ON acc.id = ord.account_id AND ord.standard_qty > 100
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id;

--Same as query above, but add poster order quantity > 50 and sort by ascending unit price
SELECT reg.name AS reg_name, acc.name AS acc_name, ord.total_amt_usd/(ord.total + .01) AS unit_price
FROM accounts AS acc
JOIN orders AS ord
ON acc.id = ord.account_id AND ord.standard_qty > 100 AND ord.poster_qty > 50
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id
ORDER BY unit_price;

--Same as query above, but sort by descending unit price
SELECT reg.name AS reg_name, acc.name AS acc_name, ord.total_amt_usd/(ord.total + .01) AS unit_price
FROM accounts AS acc
JOIN orders AS ord
ON acc.id = ord.account_id AND ord.standard_qty > 100 AND ord.poster_qty > 50
JOIN sales_reps AS srep
ON acc.sales_rep_id = srep.id
JOIN region AS reg
ON srep.region_id = reg.id
ORDER BY unit_price DESC;

SELECT DISTINCT we.channel, acc.name AS acc_name
FROM web_events AS we
JOIN accounts AS acc
ON we.account_id = acc.id AND acc.id = 1001;

SELECT ord.occurred_at, acc.name AS acc_name, ord.total, ord.total_amt_usd
FROM orders AS ord
JOIN accounts AS acc
ON ord.account_id = acc.id AND ord.occurred_at BETWEEN '2015-1-1' AND '2015-12-31';

--21. Text: Recap & Looking Ahead
/*
Mentions PK, FK, INNER JOIN, LEFT and RIGHT JOINs.
Advanced but useful JOINs we didn't discuss: UNION and UNION ALL, CROSS JOIN, and the tricky SELF JOIN.

*/


