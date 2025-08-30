/*
==========================================
Creates Database and Schemas
==========================================
Scripts Purpose:
This script create new database named DataWarehouse after checking if it already exists. 
If the databased exists, it will be droped and recreate. Additionally, the scripts sets up three schemas 
within the database: 'bronze', 'silver', 'gold' . 

WARNING:  
Running this script will drop the entire 'DataWarehouse' database if it exists. All data in the database 
will be permanently deleted. Proceed with caution and ensure you have proper backup before running this script 
*/

Use Master;
Go
-- Drop and recreate 'DataWarehouse' database 
If Exists ( Select 1 from sys.databases where name = 'DataWarehouse')
Begin 
  Alter Database DataWarehouse set single_user with rollback immediate;
  Drop Database DataWarehouse;
End;
Go 
  
-- Create the 'DataWarehouse' database 
Create database DataWarehouse
Go
  
-- Use 'DataWarehouse'
Use DataWarehouse
Go
  
-- Create Schemas
create schema bronze;
Go
create schema silver;
Go
create schema gold;
Go



