If Object_ID ('bronze.crm_cust_info', 'U') is not null
	Drop Table bronze.crm_cust_info;
Create Table bronze.crm_cust_info (
cust_id int,
cust_key nvarchar(50),
cust_firstname nvarchar(50),
cust_lastname nvarchar(50),
cust_marital_status nvarchar(50),
cust_gender nvarchar(50),
cust_create_date date
);

If Object_ID ('bronze.crm_prd_info', 'U') is not null
	Drop Table bronze.crm_prd_info;
Create Table bronze.crm_prd_info (
prd_id int, 
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_date datetime,
prd_end_date datetime
);

If Object_ID ('bronze.crm_sales_details', 'U') is not null
	Drop Table bronze.crm_sales_details;
Create table bronze.crm_sales_details (
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int, 
sls_ship_dt int,
sls_due_dt int,
sls_sales int, 
sls_quantity int,
sls_price int
);

If Object_ID ('bronze.erp_cust_az12', 'U') is not null
	Drop Table bronze.erp_cust_az12;
Create table bronze.erp_cust_az12 (
cid nvarchar(50),
bdate date, 
gen nvarchar(50)
);

If Object_ID ('bronze.erp_loc_a101', 'U') is not null
	Drop Table bronze.erp_loc_a101;
Create table bronze.erp_loc_a101(
cid nvarchar(50),
cntry nvarchar(50)
);

If Object_ID ('bronze.erp_px_cat_g1v2', 'U') is not null
	Drop Table bronze.erp_px_cat_g1v2;
Create table bronze.erp_px_cat_g1v2 (
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)
);
