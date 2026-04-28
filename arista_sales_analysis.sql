-- analyzing sales manager Ellen Lemon (id -2, Region- East, State-connecticut ) territory --
-- select *
-- from management;

/* What is total revenue overall for sales in the assigned territory, plus the start date and end date
that tell you what period the data covers?*/
select sum(Sale_Amount) as total_rev, min(Transaction_Date) as start, max(Transaction_Date) as end
from store_sales
join store_locations on store_sales.Store_ID = store_locations.StoreId
join management on store_locations.State = management.State
-- where Region = 'East' , if i use region it will show the combined total for new york and connecticut and another salesmanager --
where management.State like 'Conne%'
and SalesManager = 'Ellen Lemon';
-- total_rev 2,392,222.44, start 2022-01-01, end 2025-12-31  answer for ellen or state connecticut or both same answer --
-- in just east region total revenue is 6,723,039.53 start 2022-01-01, end 2025-12-31 --


/*What is the month by month revenue breakdown for the sales territory?*/
select date_format(Transaction_Date, '%b-%y') as month, sum(Sale_Amount) as revenue, Region, SalesManager
from store_sales
join store_locations on store_sales.Store_ID = store_locations.StoreId
join management on store_locations.State = management.State
where Region = 'East'
and SalesManager like 'Ellen%'
group by month, Region, SalesManager 
order by min(Transaction_Date);
-- used w3 schools for the date format since cant use date trunic-- 
-- %b means (date in Jan, Feb), %y means (YY last two over all YYYY) --
-- this table shows from 2022-2025 monthly revenue in ellens territory --
-- if you add all 48 revenue rows you get the same amount as the above answer "total_rev 2,392,222.44" for ellen --


/*Provide a comparison of total revenue for the specific sales territory and the region it belongs to.*/
select 'Manager( Ellen Lemon)' as level, sum(Sale_Amount) as total_rev
from store_sales
join store_locations on store_locations.StoreId = store_sales.Store_ID
join management on management.State = store_locations.State
where SalesManager = 'Ellen Lemon'
union all
select 'Region(east)' as level, sum(Sale_Amount) as total_rev
from store_sales
join store_locations on store_locations.StoreId = store_sales.Store_ID
join management on management.State = store_locations.State
where Region = 'East';
-- Ellen Lemon salesmanger total is 2,392,222.44 (same as the first question) and her region total is 6,723,039.53 --
-- Ellen is the lowest in her region--
-- Gemini told me to add As Level, the way i had it shows "Ellen Lemon 2392222.44, East 6723039.53 "east was lsited under salesmanager --


/*What is the number of transactions per month and average transaction size by product category
for the sales territory?*/
select date_format(Transaction_Date, '%b-%y') as month, Category, count(store_sales.id) as transaction_num, 
	avg(Sale_Amount) as avg_trans, Region, SalesManager
from store_sales
join store_locations on store_locations.StoreId = store_sales.Store_ID
join management on management.State = store_locations.State
join products on products.ProdNum = store_sales.Prod_Num
join inventory_categories on inventory_categories.Categoryid = products.Categoryid
where SalesManager = 'Ellen Lemon'
group by month, inventory_categories.Category, SalesManager, Region
order by min(Transaction_Date), Category;
-- 6 categories so each month will show category--
-- dateformat i used is month abbriveation and last two year number-- 
-- throught the table category TECH and TEXTBOOK have the highest avg_transactions in any month/year --

/*Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory?*/
select sum(Sale_Amount) as performance, StoreId, SalesManager, StoreLocation, count(*) as transaction
from store_sales
join store_locations on store_locations.StoreId = store_sales.Store_ID
join management on management.State = store_locations.State
where Region = 'East' -- this compare Ellen to the other salesmanager in east region by storeid--
-- where SalesManager = 'Ellen Lemon' ,this shows only Ellen stores and performance--
group by StoreId, StoreLocation, SalesManager
order by performance desc
-- Ellen has storeid for connecticut state is 865-872 -- 
-- storeid 871 (ellen) has the lowest performance and 850 (new york) has the highest performance instore for East region --

-- or online sales--
select sum(SalesTotal) as performance, ShiptoState, count(*) as transactions, Region
from online_sales
join management on management.State = online_sales.ShiptoState
where Region = 'East'
group by ShiptoState, Region
order by performance desc;
-- this shows the online ranking performace by state in the east region but i know by now that ellen only has state Connecticut in the east --
-- 'Connecticut' preformance 810,270.94 and new york performance 3,143,787.73,  NY is higher.-- 


/*What is your recommendation for where to focus sales attention in the next quarter?*/

-- in the region for east which is the region for Ellen Lemon in store performance was (adding up all her storeid saleamount ) total is 2,392,222.44--
-- in the same east region (other sales manager in the same region as ellen) in store performance is 4,330,817.09 ( adding up the sales amount ) --
-- in online sales Ellen has state connectitcut in the east and ther is only two states connecticut and new york, new york performance is 3143787.73 with 4352 transactions--
-- for connecticut performance is 810270.94 with 1235 transactions --

-- east region in store sales breakdown for ellen storeid 870 in New london,Conn made 331116.76 with 2272 transactions highest 
-- other manager in store sales storeid 850 new york, NY made 621565.02 with 4476 transactions highest
-- the differnce between the two is new york, NY made 2204 more tranctions and 290448.26 more money then Ellen.
-- on the east region ellen only has 8 stores with revenue of 2,392,222.44 and other manager has 12 stores, with revenue 4,330,817.09 (region total revenue is 6,723,039.53- ellen total revenue = other manager revenue) --

-- online ellen made 1235 transaction with 810270.94 
-- other manager made 4352 tranasactiona with 3143787.73
-- ellen only holds 20% of the market in the east while other manager holds about 80%

SELECT ShiptoState, SUM(SalesTotal) AS total_online_rev, COUNT(*) AS total_transactions,
    AVG(SalesTotal) AS avg_order_value 
FROM online_sales
WHERE ShiptoState IN ('Connecticut', 'New York')
GROUP BY ShiptoState
ORDER BY avg_order_value DESC;
-- in connecticut the average order value is lower then new york by, 66.29 ( NY 722.37 - CONN 656.08)

-- for ellen in monthly sales tranaction size average TECH and TEXTBOOKs are ellens highest sales amount in store
SELECT products.CategoryID, AVG(Sale_Amount) AS overall_avg_transaction_size
FROM Store_Sales 
JOIN store_locations ON store_sales.Store_ID = store_locations.StoreId
JOIN management ON store_locations.State = management.State
JOIN Products ON store_sales.Prod_Num = products.ProdNum
WHERE SalesManager = 'Ellen Lemon'
GROUP BY CategoryID
ORDER BY overall_avg_transaction_size DESC;
-- this table shows the 6 catergories for ellen and the over all average tranaaction size per catergoryid
-- the top catergories are 120 Tech, 100 textbook, and 115 art supplies with tech having the highest avergae 
-- overall Ellen should focus on instore tech sales for the next quarter for storeid 871 as it was the lowest store she has. Since tech had he highest average transaction size, ellen should have her staff at all 8 stores focus on upselling tech items.--
-- a tech (laptop that cost 500.00) and a textbook ( that cost 100.00), tech has a higher revenue impact
-- for online sales Ellen should focus on upselling tech items as well to close the 66.29 gap between Connecticut and new york for the average order value.
 