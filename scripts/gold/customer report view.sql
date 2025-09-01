/*
========================================================================
Customer report 
========================================================================
Purpose: 
	- This report consolidates key customer metrics and behaviors 

Highlights:
1. Gathers essential fields such as names, ages, and transaction details
2. Segments customer into categories (VIP, Regular, New) and age groups
3. Aggregates customer-level metrics:
	- total orders
	- total sales
	- total quantity purchased 
	- total products
	- lifespan (in months)
4. Calculates valuable KPIs:
	- recency (months since last order)
	- average order value 
	- average monthly spend 
========================================================================
*/ 
Create View gold.report_customers as 
with base_querry as (
/*----------------------------------------------------------------------
1) Base Query: Retrieves core column from tables
-----------------------------------------------------------------------*/
Select
f.order_number,
f.product_key,
f.orde_date,
f.sales,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
datediff(year, c.birth_date, getdate()) as age 
from gold.fact_sales f
left join gold.dim_customers c 
on c.customer_key = f.customer_key
where orde_date is not null
) 
, customer_aggregation as (
/*----------------------------------------------------------------------
2) Customer Aggregation : Summarizes key metrics at the customer level
-----------------------------------------------------------------------*/
Select 
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
SUM(sales) as total_sales,
SUM(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(orde_date) as last_order,
datediff(MONTH, min(orde_date), max(orde_date)) as life_span
from base_querry
group by customer_key,
		customer_number,
		customer_name,
		age
)

Select 
customer_key,
customer_number,
customer_name,
age,
Case When age < 20 then 'Under 20'
	 When age between 20 and 29 then '20-29'
	 When age between 30 and 39 then '30-39'
	 Else '40 and above'
end as age_group,
Case when life_span >= 12 and total_sales <= 5000 then 'Regular'
	 when life_span >= 12 and total_sales > 5000 then 'VIP'
	 else 'New'
end as customer_pool, 
last_order,
Datediff(month, last_order, getdate()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
life_span,
-- Compute avergae order value
Case when total_orders = 0 then 0 
	else total_sales/ total_orders
end as avg_order_value,
-- Compute average monthly spend 
Case when life_span = 0 then total_sales 
	else total_sales / life_span
end as avg_monthly_spend
from customer_aggregation
 

