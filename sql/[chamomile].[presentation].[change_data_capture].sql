/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		Exam 70-463: Implementing a Data Warehouse with Microsoft SQL Server 2012 
		Extract and Transform Data (23%): Design data flow:  
		...use different methods to pull out changed data from data sources; 
 
		Change data capture records insert, update, and delete activity that is applied to a SQL Server table.  
		This makes the details of the changes available in an easily consumed relational format. Column information  
		and the metadata that is required to apply the changes to a target environment is captured for the  
		modified rows and stored in change tables that mirror the column structure of the tracked source tables.  
		Table-valued functions are provided to allow systematic access to the change data by consumers. 

		A good example of a data consumer that is targeted by this technology is an extraction, transformation,  
		and loading (ETL) application. An ETL application incrementally loads change data from SQL Server source  
		tables to a data warehouse or data mart. Although the representation of the source tables within the  
		data warehouse must reflect changes in the source tables, an end-to-end technology that refreshes a  
		replica of the source is not appropriate. Instead, you need a reliable stream of change data that is  
		structured so that consumers can apply it to dissimilar target representations of the data. SQL Server  
		change data capture provides this technology. 

	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
		SQL Server Agent must be running for this presentation.


	--
	-- references
	---------------------------------------------
		[chamomile] uses change data capture to log a history of changes to [repository_secure].[data].
		[chamomile].[repository].[get_change]
		[chamomile].[repository].[get_change_job]

		CHANGE DATA CAPTURE 
			Change Data Capture - http://technet.microsoft.com/en-us/library/bb522489(v=sql.105).aspx
			About Change Data Capture (SQL Server) - http://msdn.microsoft.com/en-us/library/cc645937.aspx
			Enable and Disable Change Data Capture (SQL Server) - http://msdn.microsoft.com/en-us/library/cc627369.aspx
			Introduction to Change Data Capture (CDC) in SQL Server 2008 - http://blog.sqlauthority.com/2009/08/15/sql-server-introduction-to-change-data-capture-cdc-in-sql-server-2008/
			Track Data Changes (SQL Server): http://msdn.microsoft.com/en-us/library/bb933994.aspx 
			About Change Data Capture (SQL Server): http://msdn.microsoft.com/en-us/library/cc645937.aspx 
			Change Data Capture Functions (Transact-SQL): http://msdn.microsoft.com/en-us/library/bb510744.aspx 
			Change Data Capture Stored Procedures (Transact-SQL): http://msdn.microsoft.com/en-us/library/bb500244.aspx 
			Change Data Capture Tables (Transact-SQL): http://msdn.microsoft.com/en-us/library/bb500353.aspx 
			http://technet.microsoft.com/en-us/library/bb510627.aspx UPDATE1 VS UPDATE2:  
				3 = update (captured column values are those before the update operation). This value applies only when the  
				row filter option 'all update old' is specified.  
				4 = update (captured column values are those after the update operation) 
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'change_data_capture') is null
  execute (N'create schema change_data_capture');

go

-------------------------------------------------
-- code block end
--
--
--  ENABLE CHANGE DATA CAPTURE FOR A DATABASE 
--  [sys].sp_cdc_disable_db - Enables change data capture for the current database. This procedure must be executed for a  
--    database before any tables can be enabled for change data capture in that database. Change data capture records  
--    insert,  update, and delete activity applied to enabled tables, making the details of the changes available in  
--    an easily consumed relational format. Column information that mirrors the column structure of a tracked source  
--    table is captured for the modified rows, along with the metadata needed to apply the changes to a target environment. 
--************************************************************************************************************************** 
--************************************************************************************************************************** 
-- 
--
-- code block begin
-------------------------------------------------
if (select [is_cdc_enabled]
    from   [sys].[databases]
    where  [name] = N'chamomile')
   = 1
  exec [sys].[sp_cdc_disable_db];

go

--
--  todo - what is created here?
-------------------------------------------------
exec [sys].sp_cdc_enable_db;

go

