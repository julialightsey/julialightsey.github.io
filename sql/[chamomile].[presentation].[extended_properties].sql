/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

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
	
	--
	-- references
	---------------------------------------------
	sys.extended_properties (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms177541.aspx
	sql_variant (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms173829.aspx
		sql_variant can have a maximum length of 8016 bytes
	sys.fn_listextendedproperty (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms179853.aspx
	sp_addextendedproperty (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms180047.aspx
	sp_dropextendedproperty (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms178595.aspx
	sp_updateextendedproperty (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms186885.aspx
*/
--
-- code block begin
-------------------------------------------------
--
-- analyze an existing database to determine how many objects require documentation
--  note that, in a newly created database, there will be about five hundred columns.
-------------------------------------------------
--use [{database}];
go
--
-- how many schema objects are there in the database?
-------------------------------------------------
-------------------------------------------------
declare @procedure_count   [int] = (select count(*) as [procedure_count]
           from   [sys].[procedures])
        , @function_count  [int] = (select count(*)
           from   [sys].[objects]
           where  lower([type_desc]) like N'%function%')
        , @parameter_count [int] = (select count(*) as [parameter_count]
           from   [sys].[parameters])
        , @table_count     [int] = (select count(*)
           from   [sys].[tables])
        , @view_count      [int] = (select count(*)
           from   [sys].[views])
        , @column_count    [int] = (select count(*)
           from   [sys].[columns]);
select @procedure_count   as [procedure_count]
       , @function_count  as [function_count]
       , @parameter_count as [parameter_count]
       , @table_count     as [table_count]
       , @view_count      as [view_count]
       , @column_count    as [column_count]
       , @procedure_count + @function_count
         + @parameter_count + @table_count + @view_count
         + @column_count  as [total_object_count];
--
-- how many extended properties are there to document schema objects?
-------------------------------------------------
select count(*) as [extended_property_count]
from   [sys].[extended_properties];
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- evaluate the columns and parameters in your database for clarity
-------------------------------------------------
select distinct object_schema_name([object_id]) as [schema]
                , object_name([object_id])      as [parent]
                , [name]                        as [object_name]
from   [sys].[columns]
order  by [name]
          , [parent];
go
--
select distinct object_schema_name([object_id]) as [schema]
                , object_name([object_id])      as [parent]
                , [name]                        as [object_name]
from   [sys].[parameters]
order  by [name];
go
-----------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- how many procedures have more than ten parameters and how many tables have 
--	more than 25 columns (a measure of complexity)?
select [major_object].[name]          as [table]
       , count([minor_object].[name]) as [column_count]
from   [sys].[tables] as [major_object]
       inner join [sys].[columns] as [minor_object]
               on [major_object].[object_id] = [minor_object].[object_id]
group  by [major_object].[name]
having count([minor_object].[name]) > 25
order  by count([minor_object].[name]) desc;
go
--
select [major_object].[name]          as [procedure]
       , count([minor_object].[name]) as [parameter_count]
from   [sys].[procedures] as [major_object]
       inner join [sys].[parameters] as [minor_object]
               on [major_object].[object_id] = [minor_object].[object_id]
group  by [major_object].[name]
having count([minor_object].[name]) > 10
order  by count([minor_object].[name]) desc;
go 

-------------------------------------------------
-- code block end
--


-- execute [where_documentation_is_needed].sql


--
-- code block begin
-------------------------------------------------


-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create a database to be used for testing
--	rename this as required to avoid overwriting existing objects
-------------------------------------------------
use [master];
go
if db_id(N'extended_properties_test') is not null
  drop database [extended_properties_test];
go
if db_id(N'extended_properties_test') is null
  create database [extended_properties_test];
go
use [extended_properties_test];
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- database properties
--	1. implement this block of code then select "properties" on the database in SSMS and select "extended properties"
--  2. add a new extended property with a unique name and description and then find it both in SSMS and by script.
--	repeat these two steps for each section in the presentation
-------------------------------------------------
-------------------------------------------------
if exists
   (select *
    from   sys.fn_listextendedproperty(N'description', default, default, default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = null
    , @level0name = null
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'database [extended_properties_test] is used for a test sandbox for the extended properties presentation. No permanent objects should be placed here. This database may be deleted at will.'
  , @level0type = null
  , @level0name = null
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
if exists
   (select *
    from   sys.fn_listextendedproperty(N'revision_20140729', default, default, default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140729'
    , @level0type = null
    , @level0name = null
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140729'
  , @value      = N'Katherine E. Lightsey - created.'
  , @level0type = null
  , @level0name = null
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   sys.fn_listextendedproperty(N'package_extended_properties_demonstration', default, default, default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = null
    , @level0name = null
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = null
  , @level0name = null
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
--
-- you can extract extended properties by name
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   sys.fn_listextendedproperty(N'description', default, default, default, default, default, default) as [extended_properties];
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   sys.fn_listextendedproperty(N'revision_20140729', default, default, default, default, default, default) as [extended_properties];
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   sys.fn_listextendedproperty(N'package_extended_properties_demonstration', default, default, default, default, default, default) as [extended_properties];
--
-- you can extract all extended properties for an object
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   sys.fn_listextendedproperty(default, default, default, default, default, default, default) as [extended_properties];
--
-- you can extract extended properties directly from system views
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
       , [extended_properties].[class]
       , [extended_properties].[class_desc]
       , [extended_properties].[major_id]
       , [extended_properties].[minor_id]
from   [sys].[extended_properties] as [extended_properties]
where  [extended_properties].[class_desc] = N'DATABASE';
--
-- you can extract extended properties using pattern matching
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
       , [extended_properties].[class]
       , [extended_properties].[class_desc]
       , [extended_properties].[major_id]
       , [extended_properties].[minor_id]
from   [sys].[extended_properties] as [extended_properties]
where  [extended_properties].[class_desc] = N'DATABASE'
       and [extended_properties].[name] like N'%revision%';
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   sys.fn_listextendedproperty(default, default, default, default, default, default, default) as [extended_properties]
where  [name] like N'%package%';
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- schema level properties
-------------------------------------------------
-------------------------------------------------
if schema_id(N'workflow') is null
  execute('create schema workflow');
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'workflow', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'schema [workflow] contains objects specific to workflow including command objects.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140729', N'schema', N'workflow', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140729'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140729'
  , @value      = N'Katherine E. Lightsey - created.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'workflow', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
--
---------------------------------------------
if schema_id(N'billing') is null
  execute('create schema billing');
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'schema [billing] is is a grouping of business objects that... business description stuff goes here...'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140601', N'schema', N'billing', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140601'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140601'
  , @value      = N'Katherine E. Lightsey - created.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140729', N'schema', N'billing', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140729'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140729'
  , @value      = N'Updated to include the quick brown fox jumps over the lazy dog.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'billing', default, default, default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = null
    , @level1name = null
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = null
  , @level1name = null
  , @level2type = null
  , @level2name =null;
--
-- properties can be extracted individually or 
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
from   fn_listextendedproperty(default, N'schema', N'billing', default, default, default, default) as [extended_properties];
select [extended_properties].[name]
       , [extended_properties].[value]
from   fn_listextendedproperty(default, N'schema', N'workflow', default, default, default, default) as [extended_properties];
select [extended_properties].[name]
       , [extended_properties].[value]
from   fn_listextendedproperty(default, N'schema', default, default, default, default, default) as [extended_properties];
--
---------------------------------------------
select [extended_properties].[name]
       , [extended_properties].[value]
       , [extended_properties].[class]
       , [extended_properties].[class_desc]
       , [extended_properties].[major_id]
       , [extended_properties].[minor_id]
from   [sys].[schemas] as [schemas]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [schemas].[schema_id]
where  [schemas].[name] = N'billing';
--
---------------------------------------------
select [schemas].[name]                     as [schema]
       , [extended_properties].[name]       as [property]
       , [extended_properties].[value]      as [value]
       , [extended_properties].[class]      as [class]
       , [extended_properties].[class_desc] as [class_description]
       , [extended_properties].[major_id]   as [major_id]
       , [extended_properties].[minor_id]   as [minor_id]
from   [sys].[schemas] as [schemas]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [schemas].[schema_id]
order  by [schema]
          , [property];
--
---------------------------------------------
select [schemas].[name]                     as [schema]
       , [extended_properties].[name]       as [property]
       , [extended_properties].[value]      as [value]
       , [extended_properties].[class]      as [class]
       , [extended_properties].[class_desc] as [class_description]
       , [extended_properties].[major_id]   as [major_id]
       , [extended_properties].[minor_id]   as [minor_id]
from   [sys].[schemas] as [schemas]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [schemas].[schema_id]
where  [schemas].[name] = N'billing'
       and [extended_properties].[name] like N'revision_%'
order  by [schema]
          , [property];
--
---------------------------------------------
select [schemas].[name]                     as [schema]
       , [extended_properties].[name]       as [property]
       , [extended_properties].[value]      as [value]
       , [extended_properties].[class]      as [class]
       , [extended_properties].[class_desc] as [class_description]
       , [extended_properties].[major_id]   as [major_id]
       , [extended_properties].[minor_id]   as [minor_id]
from   [sys].[schemas] as [schemas]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [schemas].[schema_id]
where  [extended_properties].[name] = N'package_extended_properties_demonstration'
order  by [schema]
          , [property];
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- table properties
-------------------------------------------------
-------------------------------------------------
if object_id(N'[billing].[reconciliation]') is not null
  drop table [billing].[reconciliation];
---------------------------------------------
create table [billing].[reconciliation] (
  [id]       [int] identity(1, 1) not null,
    constraint [billing.reconciliation.id.clustered_primary_key] primary key clustered ([id])
  , [amount] [money] not null
  , [type]   [sysname] not null constraint [billing.reconciliation.type.check] check (lower([type]) in (N'on_time', N'late', N'coerced'))
  , [added]  [datetime] not null constraint [billing.reconciliation.added.default] default (current_timestamp)
  );
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing reconciliation table.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = null
  , @level2name =null;
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140729', N'schema', N'billing', N'table', N'reconciliation', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140729'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140729'
  , @value      = N'Katherine E. Lightsey - created.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = null
  , @level2name =null;
--
-- update an extended property
---------------------------------------------
exec sp_updateextendedproperty
  @name         = N'description'
  , @value      = N'billing reconciliation table updated version.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation';
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'billing', N'table', N'reconciliation', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = null
  , @level2name =null;
--
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', null, null);
--
-- to view documentation
---------------------------------------------
declare @schema   [sysname] = N'billing'
        , @object [sysname] = N'reconciliation';
select [schemas].[name]                as [schema]
       , [objects].[name]              as [object]
       , [extended_properties].[name]  as [property]
       , [extended_properties].[value] as [value]
from   [sys].[extended_properties] as [extended_properties]
       join [sys].[tables] as [objects]
         on [objects].[object_id] = [extended_properties].[major_id]
       join [sys].[schemas] as [schemas]
         on [objects].[schema_id] = [schemas].[schema_id]
where  [schemas].[name] = @schema
       and [objects].[name] = @object;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- column properties
-------------------------------------------------
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'id'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'COLUMN'
    , @level2name =N'id';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'<ol><li></li></ol>'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'COLUMN'
  , @level2name =N'id';
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'amount'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'COLUMN'
    , @level2name =N'amount';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing amount column.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'COLUMN'
  , @level2name =N'amount';
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'added'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'COLUMN'
    , @level2name =N'added';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing added Timestamp'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'COLUMN'
  , @level2name =N'added';
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'id');
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'amount');
---------------------------------------------
select [schemas].[name]
       , [tables].[name]
       , [columns].[name]
       , [extended_properties].*
from   [sys].[columns] as [columns]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [columns].[object_id]
            and [columns].column_id = [extended_properties].[minor_id]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [schemas].[name] = N'billing'
       and [tables].[name] = N'reconciliation';
--
-- using cross apply 
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'COLUMN', N'id');
select [schemas].[name]
       , [tables].[name]
       , [columns].[name]
       , [extended_properties].[name]
       , [extended_properties].[value]
from   [sys].[tables] as [tables]
       join [sys].[columns] as [columns]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
       cross apply fn_listextendedproperty(null, N'schema', [schemas].[name], N'table', [tables].[name], N'COLUMN', [columns].[name]) as [extended_properties];
--
-- extracting both table and column documentation
---------------------------------------------
select [schemas].[name]                as [schema]
       , [objects].[name]              as [object]
       , N'table'                      as [type]
       , [extended_properties].[name]  as [property]
       , [extended_properties].[value] as [value]
from   [sys].[extended_properties] as [extended_properties]
       left join [sys].[tables] as [objects]
              on [objects].[object_id] = [extended_properties].[major_id]
       join [sys].[schemas] as [schemas]
         on [objects].[schema_id] = [schemas].[schema_id]
union
select [schemas].[name]                as [schema]
       , [objects].[name]              as [object]
       , N'column'                     as [type]
       , [extended_properties].[name]  as [property]
       , [extended_properties].[value] as [value]
from   [sys].[columns] as [columns]
       join [sys].[tables] as [objects]
         on [objects].[object_id] = [columns].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [objects].[schema_id]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [schemas].[schema_id]
order  by [schema]
          , [object]
          , [property];
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- Index properties
-------------------------------------------------
-------------------------------------------------
if indexproperty(object_id(N'[billing].[reconciliation]', N'U'), N'billing.reconciliation.amount.index', N'index_id') is not null
  drop index [billing.reconciliation.amount.index] on [billing].[reconciliation];
create index [billing.reconciliation.amount.index]
  on [billing].[reconciliation]([amount]);
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'INDEX', N'billing.reconciliation.amount.index'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'INDEX'
    , @level2name =N'billing.reconciliation.amount.index';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing billing.reconciliation.amount.index Index.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'INDEX'
  , @level2name =N'billing.reconciliation.amount.index';
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'billing', N'table', N'reconciliation', N'INDEX', N'billing.reconciliation.amount.index'))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'INDEX'
    , @level2name =N'billing.reconciliation.amount.index';
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'INDEX'
  , @level2name =N'billing.reconciliation.amount.index';
---------------------------------------------
if indexproperty(object_id(N'[billing].[reconciliation]'), N'billing.reconciliation.added.index', N'index_id') is not null
  drop index [billing.reconciliation.added.index] on [billing].[reconciliation];
create index [billing.reconciliation.added.index]
  on [billing].[reconciliation]([amount]);
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'INDEX', N'billing.reconciliation.added.index'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'INDEX'
    , @level2name =N'billing.reconciliation.added.index';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing billing.reconciliation.added.index Index.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'INDEX'
  , @level2name =N'billing.reconciliation.added.index';
--
-- get documentation for a specific index
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'INDEX', N'billing.reconciliation.amount.index');
--
-- get documentation for all indexes
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'INDEX', null);
---------------------------------------------
select *
from   fn_listextendedproperty(null, N'schema', N'billing', N'table', N'reconciliation', N'INDEX', null)
where  [name] = N'package_extended_properties_demonstration';
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- constraint properties
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'CONSTRAINT', N'billing.reconciliation.type.check'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'CONSTRAINT'
    , @level2name =N'billing.reconciliation.type.check';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing.reconciliation.type.check validates that the type is constrained to only allowable and expected values. If these same constraints are used in multiple tables a meta data table should be considered and a foreign key reference should replace this check constraint.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'CONSTRAINT'
  , @level2name =N'billing.reconciliation.type.check';
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'CONSTRAINT', N'billing.reconciliation.added.default'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'CONSTRAINT'
    , @level2name =N'billing.reconciliation.added.default';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing.reconciliation.added.default setst the [added] field to the current timestamp.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'CONSTRAINT'
  , @level2name =N'billing.reconciliation.added.default';
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'billing', N'table', N'reconciliation', N'CONSTRAINT', N'billing.reconciliation.id.clustered_primary_key'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'CONSTRAINT'
    , @level2name =N'billing.reconciliation.id.clustered_primary_key';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'billing.reconciliation.id.clustered_primary_key is the primary key constraint on the primary key of the table and it really is good with milk and vanilla wafer cookies.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'CONSTRAINT'
  , @level2name =N'billing.reconciliation.id.clustered_primary_key';
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'billing', N'table', N'reconciliation', N'CONSTRAINT', N'billing.reconciliation.id.clustered_primary_key'))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'billing'
    , @level1type = N'table'
    , @level1name = N'reconciliation'
    , @level2type = N'CONSTRAINT'
    , @level2name =N'billing.reconciliation.id.clustered_primary_key';
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N'Implementation of extended properties demonstration.'
  , @level0type = N'schema'
  , @level0name = N'billing'
  , @level1type = N'table'
  , @level1name = N'reconciliation'
  , @level2type = N'CONSTRAINT'
  , @level2name =N'billing.reconciliation.id.clustered_primary_key';
--
-- get check constraint properties
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
select object_schema_name([tables].[object_id])
       , [tables].[name]                   as [table]
       , [check_constraints].[name]        as [check_constraint]
       , [check_constraints].[create_date] as [create_date]
       , [extended_properties].[name]      as [property]
       , [extended_properties].[value]     as [value]
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[check_constraints] as [check_constraints]
         on [check_constraints].[parent_object_id] = [tables].[object_id]
            and [check_constraints].[parent_column_id] = [columns].[column_id]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [check_constraints].[object_id];
-------------------------------------------------
-- code block end
--
--
-- get default constraint properties
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
select object_schema_name([tables].[object_id])
       , [tables].[name]                     as [table]
       , [default_constraints].[name]        as [check_constraint]
       , [default_constraints].[create_date] as [create_date]
       , [extended_properties].[name]        as [property]
       , [extended_properties].[value]       as [value]
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[default_constraints] as [default_constraints]
         on [default_constraints].[parent_object_id] = [tables].[object_id]
            and [default_constraints].[parent_column_id] = [columns].[column_id]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [default_constraints].[object_id];
-------------------------------------------------
-- code block end
--
--
-- get primary key constraint properties
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
select [schemas].[name]                as [schema]
       , [tables].[name]               as [table]
       , [columns].[name]              as [column]
       , [indexes].[name]              as [index]
       , [types].[name]                as [type]
       , [extended_properties].[name]  as [property]
       , [extended_properties].[value] as [value]
from   [sys].[indexes] as [indexes]
       inner join [sys].[index_columns] as [index_columns]
               on [indexes].[object_id] = [index_columns].[object_id]
                  and [indexes].index_id = [index_columns].index_id
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [index_columns].[object_id]
       join [sys].[columns] as [columns]
         on [columns].[object_id] = [tables].[object_id]
            and [columns].[column_id] = [index_columns].[column_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
       join [sys].[types] as [types]
         on [types].[user_type_id] = [columns].[user_type_id]
       join [sys].[key_constraints] as [key_constraints]
         on [key_constraints].[parent_object_id] = [tables].[object_id]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [key_constraints].[object_id]
where  [indexes].[is_primary_key] = 1;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- get all schema properties
-------------------------------------------------
select object_schema_name([major_id])
       , object_name([major_id])
       , *
from   [sys].[extended_properties]
where  object_schema_name([major_id]) in ( N'billing', N'workflow' );
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- procedure properties
-------------------------------------------------
-------------------------------------------------
if object_id(N'[workflow].[set]', N'P') is not null
  drop procedure [workflow].[set];
go
create procedure [workflow].[set]
  @id       [int] = null
  , @flower [sysname] = null
  , @color  [sysname] = null
  , @stack  [xml] = null output
as
  begin
      select N'do something interesting';
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'workflow', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'mutate (create, update, or delete) a workflow for something valuable.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140806', N'schema', N'workflow', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140806'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'revision_20140806'
  , @value      = N'Katherine E. Lightsey - created.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
---------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'package_extended_properties_demonstration', N'schema', N'workflow', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_extended_properties_demonstration'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'package_extended_properties_demonstration'
  , @value      = N''
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'business_requirements'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'business_requirements'
  , @value      = N'we need to do something to show we are doing something.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
select *
from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', default, default);
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
select *
from   fn_listextendedproperty(default, N'schema', N'workflow', N'procedure', N'set', default, default);
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- parameters properties
-------------------------------------------------
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', N'parameter', N'@flower'))
  exec sys.sp_dropextendedproperty
    @name         = N'business_requirements'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = N'parameter'
    , @level2name =N'@flower';
exec sys.sp_addextendedproperty
  @name         = N'business_requirements'
  , @value      = N'@flower [sysname] - source {cast([dbo].[basic].[company] as [sysname])}'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = N'parameter'
  , @level2name =N'@flower';
if exists
   (select *
    from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', N'parameter', N'@color'))
  exec sys.sp_dropextendedproperty
    @name         = N'business_requirements'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = N'parameter'
    , @level2name =N'@color';
exec sys.sp_addextendedproperty
  @name         = N'business_requirements'
  , @value      = N'@color [int] - source {case when isnumeric([dbo].[basic].[contract_number]) = 1 then cast([dbo].[basic].[contract_number] as [int]) else 0 end}'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = N'parameter'
  , @level2name =N'@color';
if exists
   (select *
    from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', N'parameter', N'@stack'))
  exec sys.sp_dropextendedproperty
    @name         = N'business_requirements'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = N'parameter'
    , @level2name =N'@stack';
exec sys.sp_addextendedproperty
  @name         = N'business_requirements'
  , @value      = N'@stack [xml] output - output parameter for the method, returns <stack company="0" contract_number="0" id_letters_interface="0" ></stack>'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = N'parameter'
  , @level2name =N'@stack';
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
select *
from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', N'parameter', N'@stack');
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
select *
from   fn_listextendedproperty(N'business_requirements', N'schema', N'workflow', N'procedure', N'set', N'parameter', default);
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-------------------------------------------------
-------------------------------------------------
-- using structured documentation
--
-- xml
-------------------------------------------------
-------------------------------------------------
--
--
-------------------------------------------------
if schema_id(N'flower') is null
  execute (N'create schema flower');
go
if schema_id(N'flower_secure') is null
  execute (N'create schema flower_secure');
go
if schema_id(N'customer_secure') is null
  execute (N'create schema customer_secure');
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-------------------------------------------------
if object_id(N'[flower_secure].[order]', N'U') is not null
  drop table [flower_secure].[order];
go
if object_id(N'[customer_secure].[data]', N'U') is not null
  drop table [customer_secure].[data];
go
create table [customer_secure].[data] (
  [id]     [int] not null identity(1, 1)
    constraint [customer_secure.data.id.clustered_primary_key] primary key clustered ([id])
  , [name] [sysname]
  );
go
if object_id(N'[flower_secure].[order]', N'U') is not null
  drop table [flower_secure].[order];
go
create table [flower_secure].[order] (
  [id]         [int] identity(1, 1)
  , [customer] [int] not null constraint [flower_secure.order.customer.references] references [customer_secure].[data] ([id])
  , [deliver]  [datetime] not null
  , [flower]   [sysname]
  , [color]    [sysname]
  , [quantity] [int] constraint [flower_secure.order.quantity.default] default (0),
  constraint [flower_secure.order.customer.deliver.flower.color.unique] unique ([customer], [deliver], [flower], [color])
  );
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-------------------------------------------------
if object_id(N'[flower].[set]', N'P') is not null
  drop procedure [flower].[set];
go
create procedure [flower].[set]
  @id         [int] = null
  , @customer [int] = null
  , @deliver  [datetime] = null
  , @flower   [sysname] = null
  , @color    [sysname] = null
  , @quantity [int] = 0
  , @delete   [bit] = 0
  , @stack    [xml] = null output
as
  begin
      declare @message [nvarchar](max);
      -------------------------------------------
      if @delete = 1
        begin
            --
            if @id is not null
              delete from [flower_secure].[order]
              where  [id] = @id;
            --
            else if @customer is not null
               and @deliver is not null
               and @flower is not null
               and @color is not null
              delete from [flower_secure].[order]
              where  [flower] = @flower
                     and [color] = @color;
            --
            else
              begin
                  set @message = N'if @delete = 1, either @id or @customer, @deliver, @flower and @color must be specified';
                  raiserror(51000,@message,1);
              end;
        end;
      -------------------------------------------
      else if @id is not null
        merge into [flower_secure].[order] as target
        using (values (@id
              , @customer
              , @deliver
              , @flower
              , @color
              , @quantity)) as source([id], [customer], [deliver], [flower], [color], [quantity])
        on target.[id] = source.[id]
        when matched then
          update set target.[customer] = coalesce(source.[customer], target.[customer])
                     , target.[deliver] = coalesce(source.[deliver], target.[deliver])
                     , target.[flower] = coalesce(source.[flower], target.[flower])
                     , target.[color] = coalesce(source.[color], target.[color])
                     , target.[quantity] = coalesce(source.[quantity], target.[quantity]);
      -------------------------------------------
      else if @flower is not null
         and @color is not null
        merge into [flower_secure].[order] as target
        using (values (@id
              , @customer
              , @deliver
              , @flower
              , @color
              , @quantity)) as source([id], [customer], [deliver], [flower], [color], [quantity])
        on target.[customer] = source.[customer]
           and target.[deliver] = source.[deliver]
           and target.[flower] = source.[flower]
           and target.[color] = source.[color]
        when matched then
          update set target.[quantity] = coalesce(source.[quantity], target.[quantity]);
      --
      else
        begin
            set @message = N'if @delete = 1, either @id or both @flower and @color must be specified';
            raiserror(51000,@message,1);
        end;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'flower', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'flower'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'<execute_as>
	<delete>
		<description>deletes the record defined by either @id or @flower and @color. if no record is found, nothing is done.</description>
		<by_id>execute [flower].[set] @id={n}, @delete=1;</by_id>
		<by_flower_color>execute [flower].[set] @flower={flower}, @color={color}</by_flower_color>
	</delete>
	<insert>
		<description>quantity defaults to 0 if not set.</description>
		<default>execute [flower].[set] @flower={flower}, @color={color};</default>
		<with_quantity>execute [flower].[set] @flower={flower}, @color={color}, @quantity={quantity};</with_quantity>
	</insert>
	<update>
		<description>update description goes here</description>
		<flower_by_id>execute [flower].[set] @id={n}, @flower={flower};</flower_by_id>
		<color_by_id>execute [flower].[set] @id={n}, @color={color};</color_by_id>
		<flower_and_color_by_id>execute [flower].[set] @id={n}, @flower={flower}, @color={color};</flower_and_color_by_id>
	</update>
  </execute_as>'
  , @level0type = N'schema'
  , @level0name = N'flower'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
declare @execute_as [xml] = (select cast(cast([value] as [nvarchar](max))as [xml])
   from   fn_listextendedproperty(N'execute_as', N'schema', N'flower', N'procedure', N'set', default, default));
--
select @execute_as as [@execute_as]
       , @execute_as.value(N'(/*/delete/by_id/text())[1]', N'[nvarchar](max)');
--
select t.c.query(N'.')
from   @execute_as.nodes(N'/*/delete') as t(c);
--
select t.c.query(N'./*[local-name()!="description"]')
from   @execute_as.nodes(N'/*/delete') as t(c);
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-------------------------------------------------
-------------------------------------------------
-- using structured documentation
--
-- embedded html
-------------------------------------------------
-------------------------------------------------
--
-- run the code below and examine the output
-- copy the [html_output] and save it as an html file then review the html file in a browser
-- use a tool such as http://www.freeformatter.com (http://www.freeformatter.com/html-formatter.html#ad-output)
--	to format the output and inspect it. note that it is both valid xml and valid html5, allowing
--	data to be extracted using xquery or displayed as html.
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'flower', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'flower'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'<ol>
	<details><summary>delete</summary><delete><ol>
		<li><description>deletes the record defined by either @id or @flower and @color. if no record is found, nothing is done.</description></li>
		<li><by_id>execute [flower].[set] @id={n}, @delete=1;</by_id></li>
		<li><by_flower_color>execute [flower].[set] @flower={flower}, @color={color}</by_flower_color></li>
	</ol></delete></details>
	<details><summary>insert</summary><insert><ol>
		<li><description>quantity defaults to 0 if not set.</description></li>
		<li><default>execute [flower].[set] @flower={flower}, @color={color};</default></li>
		<li><with_quantity>execute [flower].[set] @flower={flower}, @color={color}, @quantity={quantity};</with_quantity></li>
	</ol></insert></details>
	<details><summary>update</summary><update><ol>
		<li><description>update description goes here</description></li>
		<li><flower_by_id>execute [flower].[set] @id={n}, @flower={flower};</flower_by_id></li>
		<li><color_by_id>execute [flower].[set] @id={n}, @color={color};</color_by_id></li>
		<li><flower_and_color_by_id>execute [flower].[set] @id={n}, @flower={flower}, @color={color};</flower_and_color_by_id></li>
	</ol></update></details>
  </ol>'
  , @level0type = N'schema'
  , @level0name = N'flower'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- extract the documentation using html formatting
-------------------------------------------------
declare @schema   [sysname] = N'flower'
        , @object [sysname] = N'set'
        , @output [nvarchar](max)
        , @list   [xml];
--
select @output = coalesce(@output + N' ', N'')
                 + N'<details><summary>['
                 + [extended_properties].[name]
                 + N']</summary>'
                 + cast([extended_properties].[value] as [nvarchar](max))
                 + N'</details>'
from   [sys].[procedures] as [procedures]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [procedures].[object_id]
where  [extended_properties].[class] = 1
       and object_schema_name([procedures].[object_id]) = @schema
       and [procedures].[name] = @object;
--
select N'<details><summary>[procedure_properties]</summary>'
       + @output + N'</details>'
       , cast(@output as [xml]) as [xml];
--
set @list = (select cast(cast([value] as [nvarchar](max))as [xml])
             from   fn_listextendedproperty(N'execute_as', N'schema', N'flower', N'procedure', N'set', default, default));
--
select @list                                            as [@list]
       , t.c.query(N'.')                                as [delete]
       , t.c.value(N'(//by_id)[1]', N'[nvarchar](max)') as [delete_by_id]
from   @list.nodes(N'//delete') as t(c);
--
set @output = N'<!DOCTYPE html><html><head>
	<link rel="stylesheet" type="text/css" href=".\common.css" target="blank" />
	<p class="header">built on <a href="http://www.katherinelightsey.com" target="blank">[chamomile]</a></p>
<h2>[' + db_name() + N'].[' + @schema + N'].['
              + @object + N']</h2></head><body>'
              + cast(@list as [nvarchar](max))
              + N'</body><p class="footer">copyright 2014 <a href="http://www.katherinelightsey.com" target="blank">Katherine Elizabeth Lightsey</a></p></html>';
select @output as [html_output];
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create documentation for the business requirements 
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'flower', N'procedure', N'set', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'flower'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'<ol>
	<li>
		<functional_specification><details><summary>functional_specification</summary>
			<ol>
				<li>inserts a new flower order when flower, color, and quantity are passed in</li>
				<li>inserts a new flower template when flower and color are passed in</li>
				<li>updates do not require all values to be passed in. if a null is passed in (or a parameter not entered) the value in the table persists.
					<ol>
						<li>updates a flower order when flower, color, and quantity are passed in</li>
					</ol>
				</li>
				<li>updates a flower order when id is passed in</li>
				<li>deletes a flower order or template when either id or flower and color are passed in</li>
			</ol>
			</details></functional_specification>
	</li>
	<li><business_requirement>business_requirement - Provide mutator functionality for the flower order repository</business_requirement></li>
	<li><use>use - for inserting, updating, or deleting flower orders.</use></li>
	<li><further_documentation><a href="http://www.wikipedia.org/" target="blank">further_documentation</a></further_documentation></li>
  </ol>'
  , @level0type = N'schema'
  , @level0name = N'flower'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- select and display the business requirements along with the execute_as requirements
-------------------------------------------------
declare @description  [xml]
        , @execute_as [xml]
        , @sql        [nvarchar](max)
        , @parameters [nvarchar](max)
        , @schema     [sysname] = N'flower'
        , @object     [sysname] = N'set'
        , @output     [nvarchar](max);
select @sql = N'set @description = (select cast(cast([value] as [nvarchar](max))as [xml])
                   from   fn_listextendedproperty(N''description'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@description [xml] output';
--
execute sp_executesql
  @sql          =@sql
  , @parameters =@parameters
  , @description=@description output;
--
select @sql = N'set @execute_as = (select cast(cast([value] as [nvarchar](max))as [xml])
                   from   fn_listextendedproperty(N''execute_as'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@execute_as [xml] output';
--
execute sp_executesql
  @sql         =@sql
  , @parameters=@parameters
  , @execute_as=@execute_as output;
--
set @output = N'<!DOCTYPE html><html><head>
	<link rel="stylesheet" type="text/css" href=".\common.css" target="blank" />
	<p class="header">built on <a href="http://www.katherinelightsey.com" target="blank">[chamomile]</a></p>
<h2>[' + db_name() + N'].[' + @schema + N'].['
              + @object + N']</h2></head><body>'
              + N'<details><summary>[description]</summary><delete><ol>'
              + cast(@description as [nvarchar](max))
              + N'</details>'
              + N'<details><summary>[execute_as]</summary><delete><ol>'
              + cast(@execute_as as [nvarchar](max))
              + N'</details>'
              + N'</body><p class="footer">copyright 2014 <a href="http://www.katherinelightsey.com" target="blank">Katherine Elizabeth Lightsey</a></p></html>';
select @output as [html_output];
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- document the parameters
-------------------------------------------------
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'flower', N'procedure', N'set', N'parameter', N'@flower'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'flower'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = N'parameter'
    , @level2name =N'@flower';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'the flower for the order'
  , @level0type = N'schema'
  , @level0name = N'flower'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = N'parameter'
  , @level2name =N'@flower';
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'flower', N'procedure', N'set', N'parameter', N'@deliver'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'flower'
    , @level1type = N'procedure'
    , @level1name = N'set'
    , @level2type = N'parameter'
    , @level2name =N'@deliver';
exec sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'the delivery date and time requested for the order; use only to the nearest hour.'
  , @level0type = N'schema'
  , @level0name = N'flower'
  , @level1type = N'procedure'
  , @level1name = N'set'
  , @level2type = N'parameter'
  , @level2name =N'@deliver';
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-------------------------------------------------
declare @schema           [sysname] = N'flower'
        , @object         [sysname] = N'set'
        , @parameter_list [xml];
select @parameter_list = (select [parameters].[name]                      as N'@column'
                                 , type_name([parameters].[user_type_id]) as N'@type'
                                 , [extended_properties].[name]           as N'@property'
                                 , [extended_properties].[value]          as N'description'
                          from   [sys].[parameters] as [parameters]
                                 join [sys].[extended_properties] as [extended_properties]
                                   on [extended_properties].[major_id] = [parameters].[object_id]
                                      and [extended_properties].[minor_id] = [parameters].[parameter_id]
                          where  object_schema_name([parameters].[object_id]) = @schema
                                 and object_name([parameters].[object_id]) = @object
                          for xml path(N'parameter'), root(N'parameter_list'));
select @parameter_list;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-------------------------------------------------
declare @schema           [sysname] = N'flower'
        , @object         [sysname] = N'set'
        , @parameter_list [nvarchar](max)
        , @description    [xml]
        , @execute_as     [xml]
        , @sql            [nvarchar](max)
        , @parameters     [nvarchar](max)
        , @output         [nvarchar](max);
--
-------------------------------------------------
select @parameter_list = coalesce(@parameter_list + N' ', N'')
                         + N'<li>' + [parameters].[name] + N' ['
                         + type_name([parameters].[user_type_id])
                         + N']('+
                         + cast([parameters].[max_length]/2 as [sysname])
                         + N') property="'
                         + [extended_properties].[name] + N'" value="'
                         + cast([extended_properties].[value] as [nvarchar](max))
                         + N'"</li>'
from   [sys].[parameters] as [parameters]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [parameters].[object_id]
            and [extended_properties].[minor_id] = [parameters].[parameter_id]
where  object_schema_name([parameters].[object_id]) = @schema
       and object_name([parameters].[object_id]) = @object;
--
select @sql = N'set @description = (select cast(cast([value] as [nvarchar](max))as [xml])
                   from   fn_listextendedproperty(N''description'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@description [xml] output';
--
execute sp_executesql
  @sql          =@sql
  , @parameters =@parameters
  , @description=@description output;
--
select @sql = N'set @execute_as = (select cast(cast([value] as [nvarchar](max))as [xml])
                   from   fn_listextendedproperty(N''execute_as'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@execute_as [xml] output';
--
execute sp_executesql
  @sql         =@sql
  , @parameters=@parameters
  , @execute_as=@execute_as output;
--
set @output = N'<!DOCTYPE html><html><head>
	<link rel="stylesheet" type="text/css" href=".\common.css" target="blank" />
	<p class="header">built on <a href="http://www.katherinelightsey.com" target="blank">[chamomile]</a></p>
<h2>[' + db_name() + N'].[' + @schema + N'].['
              + @object + N']</h2></head><body>'
              + N'<details><summary>[description]</summary><delete><ol>'
              + cast(@description as [nvarchar](max))
              + N'</details>'
              + N'<details><summary>[execute_as]</summary><delete><ol>'
              + cast(@execute_as as [nvarchar](max))
              + N'</details>'
              + N'<details><summary>[parameter_list]</summary><delete><ol>'
              + @parameter_list + N'</details>'
              + N'</body><p class="footer">copyright 2014 <a href="http://www.katherinelightsey.com" target="blank">Katherine Elizabeth Lightsey</a></p></html>';
select @output as [html_output];
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- using tools to generate extended properties
-------------------------------------------------
-------------------------------------------------
--
-- extract the execute_as property for the listed system procedure and create extended properties
--	for an object
-------------------------------------------------
-- MCKDEVTSQL02
use [master];
go
declare @schema   [sysname] = N'dbo'
        , @object [sysname] = N'sp_chamomile_documentation_create_extended_properties';
select [schemas].[name]                as [schema]
       , [objects].[name]              as [object]
       , [extended_properties].[name]  as [property]
       , [extended_properties].[value] as [value]
from   [sys].[extended_properties] as [extended_properties]
       join [sys].[objects] as [objects]
         on [objects].[object_id] = [extended_properties].[major_id]
       join [sys].[schemas] as [schemas]
         on [objects].[schema_id] = [schemas].[schema_id]
where  [schemas].[name] = @schema
       and [objects].[name] = @object;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- using tools to generate documentation of objects
-------------------------------------------------
-------------------------------------------------
--
-- extract the execute_as documentation for one of the listed system procedures and create formatted
--	documentation for an object you have documented with extended properties.
-------------------------------------------------
use [master];
go
select *
from   fn_listextendedproperty(default, N'schema', N'dbo', N'procedure', N'sp_chamomile_documentation_get_table', default, default);
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
use [master];
go
select *
from   fn_listextendedproperty(default, N'schema', N'dbo', N'procedure', N'sp_chamomile_documentation_get_procedure', default, default);
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create application meta data -- application meta data is data about data within a schema
--	object, where structural meta data is data about the structure itself. For example, in
--	the table [flower_secure].[order], meta data about the column [color] tells us that the
--	column holds the color of the flowers to be delivered. application meta data would tell
--	us that yellow roses are the state flower of texas.
--
-- experiment with the following test to build different meta data combinations for 
--	both application and structural meta data.
-- consider how you could use the construct below in a check constraint, for example;
--	check ([utility].[get_meta_data](N'[category].[class].[type_' + [column] + N']') is not null)
--	what would be required for this construct to work as shown in the next block of code?
-------------------------------------------------
--
--use [{your_test_database}];
go
begin
    begin transaction utility_test_get_meta_data;
    --
    declare @stack    xml
            , @random [sysname] = cast(round(rand()*100000, -1) as [sysname])
              + N'_'
              + cast(datepart(millisecond, current_timestamp) as [sysname]);
    --
    declare @object_fqn [nvarchar](max) = N'[chamomile].[utility_test].[meta_data].[test1_'
      + @random + N']';
    --
    execute [chamomile].[utility].[set_meta_data]
      @object_fqn   =@object_fqn
      , @value      =@random
      , @description=N'test description.'
      , @stack      =@stack output;
    --
    select @stack                                               as [@stack]
           , @object_fqn                                        as [meta_data_fqn]
           , [chamomile].[utility].[get_meta_data](@object_fqn) as [meta_data_value];
    --
    if (select [chamomile].[utility].[get_meta_data](@object_fqn))
       = @random
      select N'pass'
    else
      select N'fail'
    --
    rollback transaction utility_test_get_meta_data;
end;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
use [extended_properties_test];
go
if schema_id(N'utility') is null
  execute (N'create schema utility');
go
if schema_id(N'flower_secure') is null
  execute (N'create schema flower_secure');
go
if schema_id(N'customer_secure') is null
  execute (N'create schema customer_secure');
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if object_id(N'[flower_secure].[order]', N'U') is not null
  drop table [flower_secure].[order];
go
if object_id(N'[customer_secure].[data]', N'U') is not null
  drop table [customer_secure].[data];
go
create table [customer_secure].[data] (
  [id]     [int] not null identity(1, 1)
    constraint [customer_secure.data.id.clustered_primary_key] primary key clustered ([id])
  , [name] [sysname]
  );
go
insert into [customer_secure].[data] ([name]) values (N'ginger'),(N'maryanne');
go
if object_id(N'[utility].[get_meta_data]', N'FN') is not null
  drop function [utility].[get_meta_data];
go
create function [utility].[get_meta_data](
  @object_fqn [nvarchar](max))
returns [nvarchar](max)
as
  begin
      return [chamomile].[utility].[get_meta_data](@object_fqn);
  end;
go
if object_id(N'[flower_secure].[order]', N'U') is not null
  drop table [flower_secure].[order];
go
create table [flower_secure].[order] (
  [id]         [int] identity(1, 1)
  , [customer] [int] not null constraint [flower_secure.order.customer.references] references [customer_secure].[data] ([id])
  , [deliver]  [datetime] not null
  , [flower]   [sysname] not null constraint [flower_secure.order.flower.check] check ([utility].[get_meta_data](N'[flower].[' + [flower] + N']') is not null)
  , [color]    [sysname]
  , [quantity] [int] not null constraint [flower_secure.order.quantity.default] default (0),
  constraint [flower_secure.order.customer.deliver.flower.color.unique] unique ([customer], [deliver], [flower], [color])
  );
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- this fails because the check constrait fails
-------------------------------------------------
insert into [flower_secure].[order]
            ([customer]
             , [deliver]
             , [flower]
			 , [color])
values      (1,current_timestamp,N'lily', N'red');
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create the appropriate meta data objects on which you wish to constrain the column
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[flower].[rose]'
  , @value      =N'rose'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[flower].[lily]'
  , @value      =N'lily'
  , @description=N'description.';
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- now you can insert a rose or lily
-------------------------------------------------
insert into [flower_secure].[order]
            ([customer]
             , [deliver]
             , [flower]
             , [color])
values      (1,current_timestamp,N'lily',N'red');
go
insert into [flower_secure].[order]
            ([customer]
             , [deliver]
             , [flower]
             , [color])
values      (1,current_timestamp,N'rose',N'white');
go
--
-- but you still can't insert a chamomile
-------------------------------------------------
insert into [flower_secure].[order]
            ([customer]
             , [deliver]
             , [flower]
             , [color])
values      (1,current_timestamp,N'chamomile',N'yellow');
go 
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- can you see how the following meta data values could be used to constrain columns 
--	in multiple areas as well as to set common values?
-- are these meta data objects structural or descriptive meta data? http://en.wikipedia.org/wiki/Metadata
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[pass]'
  , @value      =N'pass'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[fail]'
  , @value      =N'fail'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[user].[datazap]'
  , @value      =N'datazap'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[user].[system]'
  , @value      =N'system'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[lep_change].[increased]'
  , @value      =N'increased'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[lep_change].[decreased]'
  , @value      =N'decreased'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[lep_change].[removed]'
  , @value      =N'removed'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[status].[ready]'
  , @value      =N'ready'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[status].[hold]'
  , @value      =N'hold'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[status].[processing]'
  , @value      =N'processing'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[status].[cancelled]'
  , @value      =N'cancelled'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[date].[maximum]'
  , @value      =N'20991231'
  , @description=N'description.';
go
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   = N'[torchmark].[default].[date].[minimum]'
  , @value      =N'19000101'
  , @description=N'description.';
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- list the above meta data by various partial names
-- note that a benefit of using a common construct for meta data rather than having 
--	individual tables for each category of meta data is the simplicity with which
--	you can aggregate and find it.
-------------------------------------------------
select *
from   [chamomile].[utility].[get_meta_data_list](N'[torchmark].[default]');
go 
select *
from   [chamomile].[utility].[get_meta_data_list](N'[torchmark].[default].[date]');
go 
select *
from   [chamomile].[utility].[get_meta_data_list](N'[torchmark].[default].[status]');
go 
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- how much data can this meta data construct hold and return?
-- since the sql output to screen mechanism is limited in size, how can you
--	return a larger amount of data or text? hint... this technique is used
--	by the system stored procedures referenced above.
-------------------------------------------------
declare @stack                      [xml]
        , @platos_dialogue_phaedrus [nvarchar](max) = N'PHAEDRUS

360 BC

by Plato

translated by Benjamin Jowett

New York, C. Scribner''s Sons, [1871]


  PERSONS OF THE DIALOGUE: SOCRATES; PHAEDRUS. Scene: Under a
plane-tree, by the banks of the Ilissus.

  Socrates. My dear Phaedrus, whence come you, and whither are you
going?

  Phaedrus. I come from Lysias the son of Cephalus, and I am going
to take a walk outside the wall, for I have been sitting with him
the whole morning; and our common friend Acumenus tells me that it
is much more refreshing to walk in the open air than to be shut up
in a cloister.

  Soc. There he is right. Lysias then, I suppose, was in the town?

  Phaedr. Yes, he was staying with Epicrates, here at the house of
Morychus; that house which is near the temple of Olympian Zeus.

  Soc. And how did he entertain you? Can I be wrong in supposing
that Lysias gave you a feast of discourse?

  Phaedr. You shall hear, if you can spare time to accompany me.

  Soc. And should I not deem the conversation of you and Lysias "a
thing of higher import," as I may say in the words of Pindar, "than
any business"?

  Phaedr. Will you go on?

  Soc. And will you go on with the narration?

  Phaedr. My tale, Socrates, is one of your sort, for love was the
theme which occupied us -love after a fashion: Lysias has been writing
about a fair youth who was being tempted, but not by a lover; and this
was the point: he ingeniously proved that the non-lover should be
accepted rather than the lover.

  Soc. O that is noble of him! I wish that he would say the poor man
rather than the rich, and the old man rather than the young one;
then he would meet the case of me and of many a man; his words would
be quite refreshing, and he would be a public benefactor. For my part,
I do so long to hear his speech, that if you walk all the way to
Megara, and when you have reached the wall come back, as Herodicus
recommends, without going in, I will keep you company.

  Phaedr. What do you mean, my good Socrates? How can you imagine that
my unpractised memory can do justice to an elaborate work, which the
greatest rhetorician of the age spent a long time in composing.
Indeed, I cannot; I would give a great deal if I could.

  Soc. I believe that I know Phaedrus about as well as I know
myself, and I am very sure that the speech of Lysias was repeated to
him, not once only, but again and again;-he insisted on hearing it
many times over and Lysias was very willing to gratify him; at last,
when nothing else would do, he got hold of the book, and looked at
what he most wanted to see,-this occupied him during the whole
morning; -and then when he was tired with sitting, he went out to take
a walk, not until, by the dog, as I believe, he had simply learned
by heart the entire discourse, unless it was unusually long, and he
went to a place outside the wall that he might practise his lesson.
There he saw a certain lover of discourse who had a similar
weakness;-he saw and rejoiced; now thought he, "I shall have a partner
in my revels." And he invited him to come and walk with him. But
when the lover of discourse begged that he would repeat the tale, he
gave himself airs and said, "No I cannot," as if he were indisposed;
although, if the hearer had refused, he would sooner or later have
been compelled by him to listen whether he would or no. Therefore,
Phaedrus, bid him do at once what he will soon do whether bidden or
not.

  Phaedr. I see that you will not let me off until I speak in some
fashion or other; verily therefore my best plan is to speak as I
best can.

  Soc. A very true remark, that of yours.

  Phaedr. I will do as I say; but believe me, Socrates, I did not
learn the very words-O no; nevertheless I have a general notion of
what he said, and will give you a summary of the points in which the
lover differed from the non-lover. Let me begin at the beginning.

  Soc. Yes, my sweet one; but you must first of all show what you have
in your left hand under your cloak, for that roll, as I suspect, is
the actual discourse. Now, much as I love you, I would not have you
suppose that I am going to have your memory exercised at my expense,
if you have Lysias himself here.

  Phaedr. Enough; I see that I have no hope of practising my art
upon you. But if I am to read, where would you please to sit?

  Soc. Let us turn aside and go by the Ilissus; we will sit down at
some quiet spot.

  Phaedr. I am fortunate in not having my sandals, and as you never
have any, I think that we may go along the brook and cool our feet
in the water; this will be the easiest way, and at midday and in the
summer is far from being unpleasant.

  Soc. Lead on, and look out for a place in which we can sit down.

  Phaedr. Do you see the tallest plane-tree in the distance?

  Soc. Yes.

  Phaedr. There are shade and gentle breezes, and grass on which we
may either sit or lie down.

  Soc. Move forward.

  Phaedr. I should like to know, Socrates, whether the place is not
somewhere here at which Boreas is said to have carried off Orithyia
from the banks of the Ilissus?

  Soc. Such is the tradition.

  Phaedr. And is this the exact spot? The little stream is
delightfully clear and bright; I can fancy that there might be maidens
playing near.

  Soc. I believe that the spot is not exactly here, but about a
quarter of a mile lower down, where you cross to the temple of
Artemis, and there is, I think, some sort of an altar of Boreas at the
place.

  Phaedr. I have never noticed it; but I beseech you to tell me,
Socrates, do you believe this tale?

  Soc. The wise are doubtful, and I should not be singular if, like
them, I too doubted. I might have a rational explanation that Orithyia
was playing with Pharmacia, when a northern gust carried her over
the neighbouring rocks; and this being the manner of her death, she
was said to have been carried away by Boreas. There is a
discrepancy, however, about the locality; according to another version
of the story she was taken from Areopagus, and not from this place.
Now I quite acknowledge that these allegories are very nice, but he is
not to be envied who has to invent them; much labour and ingenuity
will be required of him; and when he has once begun, he must go on and
rehabilitate Hippocentaurs and chimeras dire. Gorgons and winged
steeds flow in apace, and numberless other inconceivable and
portentous natures. And if he is sceptical about them, and would
fain reduce them one after another to the rules of probability, this
sort of crude philosophy will take up a great deal of time. Now I have
no leisure for such enquiries; shall I tell you why? I must first know
myself, as the Delphian inscription says; to be curious about that
which is not my concern, while I am still in ignorance of my own self,
would be ridiculous. And therefore I bid farewell to all this; the
common opinion is enough for me. For, as I was saying, I want to
know not about this, but about myself: am I a monster more complicated
and swollen with passion than the serpent Typho, or a creature of a
gentler and simpler sort, to whom Nature has given a diviner and
lowlier destiny? But let me ask you, friend: have we not reached the
plane-tree to which you were conducting us?

  Phaedr. Yes, this is the tree.

  Soc. By Here, a fair resting-place, full of summer sounds and
scents. Here is this lofty and spreading plane-tree, and the agnus
cast us high and clustering, in the fullest blossom and the greatest
fragrance; and the stream which flows beneath the plane-tree is
deliciously cold to the feet. Judging from the ornaments and images,
this must be a spot sacred to Achelous and the Nymphs. How
delightful is the breeze:-so very sweet; and there is a sound in the
air shrill and summerlike which makes answer to the chorus of the
cicadae. But the greatest charm of all is the grass, like a pillow
gently sloping to the head. My dear Phaedrus, you have been an
admirable guide.

  Phaedr. What an incomprehensible being you are, Socrates: when you
are in the country, as you say, you really are like some stranger
who is led about by a guide. Do you ever cross the border? I rather
think that you never venture even outside the gates.

  Soc. Very true, my good friend; and I hope that you will excuse me
when you hear the reason, which is, that I am a lover of knowledge,
and the men who dwell in the city are my teachers, and not the trees
or the country. Though I do indeed believe that you have found a spell
with which to draw me out of the city into the country, like a
hungry cow before whom a bough or a bunch of fruit is waved. For
only hold up before me in like manner a book, and you may lead me
all round Attica, and over the wide world. And now having arrived, I
intend to lie down, and do you choose any posture in which you can
read best. Begin.

  Phaedr. Listen. You know how matters stand with me; and how, as I
conceive, this affair may be arranged for the advantage of both of us.
And I maintain that I ought not to fail in my suit, because I am not
your lover: for lovers repent of the kindnesses which they have
shown when their passion ceases, but to the non-lovers who are free
and not under any compulsion, no time of repentance ever comes; for
they confer their benefits according to the measure of their
ability, in the way which is most conducive to their own interest.
Then again, lovers consider how by reason of their love they have
neglected their own concerns and rendered service to others: and
when to these benefits conferred they add on the troubles which they
have endured, they think that they have long ago made to the beloved a
very ample return. But the non-lover has no such tormenting
recollections; he has never neglected his affairs or quarrelled with
his relations; he has no troubles to add up or excuse to invent; and
being well rid of all these evils, why should he not freely do what
will gratify the beloved?

  If you say that the lover is more to be esteemed, because his love
is thought to be greater; for he is willing to say and do what is
hateful to other men, in order to please his beloved;-that, if true,
is only a proof that he will prefer any future love to his present,
and will injure his old love at the pleasure of the new. And how, in a
matter of such infinite importance, can a man be right in trusting
himself to one who is afflicted with a malady which no experienced
person would attempt to cure, for the patient himself admits that he
is not in his right mind, and acknowledges that he is wrong in his
mind, but says that he is unable to control himself? And if he came to
his right mind, would he ever imagine that the desires were good which
he conceived when in his wrong mind? Once more, there are many more
non-lovers than lovers; and if you choose the best of the lovers,
you will not have many to choose from; but if from the non-lovers, the
choice will be larger, and you will be far more likely to find among
them a person who is worthy of your friendship. If public opinion be
your dread, and you would avoid reproach, in all probability the
lover, who is always thinking that other men are as emulous of him
as he is of them, will boast to some one of his successes, and make
a show of them openly in the pride of his heart;-he wants others to
know that his labour has not been lost; but the non-lover is more
his own master, and is desirous of solid good, and not of the
opinion of mankind. Again, the lover may be generally noted or seen
following the beloved (this is his regular occupation), and whenever
they are observed to exchange two words they are supposed to meet
about some affair of love either past or in contemplation; but when
non-lovers meet, no one asks the reason why, because people know
that talking to another is natural, whether friendship or mere
pleasure be the motive.

  Once more, if you fear the fickleness of friendship, consider that
in any other case a quarrel might be a mutual calamity; but now,
when you have given up what is most precious to you, you will be the
greater loser, and therefore, you will have more reason in being
afraid of the lover, for his vexations are many, and he is always
fancying that every one is leagued against him. Wherefore also he
debars his beloved from society; he will not have you intimate with
the wealthy, lest they should exceed him in wealth, or with men of
education, lest they should be his superiors in understanding; and
he is equally afraid of anybody''s influence who has any other
advantage over himself. If he can persuade you to break with them, you
are left without friend in the world; or if, out of a regard to your
own interest, you have more sense than to comply with his desire,
you will have to quarrel with him. But those who are non-lovers, and
whose success in love is the reward of their merit, will not be
jealous of the companions of their beloved, and will rather hate those
who refuse to be his associates, thinking that their favourite is
slighted by the latter and benefited by the former; for more love than
hatred may be expected to come to him out of his friendship with
others. Many lovers too have loved the person of a youth before they
knew his character or his belongings; so that when their passion has
passed away, there is no knowing whether they will continue to be
his friends; whereas, in the case of non-lovers who were always
friends, the friendship is not lessened by the favours granted; but
the recollection of these remains with them, and is an earnest of good
things to come.

  Further, I say that you are likely to be improved by me, whereas the
lover will spoil you. For they praise your words and actions in a
wrong way; partly, because they are afraid of offending you, and also,
their judgment is weakened by passion. Such are the feats which love
exhibits; he makes things painful to the disappointed which give no
pain to others; he compels the successful lover to praise what ought
not to give him pleasure, and therefore the beloved is to be pitied
rather than envied. But if you listen to me, in the first place, I, in
my intercourse with you, shall not merely regard present enjoyment,
but also future advantage, being not mastered by love, but my own
master; nor for small causes taking violent dislikes, but even when
the cause is great, slowly laying up little wrath-unintentional
offences I shall forgive, and intentional ones I shall try to prevent;
and these are the marks of a friendship which will last.

  Do you think that a lover only can be a firm friend? reflect:-if
this were true, we should set small value on sons, or fathers, or
mothers; nor should we ever have loyal friends, for our love of them
arises not from passion, but from other associations. Further, if we
ought to shower favours on those who are the most eager suitors,-on
that principle, we ought always to do good, not to the most
virtuous, but to the most needy; for they are the persons who will
be most relieved, and will therefore be the most grateful; and when
you make a feast you should invite not your friend, but the beggar and
the empty soul; for they will love you, and attend you, and come about
your doors, and will be the best pleased, and the most grateful, and
will invoke many a blessing on your head. Yet surely you ought not
to be granting favours to those who besiege you with prayer, but to
those who are best able to reward you; nor to the lover only, but to
those who are worthy of love; nor to those who will enjoy the bloom of
your youth, but to those who will share their possessions with you
in age; nor to those who, having succeeded, will glory in their
success to others, but to those who will be modest and tell no
tales; nor to those who care about you for a moment only, but to those
who will continue your friends through life; nor to those who, when
their passion is over, will pick a quarrel with you, but rather to
those who, when the charm of youth has left you, will show their own
virtue. Remember what I have said; and consider yet this further
point: friends admonish the lover under the idea that his way of
life is bad, but no one of his kindred ever yet censured the
non-lover, or thought that he was ill-advised about his own interests.

  "Perhaps you will ask me whether I propose that you should indulge
every non-lover. To which I reply that not even the lover would advise
you to indulge all lovers, for the indiscriminate favour is less
esteemed by the rational recipient, and less easily hidden by him
who would escape the censure of the world. Now love ought to be for
the advantage of both parties, and for the injury of neither.

  "I believe that I have said enough; but if there is anything more
which you desire or which in your opinion needs to be supplied, ask
and I will answer."

  Now, Socrates, what do you think? Is not the discourse excellent,
more especially in the matter of the language?

  Soc. Yes, quite admirable; the effect on me was ravishing. And
this I owe to you, Phaedrus, for I observed you while reading to be in
an ecstasy, and thinking that you are more experienced in these
matters than I am, I followed your example, and, like you, my divine
darling, I became inspired with a phrenzy.

  Phaedr. Indeed, you are pleased to be merry.

  Soc. Do you mean that I am not in earnest?

  Phaedr. Now don''t talk in that way, Socrates, but let me have your
real opinion; I adjure you, by Zeus, the god of friendship, to tell me
whether you think that any Hellene could have said more or spoken
better on the same subject.

  Soc. Well, but are you and I expected to praise the sentiments of
the author, or only the clearness, and roundness, and finish, and
tournure of the language? As to the first I willingly submit to your
better judgment, for I am not worthy to form an opinion, having only
attended to the rhetorical manner; and I was doubting whether this
could have been defended even by Lysias himself; I thought, though I
speak under correction, that he repeated himself two or three times,
either from want of words or from want of pains; and also, he appeared
to me ostentatiously to exult in showing how well he could say the
same thing in two or three ways.

  Phaedr. Nonsense, Socrates; what you call repetition was the
especial merit of the speech; for he omitted no topic of which the
subject rightly allowed, and I do not think that any one could have
spoken better or more exhaustively.

  Soc. There I cannot go along with you. Ancient sages, men and women,
who have spoken and written of these things, would rise up in judgment
against me, if out of complaisance I assented to you.

  Phaedr. Who are they, and where did you hear anything better than
this?

  Soc. I am sure that I must have heard; but at this moment I do not
remember from whom; perhaps from Sappho the fair, or Anacreon the
wise; or, possibly, from a prose writer. Why do I say so? Why, because
I perceive that my bosom is full, and that I could make another speech
as good as that of Lysias, and different. Now I am certain that this
is not an invention of my own, who am well aware that I know
nothing, and therefore I can only infer that I have been filled
through the cars, like a pitcher, from the waters of another, though I
have actually forgotten in my stupidity who was my informant.

  Phaedr. That is grand:-but never mind where you beard the
discourse or from whom; let that be a mystery not to be divulged
even at my earnest desire. Only, as you say, promise to make another
and better oration, equal in length and entirely new, on the same
subject; and I, like the nine Archons, will promise to set up a golden
image at Delphi, not only of myself, but of you, and as large as life.

  Soc. You are a dear golden ass if you suppose me to mean that Lysias
has altogether missed the mark, and that I can make a speech from
which all his arguments are to be excluded. The worst of authors
will say something which is to the point. Who, for example, could
speak on this thesis of yours without praising the discretion of the
non-lover and blaming the indiscretion of the lover? These are the
commonplaces of the subject which must come in (for what else is there
to be said?) and must be allowed and excused; the only merit is in the
arrangement of them, for there can be none in the invention; but
when you leave the commonplaces, then there may be some originality.

  Phaedr. I admit that there is reason in what you say, and I too will
be reasonable, and will allow you to start with the premiss that the
lover is more disordered in his wits than the non-lover; if in what
remains you make a longer and better speech than Lysias, and use other
arguments, then I say again, that a statue you shall have of beaten
gold, and take your place by the colossal offerings of the Cypselids
at Olympia.

  Soc. How profoundly in earnest is the lover, because to tease him
I lay a finger upon his love! And so, Phaedrus, you really imagine
that I am going to improve upon the ingenuity of Lysias?

  Phaedr. There I have you as you had me, and you must just speak
"as you best can." Do not let us exchange "tu quoque" as in a farce,
or compel me to say to you as you said to me, "I know Socrates as well
as I know myself, and he was wanting to, speak, but he gave himself
airs." Rather I would have you consider that from this place we stir
not until you have unbosomed yourself of the speech; for here are we
all alone, and I am stronger, remember, and younger than you-Wherefore
perpend, and do not compel me to use violence.

  Soc. But, my sweet Phaedrus, how ridiculous it would be of me to
compete with Lysias in an extempore speech! He is a master in his
art and I am an untaught man.

  Phaedr. You see how matters stand; and therefore let there be no
more pretences; for, indeed, I know the word that is irresistible.

  Soc. Then don''t say it.

  Phaedr. Yes, but I will; and my word shall be an oath. "I say, or
rather swear"-but what god will be witness of my oath?-"By this
plane-tree I swear, that unless you repeat the discourse here in the
face of this very plane-tree, I will never tell you another; never let
you have word of another!"

  Soc. Villain I am conquered; the poor lover of discourse has no more
to say.

  Phaedr. Then why are you still at your tricks?

  Soc. I am not going to play tricks now that you have taken the oath,
for I cannot allow myself to be starved.

  Phaedr. Proceed.

  Soc. Shall I tell you what I will do?

  Phaedr. What?

  Soc. I will veil my face and gallop through the discourse as fast as
I can, for if I see you I shall feel ashamed and not know what to say.

  Phaedr. Only go on and you may do anything else which you please.

  Soc. Come, O ye Muses, melodious, as ye are called, whether you have
received this name from the character of your strains, or because
the Melians are a musical race, help, O help me in the tale which my
good friend here desires me to rehearse, in order that his friend whom
he always deemed wise may seem to him to be wiser than ever.

  Once upon a time there was a fair boy, or, more properly speaking, a
youth; he was very fair and had a great many lovers; and there was one
special cunning one, who had persuaded the youth that he did not
love him, but he really loved him all the same; and one day when he
was paying his addresses to him, he used this very argument-that he
ought to accept the non-lover rather than the lover; his words were as
follows:-

  "All good counsel begins in the same way; a man should know what
he is advising about, or his counsel will all come to nought. But
people imagine that they know about the nature of things, when they
don''t know about them, and, not having come to an understanding at
first because they think that they know, they end, as might be
expected, in contradicting one another and themselves. Now you and I
must not be guilty of this fundamental error which we condemn in
others; but as our question is whether the lover or non-lover is to be
preferred, let us first of all agree in defining the nature and
power of love, and then, keeping our eyes upon the definition and to
this appealing, let us further enquire whether love brings advantage
or disadvantage.

  "Every one sees that love is a desire, and we know also that
non-lovers desire the beautiful and good. Now in what way is the lover
to be distinguished from the non-lover? Let us note that in every
one of us there are two guiding and ruling principles which lead us
whither they will; one is the natural desire of pleasure, the other is
an acquired opinion which aspires after the best; and these two are
sometimes in harmony and then again at war, and sometimes the one,
sometimes the other conquers. When opinion by the help of reason leads
us to the best, the conquering principle is called temperance; but
when desire, which is devoid of reason, rules in us and drags us to
pleasure, that power of misrule is called excess. Now excess has
many names, and many members, and many forms, and any of these forms
when very marked gives a name, neither honourable nor creditable, to
the bearer of the name. The desire of eating, for example, which
gets the better of the higher reason and the other desires, is
called gluttony, and he who is possessed by it is called a glutton-I
the tyrannical desire of drink, which inclines the possessor of the
desire to drink, has a name which is only too obvious, and there can
be as little doubt by what name any other appetite of the same
family would be called;-it will be the name of that which happens to
be eluminant. And now I think that you will perceive the drift of my
discourse; but as every spoken word is in a manner plainer than the
unspoken, I had better say further that the irrational desire which
overcomes the tendency of opinion towards right, and is led away to
the enjoyment of beauty, and especially of personal beauty, by the
desires which are her own kindred-that supreme desire, I say, which by
leading conquers and by the force of passion is reinforced, from
this very force, receiving a name, is called love."

  And now, dear Phaedrus, I shall pause for an instant to ask
whether you do not think me, as I appear to myself, inspired?

  Phaedr. Yes, Socrates, you seem to have a very unusual flow of
words.

  Soc. Listen to me, then, in silence; for surely the place is holy;
so that you must not wonder, if, as I proceed, I appear to be in a
divine fury, for already I am getting into dithyrambics.

  Phaedr. Nothing can be truer.

  Soc. The responsibility rests with you. But hear what follows, and
Perhaps the fit may be averted; all is in their hands above. I will go
on talking to my youth. Listen:

  Thus, my friend, we have declared and defined the nature of the
subject. Keeping the definition in view, let us now enquire what
advantage or disadvantage is likely to ensue from the lover or the
non-lover to him who accepts their advances.

  He who is the victim of his passions and the slave of pleasure
will of course desire to make his beloved as agreeable to himself as
possible. Now to him who has a mind discased anything is agreeable
which is not opposed to him, but that which is equal or superior is
hateful to him, and therefore the lover Will not brook any superiority
or equality on the part of his beloved; he is always employed in
reducing him to inferiority. And the ignorant is the inferior of the
wise, the coward of the brave, the slow of speech of the speaker,
the dull of the clever. These, and not these only, are the mental
defects of the beloved;-defects which, when implanted by nature, are
necessarily a delight to the lover, and when not implanted, he must
contrive to implant them in him, if he would not be deprived of his
fleeting joy. And therefore he cannot help being jealous, and will
debar his beloved from the advantages of society which would make a
man of him, and especially from that society which would have given
him wisdom, and thereby he cannot fail to do him great harm. That is
to say, in his excessive fear lest he should come to be despised in
his eyes he will be compelled to banish from him divine philosophy;
and there is no greater injury which he can inflict upon him than
this. He will contrive that his beloved shall be wholly ignorant,
and in everything shall look to him; he is to be the delight of the
lover''s heart, and a curse to himself. Verily, a lover is a profitable
guardian and associate for him in all that relates to his mind.

  Let us next see how his master, whose law of life is pleasure and
not good, will keep and train the body of his servant. Will he not
choose a beloved who is delicate rather than sturdy and strong? One
brought up in shady bowers and not in the bright sun, a stranger to
manly exercises and the sweat of toil, accustomed only to a soft and
luxurious diet, instead of the hues of health having the colours of
paint and ornament, and the rest of a piece?-such a life as any one
can imagine and which I need not detail at length. But I may sum up
all that I have to say in a word, and pass on. Such a person in war,
or in any of the great crises of life, will be the anxiety of his
friends and also of his lover, and certainly not the terror of his
enemies; which nobody can deny.

  And now let us tell what advantage or disadvantage the beloved
will receive from the guardianship and society of his lover in the
matter of his property; this is the next point to be considered. The
lover will be the first to see what, indeed, will be sufficiently
evident to all men, that he desires above all things to deprive his
beloved of his dearest and best and holiest possessions, father,
mother, kindred, friends, of all whom he thinks may be hinderers or
reprovers of their most sweet converse; he will even cast a jealous
eye upon his gold and silver or other property, because these make him
a less easy prey, and when caught less manageable; hence he is of
necessity displeased at his possession of them and rejoices at their
loss; and he would like him to be wifeless, childless, homeless, as
well; and the longer the better, for the longer he is all this, the
longer he will enjoy him.

  There are some soft of animals, such as flatterers, who are
dangerous and, mischievous enough, and yet nature has mingled a
temporary pleasure and grace in their composition. You may say that
a courtesan is hurtful, and disapprove of such creatures and their
practices, and yet for the time they are very pleasant. But the
lover is not only hurtful to his love; he is also an extremely
disagreeable companion. The old proverb says that "birds of a
feather flock together"; I suppose that equality of years inclines
them to the same pleasures, and similarity begets friendship; yet
you may have more than enough even of this; and verily constraint is
always said to be grievous. Now the lover is not only unlike his
beloved, but he forces himself upon him. For he is old and his love is
young, and neither day nor night will he leave him if he can help;
necessity and the sting of desire drive him on, and allure him with
the pleasure which he receives from seeing, hearing, touching,
perceiving him in every way. And therefore he is delighted to fasten
upon him and to minister to him. But what pleasure or consolation
can the beloved be receiving all this time? Must he not feel the
extremity of disgust when he looks at an old shrivelled face and the
remainder to match, which even in a description is disagreeable, and
quite detestable when he is forced into daily contact with his
lover; moreover he is jealously watched and guarded against everything
and everybody, and has to hear misplaced and exaggerated praises of
himself, and censures equally inappropriate, which are intolerable
when the man is sober, and, besides being intolerable, are published
all over the world in all their indelicacy and wearisomeness when he
is drunk.

  And not only while his love continues is he mischievous and
unpleasant, but when his love ceases he becomes a perfidious enemy
of him on whom he showered his oaths and prayers and promises, and yet
could hardly prevail upon him to tolerate the tedium of his company
even from motives of interest. The hour of payment arrives, and now he
is the servant of another master; instead of love and infatuation,
wisdom and temperance are his bosom''s lords; but the beloved has not
discovered the change which has taken place in him, when he asks for a
return and recalls to his recollection former sayings and doings; he
believes himself to be speaking to the same person, and the other, not
having the courage to confess the truth, and not knowing how to fulfil
the oaths and promises which he made when under the dominion of folly,
and having now grown wise and temperate, does not want to do as he did
or to be as he was before. And so he runs away and is constrained to
be a defaulter; the oyster-shell has fallen with the other side
uppermost-he changes pursuit into flight, while the other is compelled
to follow him with passion and imprecation not knowing that he ought
never from the first to have accepted a demented lover instead of a
sensible non-lover; and that in making such a choice he was giving
himself up to a faithless, morose, envious, disagreeable being,
hurtful to his estate, hurtful to his bodily health, and still more
hurtful to the cultivation of his mind, than which there neither is
nor ever will be anything more honoured in the eyes both of gods and
men. Consider this, fair youth, and know that in the friendship of the
lover there is no real kindness; he has an appetite and wants to
feed upon you:

    As wolves love lambs so lovers love their loves.

  But I told you so, I am speaking in verse, and therefore I had
better make an end; enough.

  Phaedr. I thought that you were only halfway and were going to
make a similar speech about all the advantages of accepting the
non-lover. Why do you not proceed?

  Soc. Does not your simplicity observe that I have got out of
dithyrambics into heroics, when only uttering a censure on the
lover? And if I am to add the praises of the non-lover, what will
become of me? Do you not perceive that I am already overtaken by the
Nymphs to whom you have mischievously exposed me? And therefore will
only add that the non-lover has all the advantages in which the
lover is accused of being deficient. And now I will say no more; there
has been enough of both of them. Leaving the tale to its fate, I
will cross the river and make the best of my way home, lest a worse
thing be inflicted upon me by you.

  Phaedr. Not yet, Socrates; not until the heat of the day has passed;
do you not see that the hour is almost noon? there is the midday sun
standing still, as people say, in the meridian. Let us rather stay and
talk over what has been said, and then return in the cool.

  Soc. Your love of discourse, Phaedrus, is superhuman, simply
marvellous, and I do not believe that there is any one of your
contemporaries who has either made or in one way or another has
compelled others to make an equal number of speeches. I would except
Simmias the Theban, but all the rest are far behind you. And now, I do
verily believe that you have been the cause of another.

  Phaedr. That is good news. But what do you mean?

  Soc. I mean to say that as I was about to cross the stream the usual
sign was given to me,-that sign which always forbids, but never
bids, me to do anything which I am going to do; and I thought that I
heard a voice saying in my car that I had been guilty of impiety, and.
that I must not go away until I had made an atonement. Now I am a
diviner, though not a very good one, but I have enough religion for my
own use, as you might say of a bad writer-his writing is good enough
for him; and I am beginning to see that I was in error. O my friend,
how prophetic is the human soul! At the time I had a sort of
misgiving, and, like Ibycus, "I was troubled; I feared that I might be
buying honour from men at the price of sinning against the gods."
Now I recognize my error.

  Phaedr. What error?

  Soc. That was a dreadful speech which you brought with you, and
you made me utter one as bad.

  Phaedr. How so?

  Soc. It was foolish, I say,-to a certain extent, impious; can
anything be more dreadful?

  Phaedr. Nothing, if the speech was really such as you describe.

  Soc. Well, and is not Eros the son of Aphrodite, and a god?

  Phaedr. So men say.

  Soc. But that was not acknowledged by Lysias in his speech, nor by
you in that other speech which you by a charm drew from my lips. For
if love be, as he surely is, a divinity, he cannot be evil. Yet this
was the error of both the speeches. There was also a simplicity
about them which was refreshing; having no truth or honesty in them,
nevertheless they pretended to be something, hoping to succeed in
deceiving the manikins of earth and gain celebrity among them.
Wherefore I must have a purgation. And I bethink me of an ancient
purgation of mythological error which was devised, not by Homer, for
he never had the wit to discover why he was blind, but by Stesichorus,
who was a philosopher and knew the reason why; and therefore, when
he lost his eyes, for that was the penalty which was inflicted upon
him for reviling the lovely Helen, he at once purged himself. And
the purgation was a recantation, which began thus,-

  False is that word of mine-the truth is that thou didst not embark
in ships, nor ever go to the walls of Troy;

and when he had completed his poem, which is called "the recantation,"
immediately his sight returned to him. Now I will be wiser than either
Stesichorus or Homer, in that I am going to make my recantation for
reviling love before I suffer; and this I will attempt, not as before,
veiled and ashamed, but with forehead bold and bare.

  Phaedr. Nothing could be more agreeable to me than to hear you say
so.

  Soc. Only think, my good Phaedrus, what an utter want of delicacy
was shown in the two discourses; I mean, in my own and in that which
you recited out of the book. Would not any one who was himself of a
noble and gentle nature, and who loved or ever had loved a nature like
his own, when we tell of the petty causes of lovers'' jealousies, and
of their exceeding animosities, and of the injuries which they do to
their beloved, have imagined that our ideas of love were taken from
some haunt of sailors to which good manners were unknown-he would
certainly never have admitted the justice of our censure?

  Phaedr. I dare say not, Socrates.

  Soc. Therefore, because I blush at the thought of this person, and
also because I am afraid of Love himself, I desire to wash the brine
out of my ears with water from the spring; and I would counsel
Lysias not to delay, but to write another discourse, which shall prove
that ceteris paribus the lover ought to be accepted rather than the
non-lover.

  Phaedr. Be assured that he shall. You shall speak the praises of the
lover, and Lysias shall be compelled by me to write another
discourse on the same theme.

  Soc. You will be true to your nature in that, and therefore I
believe you.

  Phaedr. Speak, and fear not.

  Soc. But where is the fair youth whom I was addressing before, and
who ought to listen now; lest, if he hear me not, he should accept a
non-lover before he knows what he is doing?

  Phaedr. He is close at hand, and always at your service.

  Soc. Know then, fair youth, that the former discourse was the word
of Phaedrus, the son of Vain Man, who dwells in the city of Myrrhina
(Myrrhinusius). And this which I am about to utter is the
recantation of Stesichorus the son of Godly Man (Euphemus), who
comes from the town of Desire (Himera), and is to the following
effect: "I told a lie when I said" that the beloved ought to accept
the non-lover when he might have the lover, because the one is sane,
and the other mad. It might be so if madness were simply an evil;
but there is also a madness which is a divine gift, and the source
of the chiefest blessings granted to men. For prophecy is a madness,
and the prophetess at Delphi and the priestesses at Dodona when out of
their senses have conferred great benefits on Hellas, both in public
and private life, but when in their senses few or none. And I might
also tell you how the Sibyl and other inspired persons have given to
many an one many an intimation of the future which has saved them from
falling. But it would be tedious to speak of what every one knows.

  There will be more reason in appealing to the ancient inventors of
names, who would never have connected prophecy (mantike) which
foretells the future and is the noblest of arts, with madness
(manike), or called them both by the same name, if they had deemed
madness to be a disgrace or dishonour;-they must have thought that
there was an inspired madness which was a noble thing; for the two
words, mantike and manike, are really the same, and the letter t is
only a modern and tasteless insertion. And this is confirmed by the
name which was given by them to the rational investigation of
futurity, whether made by the help of birds or of other signs-this,
for as much as it is an art which supplies from the reasoning
faculty mind (nous) and information (istoria) to human thought
(oiesis) they originally termed oionoistike, but the word has been
lately altered and made sonorous by the modern introduction of the
letter Omega (oionoistike and oionistike), and in proportion
prophecy (mantike) is more perfect and august than augury, both in
name and fact, in the same proportion, as the ancients testify, is
madness superior to a sane mind (sophrosune) for the one is only of
human, but the other of divine origin. Again, where plagues and
mightiest woes have bred in certain families, owing to some ancient
blood-guiltiness, there madness has entered with holy prayers and
rites, and by inspired utterances found a way of deliverance for those
who are in need; and he who has part in this gift, and is truly
possessed and duly out of his mind, is by the use of purifications and
mysteries made whole and except from evil, future as well as
present, and has a release from the calamity which was afflicting him.
The third kind is the madness of those who are possessed by the Muses;
which taking hold of a delicate and virgin soul, and there inspiring
frenzy, awakens lyrical and all other numbers; with these adorning the
myriad actions of ancient heroes for the instruction of posterity. But
he who, having no touch of the Muses'' madness in his soul, comes to
the door and thinks that he will get into the temple by the help of
art-he, I say, and his poetry are not admitted; the sane man
disappears and is nowhere when he enters into rivalry with the madman.

  I might tell of many other noble deeds which have sprung from
inspired madness. And therefore, let no one frighten or flutter us
by saying that the temperate friend is to be chosen rather than the
inspired, but let him further show that love is not sent by the gods
for any good to lover or beloved; if he can do so we will allow him to
carry off the palm. And we, on our part, will prove in answer to him
that the madness of love is the greatest of heaven''s blessings, and
the proof shall be one which the wise will receive, and the witling
disbelieve. But first of all, let us view the affections and actions
of the soul divine and human, and try to ascertain the truth about
them. The beginning of our proof is as follows:-

  The soul through all her being is immortal, for that which is ever
in motion is immortal; but that which moves another and is moved by
another, in ceasing to move ceases also to live. Only the self-moving,
never leaving self, never ceases to move, and is the fountain and
beginning of motion to all that moves besides. Now, the beginning is
unbegotten, for that which is begotten has a beginning; but the
beginning is begotten of nothing, for if it were begotten of
something, then the begotten would not come from a beginning. But if
unbegotten, it must also be indestructible; for if beginning were
destroyed, there could be no beginning out of anything, nor anything
out of a beginning; and all things must have a beginning. And
therefore the self-moving is the beginning of motion; and this can
neither be destroyed nor begotten, else the whole heavens and all
creation would collapse and stand still, and never again have motion
or birth. But if the self-moving is proved to be immortal, he who
affirms that self-motion is the very idea and essence of the soul will
not be put to confusion. For the body which is moved from without is
soulless; but that which is moved from within has a soul, for such
is the nature of the soul. But if this be true, must not the soul be
the self-moving, and therefore of necessity unbegotten and immortal?
Enough of the soul''s immortality.

  Of the nature of the soul, though her true form be ever a theme of
large and more than mortal discourse, let me speak briefly, and in a
figure. And let the figure be composite-a pair of winged horses and
a charioteer. Now the winged horses and the charioteers of the gods
are all of them noble and of noble descent, but those of other races
are mixed; the human charioteer drives his in a pair; and one of
them is noble and of noble breed, and the other is ignoble and of
ignoble breed; and the driving of them of necessity gives a great deal
of trouble to him. I will endeavour to explain to you in what way
the mortal differs from the immortal creature. The soul in her
totality has the care of inanimate being everywhere, and traverses the
whole heaven in divers forms appearing--when perfect and fully
winged she soars upward, and orders the whole world; whereas the
imperfect soul, losing her wings and drooping in her flight at last
settles on the solid ground-there, finding a home, she receives an
earthly frame which appears to be self-moved, but is really moved by
her power; and this composition of soul and body is called a living
and mortal creature. For immortal no such union can be reasonably
believed to be; although fancy, not having seen nor surely known the
nature of God, may imagine an immortal creature having both a body and
also a soul which are united throughout all time. Let that, however,
be as God wills, and be spoken of acceptably to him. And now let us
ask the reason why the soul loses her wings!

  The wing is the corporeal element which is most akin to the
divine, and which by nature tends to soar aloft and carry that which
gravitates downwards into the upper region, which is the habitation of
the gods. The divine is beauty, wisdom, goodness, and the like; and by
these the wing of the soul is nourished, and grows apace; but when fed
upon evil and foulness and the opposite of good, wastes and falls
away. Zeus, the mighty lord, holding the reins of a winged chariot,
leads the way in heaven, ordering all and taking care of all; and
there follows him the array of gods and demigods, marshalled in eleven
bands; Hestia alone abides at home in the house of heaven; of the rest
they who are reckoned among the princely twelve march in their
appointed order. They see many blessed sights in the inner heaven, and
there are many ways to and fro, along which the blessed gods are
passing, every one doing his own work; he may follow who will and can,
for jealousy has no place in the celestial choir. But when they go
to banquet and festival, then they move up the steep to the top of the
vault of heaven. The chariots of the gods in even poise, obeying the
rein, glide rapidly; but the others labour, for the vicious steed goes
heavily, weighing down the charioteer to the earth when his steed
has not been thoroughly trained:-and this is the hour of agony and
extremest conflict for the soul. For the immortals, when they are at
the end of their course, go forth and stand upon the outside of
heaven, and the revolution of the spheres carries them round, and they
behold the things beyond. But of the heaven which is above the
heavens, what earthly poet ever did or ever will sing worthily? It
is such as I will describe; for I must dare to speak the truth, when
truth is my theme. There abides the very being with which true
knowledge is concerned; the colourless, formless, intangible
essence, visible only to mind, the pilot of the soul. The divine
intelligence, being nurtured upon mind and pure knowledge, and the
intelligence of every soul which is capable of receiving the food
proper to it, rejoices at beholding reality, and once more gazing upon
truth, is replenished and made glad, until the revolution of the
worlds brings her round again to the same place. In the revolution she
beholds justice, and temperance, and knowledge absolute, not in the
form of generation or of relation, which men call existence, but
knowledge absolute in existence absolute; and beholding the other true
existences in like manner, and feasting upon them, she passes down
into the interior of the heavens and returns home; and there the
charioteer putting up his horses at the stall, gives them ambrosia
to eat and nectar to drink.

  Such is the life of the gods; but of other souls, that which follows
God best and is likest to him lifts the head of the charioteer into
the outer world, and is carried round in the revolution, troubled
indeed by the steeds, and with difficulty beholding true being;
while another only rises and falls, and sees, and again fails to see
by reason of the unruliness of the steeds. The rest of the souls are
also longing after the upper world and they all follow, but not
being strong enough they are carried round below the surface,
plunging, treading on one another, each striving to be first; and
there is confusion and perspiration and the extremity of effort; and
many of them are lamed or have their wings broken through the
ill-driving of the charioteers; and all of them after a fruitless
toil, not having attained to the mysteries of true being, go away, and
feed upon opinion. The reason why the souls exhibit this exceeding
eagerness to behold the plain of truth is that pasturage is found
there, which is suited to the highest part of the soul; and the wing
on which the soul soars is nourished with this. And there is a law
of Destiny, that the soul which attains any vision of truth in company
with a god is preserved from harm until the next period, and if
attaining always is always unharmed. But when she is unable to follow,
and fails to behold the truth, and through some ill-hap sinks
beneath the double load of forgetfulness and vice, and her wings
fall from her and she drops to the ground, then the law ordains that
this soul shall at her first birth pass, not into any other animal,
but only into man; and the soul which has seen most of truth shall
come to the birth as a philosopher, or artist, or some musical and
loving nature; that which has seen truth in the second degree shall be
some righteous king or warrior chief; the soul which is of the third
class shall be a politician, or economist, or trader; the fourth shall
be lover of gymnastic toils, or a physician; the fifth shall lead
the life of a prophet or hierophant; to the sixth the character of
poet or some other imitative artist will be assigned; to the seventh
the life of an artisan or husbandman; to the eighth that of a
sophist or demagogue; to the ninth that of a tyrant-all these are
states of probation, in which he who does righteously improves, and he
who does unrighteously, improves, and he who does unrighteously,
deteriorates his lot.

  Ten thousand years must elapse before the soul of each one can
return to the place from whence she came, for she cannot grow her
wings in less; only the soul of a philosopher, guileless and true,
or the soul of a lover, who is not devoid of philosophy, may acquire
wings in the third of the recurring periods of a thousand years; he is
distinguished from the ordinary good man who gains wings in three
thousand years:-and they who choose this life three times in
succession have wings given them, and go away at the end of three
thousand years. But the others receive judgment when they have
completed their first life, and after the judgment they go, some of
them to the houses of correction which are under the earth, and are
punished; others to some place in heaven whither they are lightly
borne by justice, and there they live in a manner worthy of the life
which they led here when in the form of men. And at the end of the
first thousand years the good souls and also the evil souls both
come to draw lots and choose their second life, and they may take
any which they please. The soul of a man may pass into the life of a
beast, or from the beast return again into the man. But the soul which
has never seen the truth will not pass into the human form. For a
man must have intelligence of universals, and be able to proceed
from the many particulars of sense to one conception of reason;-this
is the recollection of those things which our soul once saw while
following God-when regardless of that which we now call being she
raised her head up towards the true being. And therefore the mind of
the philosopher alone has wings; and this is just, for he is always,
according to the measure of his abilities, clinging in recollection to
those things in which God abides, and in beholding which He is what He
is. And he who employs aright these memories is ever being initiated
into perfect mysteries and alone becomes truly perfect. But, as he
forgets earthly interests and is rapt in the divine, the vulgar deem
him mad, and rebuke him; they do not see that he is inspired.

  Thus far I have been speaking of the fourth and last kind of
madness, which is imputed to him who, when he sees the beauty of
earth, is transported with the recollection of the true beauty; he
would like to fly away, but he cannot; he is like a bird fluttering
and looking upward and careless of the world below; and he is
therefore thought to be mad. And I have shown this of all inspirations
to be the noblest and highest and the offspring of the highest to
him who has or shares in it, and that he who loves the beautiful is
called a lover because he partakes of it. For, as has been already
said, every soul of man has in the way of nature beheld true being;
this was the condition of her passing into the form of man. But all
souls do not easily recall the things of the other world; they may
have seen them for a short time only, or they may have been
unfortunate in their earthly lot, and, having had their hearts
turned to unrighteousness through some corrupting influence, they
may have lost the memory of the holy things which once they saw. Few
only retain an adequate remembrance of them; and they, when they
behold here any image of that other world, are rapt in amazement;
but they are ignorant of what this rapture means, because they do
not clearly perceive. For there is no light of justice or temperance
or any of the higher ideas which are precious to souls in the
earthly copies of them: they are seen through a glass dimly; and there
are few who, going to the images, behold in them the realities, and
these only with difficulty. There was a time when with the rest of the
happy band they saw beauty shining in brightness-we philosophers
following in the train of Zeus, others in company with other gods; and
then we beheld the beatific vision and were initiated into a mystery
which may be truly called most blessed, celebrated by us in our
state of innocence, before we had any experience of evils to come,
when we were admitted to the sight of apparitions innocent and
simple and calm and happy, which we beheld shining impure light,
pure ourselves and not yet enshrined in that living tomb which we
carry about, now that we are imprisoned in the body, like an oyster in
his shell. Let me linger over the memory of scenes which have passed
away.

  But of beauty, I repeat again that we saw her there shining in
company with the celestial forms; and coming to earth we find her here
too, shining in clearness through the clearest aperture of sense.
For sight is the most piercing of our bodily senses; though not by
that is wisdom seen; her loveliness would have been transporting if
there had been a visible image of her, and the other ideas, if they
had visible counterparts, would be equally lovely. But this is the
privilege of beauty, that being the loveliest she is also the most
palpable to sight. Now he who is not newly initiated or who has become
corrupted, does not easily rise out of this world to the sight of true
beauty in the other; he looks only at her earthly namesake, and
instead of being awed at the sight of her, he is given over to
pleasure, and like a brutish beast he rushes on to enjoy and beget; he
consorts with wantonness, and is not afraid or ashamed of pursuing
pleasure in violation of nature. But he whose initiation is recent,
and who has been the spectator of many glories in the other world,
is amazed when he sees any one having a godlike face or form, which is
the expression of divine beauty; and at first a shudder runs through
him, and again the old awe steals over him; then looking upon the face
of his beloved as of a god he reverences him, and if he were not
afraid of being thought a downright madman, he would sacrifice to
his beloved as to the image of a god; then while he gazes on him there
is a sort of reaction, and the shudder passes into an unusual heat and
perspiration; for, as he receives the effluence of beauty through
the eyes, the wing moistens and he warms. And as he warms, the parts
out of which the wing grew, and which had been hitherto closed and
rigid, and had prevented the wing from shooting forth, are melted, and
as nourishment streams upon him, the lower end of the wings begins
to swell and grow from the root upwards; and the growth extends
under the whole soul-for once the whole was winged.

  During this process the whole soul is all in a state of ebullition
and effervescence,-which may be compared to the irritation and
uneasiness in the gums at the time of cutting teeth,-bubbles up, and
has a feeling of uneasiness and tickling; but when in like manner
the soul is beginning to grow wings, the beauty of the beloved meets
her eye and she receives the sensible warm motion of particles which
flow towards her, therefore called emotion (imeros), and is
refreshed and warmed by them, and then she ceases from her pain with
joy. But when she is parted from her beloved and her moisture fails,
then the orifices of the passage out of which the wing shoots dry up
and close, and intercept the germ of the wing; which, being shut up
with the emotion, throbbing as with the pulsations of an artery,
pricks the aperture which is nearest, until at length the entire
soul is pierced and maddened and pained, and at the recollection of
beauty is again delighted. And from both of them together the soul
is oppressed at the strangeness of her condition, and is in a great
strait and excitement, and in her madness can neither sleep by night
nor abide in her place by day. And wherever she thinks that she will
behold the beautiful one, thither in her desire she runs. And when she
has seen him, and bathed herself in the waters of beauty, her
constraint is loosened, and she is refreshed, and has no more pangs
and pains; and this is the sweetest of all pleasures at the time,
and is the reason why the soul of the lover will never forsake his
beautiful one, whom he esteems above all; he has forgotten mother
and brethren and companions, and he thinks nothing of the neglect
and loss of his property; the rules and proprieties of life, on
which he formerly prided himself, he now despises, and is ready to
sleep like a servant, wherever he is allowed, as near as he can to his
desired one, who is the object of his worship, and the physician who
can alone assuage the greatness of his pain. And this state, my dear
imaginary youth to whom I am talking, is by men called love, and among
the gods has a name at which you, in your simplicity, may be
inclined to mock; there are two lines in the apocryphal writings of
Homer in which the name occurs. One of them is rather outrageous,
and not altogether metrical. They are as follows:

   Mortals call him fluttering love,

   But the immortals call him winged one,

   Because the growing of wings is a necessity to him.

You may believe this, but not unless you like. At any rate the loves
of lovers and their causes are such as I have described.

  Now the lover who is taken to be the attendant of Zeus is better
able to bear the winged god, and can endure a heavier burden; but
the attendants and companions of Ares, when under the influence of
love, if they fancy that they have been at all wronged, are ready to
kill and put an end to themselves and their beloved. And he who
follows in the train of any other god, while he is unspoiled and the
impression lasts, honours and imitates him, as far as he is able;
and after the manner of his god he behaves in his intercourse with his
beloved and with the rest of the world during the first period of
his earthly existence. Every one chooses his love from the ranks of
beauty according to his character, and this he makes his god, and
fashions and adorns as a sort of image which he is to fall down and
worship. The followers of Zeus desire that their beloved should have a
soul like him; and therefore they seek out some one of a philosophical
and imperial nature, and when they have found him and loved him,
they do all they can to confirm such a nature in him, and if they have
no experience of such a disposition hitherto, they learn of any one
who can teach them, and themselves follow in the same way. And they
have the less difficulty in finding the nature of their own god in
themselves, because they have been compelled to gaze intensely on him;
their recollection clings to him, and they become possessed of him,
and receive from him their character and disposition, so far as man
can participate in God. The qualities of their god they attribute to
the beloved, wherefore they love him all the more, and if, like the
Bacchic Nymphs, they draw inspiration from Zeus, they pour out their
own fountain upon him, wanting to make him as like as possible to
their own god. But those who are the followers of Here seek a royal
love, and when they have found him they do just the same with him; and
in like manner the followers of Apollo, and of every other god walking
in the ways of their god, seek a love who is to be made like him
whom they serve, and when they have found him, they themselves imitate
their god, and persuade their love to do the same, and educate him
into the manner and nature of the god as far as they each can; for
no feelings of envy or jealousy are entertained by them towards
their beloved, but they do their utmost to create in him the
greatest likeness of themselves and of the god whom they honour.
Thus fair and blissful to the beloved is the desire of the inspired
lover, and the initiation of which I speak into the mysteries of
true love, if he be captured by the lover and their purpose is
effected. Now the beloved is taken captive in the following manner:-

  As I said at the beginning of this tale, I divided each soul into
three-two horses and a charioteer; and one of the horses was good
and the other bad: the division may remain, but I have not yet
explained in what the goodness or badness of either consists, and to
that I will proceed. The right-hand horse is upright and cleanly made;
he has a lofty neck and an aquiline nose; his colour is white, and his
eyes dark; he is a lover of honour and modesty and temperance, and the
follower of true glory; he needs no touch of the whip, but is guided
by word and admonition only. The other is a crooked lumbering
animal, put together anyhow; he has a short thick neck; he is
flat-faced and of a dark colour, with grey eyes and blood-red
complexion; the mate of insolence and pride, shag-eared and deaf,
hardly yielding to whip and spur. Now when the charioteer beholds
the vision of love, and has his whole soul warmed through sense, and
is full of the prickings and ticklings of desire, the obedient
steed, then as always under the government of shame, refrains from
leaping on the beloved; but the other, heedless of the pricks and of
the blows of the whip, plunges and runs away, giving all manner of
trouble to his companion and the charioteer, whom he forces to
approach the beloved and to remember the joys of love. They at first
indignantly oppose him and will not be urged on to do terrible and
unlawful deeds; but at last, when he persists in plaguing them, they
yield and agree to do as he bids them.

  And now they are at the spot and behold the flashing beauty of the
beloved; which when the charioteer sees, his memory is carried to
the true beauty, whom he beholds in company with Modesty like an image
placed upon a holy pedestal. He sees her, but he is afraid and falls
backwards in adoration, and by his fall is compelled to pull back
the reins with such violence as to bring both the steeds on their
haunches, the one willing and unresisting, the unruly one very
unwilling; and when they have gone back a little, the one is
overcome with shame and wonder, and his whole soul is bathed in
perspiration; the other, when the pain is over which the bridle and
the fall had given him, having with difficulty taken breath, is full
of wrath and reproaches, which he heaps upon the charioteer and his
fellow-steed, for want of courage and manhood, declaring that they
have been false to their agreement and guilty of desertion. Again they
refuse, and again he urges them on, and will scarce yield to their
prayer that he would wait until another time. When the appointed
hour comes, they make as if they had forgotten, and he reminds them,
fighting and neighing and dragging them on, until at length he, on the
same thoughts intent, forces them to draw near again. And when they
are near he stoops his head and puts up his tail, and takes the bit in
his teeth. and pulls shamelessly. Then the charioteer is. worse off
than ever; he falls back like a racer at the barrier, and with a still
more violent wrench drags the bit out of the teeth of the wild steed
and covers his abusive tongue and-jaws with blood, and forces his legs
and haunches to the ground and punishes him sorely. And when this
has happened several times and the villain has ceased from his
wanton way, he is tamed and humbled, and follows the will of the
charioteer, and when he sees the beautiful one he is ready to die of
fear. And from that time forward the soul of the lover follows the
beloved in modesty and holy fear.

  And so the beloved who, like a god, has received every true and
loyal service from his lover, not in pretence but in reality, being
also himself of a nature friendly to his admirer, if in former days he
has blushed to own his passion and turned away his lover, because
his youthful companions or others slanderously told him that he
would be disgraced, now as years advance, at the appointed age and
time, is led to receive him into communion. For fate which has
ordained that there shall be no friendship among the evil has also
ordained that there shall ever be friendship among the good. And the
beloved when he has received him into communion and intimacy, is quite
amazed at the good-will of the lover; he recognises that the
inspired friend is worth all other friends or kinsmen; they have
nothing of friendship in them worthy to be compared with his. And when
his feeling continues and he is nearer to him and embraces him, in
gymnastic exercises and at other times of meeting, then the fountain
of that stream, which Zeus when he was in love with Ganymede named
Desire, overflows upon the lover, and some enters into his soul, and
some when he is filled flows out again; and as a breeze or an echo
rebounds from the smooth rocks and returns whence it came, so does the
stream of beauty, passing through the eyes which are the windows of
the soul, come back to the beautiful one; there arriving and
quickening the passages of the wings, watering. them and inclining
them to grow, and filling the soul of the beloved also with love.
And thus he loves, but he knows not what; he does not understand and
cannot explain his own state; he appears to have caught the
infection of blindness from another; the lover is his mirror in whom
he is beholding himself, but he is not aware of this. When he is
with the lover, both cease from their pain, but when he is away then
he longs as he is longed for, and has love''s image, love for love
(Anteros) lodging in his breast, which he calls and believes to be not
love but friendship only, and his desire is as the desire of the
other, but weaker; he wants to see him, touch him, kiss him, embrace
him, and probably not long afterwards his desire is accomplished. When
they meet, the wanton steed of the lover has a word to say to the
charioteer; he would like to have a little pleasure in return for many
pains, but the wanton steed of the beloved says not a word, for he
is bursting with passion which he understands not;-he throws his
arms round the lover and embraces him as his dearest friend; and, when
they are side by side, he is not in it state in which he can refuse
the lover anything, if he ask him; although his fellow-steed and the
charioteer oppose him with the arguments of shame and reason.

  After this their happiness depends upon their self-control; if the
better elements of the mind which lead to order and philosophy
prevail, then they pass their life here in happiness and
harmony-masters of themselves and orderly-enslaving the vicious and
emancipating the virtuous elements of the soul; and when the end
comes, they are light and winged for flight, having conquered in one
of the three heavenly or truly Olympian victories; nor can human
discipline or divine inspiration confer any greater blessing on man
than this. If, on the other hand, they leave philosophy and lead the
lower life of ambition, then probably, after wine or in some other
careless hour, the two wanton animals take the two souls when off
their guard and bring them together, and they accomplish that desire
of their hearts which to the many is bliss; and this having once
enjoyed they continue to enjoy, yet rarely because they have not the
approval of the whole soul. They too are dear, but not so dear to
one another as the others, either at the time of their love or
afterwards. They consider that they have given and taken from each
other the most sacred pledges, and they may not break them and fall
into enmity. At last they pass out of the body, unwinged, but eager to
soar, and thus obtain no mean reward of love and madness. For those
who have once begun the heavenward pilgrimage may not go down again to
darkness and the journey beneath the earth, but they live in light
always; happy companions in their pilgrimage, and when the time
comes at which they receive their wings they have the same plumage
because of their love.

  Thus great are the heavenly blessings which the friendship of a
lover will confer upon you, my youth. Whereas the attachment of the
non-lover, which is alloyed with a worldly prudence and has worldly
and niggardly ways of doling out benefits, will breed in your soul
those vulgar qualities which the populace applaud, will send you
bowling round the earth during a period of nine thousand years, and
leave, you a fool in the world below.

  And thus, dear Eros, I have made and paid my recantation, as well
and as fairly as I could; more especially in the matter of the
poetical figures which I was compelled to use, because Phaedrus
would have them. And now forgive the past and accept the present,
and be gracious and merciful to me, and do not in thine anger
deprive me of sight, or take from me the art of love which thou hast
given me, but grant that I may be yet more esteemed in the eyes of the
fair. And if Phaedrus or I myself said anything rude in our first
speeches, blame Lysias, who is the father of the brat, and let us have
no more of his progeny; bid him study philosophy, like his brother
Polemarchus; and then his lover Phaedrus will no longer halt between
two opinions, but will dedicate himself wholly to love and to
philosophical discourses.

  Phaedr. I join in the prayer, Socrates, and say with you, if this be
for my good, may your words come to pass. But why did you make your
second oration so much finer than the first? I wonder why. And I begin
to be afraid that I shall lose conceit of Lysias, and that he will
appear tame in comparison, even if he be willing to put another as
fine and as long as yours into the field, which I doubt. For quite
lately one of your politicians was abusing him on this very account;
and called him a "speech writer" again and again. So that a feeling of
pride may probably induce him to give up writing speeches.

  Soc. What a very amusing notion! But I think, my young man, that you
are much mistaken in your friend if you imagine that he is
frightened at a little noise; and possibly, you think that his
assailant was in earnest?

  Phaedr. I thought, Socrates, that he was. And you are aware that the
greatest and most influential statesmen are ashamed of writing
speeches and leaving them in a written form, lest they should be
called Sophists by posterity.

  Soc. You seem to be unconscious, Phaedrus, that the "sweet elbow" of
the proverb is really the long arm of the Nile. And you appear to be
equally unaware of the fact that this sweet elbow of theirs is also
a long arm. For there is nothing of which our great politicians are so
fond as of writing speeches and bequeathing them to posterity. And
they add their admirers'' names at the top of the writing, out of
gratitude to them.

  Phaedr. What do you mean? I do not understand.

  Soc. Why, do you not know that when a politician writes, he begins
with the names of his approvers?

  Phaedr. How so?

  Soc. Why, he begins in this manner: "Be it enacted by the senate,
the people, or both, on the motion of a certain person," who is our
author; and so putting on a serious face, he proceeds to display his
own wisdom to his admirers in what is often a long and tedious
composition. Now what is that sort of thing but a regular piece of
authorship?

  Phaedr. True.

  Soc. And if the law is finally approved, then the author leaves
the theatre in high delight; but if the law is rejected and he is done
out of his speech-making, and not thought good enough to write, then
he and his party are in mourning.

  Phaedr. Very true.

  Soc. So far are they from despising, or rather so highly do they
value the practice of writing.

  Phaedr. No doubt.

  Soc. And when the king or orator has the power, as Lycurgus or Solon
or Darius had, of attaining an immortality or authorship in a state,
is he not thought by posterity, when they see his compositions, and
does he not think himself, while he is yet alive, to be a god?

  Phaedr. Very true.

  Soc. Then do you think that any one of this class, however
ill-disposed, would reproach Lysias with being an author?

  Phaedr. Not upon your view; for according to you he would be casting
a slur upon his own favourite pursuit.

  Soc. Any one may see that there is no disgrace in the mere fact of
writing.

  Phaedr. Certainly not.

  Soc. The disgrace begins when a man writes not well, but badly.

  Phaedr. Clearly.

  Soc. And what is well and what is badly-need we ask Lysias, or any
other poet or orator, who ever wrote or will write either a
political or any other work, in metre or out of metre, poet or prose
writer, to teach us this?

  Phaedr. Need we? For what should a man live if not for the pleasures
of discourse? Surely not for the sake of bodily pleasures, which
almost always have previous pain as a condition of them, and therefore
are rightly called slavish.

  Soc. There is time enough. And I believe that the grasshoppers
chirruping after their manner in the heat of the sun over our heads
are talking to one another and looking down at us. What would they say
if they saw that we, like the many, are not conversing, but slumbering
at mid-day, lulled by their voices, too indolent to think? Would
they not have a right to laugh at us? They might imagine that we
were slaves, who, coming to rest at a place of resort of theirs,
like sheep lie asleep at noon around the well. But if they see us
discoursing, and like Odysseus sailing past them, deaf to their
siren voices, they may perhaps, out of respect, give us of the gifts
which they receive from the gods that they may impart them to men.

  Phaedr. What gifts do you mean? I never heard of any.

  Soc. A lover of music like yourself ought surely to have heard the
story of the grasshoppers, who are said to have been human beings in
an age before the Muses. And when the Muses came and song appeared
they were ravished with delight; and singing always, never thought
of eating and drinking, until at last in their forgetfulness they
died. And now they live again in the grasshoppers; and this is the
return which the Muses make to them-they neither hunger, nor thirst,
but from the hour of their birth are always singing, and never
eating or drinking; and when they die they go and inform the Muses
in heaven who honours them on earth. They win the love of
Terpsichore for the dancers by their report of them; of Erato for
the lovers, and of the other Muses for those who do them honour,
according to the several ways of honouring them of Calliope the eldest
Muse and of Urania who is next to her, for the philosophers, of
whose music the grasshoppers make report to them; for these are the
Muses who are chiefly concerned with heaven and thought, divine as
well as human, and they have the sweetest utterance. For many reasons,
then, we ought always to talk and not to sleep at mid-day.

  Phaedr. Let us talk.

  Soc. Shall we discuss the rules of writing and speech as we were
proposing?

  Phaedr. Very good.

  Soc. In good speaking should not the mind of the speaker know the
truth of the matter about which he is going to speak?

  Phaedr. And yet, Socrates, I have heard that he who would be an
orator has nothing to do with true justice, but only with that which
is likely to be approved by the many who sit in judgment; nor with the
truly good or honourable, but only with opinion about them, and that
from opinion comes persuasion, and not from the truth.

  Soc. The words of the wise are not to be set aside; for there is
probably something in them; and therefore the meaning of this saying
is not hastily to be dismissed.

  Phaedr. Very true.

  Soc. Let us put the matter thus:-Suppose that I persuaded you to buy
a horse and go to the wars. Neither of us knew what a horse was
like, but I knew that you believed a horse to be of tame animals the
one which has the longest ears.

  Phaedr. That would be ridiculous.

  Soc. There is something more ridiculous coming:-Suppose, further,
that in sober earnest I, having persuaded you of this, went and
composed a speech in honour of an ass, whom I entitled a horse
beginning: "A noble animal and a most useful possession, especially in
war, and you may get on his back and fight, and he will carry
baggage or anything."

  Phaedr. How ridiculous!

  Soc. Ridiculous! Yes; but is not even a ridiculous friend better
than a cunning enemy?

  Phaedr. Certainly.

  Soc. And when the orator instead of putting an ass in the place of a
horse puts good for evil being himself as ignorant of their true
nature as the city on which he imposes is ignorant; and having studied
the notions of the multitude, falsely persuades them not about "the
shadow of an ass," which he confounds with a horse, but about good
which he confounds with evily-what will be the harvest which
rhetoric will be likely to gather after the sowing of that seed?

  Phaedr. The reverse of good.

  Soc. But perhaps rhetoric has been getting too roughly handled by
us, and she might answer: What amazing nonsense you are talking! As if
I forced any man to learn to speak in ignorance of the truth! Whatever
my advice may be worth, I should have told him to arrive at the
truth first, and then come to me. At the same time I boldly assert
that mere knowledge of the truth will not give you the art of
persuasion.

  Phaedr. There is reason in the lady''s defence of herself.

  Soc. Quite true; if only the other arguments which remain to be
brought up bear her witness that she is an art at all. But I seem to
hear them arraying themselves on the opposite side, declaring that she
speaks falsely, and that rhetoric is a mere routine and trick, not
an art. Lo! a Spartan appears, and says that there never is nor ever
will be a real art of speaking which is divorced from the truth.

  Phaedr. And what are these arguments, Socrates? Bring them out
that we may examine them.

  Soc. Come out, fair children, and convince Phaedrus, who is the
father of similar beauties, that he will never be able to speak
about anything as he ought to speak unless he have a knowledge of
philosophy. And let Phaedrus answer you.

  Phaedr. Put the question.

  Soc. Is not rhetoric, taken generally, a universal art of enchanting
the mind by arguments; which is practised not only in courts and
public assemblies, but in private houses also, having to do with all
matters, great as well as small, good and bad alike, and is in all
equally right, and equally to be esteemed-that is what you have heard?

  Phaedr. Nay, not exactly that; I should say rather that I have heard
the art confined to speaking and writing in lawsuits, and to
speaking in public assemblies-not extended farther.

  Soc. Then I suppose that you have only heard of the rhetoric of
Nestor and Odysseus, which they composed in their leisure hours when
at Troy, and never of the rhetoric of Palamedes?

  Phaedr. No more than of Nestor and Odysseus, unless Gorgias is
your Nestor, and Thrasymachus or Theodorus your Odysseus.

  Soc. Perhaps that is my meaning. But let us leave them. And do you
tell me, instead, what are plaintiff and defendant doing in a law
court-are they not contending?

  Phaedr. Exactly so.

  Soc. About the just and unjust-that is the matter in dispute?

  Phaedr. Yes.

  Soc. And a professor of the art will make the same thing appear to
the same persons to be at one time just, at another time, if he is
so inclined, to be unjust?

  Phaedr. Exactly.

  Soc. And when he speaks in the assembly, he will make the same
things seem good to the city at one time, and at another time the
reverse of good?

  Phaedr. That is true.

  Soc. Have we not heard of the Eleatic Palamedes (Zeno), who has an
art of speaking by which he makes the same things appear to his
hearers like and unlike, one and many, at rest and in motion?

  Phaedr. Very true.

  Soc. The art of disputation, then, is not confined to the courts and
the assembly, but is one and the same in every use of language; this
is the art, if there be such an art, which is able to find a
likeness of everything to which a likeness can be found, and draws
into the light of day the likenesses and disguises which are used by
others?

  Phaedr. How do you mean?

  Soc. Let me put the matter thus: When will there be more chance of
deception-when the difference is large or small?

  Phaedr. When the difference is small.

  Soc. And you will be less likely to be discovered in passing by
degrees into the other extreme than when you go all at once?

  Phaedr. Of course.

  Soc. He, then, who would. deceive others, and not be deceived,
must exactly know the real likenesses and differences of things?

  Phaedr. He must.

  Soc. And if he is ignorant of the true nature of any subject, how
can he detect the greater or less degree of likeness in other things
to that of which by the hypothesis he is ignorant?

  Phaedr. He cannot.

  Soc. And when men are deceived and their notions are at variance
with realities, it is clear that the error slips in through
resemblances?

  Phaedr. Yes, that is the way.

  Soc. Then he who would be a master of the art must understand the
real nature of everything; or he will never know either how to make
the gradual departure from truth into the opposite of truth which is
effected by the help of resemblances, or how to avoid it?

  Phaedr. He will not.

  Soc. He then, who being ignorant of the truth aims at appearances,
will only attain an art of rhetoric which is ridiculous and is not
an art at all?

  Phaedr. That may be expected.

  Soc. Shall I propose that we look for examples of art and want of
art, according to our notion of them, in the speech of Lysias which
you have in your hand, and in my own speech?

  Phaedr. Nothing could be better; and indeed I think that our
previous argument has been too abstract and-wanting in illustrations.

  Soc. Yes; and the two speeches happen to afford a very good
example of the way in which the speaker who knows the truth may,
without any serious purpose, steal away the hearts of his hearers.
This piece of good-fortune I attribute to the local deities; and
perhaps, the prophets of the Muses who are singing over our heads
may have imparted their inspiration to me. For I do not imagine that I
have any rhetorical art of my own.

  Phaedr. Granted; if you will only please to get on.

  Soc. Suppose that you read me the first words of Lysias'' speech.

  Phaedr. "You know how matters stand with me, and how, as I conceive,
they might be arranged for our common interest; and I maintain that
I ought not to fail in my suit, because I am not your lover. For
lovers repent-"

  Soc. Enough:-Now, shall I point out the rhetorical error of those
words?

  Phaedr. Yes.

  Soc. Every one is aware that about some things we are agreed,
whereas about other things we differ.

  Phaedr. I think that I understand you; but will you explain
yourself?

  Soc. When any one speaks of iron and silver, is not the same thing
present in the minds of all?

  Phaedr. Certainly.

  Soc. But when any one speaks of justice and goodness we part company
and are at odds with one another and with ourselves?

  Phaedr. Precisely.

  Soc. Then in some things we agree, but not in others?

  Phaedr. That is true.

  Soc. In which are we more likely to be deceived, and in which has
rhetoric the greater power?

  Phaedr. Clearly, in the uncertain class.

  Soc. Then the rhetorician ought to make a regular division, and
acquire a distinct notion of both classes, as well of that in which
the many err, as of that in which they do not err?

  Phaedr. He who made such a distinction would have an excellent
principle.

  Soc. Yes; and in the next place he must have a keen eye for the
observation of particulars in speaking, and not make a mistake about
the class to which they are to be referred.

  Phaedr. Certainly.

  Soc. Now to which class does love belong-to the debatable or to
the undisputed class?

  Phaedr. To the debatable, clearly; for if not, do you think that
love would have allowed you to say as you did, that he is an evil both
to the lover and the beloved, and also the greatest possible good?

  Soc. Capital. But will you tell me whether I defined love at the
beginning of my speech? for, having been in an ecstasy, I cannot
well remember.

  Phaedr. Yes, indeed; that you did, and no mistake.

  Soc. Then I perceive that the Nymphs of Achelous and Pan the son
of Hermes, who inspired me, were far better rhetoricians than Lysias
the son of Cephalus. Alas! how inferior to them he is! But perhaps I
am mistaken; and Lysias at the commencement of his lover''s speech
did insist on our supposing love to be something or other which he
fancied him to be, and according to this model he fashioned and framed
the remainder of his discourse. Suppose we read his beginning over
again:

  Phaedr. If you please; but you will not find what you want.

  Soc, Read, that I may have his exact words.

  Phaedr. "You know how matters stand with and how, as I conceive,
they might be arranged for our common interest; and I maintain I ought
not to fail in my suit because I am not your lover, for lovers
repent of the kindnesses which they have shown, when their love is
over."

  Soc. Here he appears to have done just the reverse of what he ought;
for he has begun at the end, and is swimming on his back through the
flood to the place of starting. His address to the fair youth begins
where the lover would have ended. Am I not right, sweet Phaedrus?

  Phaedr. Yes, indeed, Socrates; he does begin at the end.

  Soc. Then as to the other topics-are they not thrown down anyhow? Is
there any principle in them? Why should the next topic follow next
in order, or any other topic? I cannot help fancying in my ignorance
that he wrote off boldly just what came into his head, but I dare
say that you would recognize a rhetorical necessity in the
succession of the several parts of the composition?

  Phaedr. You have too good an opinion of me if you think that I
have any such insight into his principles of composition.

  Soc. At any rate, you will allow that every discourse ought to be
a living creature, having a body of its own and a head and feet; there
should be a middle, beginning, and end, adapted to one another and
to the whole?

  Phaedr. Certainly.

  Soc. Can this be said of the discourse of Lysias? See whether you
can find any more connexion in his words than in the epitaph which
is said by some to have been inscribed on the grave of Midas the
Phrygian.

  Phaedr. What is there remarkable in the epitaph?

  Soc. It is as follows:-

   I am a maiden of bronze and lie on the tomb of Midas;

   So long as water flows and tall trees grow,

   So long here on this spot by his sad tomb abiding,

   I shall declare to passers-by that Midas sleeps below.

Now in this rhyme whether a line comes first or comes last, as you
will perceive, makes no difference.

  Phaedr. You are making fun of that oration of ours.

  Soc. Well, I will say no more about your friend''s speech lest I
should give offence to you; although I think that it might furnish
many other examples of what a man ought rather to avoid. But I will
proceed to the other speech, which, as I think, is also suggestive
to students of rhetoric.

  Phaedr. In what way?

  Soc. The two speeches, as you may remember, were unlike-I the one
argued that the lover and the other that the non-lover ought to be
accepted.

  Phaedr. And right manfully.

  Soc. You should rather say "madly"; and madness was the argument
of them, for, as I said, "love is a madness."

  Phaedr. Yes.

  Soc. And of madness there were two kinds; one produced by human
infirmity, the other was a divine release of the soul from the yoke of
custom and convention.

  Phaedr. True.

  Soc. The divine madness was subdivided into four kinds, prophetic,
initiatory, poetic, erotic, having four gods presiding over them;
the first was the inspiration of Apollo, the second that of
Dionysus, the third that of the Muses, the fourth that of Aphrodite
and Eros. In the description of the last kind of madness, which was
also said to be the best, we spoke of the affection of love in a
figure, into which we introduced a tolerably credible and possibly
true though partly erring myth, which was also a hymn in honour of
Love, who is your lord and also mine, Phaedrus, and the guardian of
fair children, and to him we sung the hymn in measured and solemn
strain.

  Phaedr. I know that I had great pleasure in listening to you.

  Soc. Let us take this instance and note how the transition was
made from blame to praise.

  Phaedr. What do you mean?

  Soc. I mean to say that the composition was mostly playful. Yet in
these chance fancies of the hour were involved two principles of which
we should be too glad to have a clearer description if art could
give us one.

  Phaedr. What are they?

  Soc. First, the comprehension of scattered particulars in one
idea; as in our definition of love, which whether true or false
certainly gave clearness and consistency to the discourse, the speaker
should define his several notions and so make his meaning clear.

  Phaedr. What is the other principle, Socrates?

  Soc. The second principle is that of division into species according
to the natural formation, where the joint is, not breaking any part as
a bad carver might. Just as our two discourses, alike assumed, first
of all, a single form of unreason; and then, as the body which from
being one becomes double and may be divided into a left side and right
side, each having parts right and left of the same name-after this
manner the speaker proceeded to divide the parts of the left side
and did not desist until he found in them an evil or left-handed
love which he justly reviled; and the other discourse leading us to
the madness which lay on the right side, found another love, also
having the same name, but divine, which the speaker held up before
us and applauded and affirmed to be the author of the greatest
benefits.

  Phaedr. Most true.

  Soc. I am myself a great lover of these processes of division and
generalization; they help me to speak and to think. And if I find
any man who is able to see "a One and Many" in nature, him I follow,
and "walk in his footsteps as if he were a god." And those who have
this art, I have hitherto been in the habit of calling
dialecticians; but God knows whether the name is right or not. And I
should like to know what name you would give to your or to Lysias''
disciples, and whether this may not be that famous art of rhetoric
which Thrasymachus and others teach and practise? Skilful speakers
they are, and impart their skill to any who is willing to make kings
of them and to bring gifts to them.

  Phaedr. Yes, they are royal men; but their art is not the same
with the art of those whom you call, and rightly, in my opinion,
dialecticians:-Still we are in the dark about rhetoric.

  Soc. What do you mean? The remains of it, if there be anything
remaining which can be brought under rules of art, must be a fine
thing; and, at any rate, is not to be despised by you and me. But
how much is left?

  Phaedr. There is a great deal surely to be found in books of
rhetoric?

  Soc. Yes; thank you for reminding me:-There is the exordium, showing
how the speech should begin, if I remember rightly; that is what you
mean-the niceties of the art?

  Phaedr. Yes.

  Soc. Then follows the statement of facts, and upon that witnesses;
thirdly, proofs; fourthly, probabilities are to come; the great
Byzantian word-maker also speaks, if I am not mistaken, of
confirmation and further confirmation.

  Phaedr. You mean the excellent Theodorus.

  Soc. Yes; and he tells how refutation or further refutation is to be
managed, whether in accusation or defence. I ought also to mention the
illustrious Parian, Evenus, who first invented insinuations and
indirect praises; and also indirect censures, which according to
some he put into verse to help the memory. But shall I "to dumb
forgetfulness consign" Tisias and Gorgias, who are not ignorant that
probability is superior to truth, and who by: force of argument make
the little appear great and the great little, disguise the new in
old fashions and the old in new fashions, and have discovered forms
for everything, either short or going on to infinity. I remember
Prodicus laughing when I told him of this; he said that he had himself
discovered the true rule of art, which was to be neither long nor
short, but of a convenient length.

  Phaedr. Well done, Prodicus!

  Soc. Then there is Hippias the Elean stranger, who probably agrees
with him.

  Phaedr. Yes.

  Soc. And there is also Polus, who has treasuries of diplasiology,
and gnomology, and eikonology, and who teaches in them the names of
which Licymnius made him a present; they were to give a polish.

  Phaedr. Had not Protagoras something of the same sort?

  Soc. Yes, rules of correct diction and many other fine precepts; for
the "sorrows of a poor old man," or any other pathetic case, no one is
better than the Chalcedonian giant; he can put a whole company of
people into a passion and out of one again by his mighty magic, and is
first-rate at inventing or disposing of any sort of calumny on any
grounds or none. All of them agree in asserting that a speech should
end in a recapitulation, though they do not all agree to use the
same word.

  Phaedr. You mean that there should be a summing up of the
arguments in order to remind the hearers of them.

  Soc. I have now said all that I have to say of the art of
rhetoric: have you anything to add?

  Phaedr. Not much; nothing very important.

  Soc. Leave the unimportant and let us bring the really important
question into the light of day, which is: What power has this art of
rhetoric, and when?

  Phaedr. A very great power in public meetings.

  Soc. It has. But I should like to know whether you have the same
feeling as I have about the rhetoricians? To me there seem to be a
great many holes in their web.

  Phaedr. Give an example.

  Soc. I will. Suppose a person to come to your friend Eryximachus, or
to his father Acumenus, and to say to him: "I know how to apply
drugs which shall have either a heating or a cooling effect, and I can
give a vomit and also a purge, and all that sort of thing; and knowing
all this, as I do, I claim to be a physician and to make physicians by
imparting this knowledge to others,"-what do you suppose that they
would say?

  Phaedr. They would be sure to ask him whether he knew "to whom" he
would give his medicines, and "when," and "how much."

  Soc. And suppose that he were to reply: "No; I know nothing of all
that; I expect the patient who consults me to be able to do these
things for himself"?

  Phaedr. They would say in reply that he is a madman or pedant who
fancies that he is a physician because he has read something in a
book, or has stumbled on a prescription or two, although he has no
real understanding of the art of medicine.

  Soc. And suppose a person were to come to Sophocles or Euripides and
say that he knows how to make a very long speech about a small matter,
and a short speech about a great matter, and also a sorrowful
speech, or a terrible, or threatening speech, or any other kind of
speech, and in teaching this fancies that he is teaching the art of
tragedy-?

  Phaedr. They too would surely laugh at him if he fancies that
tragedy is anything but the arranging of these elements in a manner
which will be suitable to one another and to the whole.

  Soc. But I do not suppose that they would be rude or abusive to him:
Would they not treat him as a musician would a man who thinks that
he is a harmonist because he knows how to pitch the highest and lowest
notes; happening to meet such an one he would not say to him savagely,
"Fool, you are mad!" But like a musician, in a gentle and harmonious
tone of voice, he would answer: "My good friend, he who would be a
harmonist must certainly know this, and yet he may understand
nothing of harmony if he has not got beyond your stage of knowledge,
for you only know the preliminaries of harmony and not harmony
itself."

  Phaedr. Very true.

  Soc. And will not Sophocles say to the display of the would-be
tragedian, that this is not tragedy but the preliminaries of
tragedy? and will not Acumenus say the same of medicine to the
would-be physician?

  Phaedr. Quite true.

  Soc. And if Adrastus the mellifluous or Pericles heard of these
wonderful arts, brachylogies and eikonologies and all the hard names
which we have been endeavouring to draw into the light of day, what
would they say? Instead of losing temper and applying
uncomplimentary epithets, as you and I have been doing, to the authors
of such an imaginary art, their superior wisdom would rather censure
us, as well as them. "Have a little patience, Phaedrus and Socrates,
they would say; you should not be in such a passion with those who
from some want of dialectical skill are unable to define the nature of
rhetoric, and consequently suppose that they have found the art in the
preliminary conditions of it, and when these have been taught by
them to others, fancy that the whole art of rhetoric has been taught
by them; but as to using the several instruments of the art
effectively, or making the composition a whole,-an application of it
such as this is they regard as an easy thing which their disciples may
make for themselves."

  Phaedr. I quite admit, Socrates, that the art of rhetoric which
these men teach and of which they write is such as you
describe-there I agree with you. But I still want to know where and
how the true art of rhetoric and persuasion is to be acquired.

  Soc. The perfection which is required of the finished orator is,
or rather must be, like the perfection of anything else; partly
given by nature, but may also be assisted by art. If you have the
natural power and add to it knowledge and practice, you will be a
distinguished speaker; if you fall short in either of these, you
will be to that extent defective. But the art, as far as there is an
art, of rhetoric does not lie in the direction of Lysias or
Thrasymachus.

  Phaedr. In what direction then?

  Soc. I conceive Pericles to have been the most accomplished of
rhetoricians.

  Phaedr. What of that?

  Soc. All the great arts require discussion and high speculation
about the truths of nature; hence come loftiness of thought and
completeness of execution. And this, as I conceive, was the quality
which, in addition to his natural gifts, Pericles acquired from his
intercourse with Anaxagoras whom he happened to know. He was thus
imbued with the higher philosophy, and attained the knowledge of
Mind and the negative of Mind, which were favourite themes of
Anaxagoras, and applied what suited his purpose to the art of
speaking.

  Phaedr. Explain.

  Soc. Rhetoric is like medicine.

  Phaedr. How so?

  Soc. Why, because medicine has to define the nature of the body
and rhetoric of the soul-if we would proceed, not empirically but
scientifically, in the one case to impart health and strength by
giving medicine and food in the other to implant the conviction or
virtue which you desire, by the right application of words and
training.

  Phaedr. There, Socrates, I suspect that you are right.

  Soc. And do you think that you can know the nature of the soul
intelligently without knowing the nature of the whole?

  Phaedr. Hippocrates the Asclepiad says that the nature even of the
body can only be understood as a whole.

  Soc. Yes, friend, and he was right:-still, we ought not to be
content with the name of Hippocrates, but to examine and see whether
his argument agrees with his conception of nature.

  Phaedr. I agree.

  Soc. Then consider what truth as well as Hippocrates says about this
or about any other nature. Ought we not to consider first whether that
which we wish to learn and to teach is a simple or multiform thing,
and if simple, then to enquire what power it has of acting or being
acted upon in relation to other things, and if multiform, then to
number the forms; and see first in the case of one of them, and then
in. case of all of them, what is that power of acting or being acted
upon which makes each and all of them to be what they are?

  Phaedr. You may very likely be right, Socrates.

  Soc. The method which proceeds without analysis is like the
groping of a blind man. Yet, surely, he who is an artist ought not
to admit of a comparison with the blind, or deaf. The rhetorician, who
teaches his pupil to speak scientifically, will particularly set forth
the nature of that being to which he addresses his speeches; and this,
I conceive, to be the soul.

  Phaedr. Certainly.

  Soc. His whole effort is directed to the soul; for in that he
seeks to produce conviction.

  Phaedr. Yes.

  Soc. Then clearly, Thrasymachus or any one else who teaches rhetoric
in earnest will give an exact description of the nature of the soul;
which will enable us to see whether she be single and same, or, like
the body, multiform. That is what we should call showing the nature of
the soul.

  Phaedr. Exactly.

  Soc. He will explain, secondly, the mode in which she acts or is
acted upon.

  Phaedr. True.

  Soc. Thirdly, having classified men and speeches, and their kinds
and affections, and adapted them to one another, he will tell the
reasons of his arrangement, and show why one soul is persuaded by a
particular form of argument, and another not.

  Phaedr. You have hit upon a very good way.

  Soc. Yes, that is the true and only way in which any subject can
be set forth or treated by rules of art, whether in speaking or
writing. But the writers of the present day, at whose feet you have
sat, craftily, conceal the nature of the soul which they know quite
well. Nor, until they adopt our method of reading and writing, can
we admit that they write by rules of art?

  Phaedr. What is our method?

  Soc. I cannot give you the exact details; but I should like to
tell you generally, as far as is in my power, how a man ought to
proceed according to rules of art.

  Phaedr. Let me hear.

  Soc. Oratory is the art of enchanting the soul, and therefore he who
would be an orator has to learn the differences of human souls-they
are so many and of such a nature, and from them come the differences
between man and man. Having proceeded thus far in his analysis, he
will next divide speeches into their different classes:-"Such and such
persons," he will say, are affected by this or that kind of speech
in this or that way," and he will tell you why. The pupil must have
a good theoretical notion of them first, and then he must have
experience of them in actual life, and be able to follow them with all
his senses about him, or he will never get beyond the precepts of
his masters. But when he understands what persons are persuaded by
what arguments, and sees the person about whom he was speaking in
the abstract actually before him, and knows that it is he, and can say
to himself, "This is the man or this is the character who ought to
have a certain argument applied to him in order to convince him of a
certain opinion"; -he who knows all this, and knows also when he
should speak and when he should refrain, and when he should use
pithy sayings, pathetic appeals, sensational effects, and all the
other modes of speech which he has learned;-when, I say, he knows
the times and seasons of all these things, then, and not till then, he
is a perfect master of his art; but if he fail in any of these points,
whether in speaking or teaching or writing them, and yet declares that
he speaks by rules of art, he who says "I don''t believe you" has the
better of him. Well, the teacher will say, is this, and Socrates, your
account of the so-called art of rhetoric, or am I to look for another?

  Phaedr. He must take this, Socrates for there is no possibility of
another, and yet the creation of such an art is not easy.

  Soc. Very true; and therefore let us consider this matter in every
light, and see whether we cannot find a shorter and easier road; there
is no use in taking a long rough round-about way if there be a shorter
and easier one. And I wish that you would try and remember whether you
have heard from Lysias or any one else anything which might be of
service to us.

  Phaedr. If trying would avail, then I might; but at the moment I can
think of nothing.

  Soc. Suppose I tell you something which somebody who knows told me.

  Phaedr. Certainly.

  Soc. May not "the wolf," as the proverb says, claim a hearing"?

  Phaedr. Do you say what can be said for him.

  Soc. He will argue that is no use in putting a solemn face on
these matters, or in going round and round, until you arrive at
first principles; for, as I said at first, when the question is of
justice and good, or is a question in which men are concerned who
are just and good, either by nature or habit, he who would be a
skilful rhetorician has; no need of truth-for that in courts of law
men literally care nothing about truth, but only about conviction: and
this is based on probability, to which who would be a skilful orator
should therefore give his whole attention. And they say also that
there are cases in which the actual facts, if they are improbable,
ought to be withheld, and only the probabilities should be told either
in accusation or defence, and that always in speaking, the orator
should keep probability in view, and say good-bye to the truth. And
the observance, of this principle throughout a speech furnishes the
whole art.

  Phaedr. That is what the professors of rhetoric do actually say,
Socrates. I have not forgotten that we have quite briefly touched upon
this matter already; with them the point is all-important.

  Soc. I dare say that you are familiar with Tisias. Does he not
define probability to be that which the many think?

  Phaedr. Certainly, he does.

  Soc. I believe that he has a clever and ingenious case of this
sort:-He supposes a feeble and valiant man to have assaulted a
strong and cowardly one, and to have robbed him of his coat or of
something or other; he is brought into court, and then Tisias says
that both parties should tell lies: the coward should say that he
was assaulted by more men than one; the other should prove that they
were alone, and should argue thus: "How could a weak man like me
have assaulted a strong man like him?" The complainant will not like
to confess his own cowardice, and will therefore invent some other lie
which his adversary will thus gain an opportunity of refuting. And
there are other devices of the same kind which have a place in the
system. Am I not right, Phaedrus?

  Phaedr. Certainly.

  Soc. Bless me, what a wonderfully mysterious art is this which
Tisias or some other gentleman, in whatever name or country he
rejoices, has discovered. Shall we say a word to him or not?

  Phaedr. What shall we say to him?

  Soc. Let us tell him that, before he appeared, you and I were saying
that the probability of which he speaks was engendered in the minds of
the many by the likeness of the truth, and we had just been
affirming that he who knew the truth would always know best how to
discover the resemblances of the truth. If he has anything else to say
about the art of speaking we should like to hear him; but if not, we
are satisfied with our own view, that unless a man estimates the
various characters of his heaters and is able to divide all things
into classes and to comprehend them under single ideas he will never
be a skilful rhetorician even within the limits of human power. And
this skill he will not attain without a great deal of trouble, which a
good man ought to undergo, not for the sake of speaking and acting
before men, but in order that he may be able to say what is acceptable
to God and always to act acceptably to Him as far as in him lies;
for there is a saying of wiser men than ourselves, that a man of sense
should not try to please his fellow-servants (at least this should not
be his first object) but his good and noble masters; and therefore
if the way is long and circuitous, marvel not at this, for, where
the end is great, there we may take the longer road, but not for
lesser ends such as yours. Truly, the argument may say, Tisias, that
if you do not mind going so far, rhetoric has a fair beginning here.

  Phaedr. I think, Socrates, that this is admirable, if only
practicable.

  Soc. But even to fail in an honourable object is honourable.

  Phaedr. True.

  Soc. Enough appears to have been said by us of a true and false
art of speaking.

  Phaedr. Certainly.

  Soc. But there is something yet to be said of propriety and
impropriety of writing.

  Phaedr. Yes.

  Soc. Do you know how you can speak or act about rhetoric in a manner
which will be acceptable to God?

  Phaedr. No, indeed. Do you?

  Soc. I have heard a tradition of the ancients, whether true or not
they only know; although if we had found the truth ourselves, do you
think that we should care much about the opinions of men?

  Phaedr. Your question needs no answer; but I wish that you would
tell me what you say that you have heard.

  Soc. At the Egyptian city of Naucratis, there was a famous old
god, whose name was Theuth; the bird which is called the Ibis is
sacred to him, and he was the inventor of many arts, such as
arithmetic and calculation and geometry and astronomy and draughts and
dice, but his great discovery was the use of letters. Now in those
days the god Thamus was the king of the whole country of Egypt; and he
dwelt in that great city of Upper Egypt which the Hellenes call
Egyptian Thebes, and the god himself is called by them Ammon. To him
came Theuth and showed his inventions, desiring that the other
Egyptians might be allowed to have the benefit of them; he enumerated
them, and Thamus enquired about their several uses, and praised some
of them and censured others, as he approved or disapproved of them. It
would take a long time to repeat all that Thamus said to Theuth in
praise or blame of the various arts. But when they came to letters,
This, said Theuth, will make the Egyptians wiser and give them
better memories; it is a specific both for the memory and for the wit.
Thamus replied: O most ingenious Theuth, the parent or inventor of
an art is not always the best judge of the utility or inutility of his
own inventions to the users of them. And in this instance, you who are
the father of letters, from a paternal love of your own children
have been led to attribute to them a quality which they cannot have;
for this discovery of yours will create forgetfulness in the learners''
souls, because they will not use their memories; they will trust to
the external written characters and not remember of themselves. The
specific which you have discovered is an aid not to memory, but to
reminiscence, and you give your disciples not truth, but only the
semblance of truth; they will be hearers of many things and will
have learned nothing; they will appear to be omniscient and will
generally know nothing; they will be tiresome company, having the show
of wisdom without the reality.

  Phaedr. Yes, Socrates, you can easily invent tales of Egypt, or of
any other country.

  Soc. There was a tradition in the temple of Dodona that oaks first
gave prophetic utterances. The men of old, unlike in their
simplicity to young philosophy, deemed that if they heard the truth
even from "oak or rock," it was enough for them; whereas you seem to
consider not whether a thing is or is not true, but who the speaker is
and from what country the tale comes.

  Phaedr. I acknowledge the justice of your rebuke; and I think that
the Theban is right in his view about letters.

  Soc. He would be a very simple person, and quite a stranger to the
oracles of Thamus or Ammon, who should leave in writing or receive
in writing any art under the idea that the written word would be
intelligible or certain; or who deemed that writing was at all
better than knowledge and recollection of the same matters?

  Phaedr. That is most true.

  Soc. I cannot help feeling, Phaedrus, that writing is
unfortunately like painting; for the creations of the painter have the
attitude of life, and yet if you ask them a question they preserve a
solemn silence. And the same may be said of speeches. You would
imagine that they had intelligence, but if you want to know anything
and put a question to one of them, the speaker always gives one
unvarying answer. And when they have been once written down they are
tumbled about anywhere among those who may or may not understand them,
and know not to whom they should reply, to whom not: and, if they
are maltreated or abused, they have no parent to protect them; and
they cannot protect or defend themselves.

  Phaedr. That again is most true.

  Soc. Is there not another kind of word or speech far better than
this, and having far greater power-a son of the same family, but
lawfully begotten?

  Phaedr. Whom do you mean, and what is his origin?

  Soc. I mean an intelligent word graven in the soul of the learner,
which can defend itself, and knows when to speak and when to be
silent.

  Phaedr. You mean the living word of knowledge which has a soul,
and of which written word is properly no more than an image?

  Soc. Yes, of course that is what I mean. And now may I be allowed to
ask you a question: Would a husbandman, who is a man of sense, take
the seeds, which he values and which he wishes to bear fruit, and in
sober seriousness plant them during the heat of summer, in some garden
of Adonis, that he may rejoice when he sees them in eight days
appearing in beauty? at least he would do so, if at all, only for
the sake of amusement and pastime. But when he is in earnest he sows
in fitting soil, and practises husbandry, and is satisfied if in eight
months the seeds which he has sown arrive at perfection?

  Phaedr. Yes, Socrates, that will be his way when he is in earnest;
he will do the other, as you say, only in play.

  Soc. And can we suppose that he who knows the just and good and
honourable has less understanding, than the husbandman, about his
own seeds?

  Phaedr. Certainly not.

  Soc. Then he will not seriously incline to "write" his thoughts
"in water" with pen and ink, sowing words which can neither speak
for themselves nor teach the truth adequately to others?

  Phaedr. No, that is not likely.

  Soc. No, that is not likely-in the garden of letters he will sow and
plant, but only for the sake of recreation and amusement; he will
write them down as memorials to be treasured against the forgetfulness
of old age, by himself, or by any other old man who is treading the
same path. He will rejoice in beholding their tender growth; and while
others are refreshing their souls with banqueting and the like, this
will be the pastime in which his days are spent.

  Phaedr. A pastime, Socrates, as noble as the other is ignoble, the
pastime of a man who can be amused by serious talk, and can
discourse merrily about justice and the like.

  Soc. True, Phaedrus. But nobler far is the serious pursuit of the
dialectician, who, finding a congenial soul, by the help of science
sows and plants therein words which are able to help themselves and
him who planted them, and are not unfruitful, but have in them a
seed which others brought up in different soils render immortal,
making the possessors of it happy to the utmost extent of human
happiness.

  Phaedr. Far nobler, certainly.

  Soc. And now, Phaedrus, having agreed upon the premises we decide
about the conclusion.

  Phaedr. About what conclusion?

  Soc. About Lysias, whom we censured, and his art of writing, and his
discourses, and the rhetorical skill or want of skill which was
shown in them-these are the questions which we sought to determine,
and they brought us to this point. And I think that we are now
pretty well informed about the nature of art and its opposite.

  Phaedr. Yes, I think with you; but I wish that you would repeat what
was said.

  Soc. Until a man knows the truth of the several particulars of which
he is writing or speaking, and is able to define them as they are, and
having defined them again to divide them until they can be no longer
divided, and until in like manner he is able to discern the nature
of the soul, and discover the different modes of discourse which are
adapted to different natures, and to arrange and dispose them in
such a way that the simple form of speech may be addressed to the
simpler nature, and the complex and composite to the more complex
nature-until he has accomplished all this, he will be unable to handle
arguments according to rules of art, as far as their nature allows
them to be subjected to art, either for the purpose of teaching or
persuading;-such is the view which is implied in the whole preceding
argument.

  Phaedr. Yes, that was our view, certainly.

  Soc. Secondly, as to the censure which was passed on the speaking or
writing of discourses, and how they might be rightly or wrongly
censured-did not our previous argument show?-

  Phaedr. Show what?

  Soc. That whether Lysias or any other writer that ever was or will
be, whether private man or statesman, proposes laws and so becomes the
author of a political treatise, fancying that there is any great
certainty and clearness in his performance, the fact of his so writing
is only a disgrace to him, whatever men may say. For not to know the
nature of justice and injustice, and good and evil, and not to be able
to distinguish the dream from the reality, cannot in truth be
otherwise than disgraceful to him, even though he have the applause of
the whole world.

  Phaedr. Certainly.

  Soc. But he who thinks that in the written word there is necessarily
much which is not serious, and that neither poetry nor prose, spoken
or written, is of any great value, if, like the compositions of the
rhapsodes, they are only recited in order to be believed, and not with
any view to criticism or instruction; and who thinks that even the
best of writings are but a reminiscence of what we know, and that only
in principles of justice and goodness and nobility taught and
communicated orally for the sake of instruction and graven in the
soul, which is the true way of writing, is there clearness and
perfection and seriousness, and that such principles are a man''s own
and his legitimate offspring;-being, in the first place, the word
which he finds in his own bosom; secondly, the brethren and
descendants and relations of his others;-and who cares for them and no
others-this is the right sort of man; and you and I, Phaedrus, would
pray that we may become like him.

  Phaedr. That is most assuredly my desire and prayer.

  Soc. And now the play is played out; and of rhetoric enough. Go
and tell Lysias that to the fountain and school of the Nymphs we
went down, and were bidden by them to convey a message to him and to
other composers of speeches-to Homer and other writers of poems,
whether set to music or not; and to Solon and others who have composed
writings in the form of political discourses which they would term
laws-to all of them we are to say that if their compositions are based
on knowledge of the truth, and they can defend or prove them, when
they are put to the test, by spoken arguments, which leave their
writings poor in comparison of them, then they are to be called, not
only poets, orators, legislators, but are worthy of a higher name,
befitting the serious pursuit of their life.

  Phaedr. What name would you assign to them?

  Soc. Wise, I may not call them; for that is a great name which
belongs to God alone,-lovers of wisdom or philosophers is their modest
and befitting title.

  Phaedr. Very suitable.

  Soc. And he who cannot rise above his own compilations and
compositions, which he has been long patching, and piecing, adding
some and taking away some, may be justly called poet or speech-maker
or law-maker.

  Phaedr. Certainly.

  Soc. Now go and tell this to your companion.

  Phaedr. But there is also a friend of yours who ought not to be
forgotten.

  Soc. Who is he?

  Phaedr. Isocrates the fair:-What message will you send to him, and
how shall we describe him?

  Soc. Isocrates is still young, Phaedrus; but I am willing to
hazard a prophecy concerning him.

  Phaedr. What would you prophesy?

  Soc. I think that he has a genius which soars above the orations
of Lysias, and that his character is cast in a finer mould. My
impression of him is that he will marvelously improve as he grows
older, and that all former rhetoricians will be as children in
comparison of him. And I believe that he will not be satisfied with
rhetoric, but that there is in him a divine inspiration which will
lead him to things higher still. For he has an element of philosophy
in his nature. This is the message of the gods dwelling in this place,
and which I will myself deliver to Isocrates, who is my delight; and
do you give the other to Lysias, who is yours.

  Phaedr. I will; and now as the heat is abated let us depart.

  Soc. Should we not offer up a prayer first of all to the local
deities?

  Phaedr. By all means.

  Soc. Beloved Pan, and all ye other gods who haunt this place, give
me beauty in the inward soul; and may the outward and inward man be at
one. May I reckon the wise to be the wealthy, and may I have such a
quantity of gold as a temperate man and he only can bear and
carry.-Anything more? The prayer, I think, is enough for me.

  Phaedr. Ask the same for me, for friends should have all things in
common.

  Soc. Let us go.

                            -THE END-';
declare @object_fqn [nvarchar](max) = N'[pdp_lep].[flower].[set]';
execute [chamomile].[utility].[set_meta_data]
  @object_fqn   =@object_fqn
  , @value      =@platos_dialogue_phaedrus
  , @description=N'description.'
  , @stack      =@stack output;
go
--
select [chamomile].[utility].[get_meta_data](N'[pdp_lep].[flower].[set]') as [meta_data value];
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @object_fqn       [nvarchar](max) = N'[flower].[set]'
        , @schema         [sysname] = N'flower'
        , @object         [sysname] = N'set'
        , @parameter_list [nvarchar](max)
        , @description    [xml]
        , @execute_as     [xml]
        , @sql            [nvarchar](max)
        , @parameters     [nvarchar](max)
        , @output         [nvarchar](max);
--
-------------------------------------------------
select @parameter_list = coalesce(@parameter_list + N' ', N'')
                         + N'<li>' + [parameters].[name] + N' ['
                         + type_name([parameters].[user_type_id])
                         + N']('+
                         + cast([parameters].[max_length]/2 as [sysname])
                         + N') property="'
                         + [extended_properties].[name] + N'" value="'
                         + cast([extended_properties].[value] as [nvarchar](max))
                         + N'"</li>'
from   [sys].[parameters] as [parameters]
       join [sys].[extended_properties] as [extended_properties]
         on [extended_properties].[major_id] = [parameters].[object_id]
            and [extended_properties].[minor_id] = [parameters].[parameter_id]
where  object_schema_name([parameters].[object_id]) = @schema
       and object_name([parameters].[object_id]) = @object;
--
select @sql = N'set @description = (select cast(cast([value] as [nvarchar](max))as [xml])
					   from   fn_listextendedproperty(N''description'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@description [xml] output';
--
execute sp_executesql
  @sql          =@sql
  , @parameters =@parameters
  , @description=@description output;
--
select @sql = N'set @execute_as = (select cast(cast([value] as [nvarchar](max))as [xml])
					   from   fn_listextendedproperty(N''execute_as'', N''schema'', N''flower'', N''procedure'', N''set'', default, default));'
       , @parameters = N'@execute_as [xml] output';
--
execute sp_executesql
  @sql         =@sql
  , @parameters=@parameters
  , @execute_as=@execute_as output;
--
set @output = N'<html><head>
		<link rel="stylesheet" type="text/css" href=".\common.css" target="blank" />
		<p class="header">built on <a href="http://www.katherinelightsey.com" target="blank">[chamomile]</a></p>
	<h2>[' + db_name() + N'].[' + @schema + N'].['
              + @object + N']</h2></head><body>'
              + N'<details><summary>[description]</summary>'
              + cast(@description as [nvarchar](max))
              + N'</details>'
              + N'<details><summary>[execute_as]</summary>'
              + cast(@execute_as as [nvarchar](max))
              + N'</details>'
              + N'<details><summary>[parameter_list]</summary>'
              + @parameter_list + N'</details>'
              + N'<details><summary>[phaedrus]</summary>'
              + [chamomile].[utility].[get_meta_data](N'[pdp_lep].[flower].[set]')
              + N'</details>'
              + N'</body><p class="footer">copyright 2014 <a href="http://www.katherinelightsey.com" target="blank">Katherine Elizabeth Lightsey</a></p></html>';
select N'<!DOCTYPE html>' + @output as [html_output]
       , cast(@output as [xml])     as [xml_output];
-------------------------------------------------
-- code block end
--
