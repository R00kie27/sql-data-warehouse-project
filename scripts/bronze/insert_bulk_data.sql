/*
==================================================================================
Store Procedure: Load Bronze Layer (Source -> Bronze)
==================================================================================
Script Purpose: 
	This stored procedures loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
		Truncates the bronze tables before loading data
		Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.

Parameters:
	None
	This stored procedure does not accept any parameters or return any values 
==================================================================================
*/

Create or Alter Procedure bronze.load_bronze as 
Begin
	Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
	Begin Try
		Set @batch_start_time = getdate();
		Print '=================================================';
		Print 'Loading Bronze Layer';
		Print '=================================================';

		Print '-------------------------------------------------';
		Print 'Loading CRM Table';
		Print '-------------------------------------------------';

		Set @start_time = Getdate();
		Print '>> Truncating Table: bronze.crm_cust_info';
		Truncate table bronze.crm_cust_info;
		Print '>> Inserting Data Into: bronze.crm_cust_info';
		 Bulk insert bronze.crm_cust_info
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';

		--
		Set @start_time = Getdate();
		Print '>> Truncating Table: bronze.crm_prd_info';
		Truncate table bronze.crm_prd_info;
		Print '>> Inserting Data Into: bronze.crm_prd_info';
		 Bulk insert bronze.crm_prd_info
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';

		--
		Set @start_time = Getdate();
		Print '>> Truncating Table: bronze.crm_sales_details';
		Truncate table bronze.crm_sales_details;
		Print '>> Inserting Data Into: bronze.crm_sales_details';
		 Bulk insert bronze.crm_sales_details
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';

		-- 

		Print '-------------------------------------------------';
		Print 'Loading ERP Table';
		Print '-------------------------------------------------';

		Set @start_time = Getdate();
		Print '>> Truncating Table: bronze.erp_cust_az12';
		Truncate table bronze.erp_cust_az12;
		Print '>> Inserting Data Into: bronze.erp_cust_az12';
		 Bulk insert bronze.erp_cust_az12
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';

		--
		Set @start_time = Getdate();
		Print '>> Truncating Table: bronze.erp_loc_a101';
		Truncate table bronze.erp_loc_a101;
		Print '>> Inserting Data Into: bronze.erp_loc_a101';
		 Bulk insert bronze.erp_loc_a101
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';

		--
		Set @start_time = Getdate();
		Print '>> Truncating Table: px_cat_g1v2';
		Truncate table bronze.erp_px_cat_g1v2;
		Print '>> Inserting Data Into: px_cat_g1v2';
		 Bulk insert bronze.erp_px_cat_g1v2
		 from 'C:\Users\james\OneDrive\Desktop\Computer Skills\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		 with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		Set @end_time = Getdate();
		Print 'Load Duration: ' + Cast(Datediff(second, @start_time, @end_time) as Nvarchar) + ' seconds';
		Print '>>-------------';
		Set @batch_end_time = getdate();
		Print '=======================================';
		Print ' -Loading Bronze Layer Is Completed';
		Print 'Total Load Duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds';
		Print '=======================================';
	End Try 
	Begin Catch 
		Print '=============================================';
		Print 'Error Occured During Loading Bronze Layer';
		Print 'Error Message' + Error_message();
		Print 'Error Message' + Cast(Error_number() as Nvarchar);
		Print 'Error Message' + Cast(Error_state() as Nvarchar);
		Print '=============================================';
	End Catch
End


