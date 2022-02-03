Select * 
From online_retail_cleaned;

--- break up by item (stock code), look at most succesfull items 

with UnitSales (stockcode, description, quantity, unitprice, unitsold) as 
(
select StockCode, Description, Quantity,UnitPrice,sum(Quantity) over (PARTITION by StockCode) as UnitsSold
from online_retail_cleaned
)
select StockCode, Description, (UnitPrice*unitsold) as Revenue
from unitsales
group by Description
order by revenue DESC

--- assess growth in e-sales over the past 2 years 
--- first split date into year and month 

Select Description, Country, ItemTotal,substring(InvoiceDate,1,4) as year, substring(InvoiceDate,6,2) as month
from online_retail_cleaned

--- lets look at total revenue for 2010 and 2011

with ESales (Description, Country, ItemTotal, year, month) as 
(
Select Description, Country, ItemTotal,substring(InvoiceDate,1,4) as year, substring(InvoiceDate,6,2) as month
from online_retail_cleaned)
SELECT year, sum(ItemTotal) as Revenue 
from Esales
group by year;

--- sales per country 

Select country, sum(Quantity) as TotalUnitsSold, sum(itemtotal) as revenue
from online_retail_cleaned
where country is not 'Unspecified'
group by Country;
--- lets rank the countries by revenue and units sold (use order by to determine what to rank by)

with countryRANK (country, UnitsSold, Revenue)
as (
Select country, sum(Quantity) as TotalUnitsSold, sum(itemtotal) as revenue
from online_retail_cleaned
where country is not 'Unspecified'
group by Country)
select *, rank() over(order by revenue DESC) as revrnk, rank() over(order by UnitsSold desc) as solrnk
from countryRANK;



--- how many returns and what was most returned items, insight into potential issues with certain items
select * 
from online_retail_cleaned
where quantity <0;

select StockCode, Description, sum(quantity) as returns, sum(itemtotal) as losses 
from online_retail_cleaned
where quantity <0 and stockcode is not 'M'
group by Description
order by returns 




--- Lets look at most popular item for australia

select *
from online_retail_cleaned
where country is 'Australia'
order by Description;

Select StockCode, Description, sum(quantity) as UnitsSold, sum(itemTotal) as rev, Country
from online_retail_cleaned
where country is 'Australia'
group by Description
order by uNITSSOLD DESC