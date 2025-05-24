-----problem 1
-where we need to find player with no of gold medals won by them only for players who won only gold medals
--script:
CREATE TABLE events (
ID int,
event varchar(255),
YEAR INt,
GOLD varchar(255),
SILVER varchar(255),
BRONZE varchar(255));

INSERT INTO events VALUES (1,'100m',2016, 'Amthhew Mcgarray','donald','barbara');
INSERT INTO events VALUES (2,'200m',2016, 'Nichole','Alvaro Eaton','janet Smith');
INSERT INTO events VALUES (3,'500m',2016, 'Charles','Nichole','Susana');
INSERT INTO events VALUES (4,'100m',2016, 'Ronald','maria','paula');
INSERT INTO events VALUES (5,'200m',2016, 'Alfred','carol','Steven');
INSERT INTO events VALUES (6,'500m',2016, 'Nichole','Alfred','Brandon');
INSERT INTO events VALUES (7,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (8,'200m',2016, 'Thomas','Dawn','catherine');
INSERT INTO events VALUES (9,'500m',2016, 'Thomas','Dennis','paula');
INSERT INTO events VALUES (10,'100m',2016, 'Charles','Dennis','Susana');
INSERT INTO events VALUES (11,'200m',2016, 'jessica','Donald','Stefeney');
INSERT INTO events VALUES (12,'500m',2016,'Thomas','Steven','Catherine');

select * from events;
select 
gold as player_name,
count(1) as cnt 
from events
where gold not in (select silver from events union all select bronze from events)
group by gold;

--2 nd approach----
with cte as (
select gold,'gold' as medal_type from events
union all select silver,'silver'as medal_type from events
union all select bronze,'bronze'as medal_type from events)
select gold,count(1) as no_of_medals
from cte 
group by gold having count(distinct medal_type)= 1 and max(medal_type) ='gold'

--------------------------------------------------------------------------------------------

---2 question ---
--script:problem where we need to find number of employees inside the hospital.
create table hospital ( emp_id int
, action varchar(10)
, time Timestamp);
delete from hospital;
insert into hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into hospital values ('5', 'out', '2019-12-22 09:40:00');

select * from hospital;

with cte as (
select 
emp_id,
max(case when action ='in' then Time end) as intime,
max(case when action ='out' then Time end) as outtime
from hospital
group by emp_id)
select *
from cte 
where intime > outtime or outtime is null;

-----------------------------------------------------------------------------------------------

----question 3 
--find the room types that are searched most no of times.output the room type alongside the number of searches for it. 
--If the filter for room types has more than one room type,consider each unique roo type as a separate row. 
--Sort the result based on th number of searches in desc order.

create table airbnb_searches 
(
user_id int,
date_searched date,
filter_room_types varchar(200)
);
delete from airbnb_searches;
insert into airbnb_searches values
(1,'2022-01-01','entire home,private room')
,(2,'2022-01-02','entire home,shared room')
,(3,'2022-01-02','private room,shared room')
,(4,'2022-01-03','private room')
;

select * from airbnb_searches;
SELECT 
  TRIM(room_type) AS room_type,
  COUNT(*) AS no_of_searches
FROM (
  SELECT 
    unnest(string_to_array(filter_room_types, ',')) AS room_type
  FROM airbnb_searches
) AS normalized
GROUP BY TRIM(room_type)
ORDER BY no_of_searches DESC;

---------------------------------------------------------------------------------------------------------

----4 question---
--script:write a sql to return all employee whose salary is same in same department
CREATE TABLE emp_salary (
    emp_id INTEGER NOT NULL,
    name VARCHAR(20) NOT NULL,
    salary NUMERIC(10, 2),
    dept_id INTEGER
);

INSERT INTO emp_salary (emp_id, name, salary, dept_id)
VALUES
(101, 'sohan', 3000, 11),
(102, 'rohan', 4000, 12),
(103, 'mohan', 5000, 13),
(104, 'cat', 3000, 11),
(105, 'suresh', 4000, 12),
(109, 'mahesh', 7000, 12),
(108, 'kamal', 8000, 11);

select * from emp_salary;
WITH cte AS (
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
  ON e1.dept_id = e2.dept_id;

-------------------------------------------------------------------------------------------------

---question 5 
--write a query to obtain the number of users who purchased the same product of two or more different days. Output the number of unique users

create table purchases(
	user_id int,
	product_id int,
	quantity int,
	purchase_date Timestamp
);

insert into purchases values(536, 3223, 6, '01/11/2022 12:33:44');
insert into purchases values(827, 3585, 35, '02/20/2022 14:05:26');
insert into purchases values(536, 3223, 5, '03/02/2022 09:33:28');
insert into purchases values(536, 1435, 10, '03/02/2022 08:40:00');
insert into purchases values(827, 2452, 45, '04/09/2022 00:00:00');

select * from purchases;
select count(1) as users_num from (
select 
user_id,
product_id,
count(distinct purchase_date::date) as purchase_date
from purchases
group by 1, 2
having count(purchase_date::date) >1)a;

------------------------------------------------------------------------------------------------

---question 6 
--write a query to print highest and lowest salary emp in each depatment 
drop table employee;

create table employee 
(
emp_name varchar(10),
dep_id int,
salary int
);

insert into employee values 
('Siva',1,30000),('Ravi',2,40000),('Prasad',1,50000),('Sai',2,20000);

select * from employee;
with cte as (
select
dep_id,
max(salary) as max_salary,
min(salary) as min_salary
from employee
group by 1)
select
e.dep_id,
max(case when salary = max_salary then emp_name else null end) as max_sal_emp,
max(case when salary = min_salary then emp_name else null end) as min_sal_emp
from employee e
inner join cte c on e.dep_id = c.dep_id
group by 1;


---2nd approach---
SELECT
    dep_id,
    MAX(CASE WHEN rn_max = 1 THEN emp_name END) AS max_sal_emp,
    MAX(CASE WHEN rn_min = 1 THEN emp_name END) AS min_sal_emp
FROM (
    SELECT *,
        RANK() OVER (PARTITION BY dep_id ORDER BY salary DESC) AS rn_max,
        RANK() OVER (PARTITION BY dep_id ORDER BY salary ASC) AS rn_min
    FROM employee
) t
GROUP BY dep_id;

-----------------------------------------------------------------------------
--7 questions
--script:
create table call_start_logs
(
phone_number varchar(10),
start_time timestamp);

insert into call_start_logs values
('PN1','2022-01-01 10:20:00'),('PN1','2022-01-01 16:25:00'),('PN2','2022-01-01 12:30:00')
,('PN3','2022-01-02 10:00:00'),('PN3','2022-01-02 12:30:00'),('PN3','2022-01-03 09:20:00');

create table call_end_logs(
phone_number varchar(10),
end_time timestamp);

insert into call_end_logs values
('PN1','2022-01-01 10:45:00'),('PN1','2022-01-01 17:05:00'),('PN2','2022-01-01 12:55:00')
,('PN3','2022-01-02 10:20:00'),('PN3','2022-01-02 12:50:00'),('PN3','2022-01-03 09:40:00');


select * from call_start_logs;
select * from  call_end_logs;

select a.phone_number,a.start_time,b.end_time, AGE(end_time, start_time) AS time_diff, DATE_PART('minute', AGE(end_time, start_time)) AS minutes_diff
from
(select *, row_number() over (partition by phone_number order by start_time) as rnk_start_time from call_start_logs)a
inner join 
(select *, row_number() over (partition by phone_number order by end_time) as rnk_end_time from call_end_logs)b
on a.phone_number = b.phone_number and a.rnk_start_time= b.rnk_end_time;

---we can use both Last 2 column for minutes--

----------------------------------------------------------------------------------------------

--8 questions --(12 vdo )

create table input (
id int,
formula varchar(10),
value int
);
insert into input values (1,'1+4',10),(2,'2+1',5),(3,'3-2',40),(4,'4-1',20);
select * from input;

WITH cte AS (
  SELECT *,
    LEFT(formula, 1) AS d1,
    RIGHT(formula, 1) AS d2,
    SUBSTRING(formula, 2, 1) AS o
  FROM input
  WHERE formula IS NOT NULL
)
SELECT 
  cte.id,
  cte.value,
  cte.formula,
  cte.o,
  ip1.value AS d1_value,
  ip2.value AS d2_value,
  CASE 
    WHEN cte.o = '+' THEN ip1.value + ip2.value
    WHEN cte.o = '-' THEN ip1.value - ip2.value
    ELSE NULL
  END AS new_value
FROM cte
JOIN input ip1 ON cte.d1 = ip1.id::text
JOIN input ip2 ON cte.d2 = ip2.id::text;

-------------------------------------------------------------------------------------------

----question 9 ----(13 vdo)

create table Ameriprise_LLC
(
teamID varchar(2),
memberID varchar(10),
Criteria1 varchar(1),
Criteria2 varchar(1)
);
insert into Ameriprise_LLC values 
('T1','T1_mbr1','Y','Y'),
('T1','T1_mbr2','Y','Y'),
('T1','T1_mbr3','Y','Y'),
('T1','T1_mbr4','Y','Y'),
('T1','T1_mbr5','Y','N'),
('T2','T2_mbr1','Y','Y'),
('T2','T2_mbr2','Y','N'),
('T2','T2_mbr3','N','Y'),
('T2','T2_mbr4','N','N'),
('T2','T2_mbr5','N','N'),
('T3','T3_mbr1','Y','Y'),
('T3','T3_mbr2','Y','Y'),
('T3','T3_mbr3','N','Y'),
('T3','T3_mbr4','N','Y'),
('T3','T3_mbr5','Y','N');


select * from create table Ameriprise_LLC
(
teamID varchar(2),
memberID varchar(10),
Criteria1 varchar(1),
Criteria2 varchar(1)
);
insert into Ameriprise_LLC values 
('T1','T1_mbr1','Y','Y'),
('T1','T1_mbr2','Y','Y'),
('T1','T1_mbr3','Y','Y'),
('T1','T1_mbr4','Y','Y'),
('T1','T1_mbr5','Y','N'),
('T2','T2_mbr1','Y','Y'),
('T2','T2_mbr2','Y','N'),
('T2','T2_mbr3','N','Y'),
('T2','T2_mbr4','N','N'),
('T2','T2_mbr5','N','N'),
('T3','T3_mbr1','Y','Y'),
('T3','T3_mbr2','Y','Y'),
('T3','T3_mbr3','N','Y'),
('T3','T3_mbr4','N','Y'),
('T3','T3_mbr5','Y','N');

select * from Ameriprise_LLC;

with cte as (
select 
teamid,
count(1)
from Ameriprise_LLC 
where criteria1='Y' and criteria2='Y'
group by 1
having count(1)>=2)
select a1.*,b1.*,
case when criteria1='Y' and criteria2='Y' and b1.teamid is not null then 'Y'else'N' end as qualified_flag
from 
Ameriprise_LLC a1
left join cte b1 on a1.teamid = b1.teamid;

------------------------------------------------------------------------------------------

----question 10----

create table family 
(
person varchar(5),
type varchar(10),
age int
);

insert into family values ('A1','Adult',54)
,('A2','Adult',53),('A3','Adult',52),('A4','Adult',58),('A5','Adult',54),('C1','Child',20),('C2','Child',19),('C3','Child',22),('C4','Child',15);

select * from family;




WITH cte1 AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY person) AS rn
  FROM family
  WHERE type = 'Adult'
),
cte2 AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY person) AS rn
  FROM family
  WHERE type = 'Child'
)
SELECT 
  a.person AS adult_person, 
  b.person AS child_person
