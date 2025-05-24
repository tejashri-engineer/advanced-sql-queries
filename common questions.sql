
----1)Get the top earner in each department.
CREATE TABLE employees (
  emp_id INT,
  emp_name VARCHAR(100),
  salary INT,
  department VARCHAR(100)
);

INSERT INTO employees VALUES
(1, 'Alice', 6000, 'HR'),
(2, 'Bob', 8000, 'HR'),
(3, 'Charlie', 7000, 'IT'),
(4, 'David', 9000, 'IT'),
(5, 'Eve', 7500, 'Finance'),
(6, 'Frank', 5000, 'Finance');

select * from employees;
select
max(salary) as max_salary ,
department
from employees
group by department;

select * from (
select
department,
salary ,
row_number() over(partition by department order by salary desc) as rnk
from employees)
where rnk = 1 ;
----------------------------------------------------------------------------
--2)Calculate cumulative sales by date.
drop table sales;
CREATE TABLE sales (
  sale_id INT,
  sale_date DATE,
  amount INT
);

INSERT INTO sales VALUES
(1, '2023-01-01', 100),
(2, '2023-01-02', 150),
(3, '2023-01-03', 200);

select * from sales;
select 
sale_date,
amount,
sum(amount) over (order by sale_date) as running_total
from sales;

----------------------------------------------------------------
--3)Identify gaps in attendance dates.
CREATE TABLE attendance (
  emp_id INT,
  att_date DATE
);

INSERT INTO attendance VALUES
(1, '2023-01-01'),
(1, '2023-01-02'),
(1, '2023-01-04');


select * from attendance;
select 
emp_id,
att_date,
att_date - lag(att_date) over (order by att_date) as gap
from attendance;
----------------------------------------------------------------
--4)Get age in years

CREATE TABLE peoples (
  person_id INT,
  name VARCHAR(100),
  birth_date DATE
);

INSERT INTO peoples VALUES
(1, 'John', '1990-01-01'),
(2, 'Jane', '1985-05-20');


select * from peoples;
select 
person_id,
name,
birth_date,
extract(year from age(current_date, birth_date)) as years
from peoples;

----------------------------------------------------------------------
--5)Identify customers with more than 1 order.
 drop table orders;
CREATE TABLE orders (
  order_id INT,
  customer_id INT,
  order_date DATE
);

INSERT INTO orders VALUES
(1, 100, '2023-01-01'),
(2, 100, '2023-01-02'),
(3, 101, '2023-01-03');


select * from orders;
select customer_id,
count(*)
from orders 
group by 1
having count(*)>1;

---------------------------------------------------------------------
--6)Find employees hired before their manager.

CREATE TABLE emp_mgr (
  emp_id INT,
  emp_name VARCHAR(100),
  manager_id INT,
  hire_date DATE
);

INSERT INTO emp_mgr VALUES
(1, 'John', NULL, '2020-01-01'),
(2, 'Amy', 1, '2021-01-01'),
(3, 'Bob', 1, '2019-01-01');

select * from emp_mgr;

select e1.emp_name, e1.hire_date,e2.emp_name as manager_name,e2.hire_date  as manager_hire_date from emp_mgr e1
join emp_mgr e2 on e1.manager_id = e2.emp_id
where e1.hire_date < e2.hire_date;

---------------------------------------------------------------

--7)Identify breaks in login streaks.
drop table logins;
CREATE TABLE logins (
  user_id INT,
  login_date DATE
);

INSERT INTO logins VALUES
(1, '2023-01-01'),
(1, '2023-01-02'),
(1, '2023-01-04');


select * from logins;
SELECT user_id,
       login_date,
       login_date - (ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date))::INT AS grp
FROM logins;
--------------------------------------------------------------------------

--8)Show each category's contribution % to total.

CREATE TABLE category_sales (
  category VARCHAR(100),
  amount INT
);

INSERT INTO category_sales VALUES
('A', 100), ('B', 200), ('C', 700);


select * from category_sales;
select 
category,
amount,
sum(amount) as total,
round(amount * 100/ sum(amount) over (),2) as total1
from category_sales
group by 1, 2
order by total1 ;


SELECT category,
       amount,
       ROUND(100.0 * amount / SUM(amount) OVER (), 2) AS pct_of_total
FROM category_sales;


---------------------------------------------------------------------

--9) Get the price applicable to each transaction.

CREATE TABLE prices (
  product_id INT,
  start_date DATE,
  end_date DATE,
  price INT
);

