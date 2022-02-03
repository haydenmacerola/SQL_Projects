--- compare value gw 1 to 38 (47 in the case of the 19/20 szn), make temp tables and join , use drop table to cycle through every season

Drop table if exists TEMP_GW1
Create Table TEMP_GW1 (name TEXT,pos TEXT,value int,GW int)
Insert into TEMP_GW1
Select name, position, value,gw
From cleaned_merged_seasons
where season_x = '2019-20' and GW = 1;

Select * from TEMP_GW1

Drop table if exists TEMP_GW38
CREATE Table TEMP_GW38 (name TEXT,pos TEXT,value int,GW int)
Insert into TEMP_GW38
Select name, position, value,gw
From cleaned_merged_seasons
where season_x = '2019-20' AND GW = 47;


Select * 
from TEMP_GW38

--- tables joined now we want to return the value change in a new column , might use a cte here 

With VALUETABLE (name, pos,v1,GW,name,pos,v2, GW)
as(
Select * from TEMP_GW1 
join TEMP_GW38 
on TEMP_GW1.name = TEMP_GW38.name)
Select *, (v2 - v1) as value_change
FROM ValueTable
order by value_change DESC;
