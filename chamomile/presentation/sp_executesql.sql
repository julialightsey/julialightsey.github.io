/*
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	--
	--	description
	---------------------------------------------
		sp_executesql can be used instead of stored procedures to execute a Transact-SQL statement many times when the  
		change in parameter values to the statement is the only variation. Because the Transact-SQL statement itself     
		remains constant and only the parameter values change, the SQL Server query optimizer is likely to reuse the  
		execution plan it generates for the first execution.
		To improve performance use fully qualified object names in the statement string.
		To execute a string, we recommend that you use the sp_executesql stored procedure instead of the EXECUTE statement.  
		Because this stored procedure supports parameter substitution, sp_executesql is more versatile than EXECUTE;  
		and because sp_executesql generates execution plans that are more likely to be reused by SQL Server,  
		sp_executesql is more efficient than EXECUTE.

		sp_executesql [ @stmt = ] statement 
		[  
		{ , [ @params = ] N'@parameter_name data_type [ OUT | OUTPUT ][ ,...n ]' }  
			{ , [ @param1 = ] 'value1' [ ,...n ] } 
		] 

	--
	--	notes
	----------------------------------------------------------------------
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
		sp_executesql (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms188001.aspx 
		SQL Injection: http://msdn.microsoft.com/en-us/library/ms161953(v=SQL.105).aspx 
		SQL injection: http://en.wikipedia.org/wiki/SQL_injection 
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

-- code block end
-- 
--  Getting a list of all the columns in a table 
declare @schema [sysname] = N'repository_secure',
        @table  [sysname]=N'data';

select col.[name]
from   [sys].tables as [tables]
       join [sys].columns as col
         on [tables].[object_id] = col.object_id
       join [sys].schemas as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [schemas].[name] = @schema
       and [tables].[name] = @table;

go

--************************************************************************************************************************** 
--************************************************************************************************************************** 
-- 
--  What if you want to parameterize the query to allow getting columns from other databases 
--    and pass in the schema and table as variables? 
declare @database   [sysname]=N'chamomile_oltp',
        @schema     [sysname] = N'test',
        @table      [sysname]=N'data',
        @sql        [nvarchar](max),
        @builder    xml,
        -- This throws an error. sp_executesql only handles unicode data 
        -- @parameters VARCHAR(max) = N'@builder xml output' 
        @parameters [nvarchar](max) = N'@schema [sysname], @table [sysname], @builder xml output';

set @sql = 'set @builder=(select 
	[columns].[name]					as N''@name''
	, [types].[name]					as N''@type''
	, case
	--
		when [types].[name] = N''nvarchar'' then N''[''+[types].[name]+'']('' + cast([columns].[max_length]/2 as [sysname]) + N'')''
		when [types].[name] = N''decimal'' then N''[''+[types].[name]+'']('' 
			+ cast([columns].[precision] as [sysname]) + N'','' 
			+ cast([columns].[scale] as [sysname])  + N'')''
		else N''[''+[types].[name]+'']''
	--
	end									as N''@formatted''	
from   [' + @database + '].[sys].[tables]			as [tables] 
join   [' + @database
           + '].[sys].[columns]			as [columns] 
  on [tables].[object_id]= [columns].[object_id]
join   [' + @database + '].[sys].[schemas]			as [schemas] 
  on [schemas].[schema_id] = [tables].[schema_id]
join   [' + @database
           + '].[sys].types				as [types]
	on [types].[user_type_id] = [columns].[user_type_id]
where  [schemas].[name] =  @schema  
and [tables].[name] = @table 
for xml path (''column''), root('''
           + @database + N'.' + @schema + N'.' + @table + '''))';

select @sql as [dynamic_sql];

-- order is important!! first @sql, then @parameters, etc. 
execute sp_executesql
  @sql = @sql,
  @parameters= @parameters,
  @schema = @schema,
  @table = @table,
  @builder = @builder output;

/*   
-- This throws an error 
-- The parameter string must be immediately after the SQL string which must be first! 
EXECUTE sp_executesql 
  @sql       = @sql, 
  @builder       = @builder output, 
  @parameters= @parameters;  
 */
select @builder;

go

--
-- SQL INJECTION ATTACKS 
--------------------------------------------------------------------------
--
-- begin code block
--------------------------------------------------------------------------
if schema_id (N'test') is null
  execute(N'create schema test');

go

if object_id (N'[test].[test_01]'
              , N'U') is not null
  drop table [test].[test_01];

go

create table [test].[test_01]
  (
     id      int identity(1, 1)
     , name  [nvarchar](250)
     , color [nvarchar](250)
  );

go

insert into [test].[test_01]
            (name,
             color)
values      (N'spot',
             N'white'),
            (N'spot',
             N'blue'),
            (N'dick',
             N'red'),
            (N'jane',
             N'blue');

select *
from   [sys].tables
where  object_schema_name(object_id) = N'test'

