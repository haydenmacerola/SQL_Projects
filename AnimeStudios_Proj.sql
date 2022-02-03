select * 
from Anime
limit 5

--- Assesment of Animation Studios 2021

--- Q1 : studio with most top 50 anime for 2021
select *
from anime 
where release_year = 2021
limit 50;
--- need to create new rankings for just 2021 releases

select name, studio,rating, release_year,
rank() over  (Order By rating DESC) as 'Year_Rank'
from Anime
where Release_year = 2021
AND release_year is not NULL
order by rating DESC
limit 50;

--- lets use a cte now to do a count for each studio

with Studios_results (name, studio, rating ,release_year, year_Rank)
as (select name, studio,rating, release_year,
rank() over  (Order By rating DESC) as '2021Rank'
from Anime
where Release_year = 2021
AND release_year is not NULL
)
select * , count() over (PARTITION by Studio) as topfiftyhits
from Studios_results
where studio is not NULL
and rating is not NULL
and year_rank <= 50
order by topfiftyhits DESC
limit 50;



--- Q2: average rating for all shows per studio in 2021

select name, studio,rating, release_year, avg(Rating) over (partition by Studio) as performance, count() over (PARTITION by studio) as titles
from Anime
where Release_year = 2021
AND release_year is not NULL
order by performance DESC
limit 100;

with cleaned_studioperformance (studio,performance, titles)
as (
select studio, avg(Rating) over (partition by Studio) as performance, count() over (PARTITION by studio) as titles
from Anime
where Release_year = 2021
AND release_year is not NULL
)
select * 
from cleaned_studioperformance
where studio is not NULL
and performance is not NULL
group by Studio
order by performance DESC



--- Q3: prevelance and success of chinese studios compared to previous years in Anime


select Name, rank, studio, rating, release_year, count() over (partition by Release_year) as titles_per_year
from anime 
where tags Like '% Chinese Animation%'
and Release_year is not NULL
and release_year > 1980 and Release_year < 2022
order by rank

;
--- shows clear growth in production of chinese animation when orderd by release_year 

--- Q4 percentage of chinese anime in 2021
with chinANI (name,studio,rating,release_year ,year_rank, tags)
as (
select name, studio,rating, release_year,
rank() over  (Order By rating DESC) as 'Year_Rank', Tags
from Anime
where Release_year = 2021
AND release_year is not NULL
order by rating DESC
limit 1000)
select *,
CASE
when tags like '%Chinese Animation%' then 'yes'
else 'no'
END as 'Chinese_Animation'
from chinAni;




