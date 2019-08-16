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
		SQL Server 2005 caches temporary objects. When table-valued functions, table variables, or local temporary tables are used in a  
		stored procedure, function, or trigger, the frequent drop and create of these temporary objects can be time consuming. This can  
		cause contentions on tempdb system catalog tables and allocation pages. In SQL Server 2005, these are cached. That means that  
		dropping and creating temporary objects is very fast. When SQL Server drops a temporary object, it does not remove the catalog  
		entry for the object. If a temporary object is smaller than 8 MB, then one data page and one IAM page are also cached so that  
		there is no need to allocate them when re-creating the objects. If a temporary object is larger than 8 MB, defer drop is used.  
		When tempdb is low on space, SQL Server frees up the cached temporary objects. You can drop the associated stored procedure(s)  
		or free the procedure cache to get rid of these temporary tables.  
  
		A local temporary table created within a stored procedure or trigger can have the same name as a temporary table that was created  
		before the stored procedure or trigger is called. However, if a query references a temporary table and two temporary tables with  
		the same name exist at that time, it is not defined which table the query is resolved against. Nested stored procedures can also  
		create temporary tables with the same name as a temporary table that was created by the stored procedure that called it. However,  
		for modifications to resolve to the table that was created in the nested procedure, the table must have the same structure, with  
		the same column names, as the table created in the calling procedure. This is shown in the following example. 

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
		An interesting find about Temp tables in SQL Server - http://blogs.msdn.com/b/sqlserverfaq/archive/2012/03/15/an-interesting-find-about-temp-tables-in-sql-server.aspx 
		Working with tempdb in SQL Server 2005 - http://technet.microsoft.com/en-us/library/cc966545.aspx  
		CREATE TABLE (SQL Server) - http://msdn.microsoft.com/en-us/library/ms174979.aspx 
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
-- FIRST TEST 
-- Generic method of demonstrating the error 
-- Run this first 
if object_id('tempdb..#temp1'
             , N'U') is not null
  drop table #temp1;

select '1'  as a
       , '2'as b
into   #temp1;

select a
       , b
from   #temp1;

-- 
-- Then run this - Invalid column name 'c'. 
if object_id('tempdb..#temp1'
             , N'U') is not null
  drop table #temp1;

select '3'                  as a
       , '4'                as b
       , 'The Troublemaker' as c
into   #temp1;

select a
       , b
       , c
from   #temp1;

-- 
-- SECOND TEST 
-- Actual method used that demonstrates error 
-- Run this first 
if object_id('tempdb..#temp2'
             , N'U') is not null
  drop table #temp2;

create table #temp2
  (
     a   int
     , b int
  );

select a
       , b
from   #temp2;

-- 
-- Then run this - Invalid column name 'c'. 
declare @csql nvarchar(max) = N'ALTER TABLE #temp2 ADD c INT';

execute sp_executesql
  @csql;

select a
       , b
       , c
from   #temp2

-- 
-- THIRD TEST 
-- This also fails 
if object_id('tempdb..#temp3'
             , N'U') is not null
  drop table #temp3;

create table #temp3
  (
     a   int
     , b int
  );

select *
from   #temp3;

-- 
-- Then run this 
alter table #temp3
  add c int;

select a
       , b
       , c
from   #temp3;

-- 
-- THE FIX 
-- Run this first 
if object_id('tempdb..##donor'
             , N'U') is not null
  drop table ##donor;

create table ##donor
  (
     a   int
     , b int
  );

-- 
-- Then run this 
select donor.a
       , donor.b
       , identity(int
                  , 1
                  , 1) as c
into   #fix
from   #donor as [donor];

select a
       , b
       , c
from   #fix;

-- This does NOT have to be in the proc. I put it here for running as a script 
if object_id('tempdb..#fix'
             , N'U') is not null
  drop table #fix;

-- 
-- TEST FIX IN A PROCEDURE 
-- This works as planned and is repeatable 
use [dba_backup];

go

if schema_id(N'kate_test') is null
  execute (N'create schema kate_test');

go

if object_id(N'[kate_test].[pr_TestFix]'
             , N'P') is not null
  drop procedure [kate_test].[pr_testfix];

go

create procedure [kate_test].[pr_testfix]
as
  begin
      declare @ident_seed int = 1000;

      if object_id(N''
                   , N'U') is not null
        select object_id(N''
                         , N'U') as [this shouldn't be here!]

      -- Note that this is a violation of commonly accepted best practices (the use of * rather  
      --  than explicitly declaring columns, but I have included it here as that is how the procedure 
      --  to be fixed is written. 
      select top(0) *
                    , identity(int
                               , 1
                               , 1) as c
      into   #fix
      from   ##donor as [donor];

      dbcc checkident (#fix, reseed, @ident_seed) with no_infomsgs;

      insert into #fix
                  (a,
                   b)
      values      (1,
                   1);

      insert into #fix
                  (a,
                   b)
      values      (2,
                   2);

      select a
             , b
             , c
      from   #fix;
  end

go

declare @i int = 0;

while @i < 5
  begin
      execute [dba_backup].[kate_test].[pr_testfix];

      set @i = @i + 1;
  end 
