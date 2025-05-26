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