FROM cte1 a
LEFT JOIN cte2 b ON a.rn = b.rn;

---------------------------------------------------------------------------------------------------
----Question 11------(16)
--Find the company only whose revenue is increasing every year. 
--Note:suppose a company revenue is increasing 3 years and a very next year revenue is dipped in that case it should not come in output .
create table company_revenue 
(
company varchar(100),
year int,
revenue int
);

insert into company_revenue values 
('ABC1',2000,100),('ABC1',2001,110),('ABC1',2002,120),('ABC2',2000,100),('ABC2',2001,90),('ABC2',2002,120)
,('ABC3',2000,500),('ABC3',2001,400),('ABC3',2002,600),('ABC3',2003,800);

select * from company_revenue;

with cte as (
select *,
lag(revenue,1,0)over (partition by company order by year) as prev_rev,
revenue - lag(revenue,1,0)over (partition by company order by year) as revenue_diff,
count(1)over(partition by company) as cnt
from company_revenue)
select company,cnt,count(1) as sales_inc_years 
from cte 
where revenue_diff >0
group by 1,2
having cnt = count(1);

------------------------------------------------------------------------------------------
--question 12 ---(17)
---write a query that print the name of the childs and his parents in individual column respectively in order of the name of the child

create table people
(id int primary key not null,
 name varchar(20),
 gender char(2));

