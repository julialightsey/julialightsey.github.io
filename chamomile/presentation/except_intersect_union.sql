/*
	All content is copyright Katherine E. Lightsey(http://www.kelightsey.com/) 1959-2015 (aka; my life), 
		all rights reserved. All software contained herein is licensed as 
		[chamomile](http://www.chamomilesql.com/source/license.html) and as open source under the 
		GNU Affero GPL(http://www.gnu.org/licenses/agpl-3.0.html).
	This project is hosted on GitHub(https://github.com/KELightsey/ChamomileSQL). All software including 
		presentations and utilities may be downloaded from the GitHub project. Contributions are welcome.
	--
	--	description
	---------------------------------------------
	Returns distinct values by comparing the results of two queries.
	EXCEPT returns any distinct values from the left query that are not also found on the right query.
	INTERSECT returns any distinct values that are returned by both the query on the left and right 
		sides of the INTERSECT operand.
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
	EXCEPT and INTERSECT (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms188055(v=sql.110).aspx
*/
--
-- code block begin
-------------------------------------------------
if object_id(N'tempdb..##flower'
             , N'U') is not null
  drop table ##flower;

go

create table ##flower
  (
     [id]       [int] identity(1, 1) not null
     , [flower] [sysname]
     , [color]  [sysname]
  );

--
if object_id(N'tempdb..##flower_order'
             , N'U') is not null
  drop table ##flower_order;

go

create table ##flower_order
  (
     [id]         [int] identity(1, 1) not null
     , [flower]   [int]
     , [quantity] [int]
     , [delivery] [datetime]
  );

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
insert into ##flower
            ([flower],
             [color])
values      (N'rose',
             N'red'),
            (N'rose',
             N'white'),
            (N'lily',
             N'white'),
            (N'tulip',
             N'white'),
            (N'tulip',
             N'blue'),
            (N'chamomile',
             N'blue');

insert into ##flower_order
            ([flower],
             [quantity],
             [delivery])
values      (1,
             5,
             N'20160101'),
            (3,
             10,
             N'20160202'),
            (5,
             15,
             N'20160303'),
            (5,
             20,
             N'20160404');

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- show contents of tables
-------------------------------------------------
select [id]
       , [flower]
       , [color]
from   ##flower;

--
select [flower_order].[id] as [flower_order]
       , [flower].[flower] as [flower]
       , [quantity]        as [quantity]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- EXCEPT
--	find flowers for which there are no orders
-------------------------------------------------
-------------------------------------------------
select [flower]
from   ##flower
except
select [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- INTERSECT
--	find flowers for which there are orders
-------------------------------------------------
-------------------------------------------------
select [flower]
from   ##flower
intersect
select [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- contrast intersect with join to find flowers for which 
--	there are orders. Note that there are duplicates
-------------------------------------------------
select [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- contrast intersect with join to find flowers for which 
--	there are orders using DISTINCT. Note that the results
--	mimics the result using intersection.
-------------------------------------------------
select distinct [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- UNION
--	Note that UNION includes flowers for which have no orders
--	unlike INTERSECT which gives the desired result of only
--	those with orders, excluding those with no orders (nothing
--	in the right result set.
-------------------------------------------------
-------------------------------------------------
select [flower]
from   ##flower
union
select [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- UNION ALL
--	Note that UNION ALL includes flowers for which have no orders
--	unlike INTERSECT which gives the desired result of only
--	those with orders, excluding those with no orders (nothing
--	in the right result set.
--	Additionally, the UNION ALL statement returns duplicates
--	unlike UNION.
-------------------------------------------------
select [flower]
from   ##flower
union all
select [flower].[flower] as [flower]
from   ##flower_order as [flower_order]
       join ##flower as [flower]
         on [flower].[id] = [flower_order].[flower];
-------------------------------------------------
-- code block end
--