-- 
-- Using EXECUTE() to execute ad hoc sql is prone to attack 
declare @user_entered_parameter_value [nvarchar](max)=N'spot';
declare @sql [nvarchar](max) = N'select * from test.test_01 where name=N'''
  + @user_entered_parameter_value
  + ''' and [color] = N''white''';

select @sql;

execute(@sql);

go

--
-- end code block
--------------------------------------------------------------------------
--
-- begin code block
--------------------------------------------------------------------------
-- 
-- A user can drop the table 
declare @user_entered_parameter_value [nvarchar](max)=N'block''; DROP TABLE [test].[test_01]; --';
declare @sql [nvarchar](max) = N'select * from test.test_01 where name=N'''
  + @user_entered_parameter_value
  + ''' and [color] = N''white''';

select @sql as N'hacked sql to drop table';

execute(@sql);

go

select *
from   [sys].tables
where  object_schema_name(object_id) = N'test'

go

--
-- end code block
--------------------------------------------------------------------------
--
-- begin code block
--------------------------------------------------------------------------
-- 
-- A user can create an account 
if object_id (N'[test].[test_01]'
              , N'U') is not null
  drop table [test].[test_01];

go

create table [test].[test_01]
  (
     id      int identity(1, 1)
     , name  [nvarchar](250)
     , color [nvarchar](250)
  );

go

insert into [test].[test_01]
            (name,
             color)
values      (N'spot',
             N'white'),
            (N'spot',
             N'blue'),
            (N'dick',
             N'red'),
            (N'jane',
             N'blue');

go

if exists(select *
          from   [sys].syslogins
          where  name = N'hacker_login')
  drop login [hacker_login];

go

if exists(select *
          from   [sys].sysusers
          where  name = N'hacker_user')
  drop user [hacker_user];

go

declare @user_entered_parameter_value [nvarchar](max)=N'block''; create login hacker_login with password = ''1_Hacker''; CREATE USER hacker_user for login hacker_login;--';
declare @sql [nvarchar](max) = N'select * from test.test_01 where name=N'''
  + @user_entered_parameter_value
  + ''' and [color] = N''white''';

select @sql as N'hacked sql to create login and user.';

execute(@sql);

select *
from   [sys].syslogins
where  name = N'hacker_login';

go

select *
from   [sys].sysusers
where  name = N'hacker_user';

go

if exists(select *
          from   [sys].syslogins
          where  name = N'hacker_login')
  drop login [hacker_login];

go

if exists(select *
          from   [sys].sysusers
          where  name = N'hacker_user')
  drop user [hacker_user];

go

select *
from   [sys].syslogins
where  name = N'hacker_login';

go

select *
from   [sys].sysusers
where  name = N'hacker_user';

go

--
-- end code block
--------------------------------------------------------------------------
--
-- begin code block
--------------------------------------------------------------------------
-- 
-- SP_EXECUTE() mitigates the risk of sql injection attacks 
declare @name [nvarchar](max)=N'spot',
        @id   int;
declare @sql [nvarchar](max) = N'set @id = (select id from test.test_01 where name=@name and [color] = N''blue'')';
-- we'll declare @name as [nvarchar](max) to prove a point, but it would be best to match it to the table column width 
declare @parameters [nvarchar](max) = N'@name [nvarchar](max), @id int output';

select @sql;

execute sp_executesql
  @sql =@sql,
  @parameters=@parameters,
  @name =@name,
  @id =@id output;

select *
from   test.test_01
where  [id] = @id;

go

-- 
--  
declare @name [nvarchar](max)=N'block''; DROP TABLE [test].[test_01]; --',
        @id   int;
declare @sql [nvarchar](max) = N'set @id = (select id from test.test_01 where name=@name and [color] = N''blue'')';
-- we'll declare @name as [nvarchar](max) to prove a point, but it would be best to match it to the table column width 
declare @parameters [nvarchar](max) = N'@name [nvarchar](max), @id int output';

select @sql;

execute sp_executesql
  @sql =@sql,
  @parameters=@parameters,
  @name =@name,
  @id =@id output;

select @id;

select *
from   [sys].tables
where  object_schema_name(object_id) = N'test'

go

-- 
-- There are many other steps to take in protecting against sql injection attacks. What is shown here is only a small 
--  subset for the purposes of demonstration. 
--************************************************************************************************************************** 
--************************************************************************************************************************** 
-- EXAMPLE 
--************************************************************************************************************************** 
--************************************************************************************************************************** 
if object_id(N'[KateTest].[GetRecords]'
             , N'P') is not null
  drop procedure [katetest].[getrecords];

go

create procedure [katetest].[getrecords] @key       varchar(10)
                                         , @archive bit = 0
as
    declare @sql        [nvarchar](max),
            @parameters [nvarchar](max);

    set @parameters = N'@key VARCHAR(10)';
    set @sql = N'SELECT [value1], 
   [value2] 
FROM   [KateTest].[Records] 
WHERE  [key] = @key';

    if @archive = 0
      begin
          set @sql = @sql + ' AND [archive] IS NOT NULL;'
      end

    execute sp_executesql
      @sql = @sql,
      @parameters = @parameters,
      @key = @key;

go 