create table relations
(
    c_id int,
    p_id int,
    FOREIGN KEY (c_id) REFERENCES people(id)
);

insert into people (id, name, gender)
values
    (107,'Days','F'),
    (145,'Hawbaker','M'),
    (155,'Hansel','F'),
    (202,'Blackston','M'),
    (227,'Criss','F'),
    (278,'Keffer','M'),
    (305,'Canty','M'),
    (329,'Mozingo','M'),
    (425,'Nolf','M'),
    (534,'Waugh','M'),
    (586,'Tong','M'),
    (618,'Dimartino','M'),
    (747,'Beane','M'),
    (878,'Chatmon','F'),
    (904,'Hansard','F');

insert into relations(c_id, p_id)
values
    (145, 202),
    (145, 107),
    (278,305),
    (278,155),
    (329, 425),
    (329,227),
    (534,586),
    (534,878),
    (618,747),
    (618,904);


select * from people;
select * from relations;

with m as (
select r.c_id,p.name as mother_name from 
relations r
inner join people p on r.p_id= p.id and gender ='F'),
f as (
select r.c_id,p.name as Father_name from 
relations r
inner join people p on r.p_id= p.id and gender ='M')
select f.c_id as child_id,p.name as child_name ,m.mother_name,f.Father_name
from f
join m on  f.c_id =m.c_id 
join people p on p.id = f.c_id ;

