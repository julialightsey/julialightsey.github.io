/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		SQL Server Exam 70-461 - Work with data (27%)...Implement aggregate queries... New analytic functions 
		SQL Server 2012 supports the following analytic functions. Analytic functions compute an aggregate value  
		  based on a group of rows. However, unlike aggregate functions, they can return multiple rows for each  
		  group. You can use analytic functions to compute moving averages, running totals, percentages or  
		  top-N results within a group.  

		  CUME_DIST 
		  Calculates the cumulative distribution of a value in a group of values in SQL Server 2012. That is,  
			CUME_DIST computes the relative position of a specified value in a group of values. For a row r,  
			assuming ascending ordering, the CUME_DIST of r is the number of rows with values lower than or  
			equal to the value of r, divided by the number of rows evaluated in the partition or query result  
			set. CUME_DIST is similar to the PERCENT_RANK function. 
		  CUME_DIST() =  

		  CUME_DIST() 
			OVER ( [ partition_by_clause ] order_by_clause )  

		  PERCENT_RANK 
		  Calculates the relative rank of a row within a group of rows in SQL Server 2012. Use PERCENT_RANK  
			to evaluate the relative standing of a value within a query result set or partition. PERCENT_RANK  
			is similar to the CUME_DIST function. this represents the percentage of values less than the  
			current value in the group, excluding the highest value. Percent_Rank() for the highest value  
			in a group will always be 1.  this gives the percentage of values less than or equal to the  
			current value in the group. This is called the cumulative distribution.  
		  PERCENT_RANK() = (RANK() – 1) / (Total no of Rows – 1) 

		  PERCENT_RANK() 
			OVER ( [ partition_by_clause ] order_by_clause ) 

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
		Analytic Functions (Transact-SQL) - 
			http://msdn.microsoft.com/en-us/library/hh213234.aspx
		SQL SERVER – 2012 – Summary of All the Analytic Functions - 
			http://blog.sqlauthority.com/2011/11/23/sql-server-2012-summary-of-all-the-analytic-functions-msdn-and-sqlauthority/
		Introduction to LEAD and LAG – Analytic Functions Introduced in SQL Server 2012 - 
			http://blog.sqlauthority.com/2011/11/15/sql-server-introduction-to-lead-and-lag-analytic-functions-introduced-in-sql-server-2012/
		Introduction to CUME_DIST – Analytic Functions Introduced in SQL Server 2012 - 
			http://blog.sqlauthority.com/2011/11/08/sql-server-introduction-to-cume_dist-analytic-functions-introduced-in-sql-server-2012/
		Introduction to PERCENTILE_DISC() – Analytic Functions Introduced in SQL Server 2012 - 
			http://blog.sqlauthority.com/2011/11/22/sql-server-introduction-to-percentile_disc-analytic-functions-introduced-in-sql-server-2012/
		SQL SERVER – 2012 – Summary of All the Analytic Functions – MSDN and SQLAuthority - 
			http://www.codeproject.com/Articles/290251/SQL-SERVER-Summary-of-All-the-Analytic-Functi
		Percent_Rank and Cume_Dist functions in SQL Server 2012: 
			http://www.mssqltips.com/sqlservertip/2644/[percent_rank]-and-[cumulative_distribution]-functions-in-sql-server-2012/ 
		OVER Clause (Transact-SQL): 
			http://technet.microsoft.com/en-us/library/ms189461.aspx
*/
--
-- code block begin
--------------------------------------------------------------------------
use [chamomile];

go

if object_id(N'tempdb..##analytic_functions_01'
             , N'U') is not null
  drop table ##analytic_functions_01;

go

create table ##analytic_functions_01 (
  [id]       [int] identity(1, 1)
  , [number] [int]
  , [name]   [nvarchar](25)
  );

go

insert into ##analytic_functions_01
            ([number]
             , [name])
values      (1
             , N'one'),
            (2
             , N'two'),
            (3
             , N'three'),
            (4
             , N'four'),
            (5
             , N'five'),
            (6
             , N'six'),
            (7
             , N'seven'),
            (8
             , N'eight'),
            (9
             , N'nine'),
            (10
             , N'ten');

