CREATE TABLE employees (id INT PRIMARY KEY,first_name VARCHAR(50),last_name VARCHAR(50),age INT,sex VARCHAR(10),employee_title VARCHAR(50),
department VARCHAR(50),salary INT,target INT,bonus INT,email VARCHAR(100),city VARCHAR(50),address VARCHAR(255),manager_id INT);

INSERT INTO employees (id, first_name, last_name, age, sex, employee_title, department, salary, target, bonus, email, city, address, manager_id) VALUES(1, 'Alice', 'Smith', 40, 'F', 'Manager', 'Sales', 90000, 100000, 15000, 'alice.smith@example.com', 'New York', '123 Main St', 1),(2, 'Bob', 'Johnson', 35, 'M', 'Team Lead', 'Sales', 80000, 95000, 12000, 'bob.johnson@example.com', 'Chicago', '456 Oak St', 1),(3, 'Carol', 'Williams', 30, 'F', 'Sales Executive', 'Sales', 70000, 85000, 10000, 'carol.williams@example.com', 'New York', '789 Pine St', 1),(4, 'David', 'Brown', 28, 'M', 'Sales Executive', 'Sales', 68000, 80000, 9000, 'david.brown@example.com', 'Chicago', '101 Maple St', 1),(5, 'Emma', 'Jones', 32, 'F', 'Sales Executive', 'Sales', 71000, 86000, 9500, 'emma.jones@example.com', 'New York', '202 Cedar St', 1),(6, 'Frank', 'Miller', 45, 'M', 'Manager', 'Engineering', 95000, 105000, 16000, 'frank.miller@example.com', 'San Francisco', '303 Spruce St', 6),(7, 'Grace', 'Davis', 29, 'F', 'Engineer', 'Engineering', 73000, 87000, 11000, 'grace.davis@example.com', 'San Francisco', '404 Willow St', 6);

select * from employees;

--Find managers with at least 7 direct reporting employees. In situations where user is reporting to himself/herself, count that also.
--Output first names of managers.

select 
e2.first_name as manager_name,
count(*) as no_of_reporting 
from employees e1
join employees e2 on e1.manager_id = e2.id
group by e2.first_name 
having count(*)>=3;


CREATE TABLE linkedin_users (user_id INT,employer VARCHAR(255),position VARCHAR(255),start_date Timestamp,end_date Timestamp);

INSERT INTO linkedin_users (user_id, employer, position, start_date, end_date) VALUES(1, 'Microsoft', 'developer', '2020-04-13', '2021-11-01'),(1, 'Google', 'developer', '2021-11-01', NULL),(2, 'Google', 'manager', '2021-01-01', '2021-01-11'),(2, 'Microsoft', 'manager', '2021-01-11', NULL),(3, 'Microsoft', 'analyst', '2019-03-15', '2020-07-24'),(3, 'Amazon', 'analyst', '2020-08-01', '2020-11-01'),(3, 'Google', 'senior analyst', '2020-11-01', '2021-03-04'),(4, 'Google', 'junior developer', '2018-06-01', '2021-11-01'),(4, 'Google', 'senior developer', '2021-11-01', NULL),(5, 'Microsoft', 'manager', '2017-09-26', NULL),(6, 'Google', 'CEO', '2015-10-02', NULL);


--Consider all LinkedIn users who, at some point, worked at Microsoft. For how many of them was Google their 
--next employer right after Microsoft (no employers in between)?

select * from linkedin_users;
with cte as (
select 
*,
lead(employer) over (partition by user_id order by start_date ) as next_employer
from linkedin_users)
select * 
from cte where employer ='Microsoft'and next_employer ='Google';





CREATE TABLE employee_o (id INT PRIMARY KEY,first_name VARCHAR(50),last_name VARCHAR(50),age INT,gender VARCHAR(10),employee_title VARCHAR(50),department VARCHAR(50),salary INT,manager_id INT);