-----------------------------------------------------------------------------------

---Question 13----(18)
create table icc_world_cup
(
match_no int,
team_1 Varchar(20),
team_2 Varchar(20),
winner Varchar(20)
);
INSERT INTO icc_world_cup values(1,'ENG','NZ','NZ');
INSERT INTO icc_world_cup values(2,'PAK','NED','PAK');
INSERT INTO icc_world_cup values(3,'AFG','BAN','BAN');
INSERT INTO icc_world_cup values(4,'SA','SL','SA');
INSERT INTO icc_world_cup values(5,'AUS','IND','IND');
INSERT INTO icc_world_cup values(6,'NZ','NED','NZ');
INSERT INTO icc_world_cup values(7,'ENG','BAN','ENG');
INSERT INTO icc_world_cup values(8,'SL','PAK','PAK');
INSERT INTO icc_world_cup values(9,'AFG','IND','IND');
INSERT INTO icc_world_cup values(10,'SA','AUS','SA');
INSERT INTO icc_world_cup values(11,'BAN','NZ','NZ');
INSERT INTO icc_world_cup values(12,'PAK','IND','IND');
INSERT INTO icc_world_cup values(12,'SA','IND','DRAW');

select * from icc_world_cup;
with all_matches as (
select team,sum(matches_played) as matches_played from
(
select team_1 as team,count(*) as matches_played from icc_world_cup group by 1
union all
select team_2 as team,count(*) as matches_played from icc_world_cup group by 1)A
group  by team
),
winners as (
select winner ,
count(*) as wins from icc_world_cup group by winner)
select m.team,m.matches_played,coalesce(w.wins,0) as wins,m.matches_played - coalesce(w.wins,0) as losses,
coalesce(w.wins,0)*2  as pts
from all_matches m
left join winners w on m.team = w.winner
order by wins desc;

----------------------------------------------------------------------------------------------------

---Question 13----(19)

--find the origin and final destination for each cid 
CREATE TABLE flights 
(
    cid VARCHAR(512),
    fid VARCHAR(512),
    origin VARCHAR(512),
    Destination VARCHAR(512)
);

INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f1', 'Del', 'Hyd');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f2', 'Hyd', 'Blr');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f3', 'Mum', 'Agra');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f4', 'Agra', 'Kol');

select * from flights;

select o.cid,o.origin,d.destination as final_destination
from flights o
inner join flights d on o.destination = d.origin;

Problem 2:
--Find the count of new_customer added in ea
drop table sales;
CREATE TABLE sales 
(
    order_date date,
    customer VARCHAR(512),
    qty INT
);

INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C1', '20');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C2', '30');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C1', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C3', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C5', '19');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C4', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C3', '13');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C5', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C6', '10');

select * from sales;
select order_date,count(distinct customer) as count_new_cust from (
select *,
row_number() over(partition by customer order by order_date) as rn
from sales) a
where rn = 1
group by 1;