-------------------------------------------------
-- code block end
--
/*
	ENABLE CHANGE DATA CAPTURE FOR A TABLE 
	  [sys].sp_cdc_disable_table - Enables change data capture for the specified source table in the current database. When a  
		table is enabled for change data capture, a record of each data manipulation language (DML) operation applied to  
		the table is written to the transaction log. The change data capture process retrieves this information from the 
		log and writes it to change tables that are accessed by using a set of functions. 
*/
-- 
-- code block begin
-------------------------------------------------
--
--  Disable Change Data Tracking for [change_data_capture].[meta_data] 
-------------------------------------------------
if exists
   (select [tables].[is_tracked_by_cdc]
    from   [sys].[tables] as [tables]
    where  [tables].[name] = N'meta_data'
           and [is_tracked_by_cdc] = 1)
  execute [sys].sp_cdc_disable_table
    @source_schema      = N'change_data_capture'
    , @source_name      = N'meta_data'
    , @capture_instance = N'change_data_capture_meta_data';

go

if object_id(N'[change_data_capture].[meta_data]', N'U') is not null
  drop table [change_data_capture].[meta_data];

go

create table [change_data_capture].[meta_data] (
  [id]            [int] identity(1, 1) not null
  , [category]    [sysname]
  , [class]       [sysname]
  , [type]        [sysname]
  , [value]       [nvarchar](max)
  , [constraint]  [nvarchar](max)
  , [description] [nvarchar](max)
  constraint [change_data_capture.meta_data.id.clustered_primary_key] primary key clustered ( [id] asc )
  );

go

-- 
--  @capture_instance defaults to <@source_schema>_<@source_name> or it can be named explicitly as is done here. 
--  @filegroup_name: allows the change table to be created on the specified filegroup. Default will be used 
--    if @filegroup_name is NULL. 
--  todo - what is created here?? 
exec [sys].sp_cdc_enable_table
  @source_schema          = N'change_data_capture'
  , @source_name          = N'meta_data'
  , @role_name            = null
  , @capture_instance     =N'change_data_capture_meta_data'
  , @supports_net_changes = 1

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Getting information about the change data capture enabled table 
-------------------------------------------------
execute [sys].sp_cdc_help_change_data_capture
  @source_schema = N'change_data_capture'
  , @source_name = N'meta_data';

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  Returns captured columns only for the @capture_instance 
-------------------------------------------------
execute [sys].[sp_cdc_get_captured_columns]
  @capture_instance = 'change_data_capture_meta_data';

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  Notice that there are new objects and functions created for the change data capture enabled table 
-------------------------------------------------
select object_schema_name([objects].[object_id]) as [schema]
       , [name]
       , [type_desc]
       , [create_date]
from   [sys].[objects] as [objects]
where  lower([objects].[name]) like lower(N'%meta_data%')
order  by [schema]
          , [name];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  fn_cdc_get_all_changes_: Returns one row for each change applied to the source table within the specified log sequence number (LSN) range. 
--  fn_cdc_get_net_changes_: Returns one net change row for each source row changed within the specified LSN range. 
--
--  Returns all captured columns 
--  Note that these instances will NOT show up until the database is enabled for change data capture!
-------------------------------------------------
select [tables].[name]                      as [source_table]
       , [capture_table].[name]             as [capture_table]
       , [change_tables].[capture_instance] as [capture_instance]
       , [captured_columns].[column_name]   as [column_name]
       , [captured_columns].[column_type]   as [column_type]