INSERT INTO employee_o (id, first_name, last_name, age, gender, employee_title, department, salary, manager_id) VALUES(1, 'Alice', 'Smith', 45, 'F', 'Manager', 'HR', 9000, 1),(2, 'Bob', 'Johnson', 34, 'M', 'Assistant', 'HR', 4500, 1),(3, 'Charlie', 'Williams', 28, 'M', 'Coordinator', 'HR', 4800, 1),(4, 'Diana', 'Brown', 32, 'F', 'Manager', 'IT', 12000, 4),(5, 'Eve', 'Jones', 27, 'F', 'Analyst', 'IT', 7000, 4),(6, 'Frank', 'Garcia', 29, 'M', 'Developer', 'IT', 7500, 4),(7, 'Grace', 'Miller', 30, 'F', 'Manager', 'Finance', 10000, 7),(8, 'Hank', 'Davis', 26, 'M', 'Analyst', 'Finance', 6200, 7),(9, 'Ivy', 'Martinez', 31, 'F', 'Clerk', 'Finance', 5900, 7),(10, 'John', 'Lopez', 36, 'M', 'Manager', 'Marketing', 11000, 10),(11, 'Kim', 'Gonzales', 29, 'F', 'Specialist', 'Marketing', 6800, 10),(12, 'Leo', 'Wilson', 27, 'M', 'Coordinator', 'Marketing', 6600, 10);

select * from employee_o;

---Write a query that compares each employee's salary to their manager's and the average department salary 
--(excluding the manager's salary). Display the department, employee ID, employee's salary, manager's salary, and department average salary. 
--Order by department, then by employee salary (highest to lowest).

with cte as (
select 
e1.id as employee_id,
e1.first_name as employee_name,
e1.salary as employee_salary ,
e2.id as manager_id,
e2.first_name as manager_name,
e2.salary as manager_salary,
e2.department,
avg(e1.salary) over (partition by e1.department) as avg_dept_salary
from employee_o e1
join employee_o e2 on e1.manager_id = e2.id
order by e1.department,e1.salary desc)
select * from cte 
where employee_salary >avg_dept_salary ;


drop table card_orders;

CREATE TABLE customers (id INT,first_name VARCHAR(50),last_name VARCHAR(50),city VARCHAR(100),address VARCHAR(200),phone_number VARCHAR(20));

INSERT INTO customers (id, first_name, last_name, city, address, phone_number) VALUES(1, 'Jill', 'Doe', 'New York', '123 Main St', '555-1234'),(2, 'Henry', 'Smith', 'Los Angeles', '456 Oak Ave', '555-5678'),(3, 'William', 'Johnson', 'Chicago', '789 Pine Rd', '555-8765'),(4, 'Emma', 'Daniel', 'Houston', '321 Maple Dr', '555-4321'),(5, 'Charlie', 'Davis', 'Phoenix', '654 Elm St', '555-6789');

CREATE TABLE card_orders (order_id INT,cust_id INT,order_date timestamp,order_details VARCHAR(255),total_order_cost INT);

INSERT INTO card_orders (order_id, cust_id, order_date, order_details, total_order_cost) 
VALUES(1, 1, '2024-11-01 10:00:00', 'Electronics', 200),(2, 2, '2024-11-02 11:30:00', 'Groceries', 150),(3, 1, '2024-11-03 15:45:00', 'Clothing', 120),(4, 3, '2024-11-04 09:10:00', 'Books', 90),(8, 3, '2024-11-08 10:20:00', 'Groceries', 130),(9, 1, '2024-11-09 12:00:00', 'Books', 180),(10, 4, '2024-11-10 11:15:00', 'Electronics', 200),(11, 5, '2024-11-11 14:45:00', 'Furniture', 150),(12, 2, '2024-11-12 09:30:00', 'Furniture', 180);

---American Express is reviewing their customers' transactions, and you have been tasked with locating the customer 
--who has the third highest total transaction amount. The output should include the customer's id, 
--as well as their first name and last name. For ranking the customers, use type of ranking with no gaps between subsequent ranks.

select * from card_orders;
select * from customers;

with cte as (
	select 
		id,
		first_name,
		last_name,
		sum(total_order_cost) as tranaction_amounts,
		dense_rank() over (order by sum(total_order_cost) desc) as rnk
	from customers c1
	join card_orders c2 on c1.id = c2.cust_id
	group by 1,2,3
)
select * 
from cte 
where rnk =3;








