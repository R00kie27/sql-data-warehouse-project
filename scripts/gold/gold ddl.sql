/* 
===============================================================================================================================
DDL Script: Create Gold Views
===============================================================================================================================
Script Purpose:
  This script create view for the Gold layer in the datawarehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)
  
  Each view perform tranformation and combines data from the Silver layer 
  to produce a clean, enriched and business-ready dataset.
Usage: 
  These views can be querries directly for analytics and reporting 
===============================================================================================================================
*/

-- Create Dimension: gold.dim_customers
>> ==========================================
If Object_ID ('gold.dim_customers', 'V') is not null 
  Drop View gold.dim_customers;
Go 
Create View gold.dim_customers as 
Select 
	Row_number() over (order by cust_id) as customer_key,
	ci.cust_id as customer_id,
	ci.cust_key as customer_number,
	ci.cust_firstname as first_name,
	ci.cust_lastname as last_name,
	la.cntry as country,
	ci.cust_marital_status as marital_status,
	case when ci.cust_gender != 'N/A' then ci.cust_gender --CRM is the Master for Gender Info
		 else coalesce(ca.gen, 'N/A')
	end as gender,
	ca.bdate as birth_date,
	ci.cust_create_date as create_date
	from silver.crm_cust_info ci 
	left join silver.erp_cust_az12 ca 
	on		ca.cid = ci.cust_key
	left join silver.erp_loc_a101 la
	on		la.cid = ci.cust_key
Go
-- Create Dimension: gold.dim_product
>> ==========================================
If Object_ID ('gold.dim_product', 'V') is not null 
  Drop View gold.dim_product;
Go   
Create View gold.dim_product as 
select 
	Row_number() over (order by pn.prd_start_date, pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cast_id as category_id,
	pc.cat as category,
	pc.subcat as sub_category,
	pc.maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_date
from [silver].[crm_prd_info] pn
left join silver.erp_px_cat_g1v2 pc
	on pc.id = pn.cast_id
where prd_end_date is null --Filter out all historical data
Go
-- Create Dimension: gold.fact_sales
>> ==========================================
If Object_ID ('gold.fact_sales', 'V') is not null 
  Drop View gold.fact_sales;
Go   
Create View gold.fact_sales as 
Select 
  sd.sls_ord_num as order_number,
  pr.product_key,
  cu.customer_key,
  sd.sls_order_dt as orde_date,
  sd.sls_ship_dt as ship_date,
  sd.sls_due_dt as due_date,
  sd.sls_sales as sales,
  sd.sls_quantity as quantity,
  sd.sls_price as price
from silver.crm_sales_details sd 
left join gold.dim_product pr
  on sd.sls_prd_key = pr.product_number 
left join gold.dim_customers cu
  on sd.sls_cust_id = cu.customer_id
Go

