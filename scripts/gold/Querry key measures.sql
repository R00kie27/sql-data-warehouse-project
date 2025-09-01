Select 'Total Sales' as measure_name, sum(sales) as measure_value from gold.fact_sales 
union all 
Select 'Total Quantity', sum(quantity) from gold.fact_sales
Union all
Select 'Average Price', avg(price) from gold.fact_sales
Union all
Select 'Total # of Orders', count(distinct order_number) from gold.fact_sales
Union all
Select 'Total # of Proudcts', count(product_name) from gold.dim_product
Union all 
Select 'Total # of Cutomers', count(distinct customer_key) from gold.fact_sales
==================================================================================
-- Find total customer by country 
Select 
country,
count (customer_key)  as Total_customers
from gold.dim_customers cu
group by country 
order by Total_customers desc
-- Find total customer by gender 
Select 
gender,
count (customer_key)  as Total_customers
from gold.dim_customers cu
group by gender 
order by Total_customers desc
-- Fidn total products by category 
Select 
category,
count (product_key)  as Total_product
from gold.dim_product 
group by category 
order by Total_product desc
-- Find average cost by category
Select 
category,
avg(cost) as avg_cost
from gold.dim_product 
group by category 
order by avg_cost desc
-- Find total revenue by category 
Select 
pr.category,
sum(fs.sales) as total_revenue
from gold.fact_sales fs
left join gold.dim_product pr
on pr.product_key = fs.product_key
group by category
order by total_revenue desc
-- Find total revenue by customers
Select 
cs.customer_key,
cs.first_name,
cs.last_name,
sum(fs.sales) as total_revenue
from gold.fact_sales fs
left join gold.dim_customers cs 
on cs.customer_key = fs.customer_key
group by cs.customer_key,
cs.first_name,
cs.last_name
order by total_revenue desc
-- Find the distribution of sold items across countries 
Select 
cs.country, 
SUM(fs.quantity) as Total_sold
from gold.fact_sales fs 
left join gold.dim_customers cs 
on cs.customer_key = fs.customer_key
group by country 
order by Total_sold desc 
============================================================================

-- Find the 5 worst performing products 
Select top 5
pr.product_name,
sum(fs.sales) as total_revenue
from gold.fact_sales fs
left join gold.dim_product pr
on pr.product_key = fs.product_key
group by product_name
order by total_revenue asc

-- Using window funxtion 
Select * from (
Select 
pr.product_name,
sum(fs.sales) as total_revenue,
row_number() over(order by sum(fs.sales) desc) as rank_products
from gold.fact_sales fs
left join gold.dim_product pr
on pr.product_key = fs.product_key
group by product_name
) t 
where rank_products <= 5

-- Find top 10 customers generate highest revenue
cs.customer_key,
cs.first_name,
cs.last_name,
sum(fs.sales) as total_revenue
from gold.fact_sales fs
left join gold.dim_customers cs 
on cs.customer_key = fs.customer_key
group by cs.customer_key,
cs.first_name,
cs.last_name
order by total_revenue desc 

-- 3 with fewest orders placed 
Select top 10
Select top 3 
cs.customer_key,
cs.first_name,
cs.last_name,
count(distinct order_number) as total_orders
from gold.fact_sales fs
left join gold.dim_customers cs 
on cs.customer_key = fs.customer_key
group by cs.customer_key,
cs.first_name,
cs.last_name
order by total_orders asc  

============================================================================

-- Advance analytics 

Select 
year(orde_date) as order_year, 
sum(sales) as total_sales  
from gold.fact_sales 
where orde_date is not null 
group by  year(orde_date)
order by year(orde_date) 

-- Calculate the total sales per month 
-- and the running total of sales over time 
select 
order_date,
total_sale,
sum(total_sale) over (partition by year(order_date) order by order_date) as running_total,
avg(avg_price) over (order by order_date) as moving_avg
from (
select 
datetrunc(month, orde_date) as order_date, 
SUM(sales) as total_sale,
avg(price) as avg_price
from gold.fact_sales
where orde_date is not null
group by datetrunc(month, orde_date) 
) t 


/* Analyze the yearly performance of products by comparing their sales to both 
the average sales performance of the products and the previous year's sales */ 
With yearly_product_sales as (
Select 
year(fs.orde_date) as order_year,
pr.product_name,
sum(fs.sales) as current_sales
from gold.fact_sales fs 
left join gold.dim_product pr
on pr.product_key = fs.product_key
where fs.orde_date is not null 
group by year(fs.orde_date), pr.product_name )

Select 
order_year, 
product_name,
current_sales,
avg(current_sales) over (partition by product_name) as avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above avg'
	 when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below avg'
	 else 'Avg'
end avg_change,
lag(current_sales) over (partition by product_name order by order_year) as previous_year_sales,  
current_sales - lag(current_sales) over (partition by product_name order by order_year) as diff_previous,
case when current_sales - lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increased'
	 when current_sales - lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Decreased'
	 else 'No change'
end previous_change
from yearly_product_sales
order by product_name, order_year

============================================================================

-- Part-to-Whole analysis

-- Which category contribute most to overall sales 
With category_sales as (
Select 
p.category,
sum(f.sales) as total_sales
from gold.fact_sales f
left join gold.dim_product p
on f.product_key = p.product_key
group by category )

select 
category,
total_sales,
sum(total_sales) over () as overall_sales,
concat(round((cast(total_sales as float) / sum(total_sales) over ()) * 100, 2), '%') as percentage_of_total
from category_sales
order by total_sales desc  


-- Data Segmentation 

-- Segment products into cost ranges and count how mamy fall into each segments 
With product_segments as (
Select 
product_key,
product_name,
cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500-1000'
	 else 'Above 1000'
end cost_range 
from gold.dim_product )

select 
cost_range, 
count(product_key) as total_products
from product_segments
group by cost_range 
order by total_products desc 

/* Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than $5,000
	- Regular: Customers with at least 12 months of history but spending $5,000 or less
	- New: Customers with a life span less than 12 months 
And find the total number of customers by each group  */

With customer_segments as (
Select
c.customer_key,
SUM(f.sales) total_spending,
min(f.orde_date) as first_order,
max(f.orde_date) as last_order,
datediff(month, min(f.orde_date), max(f.orde_date)) as life_span
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key )
 
 Select 
 customer_pool,
 count(customer_key) as total_customers
 from (
Select 
customer_key,
total_spending,
life_span,
Case when life_span >= 12 and total_spending <= 5000 then 'Regular'
	 when life_span >= 12 and total_spending > 5000 then 'VIP'
	 else 'New'
end customer_pool
from customer_segments
) t
group by customer_pool
order by total_customers desc
============================================================================

