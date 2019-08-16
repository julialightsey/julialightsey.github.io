
--
-- Making a more reliable and flexible sp_MSforeachdb
-- https://www.mssqltips.com/sqlservertip/2201/making-a-more-reliable-and-flexible-spmsforeachdb/


--
-- Run same command on all SQL Server databases without cursors
-- https://www.mssqltips.com/sqlservertip/1414/run-same-command-on-all-sql-server-databases-without-cursors/


-- 
-- Iterate through SQL Server database objects without cursors
-- https://www.mssqltips.com/sqlservertip/1905/iterate-through-sql-server-database-objects-without-cursors/

--
-- Common uses for sp_MSforeachdb
-- http://reeltym.blogspot.com/2010/09/common-uses-for-spmsforeachdb.html

--
-- A more reliable and more flexible sp_MSforeachdb
-- https://sqlblog.org/2010/12/29/a-more-reliable-and-more-flexible-sp_msforeachdb


exec sp_MSforeachdb
  'use [?]; select db_name() + ''.'' + object_name([object_id]) FROM sys.tables where [name] = N''sysssislog''' 