--------------------------------------------------------------------------------------------

---question 14 ---------(20)

create table source(id int, name varchar(5));

create table target(id int, name varchar(5));

insert into source values(1,'A'),(2,'B'),(3,'C'),(4,'D');

insert into target values(1,'A'),(2,'B'),(4,'X'),(5,'F');

select * from source;
select * from target;

select coalesce (s.id,t.id) as id,s.name, t.name,
case when t.name is null then 'new in source'
when s.name is null then 'new in target' else 'mismatch' end as comment
from source s
full join target t on s.id = t.id
where s.name !=t.name or s.name is null or t.name is null

---------------------------------------------------------------------------------------------

---question 15 ---------(21)
--Find the words which are repeating more than once considering all the rows of content column 
create table namaste_python (
file_name varchar(25),
content varchar(200)
);

delete from namaste_python;
insert into namaste_python values ('python bootcamp1.txt','python for data analytics 0 to hero bootcamp starting on Jan 6th')
,('python bootcamp2.txt','classes will be held on weekends from 11am to 1 pm for 5-6 weeks')
,('python bootcamp3.txt','use code NY2024 to get 33 percent off. You can register from namaste sql website. Link in pinned comment');

select * from namaste_python
select unnest(string_to_array('I want to split my sentence', ' ')) AS word;

SELECT 
  value AS word,
  COUNT(*) AS cnt_of_word
FROM namaste_python,
LATERAL unnest(string_to_array(content, ' ')) AS value
GROUP BY value
having count(*)>1
ORDER BY cnt_of_word DESC;

----------------------------------------------------------------------------------------------
--Find the number of employees who received the bonus and who didn't. Bonus values in employee table are corrupted so you 
--should use values from the bonus table. Be aware of the fact that employee can receive more than one bonus. Output value inside has_bonus column 
--(1 if they had bonus, 0 if not) 
--along with the corresponding number of employees for each.

CREATE TABLE employee_details (id BIGINT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), 
age BIGINT, sex VARCHAR(10), email VARCHAR(100), address VARCHAR(100), city VARCHAR(50), department VARCHAR(50), 
employee_title VARCHAR(50), manager_id BIGINT, salary BIGINT, target BIGINT, bonus BIGINT);

INSERT INTO employee_details (id, first_name, last_name, age, sex, email, address, city, department, employee_title, manager_id, salary, target, bonus)
VALUES (1, 'John', 'Doe', 30, 'Male', 'john.doe@example.com', '123 Elm St', 'New York', 'IT', 'Engineer', 
101, 70000, 80000, 5000),(2, 'Jane', 'Smith', 28, 'Female', 'jane.smith@example.com',
'456 Oak St', 'Los Angeles', 'HR', 'Manager', 102, 75000, 90000, NULL),(3, 'Alice', 'Johnson', 35,
'Female', 'alice.johnson@example.com', '789 Pine St', 'Chicago', 'Finance', 'Analyst', 103, 80000, 95000, NULL),
(4, 'Bob', 'Brown', 40, 'Male', 'bob.brown@example.com', '321 Maple St', 'Boston', 'IT', 'Director', 104, 120000, 130000, NULL),
(5, 'Charlie', 'Davis', 25, 'Male', 'charlie.davis@example.com', '654 Cedar St', 'Seattle', 'Marketing', 'Specialist', 105, 50000, 60000, NULL);


CREATE TABLE bonus (worker_ref_id BIGINT, bonus_amount BIGINT, bonus_date timestamp);

INSERT INTO bonus (worker_ref_id, bonus_amount, bonus_date) VALUES (1, 5000, '2024-01-15'),(1, 3000, '2024-02-20'),(3, 2000, '2024-03-10'),(5, 1000, '2024-04-05');

select * from employee_details;
select * from bonus;

with cte as (
	select *,
	case when bonus_amount is null then 0 else 1 end as has_bonus
	from employee_details ed
	left join bonus b on ed.id = b.worker_ref_id
)
select 
	has_bonus,
	count(distinct(id))
from cte
group by 1;
----------------------------------------------------------------
---Find the best selling item for each month (no need to separate months by year) where the biggest total invoice was paid. 
--The best selling item is calculated using the formula (unitprice * quantity). 
--Output the month, the description of the item along with the amount paid.

