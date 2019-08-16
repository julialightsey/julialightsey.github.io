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
		Ranking functions return a ranking value for each row in a partition. Depending on the function that is used,  
		some rows might receive the same value as other rows. Ranking functions are nondeterministic. 

		ROW_NUMBER() - Returns the sequential number of a row within a partition of a result set, starting at 1 for  
		the first row in each partition. 

		RANK() - Returns the rank of each row within the partition of a result set. The rank of a row is one plus  
		the number of ranks that come before the row in question. If two or more rows tie for a rank, each tied  
		rows receives the same rank. For example, if the two top salespeople have the same SalesYTD value, they  
		are both ranked one. The salesperson with the next highest SalesYTD is ranked number three, because  
		there are two rows that are ranked higher. Therefore, the RANK function does not always return consecutive  
		integers. The sort order that is used for the whole query determines the order in which the rows appear  
		in a result set. 

		DENSE_RANK() - Returns the rank of rows within the partition of a result set, without any gaps in the ranking.  
		The rank of a row is one plus the number of distinct ranks that come before the row in question. If two or  
		more rows tie for a rank in the same partition, each tied rows receives the same rank. For example, if the  
		two top salespeople have the same SalesYTD value, they are both ranked one. The salesperson with the next  
		highest SalesYTD is ranked number two. This is one more than the number of distinct rows that come before  
		this row. Therefore, the numbers returned by the DENSE_RANK function do not have gaps and always have  
		consecutive ranks. The sort order used for the whole query determines the order in which the rows appear  
		in a result. This implies that a row ranked number one does not have to be the first row in the partition. 

		NTILE() - Distributes the rows in an ordered partition into a specified number of groups. The groups are  
		numbered, starting at one. For each row, NTILE returns the number of the group to which the row belongs. 
		If the number of rows in a partition is not divisible by integer_expression, this will cause groups of  
		two sizes that differ by one member. Larger groups come before smaller groups in the order specified by  
		the OVER clause. For example if the total number of rows is 53 and the number of groups is five, the first  
		three groups will have 11 rows and the two remaining groups will have 10 rows each. If on the other hand  
		the total number of rows is divisible by the number of groups, the rows will be evenly distributed among  
		the groups. For example, if the total number of rows is 50, and there are five groups, each bucket will  
		contain 10 rows. 

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
	----------------------------------------------------------------------
	Ranking Functions (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms189798.aspx
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'presentation') is null
  execute (N'create schema presentation');

go

-- code block end
if object_id(N'tempdb..##flower', N'U') is not null
  drop table ##flower;

go

create table ##flower (
  [id]       [int] identity(1, 1)
  , [flower] [sysname]
  , [color] [sysname]
  , [count] [int]
  );

go

insert into ##flower
            ([flower],[color])
values      (1,N'one'),
            (1,N'one'),
            (1,N'one'),
            (2,N'two'),
            (3,N'three'),
            (4,N'four'),
            (4,N'four'),
            (5,N'five');

go

select [id]
       , [flower]
       , [color]
       , rank()
           over (
             order by [flower]) as N'Rank'
       , dense_rank()
           over (
             order by [flower]) as N'DenseRank'
       , row_number()
           over (
             partition by [flower]
             order by [flower]) as N'RowNumber'
       , ntile(3)
           over (
             order by [flower]) as N'NTile'
from   ##flower;

go

--************************************************************************************************************************** 
--************************************************************************************************************************** 
if object_id(N'tempdb..##flower', N'U') is not null
  drop table ##flower;

go

create table ##flower (
  [id]          int identity(1, 1)
  , [flower]    nvarchar(50)
  , [salesdate] datetime
  , [sales]     money
  );

go

insert into ##flower
            ([flower],[salesdate],[sales])
values      (N'tulip',N'2005-01-01',12589),
            (N'tulip',N'2006-02-01',85456),
            (N'tulip',N'2007-03-01',32598),
            (N'tulip',N'2008-04-01',54946),
            (N'tulip',N'2009-05-01',38746),
            (N'lily',N'2005-01-01',18000),
            (N'lily',N'2006-02-01',65231),
            (N'lily',N'2007-03-01',87325),
            (N'lily',N'2008-04-01',35687),
            (N'petunia',N'2005-01-01',25000),
            (N'petunia',N'2006-02-01',25765),
            (N'petunia',N'2007-03-01',33256),
            (N'petunia',N'2008-04-01',64125);

select [id]
       , [flower]
       , [salesdate]
       , [sales]
       , row_number()
           over (
             order by [flower], [sales]) as [row_number]
       , row_number()
           over (
             partition by month(salesdate)
             order by month(salesdate))  as [row_number by month]
       , rank()
           over (
             order by [flower])          as [rank]
       , dense_rank()
           over (
             order by [flower])          as [dense_rank]
       , ntile(3)
           over (
             order by [salesdate])       as [ntile]
from   ##flower
order  by [flower]
          , [sales]

--************************************************************************************************************************** 
--************************************************************************************************************************** 
--  ROW_NUMBER 
--  Remove duplicates from a table 
-- 
declare @duplicate table (
   [flower] nvarchar(50)
  )

insert into @duplicate
            ( [flower])
values      (N'white'),
            (N'white'),
            (N'white'),
            (N'white'),
            (N'red'),
            (N'red'),
            (N'red'),
            (N'blue'),
            (N'blue'),
            (N'blue'),
            (N'blue'),
            (N'blue'),
            (N'blue');

-- 
-- Note that the records are deleted directly from the CTE rather than from the table! 
with cte_deleteduplicates( [flower], rnumber)
     as (select [flower]
                , row_number()
                    over (
                      partition by  [flower]
                      order by [flower]) as rnumber
         from   @duplicate)
delete from cte_deleteduplicates
where  rnumber > 1;

select  [flower]
from   @duplicate;

--************************************************************************************************************************** 
--************************************************************************************************************************** 
--  ROW_NUMBER 
--  Using row_number to get the most recent records from a record set. 
-- 
if object_id (N'tempdb..##flower', N'U') is not null
  drop table ##flower;

go

create table ##flower (
  [id]       int identity(1, 1)
  , [flower] int
  , [color] datetime
  );

go

insert into ##flower
            ([flower],[color])
values      (1,N'2013-01-21'),
            (1,N'2013-01-12'),
            (1,N'2013-01-07'),
            (2,N'2013-01-13'),
            (2,N'2013-01-19'),
            (2,N'2013-01-23'),
            (2,N'2013-01-24'),
            (5,N'2013-01-16'),
            (5,N'2013-01-22'),
            (5,N'2013-01-16'),
            (5,N'2013-01-17');

go

with [get_latest]
     as (select [id]
                , [flower]
                , cast([color] as date)      as [color]
                , row_number()
                    over (
                      partition by [flower]
                      order by [color] desc) as [row_number]
         from   ##flower)
select [id]
       , [flower]
       , [color]
from   [get_latest]
where  [row_number] = 1; 