insert into ##analytic_functions_01
            ([number]
             , [name])
values      (3
             , N'three'),
            (3
             , N'three'),
            (3
             , N'three'),
            (3
             , N'three'),
            (7
             , N'seven'),
            (7
             , N'seven'),
            (7
             , N'seven');

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
--
-- compare cume_dist() and percent_rank()
--------------------------------------------------------------------------
select [number]
       , [name]
       , cast(cume_dist()
                over (
                  order by [number])as decimal (5, 2)) as [cumulative_distribution]
       , cast(percent_rank()
                over (
                  order by [number])as decimal (5, 2)) as [percent_rank]
from   ##analytic_functions_01;

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
-- 
-- Using cume_dist() and percent_rank()to identify worst performing queries 
--------------------------------------------------------------------------
select [text]
       , [total_elapsed_time]
       , cast(cume_dist()
                over (
                  order by [total_elapsed_time])as decimal (5, 2)) as [cumulative_distribution]
       , cast(percent_rank()
                over (
                  order by [total_elapsed_time])as decimal (5, 2)) as [percent_rank]
       , *
from   [sys].[dm_exec_query_stats]
       cross apply [sys].[dm_exec_sql_text](sql_handle)
order  by [cumulative_distribution] desc;

--
-- code block end
--------------------------------------------------------------------------
/* 
  FIRST_VALUE 
  Returns the first value in an ordered set of values in SQL Server 2012. 

  FIRST_VALUE ( [scalar_expression ] )  
    OVER ( [ partition_by_clause ] order_by_clause [ rows_range_clause ] )  

  LAST_VALUE 
  Returns the last value in an ordered set of values in SQL Server 2012. 

  LAST_VALUE ( [scalar_expression )  
    OVER ( [ partition_by_clause ] order_by_clause rows_range_clause ) 

  OVER() 
  OVER (  
       [  ] 
       [  ]  
       [  ] 
      ) 
  ROWS | RANGE - Further limits the rows within the partition by specifying start and end points within the  
    partition. This is done by specifying a range of rows with respect to the current row either by  
    logical association or physical association. Physical association is achieved by using the ROWS clause.  
  UNBOUNDED PRECEDING - Specifies that the window starts at the first row of the partition. UNBOUNDED PRECEDING  
    can only be specified as window starting point.  
  UNBOUNDED FOLLOWING - Specifies that the window ends at the last row of the partition. UNBOUNDED FOLLOWING  
    can only be specified as a window end point.  
*/
--
-- code block begin
--------------------------------------------------------------------------
if object_id(N'tempdb..##history_table'
             , N'U') is not null
  drop table ##history_table;

go

create table ##history_table (
  [id]        [int] identity(1, 1)
  , [color]   [nvarchar](250)
  , [object]  [nvarchar](250)
  , [created] [date]
  );

go

declare @jan   [date] = N'2013-01-01'
        , @feb [date] = N'2013-02-01'
        , @mar [date] = N'2013-03-01'
        , @apr [date] = N'2013-04-01'
        , @may [date] = N'2013-05-01';

insert into ##history_table
            ([color]
             , [object]
             , [created])
