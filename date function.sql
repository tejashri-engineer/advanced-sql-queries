--1)Compute days between start_date and end_date

drop table events;
CREATE TABLE events (
  event_id INT,
  start_date DATE,
  end_date DATE
);
INSERT INTO events VALUES (1,'2024-01-01','2024-01-10');

select * from events;
select 
	event_id,
	start_date,
	end_date,
	end_date - start_date as days_differeance,
	abs(start_date - end_date) as days_differeance1
from events;
-------------------------------------------------------------

---2) Calculate expiry_date by adding term_months to start_date
CREATE TABLE subscriptions (
  sub_id INT,
  start_date DATE,
  term_months INT
);
INSERT INTO subscriptions VALUES (1,'2024-01-15',6);

select * from subscriptions;
select 
	start_date,
	term_months,
	start_date +(term_months || 'months'):: interval as expiry_date 
from subscriptions;


SELECT 
  start_date,
  term_months,
  start_date + (INTERVAL '1 month' * term_months) AS expiry_date
FROM subscriptions;
-------------------------------------------------------------

--3)Return first day of sale month
drop table sales;
CREATE TABLE sales (
  sale_id INT,
  sale_date DATE
);
INSERT INTO sales VALUES (1,'2024-03-17');

select * from sales;

SELECT sale_id, date_trunc('month', sale_date)::DATE AS first_of_month FROM sales;

SELECT sale_id,
       TO_DATE(TO_CHAR(sale_date, 'YYYY-MM-01'), 'YYYY-MM-DD') AS first_of_month
FROM sales;

---------------------------------------------------
--4)Return last day of sale month
SELECT sale_id, (date_trunc('month', sale_date) + '1 month'::INTERVAL - '1 day'::INTERVAL)::DATE AS last_of_month FROM sales;

--5)Return weekday name of sale_date
SELECT sale_id, to_char(sale_date,'Day') AS weekday FROM sales;

--6)Extract year/month/day into columns
SELECT sale_id,
       EXTRACT(YEAR FROM sale_date) AS yr,
       EXTRACT(MONTH FROM sale_date) AS mon,
       EXTRACT(DAY FROM sale_date) AS dy,
       EXTRACT(WEEK FROM sale_date) AS week_no,
       EXTRACT(QUARTER FROM sale_date) AS qtr,
       TRIM(TO_CHAR(sale_date, 'Day')) AS weekday,
       EXTRACT(DOW FROM sale_date) as day_number
       FROM sales;

--7)Compute age in years
drop table peoples1;
CREATE TABLE peoples1 (person_id INT, birth DATE);
INSERT INTO peoples1 VALUES(1,'1990-06-15');

SELECT person_id, EXTRACT(YEAR FROM AGE(CURRENT_DATE,birth)) AS age FROM peoples1;

---8)Calculate business days between start_date and end_date, excluding weekends
SELECT event_id,
       SUM(CASE WHEN EXTRACT(DOW FROM d) NOT IN (0,6) THEN 1 ELSE 0 END) AS biz_days
FROM events,
LATERAL generate_series(start_date,end_date,'1 day') AS d
GROUP BY event_id;