CREATE TABLE sales_txn (
  product_id INT,
  txn_date DATE
);

INSERT INTO prices VALUES
(1, '2023-01-01', '2023-01-15', 100),
(1, '2023-01-16', '2023-01-31', 120);

INSERT INTO sales_txn VALUES
(1, '2023-01-10'),
(1, '2023-01-18');


select * from prices;
select * from sales_txn;

select  s.product_id, s.txn_date, p.price
from prices p
join sales_txn s on p.product_id = s.product_id;-----na

SELECT s.product_id, s.txn_date, p.price
FROM sales_txn s
JOIN prices p
  ON s.product_id = p.product_id
 AND s.txn_date BETWEEN p.start_date AND p.end_date;



---------------------------------------------------------

--10)Pivot the subject scores into columns.

CREATE TABLE scores (
  student VARCHAR(100),
  subject VARCHAR(50),
  marks INT
);

INSERT INTO scores VALUES
('John', 'Math', 90),
('John', 'Science', 85),
('Jane', 'Math', 95),
('Jane', 'Science', 80);

select * from scores;

SELECT student,
       MAX(marks) FILTER (WHERE subject = 'Math') AS math_score,
       MAX(marks) FILTER (WHERE subject = 'Science') AS science_score
FROM scores
GROUP BY student;

--------------------------------------------------------------------
--11)Find top 2 salaries per department.

drop table employees;
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees VALUES
(1, 'John', 'HR', 60000),
(2, 'Sara', 'HR', 55000),
(3, 'Mike', 'IT', 80000),
(4, 'Tom', 'IT', 75000),
(5, 'Emma', 'IT', 72000),
(6, 'Bob', 'Sales', 50000);

select * from employees;

with cte as (
select 
emp_name,
department,
salary,
row_number () over (partition by department order by salary desc) as rnk
from employees)
select * from 
cte where rnk <=2;

-------------------------------------------------------------------------

--12) Find customers who have placed orders on consecutive days.

drop table orders;
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders VALUES
(1, 101, '2024-01-01', 100),
(2, 101, '2024-01-02', 200),
(3, 102, '2024-01-01', 300),
(4, 101, '2024-01-10', 150);

select * from orders;

select * from (
SELECT customer_id, order_date,
       LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order
FROM orders)
WHERE next_order = order_date + INTERVAL '1 day';


-----------------------------------------------------------------

---13)Find employees who share the same salary within the same department.

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees VALUES
(1, 'John', 'HR', 60000),
(2, 'Sara', 'HR', 55000),
(3, 'Mike', 'IT', 80000),
(4, 'Tom', 'IT', 75000),
(5, 'Emma', 'IT', 72000),
(6, 'Bob', 'Sales', 50000);

select * from employees;

select e1.* from employees e1
join employees e2 on e1.emp_id  = e2.emp_id
and e1.salary = e2.salary
having count(*) >1;

/*WITH cte AS (
    SELECT 
        dept_id,
        salary
    FROM emp_salary 
    GROUP BY dept_id, salary
    HAVING COUNT(*) > 1
)
SELECT e1.* 
FROM emp_salary e1
INNER JOIN cte e2 
  ON e1.dept_id = e2.dept_id;*/
  
  SELECT e.*
FROM employees e
JOIN (
    SELECT department, salary
    FROM employees
    GROUP BY department, salary
    HAVING COUNT(*) > 1
) dup ON e.department = dup.department AND e.salary = dup.salary;

----------------------------------------------------------------------------------
--14)Pivot sales into columns (one row per emp_id).
drop table sales;
CREATE TABLE sales (
    emp_id INT,
    month VARCHAR(10),
    amount INT
);

INSERT INTO sales VALUES
(1, 'Jan', 100), (1, 'Feb', 200), (1, 'Mar', 150),
(2, 'Jan', 300), (2, 'Feb', 100), (2, 'Mar', 250);

select * from sales;
SELECT emp_id,
    SUM(amount) FILTER (WHERE month = 'Jan') AS Jan,
    SUM(amount) FILTER (WHERE month = 'Feb') AS Feb,
    SUM(amount) FILTER (WHERE month = 'Mar') AS Mar
FROM sales
GROUP BY emp_id;
----------------------------------------------------------------
--15)Find customers who placed more than one order on the same day.
drop table orders;
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders VALUES
(1, 101, '2024-01-01', 100),
(2, 101, '2024-01-01', 200),
(3, 102, '2024-01-01', 300),
(4, 101, '2024-01-02', 150),
(5, 102, '2024-01-02', 400);

