--1) Given match data with two teams and a winner, calculate how many matches each team played, won, and lost.
drop table icc_world_cup;
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;
select team_name,count(1) as no_of_matches_played, sum(win_flag) as no_of_matches_won, count(1)- sum(win_flag) as no_of_losses from(
select team_1 as team_name,
case when team_1 = winner then 1 else 0 end as win_flag
from icc_world_cup
union all
select team_2,
case when team_2 = winner then 1 else 0 end as win_flag
from icc_world_cup)
group by 1
order by no_of_matches_won;

----------------------------------------------------------
--2)Given a table of customer orders, identify for each order whether it was the customer's first visit or a repeat visit.
create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;

select * from customer_orders;
with cte as (
select 
customer_id,
min(order_date) as first_visit_date
from customer_orders
group by 1),
cte2 as (
select co.*,c.first_visit_date,
case when co.order_date = c.first_visit_date then 1 else 0 end as first_visit_flag,
case when co.order_date != c.first_visit_date then 1 else 0 end as repeat_visit_flag
from customer_orders co
inner join cte c on co.customer_id = c.customer_id
order by order_id)
select order_date,sum(first_visit_flag) as no_of_new_cutomers,sum(repeat_visit_flag) as no_orepeat_visit_flag
from cte2 group by 1;

-----------------------------------------------------------------------------
--3)write a query to find personid, name, mo_of_friends,sum_of_marks of person who have friends with total score greater than 100----(6)

drop table friend ;
Create table friend (pid int, fid int);
insert into friend (pid , fid ) values ('1','2');
insert into friend (pid , fid ) values ('1','3');
insert into friend (pid , fid ) values ('2','1');
insert into friend (pid , fid ) values ('2','3');
insert into friend (pid , fid ) values ('3','5');
insert into friend (pid , fid ) values ('4','2');
insert into friend (pid , fid ) values ('4','3');
insert into friend (pid , fid ) values ('4','5');
drop table person;
create table person (PersonID int,Name varchar(50),Score int);

INSERT INTO person(PersonID, Name, Score) VALUES (1, 'Alice', 88);
INSERT INTO person(PersonID, Name, Score) VALUES (2, 'Bob', 11);
INSERT INTO person(PersonID, Name, Score) VALUES (3, 'Devis', 27);
INSERT INTO person(PersonID, Name, Score) VALUES (4, 'Tara', 45);
INSERT INTO person(PersonID, Name, Score) VALUES (5, 'John', 63);

select * from person;
select * from friend;

with cte as (
select 
f.pid,
sum(p.score) as total_friend_score,
count(1) as no_of_friends
from person p
join friend f on p.personid = f.fid
group by 1
having sum(p.score)>100
)
select c.*,p.name as person_name 
from cte c
join person p on p.personid = c.pid;

--------------------------------------------------------------------------

/*4)write a sql query to find the cancellation rate of equests with unbanned users(both client and driver must not be banned) each day between "2023-10-01"
  and "2023-10-03". Round cancelllation rate to two decimal points.
  The cancellation rate is computed by duviding the number of cencelled (by client or driver) requests with unabnned users
   by the total number of requests with unbanned users on that day*/----(7)


Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));

insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');

insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');


select * from Trips;
select * from Users;

select request_at,
count(case when status in('cancelled_by_client','cancelled_by_driver') then 1 else null end) as cancelled_trip_count,
count(1) as total_trips,
1.0*count(case when status in('cancelled_by_client','cancelled_by_driver') then 1 else null end)/count(1)*100 as cancelled_percent
from Trips t
join Users c on t.client_id = c.users_id
join Users d on t.driver_id = d.users_id
where c.banned ='No' and d.banned ='No'
group by 1;
-----------------------------------------------------------------------------------------


