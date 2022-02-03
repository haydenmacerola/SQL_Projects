Select * 
from merged_gw20

---- sort by transfer_balance per GW 

Select name, position, max(transfers_balance), minutes, GW
FROM merged_gw20
group by gw
order by transfers_balance;

--- ignore gw1 not relevant as transfers in cannot be based on previous GW , also add points 

Select name, position, max(transfers_balance), minutes, GW, total_points
FROM merged_gw20
Where gw > 1
group by gw
order by transfers_balance;

--- add 'performance' to indicate wether kneejerk had some sort of return (5 or more points)

Select name, position, max(transfers_balance) as tb, minutes, GW, total_points,
CASE 
WHEN total_points >= 5 then 'Hit'
WHEN total_points < 5 then 'Miss'
Else NULL
END as 'Performance'
FROM merged_gw20
where gw > 1
group by gw
order by tb DESC;

--- create cte to produce count and percentage of 'hits' that is did the kneejerked player return 5 or more points 

With Kneejerk (name, position, tb , minutes, GW, total_points, performance) 
as (
Select name, position, max(transfers_balance) as tb, minutes, GW, total_points,
CASE 
WHEN total_points >= 5 then 'Hit'
WHEN total_points < 5 then 'Miss'
Else NULL
END as 'performance'
FROM merged_gw20
where gw > 1
group by gw
order by gw )
Select count(*)
FROM Kneejerk
where performance = 'Hit';

--- amend table to add column 'year' to prepare for union 

alter table merged_gw20
ADD year INT

--- add season e.g 2020 to every row of table (need to use update)

update merged_gw20
set year = 2020;

--- add this for pl season tables 

alter table merged_gw19
add year int;

update merged_gw19
set year = 2019;

alter table merged_gw18
add year int;

update merged_gw18
set year = 2018;

alter table merged_gw17
add year int;

update merged_gw17
set year = 2017;

alter table merged_gw16
add year int;

update merged_gw16
set year = 2016;

---- union all tables 

select name, max(transfers_balance) as transfers_balance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfers_balance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfers_balance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfers_balance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfers_balance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year;

---- create cte of union-ed data 

With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year
order by total_points DESC)
Select *,
case 
when total_points >= 5 then 'Hit'
when total_points < 5 then 'Miss'
else null 
end as 'performance'
from master;


--- nested cte to produce count of performance

With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year),
results as 
(
Select *,
case 
when total_points >= 5 then 'Hit'
when total_points < 5 then 'Miss'
else null 
end as 'performance'
from master)
Select count(*) as hits 
From results 
where performance = 'Hit';
-- hits = 85

--------- notes on nested ctes, second cte no need for WITH , sperate ctes with ","
--- count rows again and divide by hits (85)
With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year
order by transfersbalance DESC)
select 85*100/count(*) as hitpercent
from master;

--- 45% return rate 
---- lets look at pogba (this weeks kneejerk)

With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year
order by total_points DESC)
Select *,
case 
when total_points >= 5 then 'Hit'
when total_points < 5 then 'Miss'
else null 
end as 'performance'
from master;

--- finding the average total_points (just going through a bunch of aggregate functions now 

With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw19
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 1
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 1
group by gw , year
order by total_points DESC)
Select *
from master
where transfersbalance > 1000000;


--- avgpoints 5.13
--- min points Richarlison 18/19 GW3 713570 tb -2 points 
---- max points Hazard 18/19 GW5 364850 tb 20 points 
----- count double digit hauls - 31


--- want to explore second half of season kneejerks lets just look at last season for this(casual players generally stop doing there teams by then)
 
 select name, max(transfers_balance) as transferbalance, minutes, gw, total_points
 from merged_gw20
 where gw >= 18
 group by gw
 order by gw;
 
 --- actually lets just record second half for all seasons excluding 19 cos its a mess due to covid
 
 With master (name, transfersbalance, minutes, GW, total_points, year)
as 
(select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw20
where gw > 18
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw18
where gw > 18
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw17
where gw > 18
group by gw , year
UNION
select name, max(transfers_balance) as transfersbalance, minutes, GW, total_points, year 
FROM merged_gw16
where gw > 18
group by gw , year),
results as 
(
Select *,
case 
when total_points >= 5 then 'Hit'
when total_points < 5 then 'Miss'
else null 
end as 'performance'
from master)
Select *
From results 
where total_points >= 10
Limit 6;

--- 39 hits post gw 18 (excluding season 19/20 due to covid giving it more gws)
--- 39/80
--- 14/80 double digit hauls 

---- search for most kneejerked player of all time? doesnt work would need to clean data :(
--- did some cleaning in excel 

Select *
FROM kneejerk
order by totalpoints ASC;


--- Harry Kane 8, Aguero 7, Son 7, Sterling 7