select * from orders;
select 
order_date,
customer_id,
count(*) as cnt
from orders
group by 1,2
having count(*)>1;
------------------------------------------------------------------
--16)Show employees earning more than their department’s average.
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees VALUES
(1, 'John', 'HR', 60000),
(2, 'Sara', 'HR', 55000),
(3, 'Mike', 'IT', 80000),
(4, 'Tom', 'IT', 75000),
(5, 'Emma', 'IT', 72000),
(6, 'Bob', 'Sales', 50000);

select * from employees;

select 
* from employees e
join (
select
department,
avg(salary) as avg_salary 
from employees
group by 1)b
on e.department = b.department
where e.salary >b.avg_salary;

-----------------------------------------------------------------------\

--17)Find employee(s) with the highest salary in each department.
select * from employees;
select * from (
select 
department,
salary,
row_number () over (partition by department order by salary desc) as rnk 
from employees)
where rnk = 1;

----------------------------------------------------------------------------

--18)For each customer, find the number of days between their first and last order.

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders VALUES
(1, 101, '2024-01-01', 100),
(2, 101, '2024-01-01', 200),
(3, 102, '2024-01-01', 300),
(4, 101, '2024-01-02', 150),
(5, 102, '2024-01-02', 400);

select * from orders;

SELECT customer_id,
       MAX(order_date) - MIN(order_date) AS days_between
FROM orders
GROUP BY customer_id;

-------------------------------------------------------------------
--19)Find employees who have never made a sale.

drop table sales;
CREATE TABLE employees (
  emp_id INT,
  emp_name VARCHAR(50)
);

CREATE TABLE sales (
  sale_id INT,
  emp_id INT,
  amount DECIMAL
);

INSERT INTO employees VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie');
INSERT INTO sales VALUES (101, 1, 500), (102, 1, 300);

select * from employees;
select * from sales;

select *
from employees e
left join sales s on e.emp_id = s.emp_id
where sale_id is null;

-------------------------------------------------------------------------------
--20)Find customers with more than 1 order and no returns.

drop table returns;
CREATE TABLE customers (
  customer_id INT,
  name VARCHAR(50)
);

CREATE TABLE orders (
  order_id INT,
  customer_id INT
);

CREATE TABLE returns (
  return_id INT,
  order_id INT
);

INSERT INTO customers VALUES (1, 'Alice'), (2, 'Bob');
INSERT INTO orders VALUES (101, 1), (102, 1), (103, 2);
INSERT INTO returns VALUES (201, 103);


select * from customers;
select * from orders;
select * from returns;

select c.customer_id,c.name
from customers c 
join orders o on c.customer_id = o.customer_id
left join returns r on o.order_id = r.order_id
group by c.customer_id,c.name,r.return_id
having count(o.order_id) > 1 and r.return_id is null 


SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.order_id) > 1 AND COUNT(r.return_id) = 0;

--------------------------------------------------------------------------------

--21)Find top selling product (by amount) per region.
CREATE TABLE regions (
  region_id INT,
  region_name VARCHAR(50)
);

drop table products;
CREATE TABLE products (
  product_id INT,
  product_name VARCHAR(50)
);

CREATE TABLE sales_region (
  sale_id INT,
  product_id INT,
  region_id INT,
  amount DECIMAL
);

INSERT INTO regions VALUES (1, 'North'), (2, 'South');
INSERT INTO products VALUES (10, 'A'), (20, 'B');
INSERT INTO sales_region VALUES (1, 10, 1, 500), (2, 10, 1, 200), (3, 20, 1, 600), (4, 10, 2, 300);

select * from regions;
select * from products;
select * from sales_region;


WITH ranked_sales AS (
  SELECT sr.region_id, sr.product_id, SUM(sr.amount) AS total_sales,
         RANK() OVER (PARTITION BY sr.region_id ORDER BY SUM(sr.amount) DESC) AS rnk
  FROM sales_region sr
  GROUP BY sr.region_id, sr.product_id
)
SELECT rs.region_id, rs.product_id, rs.total_sales
FROM ranked_sales rs
WHERE rs.rnk = 1;

-----------------------------------------------------------------
--22)Users Who Liked and Commented but Never Posted
drop table users;
CREATE TABLE users (
  user_id INT,
  name VARCHAR(50)
);

CREATE TABLE posts (
  post_id INT,
  user_id INT
);

