/* 

	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
  -- 
  --  description 
  --------------------------------------------- 
	Problem
		I recently added a column to one of my core system tables referenced by a reporting view. When I run the view, the added 
		column is not appearing in my result set! What can I do?
  
  -- 
  --  notes 
  --------------------------------------------- 
    this presentation is designed to be run incrementally a code block at a time.  
    code blocks are delineated as: 

    -- 
    -- code block begin 
    ----------------------------------------- 
       
    ----------------------------------------- 
    -- code block end 
    -- 
   
  -- 
  -- references 
  --------------------------------------------- 
		dbo.sp_refreshview 
			(Transact-SQL): https://msdn.microsoft.com/en-us/library/ms187821.aspx
		Table changes not automatically reflected in a SQL Server View (Armando Prato)
			http://www.mssqltips.com/sqlservertip/1427/table-changes-not-automatically-reflected-in-a-sql-server-view/
			
			

	Solution
		When a view is created in SQL Server, metadata for the referenced table columns (column name and ordinal position) is 
		persisted in the database. Any change to the referenced base table(s) (column re-ordering, new column addition, etc) 
		will not be reflected in the view until the view is either:

		Altered with an ALTER VIEW statement
		Recreated with DROP VIEW/CREATE VIEW statements
		Refreshed using system stored procedure sp_refreshview			
	
		This occurs because the view's metadata information about the table needs to be updated; it's not maintained automatically.
		I find that this can always be avoided by not issuing "SELECT *" in your view definitions. By explicitly defining a column 
		list, you're forced to change any views that reference tables that may require a change. Another approach is to issue your 
		CREATE VIEW statements with a SCHEMABINDING option. Views defined with this option do not allow SELECT * syntax (you'll 
		receive an error if you try) and forces you to enter an explicit column list. This way, you can prevent a less experienced 
		developer from changing a view to use this syntax

		If you're curious about how your view metadata is being stored, you can take a peek at the INFORMATION_SCHEMA.COLUMNS 
		view (view column information is kept there as well as table column information).

	Next Steps
		Examine your views and consider changing SELECT * syntax to explicit column lists, if possible
		Read more about sp_refreshview in greater detail in the SQL Server 2000 and 2005 Books Online
		Read more about SCHEMABINDING option in greater detail in the SQL Server 2000 and 2005 Books Online
		Read more about INFORMATION_SCHEMA.COLUMNS view in greater detail in the SQL Server 2000 and 2005 Books Online
		
	SCHEMABINDING
		Binds the view to the schema of the underlying table or tables. When SCHEMABINDING is specified, the base table 
		or tables cannot be modified in a way that would affect the view definition. The view definition itself must 
		first be modified or dropped to remove dependencies on the table that is to be modified. When you use SCHEMABINDING, 
		the select_statement must include the two-part names (schema.object) of tables, views, or user-defined functions 
		that are referenced. All referenced objects must be in the same database.
		Views or tables that participate in a view created with the SCHEMABINDING clause cannot be dropped unless that view 
		is dropped or changed so that it no longer has schema binding. Otherwise, the Database Engine raises an error. Also, 
		executing ALTER TABLE statements on tables that participate in views that have schema binding fail when these statements 
		affect the view definition.

*/
use [chamomilesql];

go

--
-- create working schemas if not exist
-------------------------------------------------
if schema_id(N'kate_secure') is null
  execute (N'create schema kate_secure');

go

if schema_id(N'kate') is null
  execute (N'create schema kate');

go

--
-- create sample table
-------------------------------------------------
if object_id(N'kate_secure.sample_01'
             , N'U') is not null
  drop table kate_secure.sample_01;

go

create table kate_secure.sample_01
  (
     [id]          [int] identity(1, 1) not null
     , [column_01] [sysname]
     , [column_02] [sysname]
  );

go

--
-- create view and use 'select *' construct
-------------------------------------------------
if object_id(N'kate.sample_01'
             , N'V') is not null
  drop view kate.sample_01;

go

create view kate.sample_01
as
  select *
  from   kate_secure.sample_01;

go

select null as 'only two columns expected'
       , *
from   kate.sample_01;

go

alter table kate_secure.sample_01
  add [column_03] [sysname];

go

select null as 'three columns expected but only two as result!'
       , *
from   kate.sample_01;

go

select null as 'but see, the extra column did get added to the table'
       , *
from   kate_secure.sample_01;

go

execute dbo.sp_refreshview
  N'kate.sample_01';

go

select null as 'correct column list from view after using dbo.sp_refreshview'
       , *
from   kate.sample_01;

go 
