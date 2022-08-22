-- 2. Video: LEFT & RIGHT
/*
LEFT(col, num) pulls the __first__ 'num' characters of each row in the column
'col.'
RIGHT(col, num) pulls the __last__ 'num' characters of each row in the column
'col.'
LENGTH(col) returns the number of characters for each row in the column 'col.'
We can combine these functions by doing something like LEFT(col, LENGTH(col) - num)
to pull all the characters except for the last 'num' (or last 8, or whatever).
Note that we do LEFT(col, LENGTH(col) - num) not LEFT(col, LENGTH(col) + num), as
we'd then be returning the entire row entry of column 'col,' which is useless.
*/

-- 3. Quiz: LEFT & RIGHT

SELECT RIGHT(website, 3) web_address, 
	   COUNT(RIGHT(website, 3)) web_address_count
FROM accounts
GROUP BY web_address
ORDER BY web_address_count DESC;

SELECT LEFT(name, 1) name_first_char,
	   COUNT(LEFT(name, 1)) first_char_count
FROM accounts
GROUP BY name_first_char
ORDER BY first_char_count DESC;

WITH char_type_tbl AS
	(
	SELECT LEFT(name, 1) name_first_char,
		   COUNT(LEFT(name, 1)) first_char_count,
	CASE
		WHEN LEFT(name, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
		THEN 'NUM'
		ELSE 'LET'
	END AS char_type
	FROM accounts
	GROUP BY name_first_char
	)
SELECT char_type, SUM(first_char_count) occurrences
FROM char_type_tbl
GROUP BY char_type; -- 350/351 companies start with a letter

WITH char_type_tbl AS
	(
	SELECT LEFT(name, 1) name_first_char,
		   COUNT(LEFT(name, 1)) first_char_count,
	CASE
		WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u')
		THEN 'VOWEL'
		ELSE 'OTHER'
	END AS char_type
	FROM accounts
	GROUP BY accounts.name, name_first_char
	)
SELECT char_type, SUM(first_char_count) occurrences
FROM char_type_tbl
GROUP BY char_type; -- 80/351 companies start with a vowel


-- 5. Video: POSITION, STRPOS, & (SUBSTR?) (+ LOWER, UPPER)
/*
POSITION('char' IN col) returns position of the character 'char' in each row of
the column 'col.' As SQL is 1-indexed, if 'char' is in the first position, 1 will
be returned, and so on. If 'char' is __not__ in the row entry, 0 will be returned.
STRPOS(col, 'char') is the same as POSITION(), but with different syntax.
(NOTE): STRPOS() and POSITION() are both __case-sensitive__. If we just want a
letter's index, regardless if it's upper- or lower-case, use:
POSITION('char' IN LOWER(col)) or POSITION('CHAR' IN UPPER(col)), where CHAR is
an upper-case character.
*/

--6. Quiz: POSITION, STRPOS, & (SUBSTR?) (+ LOWER, UPPER)

SELECT primary_poc,
	   LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name, --Removing space from end of first name
	   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
FROM accounts;

SELECT name,
	   LEFT(name, POSITION(' ' IN name) - 1) first_name, --Removing space from end of first name
	   RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) last_name
FROM sales_reps;


-- 8. Video: CONCAT
/*
CONCAT(col1, 'separation1', col2, 'separation2', ...) concatenates strings in 
columns into 1 string in a new column, separating strings from different columns
by the corresponding 'separation'.
|| (Piping) serves the same purpose, and can be used as:
col1 || 'sep1' || col2 || 'sep2' || ...
*/

-- 9. Quiz: CONCAT

WITH first_last_name_tbl AS
	(
	SELECT name company_name, primary_poc,
		   LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name, --Removing space from end of first name
		   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
	FROM accounts acc
	)
SELECT first_name, last_name,
	   first_name || '.' || last_name || '@' || company_name || '.com' email
FROM first_last_name_tbl;

WITH first_last_name_tbl AS
	(
	SELECT name company_name, primary_poc,
		   LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name, --Removing space from end of first name
		   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
	FROM accounts acc
	)
SELECT first_name, last_name,
	   first_name || '.' || last_name || '@' || REPLACE(company_name, ' ', '') || '.com' email
	   -- REPLACE(content, initial text, target text) <-- fairly obvious command
FROM first_last_name_tbl;