from   [cdc].[captured_columns] as [captured_columns]
       join [cdc].[change_tables] as [change_tables]
         on [change_tables].[object_id] = [captured_columns].[object_id]
       join [sys].[tables] as [capture_table]
         on [capture_table].[object_id] = [captured_columns].[object_id]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [change_tables].[source_object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [schemas].[name] = N'change_data_capture'
       and [tables].[name] = N'meta_data';

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  Returns one row for each change table in the database. 
select *
from   [cdc].[change_tables];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  Returns one row for each index column associated with a change table. 
select *
from   [cdc].[index_columns];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Returns one row for each transaction having rows in a change table.  
select *
from   [cdc].[lsn_time_mapping];

-------------------------------------------------
-- code block end
--
-- code block begin
-------------------------------------------------
--
-- TRACKING CHANGES IN A TABLE 
-------------------------------------------------
-- 
insert into [change_data_capture].[meta_data]
            ([category],[class],[type],[constraint],[description])
values      (N'flower',N'rose',N'red',null,N'a red rose'),
            (N'flower',N'rose',N'yellow',null,N'a Texas rose');

go

waitfor delay N'00:00:02';

update [change_data_capture].[meta_data]
set    [description] = N'a very red rose'
where  [category] = N'flower'
       and [class] = N'rose'
       and [type] = N'red';

select [id]
       , [category]
       , [class]
       , [type]
       , [constraint]
       , [description]
from   [change_data_capture].[meta_data];

go

-------------------------------------------------
-- code block end
--
-- code block begin
-------------------------------------------------
--
-- View data changes 
-- 
-- [cdc].fn_cdc_get_all_changes_ - returns all changes for a tracked table 
-------------------------------------------------
declare @from_lsn binary(10),@to_lsn binary(10)

set @from_lsn = [sys].fn_cdc_get_min_lsn('change_data_capture_meta_data');
set @to_lsn = [sys].fn_cdc_get_max_lsn();

select *
from   [cdc].[fn_cdc_get_all_changes_change_data_capture_meta_data] (@from_lsn, @to_lsn, N'all');

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Get changes for a specific primary key value 
-- Join to [cdc].lsn_time_mapping to return transaction start and end times 
declare @from_lsn binary(10),@to_lsn binary(10)

set @from_lsn = [sys].fn_cdc_get_min_lsn('change_data_capture_meta_data');
set @to_lsn = [sys].fn_cdc_get_max_lsn();

select case [change_data_function].__$operation when 1 then
             N'DELETE'
           when 2 then
             N'INSERT'
           when 3 then
             N'UPDATE1'
           when 4 then
             N'UPDATE2'
       end as N'Operation'
       , [change_data_function].[id]
       , [change_data_function].[category]
       , [change_data_function].[class]
       , lst.tran_begin_time
       , lst.tran_end_time
       , [change_data_function].*
from   [cdc].fn_cdc_get_all_changes_change_data_capture_meta_data (@from_lsn, @to_lsn, N'all') as [change_data_function]
       join [cdc].lsn_time_mapping as lst
         on [change_data_function].__$start_lsn = lst.start_lsn
where  [change_data_function].[id] = 1
order  by [change_data_function].[id]
          , [change_data_function].__$start_lsn
          , [change_data_function].__$seqval;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  DDL CHANGES 
--  Note that the columns added here will NOT automatically be cdc tracked! 
-- 
alter table change_data_capture.meta_data
  add [entry] xml;

go

alter table change_data_capture.meta_data
  alter column [class] nvarchar(250) not null;

go

-- 
-- This one is not tracked 
alter table [change_data_capture].[meta_data]
  with nocheck add constraint ck_id check ([id] > 0);

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
select *
from   [cdc].ddl_history as dh
       join [sys].[tables] as [tables]
         on [tables].[object_id] = dh.source_object_id
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [schemas].[name] = N'change_data_capture'
       and [tables].[name] = N'meta_data';

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Check to see if a column has changed 
-------------------------------------------------
declare @from_lsn binary(10),@to_lsn binary(10),@groupnm_ordinal int;

set @from_lsn = [sys].[fn_cdc_get_min_lsn]('change_data_capture_meta_data');
set @to_lsn = [sys].[fn_cdc_get_max_lsn]();
set @groupnm_ordinal = [sys].[fn_cdc_get_column_ordinal]('change_data_capture_meta_data', 'category');

select @from_lsn
       , @to_lsn
       , @groupnm_ordinal;

select [sys].[fn_cdc_is_bit_set](@groupnm_ordinal, __$update_mask) as 'IsGroupNmUpdated'
       , *
from   [cdc].[fn_cdc_get_all_changes_change_data_capture_meta_data](@from_lsn, @to_lsn, 'all')
where  __$operation = 4;

go
-------------------------------------------------
-- code block end
--
