/*
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		INDEXED VIEWS ARE COVERED BY MICROSOFT CERTIFICATION EXAM 70-461 
		Exam 70-461: Querying Microsoft SQL Server 2012 
		Create Database Objects (24%): Create and alter views (simple statements). May include but not limited to:  
			create indexed views; create views without using the built in tools; CREATE, ALTER, DROP. Design views.  
			May include but not limited to: ensure code non regression by keeping consistent signature for  
			procedure, views and function (interfaces); security implications. 
 
		INDEXED VIEWS ARE OFTEN REFERRED TO AS MATERIALIZED VIEWS 
		"After a unique clustered index is created on the view, the view's result set is materialized immediately and  
		persisted in physical storage in the database, saving the overhead of performing this costly operation at  
		execution time." 
 
		INDEXES ON AN INDEXED VIEW ARE USED BY THE QUERY OPTIMIZER JUST AS ARE INDEXES ON THE UNDERLYING OBJECTS 
		"The indexed view can be used in a query execution in two ways. The query can reference the indexed view directly,  
		or, more importantly, the query optimizer can select the view if it determines that the view can be substituted  
		for some or all of the query in the lowest-cost query plan. In the second case, the indexed view is used instead  
		of the underlying tables and their ordinary indexes. The view does not need to be referenced in the query for the  
		query optimizer to use it during query execution. This allows existing applications to benefit from the newly  
		created indexed views without changing those applications." 

		"The first index created on a view must be a unique clustered index. After the unique clustered index has been created, 
		you can create more nonclustered indexes. Creating a unique clustered index on a view improves query performance because 
		the view is stored in the database in the same way a table with a clustered index is stored. The query optimizer may 
		use indexed views to speed up the query execution. The view does not have to be referenced in the query for the optimizer 
		to consider that view for a substitution."

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
		Create Indexed Views: http://msdn.microsoft.com/en-us/library/ms191432.aspx 
		Improving Performance with SQL Server 2005 Indexed Views: http://technet.microsoft.com/en-us/library/cc917715.aspx 
		Improving Performance with SQL Server 2008 Indexed Views: http://msdn.microsoft.com/en-us/library/dd171921(v=sql.100).aspx 
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'presentation_indexed_view') is null
  execute (N'create schema presentation_indexed_view');

go

--  Required SET Options for Indexed Views.  
-- 
--  When SET ANSI_NULLS is ON, a SELECT statement that uses WHERE column_name = NULL  
--    returns zero rows even if there are null values in column_name 
-------------------------------------------------
set ansi_nulls on;
-- 
--  Trailing blanks in character values inserted into [nvarchar] columns are not trimmed.  
--    Trailing zeros in binary values inserted into varbinary columns are not trimmed.  
--    Values are not padded to the length of the column. 
-------------------------------------------------
set ansi_padding on;
-- 
--  When set to ON, if null values appear in aggregate functions, such as SUM, AVG, MAX,  
--    MIN, STDEV, STDEVP, VAR, VARP, or COUNT, a warning message is generated. When set to OFF,  
--    no warning is issued. 
-------------------------------------------------
set ansi_warnings on;
-- 
--  Terminates a query when an overflow or divide-by-zero error occurs during query execution. 
-- "We strongly recommend that you set the ARITHABORT user option to ON server-wide as soon as the 
--	first indexed view or index on a computed column is created in any database on the server."
set arithabort on;
-- 
--  'abc' + NULL returns the value NULL. 
-------------------------------------------------
set concat_null_yields_null on;
-- 
--  When SET NUMERIC_ROUNDABORT is ON, an error is generated after a loss of precision occurs in an  
--    expression. When OFF, losses of precision do not generate error messages and the result is  
--    rounded to the precision of the column or variable storing the result. 
-------------------------------------------------
set numeric_roundabort off;
-- 
--  When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by double quotation marks,  
--    and literals must be delimited by single quotation marks. When SET QUOTED_IDENTIFIER  
--    is OFF, identifiers cannot be quoted and must follow all Transact-SQL rules for identifiers. 
-------------------------------------------------
set quoted_identifier on;

-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
if object_id (N'[presentation_indexed_view].[view_flower]'
              , N'V') is not null
  drop view [presentation_indexed_view].[view_flower];

go

if object_id (N'[presentation_indexed_view].[flower]'
              , N'U') is not null
  drop table [presentation_indexed_view].[flower];

go

create table [presentation_indexed_view].[flower]
  (
     [id]       [int] identity(1, 1) not null
     , [color]  [sysname]
     , [flower] [sysname]
  );

go

-------------------------------------------------
-- code block end
-- 
-- 
--  The view must be created WITH SCHEMABINDING in order to create an index on it. 
--  Tables must be referenced by two-part names, schema.tablename in the view definition. 
--  The definition of an indexed view must be deterministic.  
-------------------------------------------------
--
--  Msg 4512, Level 16, State 3, Procedure [view_flower], Line 5 
--  Cannot schema bind view '[presentation_indexed_view].[view_flower]' because name 'flower' is invalid for schema binding. Names must be in two-part  
--    format and an object cannot reference itself. 
--
-- code block begin
-------------------------------------------------
if object_id (N'[presentation_indexed_view].[view_flower]'
              , N'V') is not null
  drop view [presentation_indexed_view].[view_flower];

go

create view [presentation_indexed_view].[view_flower]
with schemabinding
as
  select [id]
         , [color]
         , [flower]
         ,
         -- 
         --  Having a non-deterministic function in the view will allow the view to be created, but attempts to create indexes will fail. 
         getdate() as [timestamp]
  from   [flower];

go

-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
if object_id (N'[presentation_indexed_view].[view_flower]'
              , N'V') is not null
  drop view [presentation_indexed_view].[view_flower];

go

create view [presentation_indexed_view].[view_flower]
with schemabinding
as
  select [id]
         , [color]
         , [flower]
         ,
         -- 
         --  Having a non-deterministic function in the view will allow the view to be created, but attempts to create indexes will fail. 
         getdate() as [timestamp]
  from   [presentation_indexed_view].[flower];

go

-------------------------------------------------
-- code block end
-- 
-- 
--  Msg 1949, Level 16, State 1, Line 2 
--  Cannot create index on view 'flower.[presentation_indexed_view].[view_flower]'. The function 'getdate' yields nondeterministic results.  
--    Use a deterministic system function, or modify the user-defined function to return deterministic results. 
--
-- code block begin
-------------------------------------------------
if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.view_flower.flower.unique_clustered_index'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.view_flower.flower.unique_clustered_index] on [presentation_indexed_view].[view_flower];

go

begin try
    create unique clustered index [presentation_indexed_view.view_flower.flower.unique_clustered_index]
      on [presentation_indexed_view].[view_flower] (id);
end try

begin catch
    select error_message();
end catch;

go

-------------------------------------------------
-- code block end
-- 
--
-- recreate the table with the timestamp to allow a view to be created
--
-- code block begin
-------------------------------------------------
if object_id (N'[presentation_indexed_view].[view_flower]'
              , N'V') is not null
  drop view [presentation_indexed_view].[view_flower];

go

if object_id (N'[presentation_indexed_view].[flower]'
              , N'U') is not null
  drop table [presentation_indexed_view].[flower];

go

create table [presentation_indexed_view].[flower]
  (
     [id]          [int] identity(1, 1) not null
     , [color]     [sysname]
     , [flower]    [sysname]
     , [care]      [sysname]
     , [timestamp] [datetime] constraint [letter_secure.standard.created.default] default (current_timestamp)
  );

go

-------------------------------------------------
-- code block end
-- 
--
-- the view can now be created with schemabinding and indexed
--
-- code block begin
-------------------------------------------------
if object_id (N'[presentation_indexed_view].[view_flower]'
              , N'V') is not null
  drop view [presentation_indexed_view].[view_flower];

go

create view [presentation_indexed_view].[view_flower]
with schemabinding
as
  select [id]
         , [color]
         , [flower]
         , [care]
  from   [presentation_indexed_view].[flower];

go

-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.view_flower.flower.unique_clustered_index'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.view_flower.flower.unique_clustered_index] on [presentation_indexed_view].[view_flower];

go

create unique clustered index [presentation_indexed_view.view_flower.flower.unique_clustered_index]
  on [presentation_indexed_view].[view_flower] ([flower]);

go

-------------------------------------------------
-- code block end
-- 
--
-- An index on the table is not required to created an index on the view. note that the type_desc
--	is "HEAP", which is how a table is created and managed before it has indexes.
--
-- code block begin
-------------------------------------------------
select *
from   [sys].[indexes] as [indexes]
where  [indexes].object_id = object_id(N'[presentation_indexed_view].[flower]'
                                       , N'U');

go

-------------------------------------------------
-- code block end
-- 
-- 
--  A UNIQUE CLUSTERED INDEX is required before a NONCLUSTERED INDEX can be created 
--	Msg 1940, Level 16, State 1, Line 282
--	Cannot create index on view 'presentation_indexed_view.view_flower'. It does not have a unique clustered index.
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.view_flower.flower.unique_clustered_index'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.view_flower.flower.unique_clustered_index] on [presentation_indexed_view].[view_flower];

go

if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_flower'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_flower] on [presentation_indexed_view].[view_flower];

go

create nonclustered index [presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_care]
  on [presentation_indexed_view].[view_flower]([color])
  include ([care]);

go

-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.view_flower.flower.unique_clustered_index'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.view_flower.flower.unique_clustered_index] on [presentation_indexed_view].[view_flower];

go

create unique clustered index [presentation_indexed_view.view_flower.flower.unique_clustered_index]
  on [presentation_indexed_view].[view_flower] ([flower]);

go

if indexproperty (object_id('[presentation_indexed_view].[view_flower]')
                  , 'presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_flower'
                  , 'IndexID') is not null
  drop index [presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_flower] on [presentation_indexed_view].[view_flower];

go

create nonclustered index [presentation_indexed_view.flower.view_flower.nonclustered_index_color_include_care]
  on [presentation_indexed_view].[view_flower]([color])
  include ([care]);

go

-------------------------------------------------
-- code block end
-- 
-- 
-- There are now two indexes on the view but still none on the table (although it is listed as a "HEAP")
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
select [indexes].*
from   [sys].[indexes] as [indexes]
where  [indexes].[object_id] = object_id(N'[presentation_indexed_view].[view_flower]'
                                         , N'V');

go

select *
from   [sys].[indexes] as [indexes]
where  [indexes].object_id = object_id(N'[presentation_indexed_view].[flower]'
                                       , N'U');

go

-------------------------------------------------
-- code block end
-- 
--
--	inserts can be made directly into the view if required
--
-- code block begin
-------------------------------------------------
insert into [presentation_indexed_view].[flower]
            ([flower],
             [color],
             [care])
values      (N'rose',
             N'red',
             N'lots of water'),
            (N'chamomile',
             N'yellow',
             N'just a little water');

select [flower]
       , [color]
       , [care]
from   [presentation_indexed_view].[view_flower];

-------------------------------------------------
-- code block end
-- 
-- 
--  Attempts to truncate the table will fail. 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
begin try
    truncate table [presentation_indexed_view].[flower];
end try

begin catch
    select error_message();
end catch;

-------------------------------------------------
-- code block end
-- 
--
--  Records can still be deleted from the table 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
delete from [presentation_indexed_view].[flower]
where  [flower] = N'rose';

select [flower]
       , [color]
from   [presentation_indexed_view].[view_flower];

-------------------------------------------------
-- code block end
-- 
-- 
--  Attempts to change the underlying table in a way that would break the view will fail.
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
begin try
    alter table [presentation_indexed_view].[flower]
      drop column [color];
end try

begin catch
    select error_message();
end catch;

-------------------------------------------------
-- code block end
-- 
-- 
--  Attempts to drop the table will fail.
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
begin try
    if object_id (N'[presentation_indexed_view].[flower]'
                  , N'U') is not null
      drop table [presentation_indexed_view].[flower];
end try

begin catch
    select error_message();
end catch;

-------------------------------------------------
-- code block end
-- 
-- 
--  Columns can still be added to the table 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
alter table [presentation_indexed_view].[flower]
  add [available] [bit];

go

select [schemas].[name]   as [schema]
       , [tables].[name]  as [table]
       , [columns].[name] as [column]
       , [types].[name]   as [type]
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
       join [sys].[types] as [types]
         on [columns].[user_type_id] = [types].[user_type_id]
where  [schemas].[name] = N'presentation_indexed_view'
       and [tables].[name] = N'flower';

-------------------------------------------------
-- code block end
-- 
-- 
-- Columns not referenced by the view can be altered 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
alter table [presentation_indexed_view].[flower]
  alter column [available] [int];

go

select [schemas].[name]   as [schema]
       , [tables].[name]  as [table]
       , [columns].[name] as [column]
       , [types].[name]   as [type]
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
       join [sys].[types] as [types]
         on [columns].[user_type_id] = [types].[user_type_id]
where  [schemas].[name] = N'presentation_indexed_view'
       and [tables].[name] = N'flower';

-------------------------------------------------
-- code block end
-- 
-- 
--  Attempts to alter columns accessed by the view will fail 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
begin try
    alter table [presentation_indexed_view].[flower]
      alter column [flower] [nvarchar](max);
end try

begin catch
    select error_message();
end catch;

go

-------------------------------------------------
-- code block end
-- 
-- 
--  Creating views that access system objects will fail 
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
if object_id(N'[presentation_indexed_view].try_to_access_system_objects'
             , N'V') is not null
  drop view [presentation_indexed_view].[try_to_access_system_objects];

go

create view [presentation_indexed_view].[try_to_access_system_objects]
with schemabinding
as
  select col.name
  from   sys.columns as col;

go

-------------------------------------------------
-- code block end
-- 
--
-- tables used indexes on indexed views as if they were their own
--
-- code block begin
-------------------------------------------------
set nocount on;

declare @i [int] = 0;

while @i < 50000
  begin
      insert into [presentation_indexed_view].[flower]
                  ([flower],
                   [color],
                   [care])
      values      (N'rose_' + cast(@i as [sysname]),
                   N'red',
                   N'water');

      set @i = @i + 1;
  end;

--
update statistics [presentation_indexed_view].[flower] with fullscan

--
--
--
set statistics xml on;

go

select *
from   [presentation_indexed_view].[view_flower] with (index=[presentation_indexed_view.view_flower.flower.unique_clustered_index])
where  [flower] = N'rose_31000';

go

set statistics xml off;

go
-------------------------------------------------
-- code block end
-- 