CREATE TABLE likes (
  like_id INT,
  user_id INT
);

CREATE TABLE comments (
  comment_id INT,
  user_id INT
);

INSERT INTO users VALUES (1, 'Tom'), (2, 'Jerry'), (3, 'Spike');
INSERT INTO likes VALUES (1, 1), (2, 2);
INSERT INTO comments VALUES (1, 1), (2, 2);
INSERT INTO posts VALUES (1, 3);


select * from users;
select * from likes;
select * from comments;
select * from posts;


SELECT *
FROM users u
JOIN likes l ON u.user_id = l.user_id
JOIN comments c ON u.user_id = c.user_id
LEFT JOIN posts p ON u.user_id = p.user_id
WHERE p.user_id IS null

------------------------------------------------------------------------------

--23)Invoices Without Payments

CREATE TABLE invoices (
  invoice_id INT,
  invoice_date DATE
);

drop table payments;
CREATE TABLE payments (
  payment_id INT,
  invoice_id INT,
  amount DECIMAL
);
INSERT INTO invoices VALUES (100, '2023-01-01'), (101, '2023-01-05');
INSERT INTO payments VALUES (201, 100, 100);

select * from invoices;
select * from  payments;

select * 
from invoices i
left join payments p on i.invoice_id = p.invoice_id
where p.invoice_id is null;

------------------------------------------------------------------------
--24) First and Last Login per User
drop table logins;
CREATE TABLE logins (
  user_id INT,
  login_time TIMESTAMP
);
INSERT INTO logins VALUES
  (1, '2023-01-01 08:00'), (1, '2023-01-02 09:00'),
  (2, '2023-01-01 10:00');

select * from logins;

select 
user_id,
max(login_time) as last_login,
min(login_time) as first_login
from logins
group by 1;

SELECT user_id,
       MIN(login_time) AS first_login,
       MAX(login_time) AS last_login
FROM logins
GROUP BY user_id;

------------------------------------------------------------------

---25) Students Enrolled in All Courses
drop table enrollments;
CREATE TABLE students (
  student_id INT
);
CREATE TABLE courses (
  course_id INT
);
CREATE TABLE enrollments (
  student_id INT,
  course_id INT
);
INSERT INTO students VALUES (1), (2);
INSERT INTO courses VALUES (10), (20);
INSERT INTO enrollments VALUES (1, 10), (1, 20), (2, 10);

select * from students;
select * from courses;
select * from enrollments;

SELECT student_id
FROM enrollments
GROUP BY student_id
HAVING COUNT(DISTINCT course_id) = (SELECT COUNT(*) FROM courses);

SELECT e.student_id
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY e.student_id
HAVING COUNT(DISTINCT e.course_id) = (SELECT COUNT(*) FROM courses);

----------------------------------------------------------------------------

--26) Find orders without any audit entries

CREATE TABLE orders_audit (
  order_id INT,
  status VARCHAR(20)
);
CREATE TABLE orders_main (
  order_id INT,
  total DECIMAL
);
INSERT INTO orders_main VALUES (1,100), (2,200);
INSERT INTO orders_audit VALUES (1,'CREATED'), (1,'PAID');

select * from orders_audit;
select * from orders_main;

select * 
from orders_main om
left join orders_audit oa on om.order_id = oa.order_id
where oa.order_id is null;

------------------------------------------------------------------

--27 Overlapping Room Bookings
drop table bookings;
CREATE TABLE bookings (
  booking_id INT,
  room_id INT,
  start_time TIMESTAMP,
  end_time TIMESTAMP
);
INSERT INTO bookings VALUES
  (1,101,'2023-01-01 10:00','2023-01-01 12:00'),
  (2,101,'2023-01-01 11:00','2023-01-01 13:00');

-- Solution:
SELECT b1.booking_id, b2.booking_id,b1.start_time,b2.start_time,b1.end_time,b2.end_time
FROM bookings b1
JOIN bookings b2 ON b1.room_id = b2.room_id
  AND b1.booking_id < b2.booking_id
  AND b1.start_time < b2.end_time
  AND b2.start_time < b1.end_time;

---------------------------------------------------------------------------------

--28 Pair of Products Bought Together Most Frequently

CREATE TABLE orders_items (
  order_id INT,
  product_id INT
);
INSERT INTO orders_items VALUES
  (1,10),(1,20),(2,10),(2,20),(2,30);