CREATE TABLE online_retails (country VARCHAR(10),customerid FLOAT,description VARCHAR(10),invoicedate timestamp,invoiceno VARCHAR(10),
quantity BIGINT,stockcode VARCHAR(10),unitprice FLOAT);

INSERT INTO online_retails (country, customerid, description, invoicedate, invoiceno, quantity, stockcode, unitprice) VALUES
('UK', 10001, 'Mug',     '2024-01-10 10:00:00', 'INV001', 10, 'A1', 5.0),
('UK', 10002, 'Plate',   '2024-01-15 14:00:00', 'INV002', 15, 'B2', 3.0),
('UK', 10003, 'Mug',     '2024-01-20 09:30:00', 'INV003', 5,  'A1', 5.0),
('UK', 10004, 'Bowl',    '2024-02-05 12:00:00', 'INV004', 20, 'C3', 4.0),
('UK', 10005, 'Mug',     '2024-02-10 13:00:00', 'INV005', 8,  'A1', 5.0),
('UK', 10006, 'Bowl',    '2024-02-18 15:30:00', 'INV006', 15, 'C3', 4.0),
('UK', 10007, 'Plate',   '2024-03-03 11:00:00', 'INV007', 10, 'B2', 3.0);

select * from online_retails;

with cte as (
	select 
		description,
		extract(month from invoicedate) as month,
		extract(year from invoicedate) as year,
		sum(unitprice * quantity) as price
	from online_retails
	group by 1,2,3
	order by 2,3
)
select * from (
select *,
	dense_rank() over(partition by month,year order by price desc) as rnk
from cte)
where rnk = 1;
--------------------------------------------------------------------------

--Find the top two hotels with the most negative reviews.
--Output the hotel name along with the corresponding number of negative reviews. 
--Negative reviews are all the reviews with text under negative review different than "No Negative". 
--Sort records based on the number of negative reviews in descending order.


drop table hotel_reviews;
CREATE TABLE hotel_reviews (additional_number_of_scoring BIGINT, average_score FLOAT, days_since_review VARCHAR(255),
hotel_address VARCHAR(255), hotel_name VARCHAR(255), 
lat FLOAT, lng FLOAT, negative_review VARCHAR, positive_review VARCHAR, review_date Timestamp,
review_total_negative_word_counts BIGINT, review_total_positive_word_counts BIGINT, reviewer_nationality VARCHAR(255), 
reviewer_score FLOAT, tags VARCHAR, total_number_of_reviews BIGINT, total_number_of_reviews_reviewer_has_given BIGINT);

INSERT INTO hotel_reviews VALUES
(25, 8.7, '15 days ago', '123 Street, City A', 'Hotel Alpha', 12.3456, 98.7654, 'Too noisy at night', 'Great staff and clean rooms', '2024-12-01',
5, 15, 'USA', 8.5, '["Couple"]', 200, 10), (30, 9.1, '20 days ago', '456 Avenue, City B', 'Hotel Beta', 34.5678, 76.5432, 'Old furniture', 
'Excellent location', '2024-12-02', 4, 12, 'UK', 9.0, '["Solo traveler"]',
150, 8), (12, 8.3, '10 days ago', '789 Boulevard, City C', 'Hotel Gamma', 23.4567, 67.8901, 'No Negative', 'Friendly staff', 
'2024-12-03', 0, 10, 'India', 8.3, '["Family"]', 100, 5), (15, 8.0, '5 days ago', '321 Lane, City D', 
'Hotel Delta', 45.6789, 54.3210, 'Uncomfortable bed', 'Affordable price', '2024-12-04', 6, 8, 'Germany', 7.8, '["Couple"]', 120, 7),
(20, 7.9, '8 days ago', '654 Road, City E', 'Hotel Alpha', 67.8901, 12.3456, 'Poor room service', 
'Good breakfast', '2024-12-05', 7, 9, 'France', 7.5, '["Solo traveler"]', 180, 6), (18, 9.3, '18 days ago', '987 Highway, City F',
'Hotel Beta', 34.5678, 76.5432, 'No Negative', 'Amazing facilities', '2024-12-06', 0, 20, 'USA', 9.2, '["Couple"]', 250, 15);


select * from hotel_reviews;
select 
	hotel_name,
	count(negative_review)as cnt
from hotel_reviews
where negative_review != 'No Negative'
group by 1;


