/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
	  The APPLY operator allows you to invoke a table-valued function for each row returned by an outer table expression of a  
		query. The table-valued function acts as the right input and the outer table expression acts as the left input.  
		The right input is evaluated for each row from the left input and the rows produced are combined for the final  
		output. The list of columns produced by the APPLY operator is the set of columns in the left input followed by  
		the list of columns returned by the right input.  
	  There are two forms of APPLY: CROSS APPLY and OUTER APPLY. CROSS APPLY returns only rows from the outer table that  
		produce a result set from the table-valued function. OUTER APPLY returns both rows that produce a result set, and  
		rows that do not, with NULL values in the columns produced by the table-valued function. 

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
		Using APPLY - http://technet.microsoft.com/en-us/library/ms175156(v=sql.105).aspx
		SQL Server APPLY Basics - https://www.simple-talk.com/sql/t-sql-programming/sql-server-apply-basics/
		SQL Server CROSS APPLY and OUTER APPLY - http://www.mssqltips.com/sqlservertip/1958/sql-server-cross-apply-and-outer-apply/
		The power of T-SQL's APPLY operator - http://sqlblog.com/blogs/rob_farley/archive/2011/04/13/the-power-of-t-sql-s-apply-operator.aspx
		sys.dm_exec_query_stats (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms189741.aspx 
		sys.dm_exec_sql_text (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms181929.aspx 
		sys.dm_exec_plan_attributes (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms189472.aspx 

*/
--
-- code block begin
--------------------------------------------------------------------------
use [chamomile];

go

if schema_id(N'apply_demo') is null
  execute (N'create schema apply_demo');

go

if object_id(N'[apply_demo].[test_01]'
             , N'U') is not null
  drop table [apply_demo].[test_01];

go

create table [apply_demo].[test_01]
  (
     [id]         [int] identity(1, 1)
     , [value_01] nvarchar(25)
     , [value_02] [datetime]
     , [value_03] [decimal](5, 2)
  );

go

insert into [apply_demo].[test_01]
            ([value_01],
             [value_02],
             [value_03])
values      (N'jan',
             N'2013-01-01',
             1.11),
            (N'feb',
             N'2013-02-01',
             2.22),
            (N'mar',
             N'2013-03-01',
             3.33),
            (N'apr',
             N'2013-04-01',
             4.44);

go

if object_id(N'[apply_demo].[test_02]'
             , N'U') is not null
  drop table [apply_demo].[test_02];

go

create table [apply_demo].[test_02]
  (
     [id]         [int] identity(1, 1)
     , [value_02] [datetime]
     , [value_03] [decimal](5, 2)
  );

insert into [apply_demo].[test_02]
            ([value_02],
             [value_03])
values      (N'2013-01-01',
             10),
            (N'2013-01-01',
             15),
            (N'2013-02-01',
             20),
            (N'2013-02-01',
             25);

go

if object_id(N'[apply_demo].[calculate_offset]'
             , N'TF') is not null
  drop function [apply_demo].[calculate_offset];

go

-- 
-- Creates one record for each match 
create function [apply_demo].[calculate_offset](@value_02   [datetime]
                                                , @value_03 [decimal](5, 2))
returns @table table (
  [value_02] [datetime],
  [value_03] [decimal](5, 2))
as
  begin
      with [offset_list]
           as (select [value_02]
                      , [value_03]
               from   [apply_demo].[test_02]
               where  [value_02] = @value_02)
      insert into @table
                  ([value_02],
                   [value_03])
      select dateadd(day
                     , [value_03]
                     , @value_02)
             , [value_03]
      from   [offset_list]

      return;
  end;

go

--------------------------------------------------------------------------
-- code block end
--
-- code block begin
--------------------------------------------------------------------------
-- CROSS APPLY 
-- CROSS APPLY is like an inner join, returning only those records that match both the inner/right recordset 
--  (the table valued function) and the outer/left recordset (the outer table). 
select [test_01].[value_01]
       , [test_01].[value_02]
       , [test_01].[value_03]
       , [calculated_value].*
from   [apply_demo].[test_01] as [test_01]
       cross apply [apply_demo].[calculate_offset]([test_01].[value_02]
                                                   , [test_01].[value_03]) as [calculated_value];

--------------------------------------------------------------------------
-- code block end
--
-- code block begin
--------------------------------------------------------------------------
-- 
-- OUTER APPLY 
-- OUTER APPLY is like a LEFT JOIN, returning all records from the left recordset (the outer table), 
--  even where they do not match a record in the right recordset (the table valued function). 
select [test_01].[value_01]
       , [test_01].[value_02]
       , [test_01].[value_03]
       , [calculated_value].*
from   [apply_demo].[test_01] as [test_01]
       outer apply [apply_demo].[calculate_offset]([test_01].[value_02]
                                                   , [test_01].[value_03]) as [calculated_value];

--------------------------------------------------------------------------
-- code block end
--
-- code block begin
--------------------------------------------------------------------------
-- 
-- EXAMPLE:  
--  sys.dm_exec_sql_text is a table valued function that returns the text of the SQL batch that is identified by  
--    the specified sql_handle. 
--  sys.dm_exec_plan_attributes returns one row per plan attribute for the plan specified by the plan handle. You  
--    can use this table-valued function to get details about a particular plan, such as the cache key values or 
--    the number of current simultaneous executions of the plan.  
select [dm_exec_query_stats].*
       , [dm_exec_sql_text].*
       , [dm_exec_plan_attributes].*
from   sys.[dm_exec_query_stats] as [dm_exec_query_stats]
       cross apply sys.[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) as [dm_exec_sql_text]
       outer apply sys.[dm_exec_plan_attributes]([dm_exec_query_stats].plan_handle) as [dm_exec_plan_attributes];
--------------------------------------------------------------------------
-- code block end
--