-- Solution:
SELECT oi1.product_id AS prod_a, oi2.product_id AS prod_b, COUNT(*) AS pair_count
FROM orders_items oi1
JOIN orders_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
GROUP BY prod_a, prod_b
ORDER BY pair_count DESC
LIMIT 1;

----------------------------------------------------------------------------------

--29) Employees with Same Title in Different Departments
CREATE TABLE emp_titles (
  emp_id INT,
  dept_id INT,
  title VARCHAR(50)
);
INSERT INTO emp_titles VALUES
  (1,10,'A nalyst'),(2,20,'Analyst'),(3,10,'Manager');
-- Solution:
SELECT e1.emp_id, e2.emp_id, e1.title
FROM emp_titles e1
JOIN emp_titles e2 ON e1.title = e2.title AND e1.dept_id <> e2.dept_id;

--------------------------------------------------------------------------------

---30) Most Recent Login Before Failure Event
CREATE TABLE events (
  user_id INT,
  event_time TIMESTAMP,
  event_type VARCHAR(20)
);
INSERT INTO events VALUES
  (1,'2023-01-01 09:00','LOGIN'),
  (1,'2023-01-01 09:05','FAIL'),
  (1,'2023-01-01 08:55','LOGIN');
-- Solution:
SELECT f.user_id, 
       LAG(event_time) OVER (PARTITION BY user_id ORDER BY event_time) AS prev_login
FROM events f
WHERE event_type = 'FAIL'
------------------------------------------------------------------------------

--31)Comments Referencing Non-Existing Posts

drop table comments;
CREATE TABLE posts (
  post_id INT,
  content TEXT
);
CREATE TABLE comments (
  comment_id INT,
  post_id INT,
  comment TEXT
);
INSERT INTO posts VALUES (1, 'Post A'), (2, 'Post B');
INSERT INTO comments VALUES (100, 1, 'Nice'), (101, 3, 'Spam'), (102, 2, 'Great');

select * from posts;
select * from comments;

SELECT c.comment_id, c.post_id
FROM comments c
LEFT JOIN posts p ON c.post_id = p.post_id
WHERE p.post_id IS NULL;

------------------------------------------------------------------------------

--32) Instructors Who Taught All Advanced Level Courses
CREATE TABLE instructors (
  instr_id INT,
  name VARCHAR(50)
);
CREATE TABLE courses (
  course_id INT,
  level VARCHAR(20)
);
CREATE TABLE teaching_assignments (
  instr_id INT,
  course_id INT
);
INSERT INTO instructors VALUES (1, 'Ana'), (2, 'Ben');
INSERT INTO courses VALUES (10, 'Basic'), (20, 'Advanced'), (30, 'Advanced');
INSERT INTO teaching_assignments VALUES (1, 20), (1, 30), (2, 20);


SELECT instr_id
FROM teaching_assignments ta
JOIN courses c ON ta.course_id = c.course_id AND c.level = 'Advanced'
GROUP BY instr_id
HAVING COUNT(DISTINCT ta.course_id) = (
  SELECT COUNT(*) FROM courses WHERE level = 'Advanced');
------------------------------------------------------------------------

--33) Orders Not Delivered on Same Day
CREATE TABLE orders (
  order_id INT,
  order_date DATE
);
CREATE TABLE deliveries (
  order_id INT,
  delivery_date DATE
);
INSERT INTO orders VALUES (1, '2023-06-01'), (2, '2023-06-02');
INSERT INTO deliveries VALUES (1, '2023-06-03'), (2, '2023-06-02');
-- Solution:
SELECT o.order_id, o.order_date, d.delivery_date
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
WHERE o.order_date <> d.delivery_date;
---------------------------------------------------------------------------

------------------------------------------------------------------------------

--34)Identify rows missing in target or mismatched values.

CREATE TABLE source_data (
  id INT,
  value TEXT
);	
CREATE TABLE target_data (
  id INT,
  value TEXT
);
INSERT INTO source_data VALUES (1, 'A'), (2, 'B'), (3, 'C');
INSERT INTO target_data VALUES (1, 'A'), (3, 'C');

select * from source_data;
select * from target_data ;

SELECT COALESCE(s.id, t.id) AS id,
       s.value AS source_val,
       t.value AS target_val
FROM source_data s
FULL OUTER JOIN target_data t ON s.id = t.id
WHERE s.value IS DISTINCT FROM t.value;

select * 
from source_data s
full join target_data t on s.id = t.id
where s.value is distinct from t.value;