values      (N'purple'
             , N'dogs'
             , @jan),
            (N'purple'
             , N'kittens'
             , @feb),
            (N'purple'
             , N'bunnies'
             , @mar),
            (N'purple'
             , N'chicks'
             , @apr),
            (N'yellow'
             , N'stars'
             , @jan),
            (N'yellow'
             , N'moons'
             , @feb),
            (N'yellow'
             , N'clovers'
             , @mar),
            (N'green'
             , N'chair'
             , @feb),
            (N'green'
             , N'sofa'
             , @mar),
            (N'green'
             , N'desk'
             , @may);

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
-- 
--  Displays each record along with the most recent value in the partition 
--------------------------------------------------------------------------
with [get_most_recent_records]
     as (select [id],
                [color],
                [object],
                [created],
                first_value([id])
                  over (
                    partition by [color]
                    order by [color], [created] asc) as [first_value],
                first_value([created])
                  over (
                    partition by [color]
                    order by [created] asc) as [first_date],
                last_value([id])
                  over (
                    partition by [color]
                    order by [color], [created] asc range between unbounded preceding and unbounded following) as [last_value],
                last_value([created])
                  over (
                    partition by [color]
                    order by [created] asc range between unbounded preceding and unbounded following) as [last_date]
         from   ##history_table),
[get_color] as(
  select [color], [first_value],[last_value]
  from   [get_most_recent_records]
  group by [color], [first_value],[last_value])
select [get_color].[color],
       [first_history_table].[object] as [firstvalue],
       [last_history_table].[object]  as [lastvalue]
from   [get_color]
join   ##history_table as [last_history_table]
  on [last_history_table].[id] = [get_color].[last_value]
join   ##history_table as [first_history_table]
  on [first_history_table].[id] = [get_color].[first_value]
order by [get_color].[color];
go 


--
-- code block end
--------------------------------------------------------------------------
--************************************************************************************************************************** 
--************************************************************************************************************************** 
/* 
  LAG  
  Accesses data from a previous row in the same result set without the use of a self-join in SQL Server 2012. LAG  
    provides access to a row at a given physical offset that comes before the current row. Use this analytic  
    function in a SELECT statement to compare values in the current row with values in a previous row.  

  LAG (scalar_expression [,offset] [,default]) 
    OVER ( [ partition_by_clause ] order_by_clause ) 

  LEAD 
  Accesses data from a subsequent row in the same result set without the use of a self-join in SQL Server 2012.  
    LEAD provides access to a row at a given physical offset that follows the current row. Use this analytic  
    function in a SELECT statement to compare values in the current row with values in a following row.  

  LEAD ( scalar_expression [ ,offset ] , [ default ] )  
      OVER ( [ partition_by_clause ] order_by_clause ) 

*/
--
-- code block begin
--------------------------------------------------------------------------
if object_id(N'tempdb..##lag_table'
             , N'U') is not null
  drop table ##lag_table;

go

create table ##lag_table (
  [id]         [int] identity(1, 1)
  , [model]    [sysname]
  , [residual] [decimal] (9, 2)
  , [created]  [date]
  );

go

insert into ##lag_table
            ([model]
             , [residual]
             , [created])
values      (N'modelA'
             , 10
             , N'2013-01-01'),
            (N'modelA'
             , 11
             , N'2013-01-01'),
            (N'modelA'
             , 12
             , N'2013-02-01'),
            (N'modelA'
             , 13
             , N'2013-02-01'),
            (N'modelA'
             , 14
             , N'2013-03-01'),
            (N'modelB'
             , 20
             , N'2013-03-01'),
            (N'modelB'
             , 21
             , N'2013-04-01'),
            (N'modelB'
             , 22
             , N'2013-04-01'),
            (N'modelB'
             , 23
             , N'2013-05-01'),
            (N'modelB'
             , 24
             , N'2013-05-01');

go

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
-- 
--  Select a prior value based on a stated interval or count 
select [id]
       , [model]
       , [residual]
       , lag([residual]
             , 1.0)
           over (
             partition by [model]
             order by [id])              as [prior]
       , lag([residual]
             , 1.0)
           over (
             order by [id]) - [residual] as [prior_delta]
       , lead([residual]
              , 1.0)
           over (
             partition by [model]
             order by [id])              as [next]
       , lead([residual]
              , 1.0)
           over (
             order by [id]) - [residual] as [next_delta]
from   ##lag_table;

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
-- 
--  Select a prior value based on a calculated [date] interval 
select [id]
       , [model]
       , [residual]
       , [created]
       , ( datediff(month
                    , [created]
                    , cast(getdate() as [date])) ) as [date_difference]
       , lag([residual]
             , datediff(month
                        , [created]
                        , cast(getdate() as [date])))
           over (
             partition by [model]
             order by [id])                        as [prior]
from   ##lag_table;