WITH fn_fl AS
		(
		SELECT id, LOWER(LEFT(primary_poc, 1)) fnfl
		FROM accounts
		),
	 ln_fl AS
		(
		SELECT id, LOWER(LEFT(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)), 1)) lnfl
		FROM accounts
		),
	 fn_ll AS
		(
		SELECT id, RIGHT(LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1), 1) fnll
		FROM accounts
		),
	 ln_ll AS
		(
		SELECT id, RIGHT(primary_poc, 1) lnll
		FROM accounts
		),
	 fn_letters AS
		(
		SELECT id, LENGTH(LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1)) fn_letters
		FROM accounts
		),
	 ln_letters AS
		(
		SELECT id, LENGTH(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))) ln_letters
		FROM accounts
		),
	 company_name AS
		(
		SELECT id, REPLACE(UPPER(name), ' ', '') company_name
		FROM accounts
		)
SELECT fn_fl.id, acc.primary_poc,
	   fnfl || fnll || lnfl || lnll || fn_letters || ln_letters || company_name InitialPw
FROM fn_fl
JOIN fn_ll
ON fn_fl.id = fn_ll.id
JOIN ln_fl
ON fn_fl.id = ln_fl.id
JOIN ln_ll
ON fn_fl.id = ln_ll.id
JOIN accounts acc
ON fn_fl.id = acc.id
JOIN fn_letters
ON fn_fl.id = fn_letters.id
JOIN ln_letters
ON fn_fl.id = ln_letters.id
JOIN company_name
ON fn_fl.id = company_name.id;

-- 11. Video: CAST
/*
TO_DATE(time, 'time') will convert string formatted date data into a numeric
formatted date data so it can be concatenated more easily for analysis.
Read more here: https://www.techonthenet.com/oracle/functions/to_date.php
CAST casts a column from 1 data type to another. In this case, it can cast
a string column into a date column with the following:
CAST(date_column_in_string_format AS DATE)
Other types of casting: https://www.postgresqltutorial.com/postgresql-cast/.
We can also use the following double colon notation (::) to cast instead:
date_column_in_string_format::DATE
Most functions in this lesson are string-specific, so using them will treat/cast
the data to a string format. Some examples are LEFT() and RIGHT. For more string
functions, read here: https://www.postgresql.org/docs/9.1/functions-string.html.
*/

-- 14. Video: COALESCE ******REVISIT******
/*
COALESCE returns the first non-NULL value passed for each row. <-- What does this mean? idk
COALESCE(col, val) makes NULL values in column 'col' have a value of 'val.'
Substituting 'val' for NULL in a column has effects on functions that handle
NULLs differently, particularly COUNT() and AVG(), since setting a value 'val'
instead of NULL makes it impact the COUNT() and contribute to the AVG().
*/

-- 15. Quiz: COALESCE

SELECT a.*, COALESCE(o.id, a.id) AS order_id,
	   COALESCE(o.account_id, a.id) AS order_acc_id,
	   COALESCE(o.standard_qty, 0) std_qty,
	   COALESCE(o.gloss_qty, 0) gloss_qty, 
	   COALESCE(o.poster_qty, 0) poster_qty,
	   COALESCE(o.total, 0) total_qty,
	   COALESCE(o.standard_amt_usd, 0) std_amt_usd, 
	   COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd, 
	   COALESCE(o.poster_amt_usd, 0) poster_amt_usd,
	   COALESCE(o.total_amt_usd, 0) total_amt_usd  
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COUNT(o.id)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id; -- 6912

WITH mod_tbl AS
		(
		SELECT a.*, COALESCE(o.id, a.id) AS order_id,
			   COALESCE(o.account_id, a.id) AS order_acc_id,
			   COALESCE(o.standard_qty, 0) std_qty,
			   COALESCE(o.gloss_qty, 0) gloss_qty, 
			   COALESCE(o.poster_qty, 0) poster_qty,
			   COALESCE(o.total, 0) total_qty,
			   COALESCE(o.standard_amt_usd, 0) std_amt_usd, 
			   COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd, 
			   COALESCE(o.poster_amt_usd, 0) poster_amt_usd,
			   COALESCE(o.total_amt_usd, 0) total_amt_usd  
		FROM accounts a
		LEFT JOIN orders o
		ON a.id = o.account_id
		)
SELECT COUNT(*)
FROM mod_tbl; -- 6913
-- Therefore the 1 record with NULL order data got modified and added to the count.

-- Video + Text: Recap
/*
SQL NULL functions (we used COALESCE(), other editors will use other functions):
https://www.w3schools.com/sql/sql_isnull.asp
SQL string functions (LEFT, RIGHT, LENGTH, TRIM, POSITION, STRPOS, SUBSTR,
CONCAT, UPPER, LOWER), manipulating improperly formatted dates to properly formatted
dates using string functions:
https://mode.com/sql-tutorial/sql-string-functions-for-cleaning/
*/