--
-- code block end
--------------------------------------------------------------------------
--************************************************************************************************************************** 
--************************************************************************************************************************** 
/* 
  Percentile: "In statistics, a percentile (or a centile) is the value of a variable below which a certain percent  
    of observations fall. For example, the 20th percentile is the value (or score) below which 20 percent of  
    the observations may be found. The term percentile and the related term percentile rank are often used in  
    the reporting of scores from norm-referenced tests. For example, if a score is in the 86th percentile,  
    it is higher than 85% of the other scores. 

  PERCENTILE_CONT() - Percentile Continuous 
  Calculates a percentile based on a continuous distribution of the column value in SQL Server 2012. The result is  
    interpolated and might not be equal to any of the specific values in the column.  
  PERCENTILE_CONT interpolates the appropriate value, whether or not it exists in the data set 

  PERCENTILE_CONT ( PERCENTILE )  
    WITHIN GROUP ( ORDER BY order_by_expression [ ASC | DESC ] ) 
    OVER ( [  ] ) 

  PERCENTILE_DISC() - Percentile Distinct 
  Computes a specific percentile for sorted values in an entire rowset or within distinct partitions of a rowset in  
    SQL Server 2012. For a given percentile value P, PERCENTILE_DISC sorts the values of the expression in the  
    ORDER BY clause and returns the value with the smallest CUME_DIST value (with respect to the same sort  
    specification) that is greater than or equal to P. For example, PERCENTILE_DISC (0.5) will compute the  
    50th percentile (that is, the median) of an expression. PERCENTILE_DISC calculates the percentile based  
    on a discrete distribution of the column values; the result is equal to a specific value in the column.  
  PERCENTILE_DISC always returns an actual value from the set. 

  PERCENTILE_DISC ( PERCENTILE ) WITHIN GROUP ( ORDER BY order_by_expression [ ASC | DESC ] ) 
      OVER ( [  ] ) 
*/
--
-- code block begin
--------------------------------------------------------------------------
if object_id(N'tempdb..##percentile_continuous'
             , N'U') is not null
  drop table ##percentile_continuous;

go

create table ##percentile_continuous (
  [id]           [int] identity(1, 1)
  , [group]      [nvarchar](25)
  , [individual] [nvarchar](25)
  , [rate]       decimal(9, 2)
  );

go

insert into ##percentile_continuous
            ([group]
             , [individual]
             , [rate])
values      (N'GroupA'
             , 'Fred'
             , 1022.00),
            (N'GroupA'
             , 'Lisa'
             , 1954.00),
            (N'GroupA'
             , 'Victory'
             , 5954.00),
            (N'GroupA'
             , 'Tom'
             , 9125.00),
            (N'GroupB'
             , 'Ed'
             , 2725.00),
            (N'GroupB'
             , 'June'
             , 4315.00),
            (N'GroupB'
             , 'Sally'
             , 7684.00),
            (N'GroupC'
             , 'Jeff'
             , 3587.00),
            (N'GroupC'
             , 'Kim'
             , 6987.00),
            (N'GroupC'
             , 'Joe'
             , 8758.00);

--
-- code block end
--------------------------------------------------------------------------
--
-- code block begin
--------------------------------------------------------------------------
-- 
-- Note that PERCENTILE_CONT calculates a value, where PERCENTILE_DISC returns an existing value. 
select [group],
    percentile_cont (0.2) within group (order by [rate])
      over (partition by [group]) as [percentile_cont (0.2) - calculated value],
    percentile_cont (0.5) within group (order by [rate])
      over (partition by [group]) as [percentile_cont (0.5) - calculated value],
    percentile_cont (0.7) within group (order by [rate])
      over (partition by [group]) as [percentile_cont (0.7) - calculated value],
    percentile_disc (0.2) within group (order by [rate])
      over (partition by [group]) as [percentile_disc (0.5) - existing value],
    percentile_disc (0.5) within group (order by [rate])
      over (partition by [group]) as [percentile_disc (0.5) - existing value],
    percentile_disc (0.7) within group (order by [rate])
      over (partition by [group]) as [percentile_disc (0.7) - existing value]
from   ##percentile_continuous;
			
--
-- code block end
--------------------------------------------------------------------------
