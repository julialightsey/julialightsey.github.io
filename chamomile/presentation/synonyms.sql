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
		A synonym is a database object that serves the following purposes:
		Provides an alternative name for another database object, referred to as the base object, 
			that can exist on a local or remote server.
		Provides a layer of abstraction that protects a client application from changes made to 
			the name or location of the base object.
		Four-part names for function base objects are not supported.
		A synonym cannot be the base object for another synonym, and a synonym cannot reference 
			a user-defined aggregate function.
		The binding between a synonym and its base object is by name only. All existence, type, 
			and permissions checking on the base object is deferred until run time. Therefore, the 
			base object can be modified, dropped, or dropped and replaced by another object that 
			has the same name as the original base object. For example, consider a synonym, 
			MyContacts, that references the Person.Contact table in Adventure Works. If the Contact 
			table is dropped and replaced by a view named Person.Contact, MyContacts now references 
			the Person.Contact view.
		References to synonyms are not schema-bound. Therefore, a synonym can be dropped at any time. 
			However, by dropping a synonym, you run the risk of leaving dangling references to the 
			synonym that was dropped. These references will only be found at run time.

	--
	--	notes
		-----------------------------------------
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
		CREATE SYNONYM (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms177544.aspx
		Synonyms (Database Engine) - http://msdn.microsoft.com/en-us/library/ms187552.aspx
		Introduction and Explanation to SYNONYM - http://blog.sqlauthority.com/2008/01/07/sql-server-2005-introduction-and-explanation-to-synonym-helpful-t-sql-feature-for-developer/
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'synonyms_demo') is null
  execute (N'create schema synonyms_demo');

go

-- code block end
if object_id(N'[synonyms_demo].[test_01]'
             , N'U') is not null
  drop table [synonyms_demo].[test_01];

go

create table [synonyms_demo].[test_01]
  (
     [id]      int identity(1, 1)
     , [color] [nvarchar](25)
  );

insert into [synonyms_demo].[test_01]
            ([color])
values      (N'red'),
            (N'blue');

go

if (select count(*)
    from   [sys].[synonyms]
    where  [name] = N'test_01'
           and object_schema_name(object_id) = N'dbo') > 0
  drop synonym [dbo].[test_01];

go

create synonym [dbo].[test_01] for [synonyms_demo].[test_01];

go

if object_id(N'[synonyms_demo].[get_test_01]'
             , N'FN') is not null
  drop function [synonyms_demo].[get_test_01];

go

create function [synonyms_demo].[get_test_01] ()
returns [nvarchar](25)
as
  begin
      declare @color [nvarchar](25);

      select @color = (select [color]
                       from   [synonyms_demo].[test_01]
                       where  [id] = 1);

      return @color
  end

go

select [chamomile].[synonyms_demo].[get_test_01]();

go

/* 
  !!! the code below has NOT been updated to the naming structure above! 
*/
if object_id(N'[synonyms_demo].[test_01]'
             , N'U') is not null
  drop table [synonyms_demo].[test_01];

go

use [chamomile];

go

if schema_id(N'synonyms_demo') is null
  execute (N'create schema synonyms_demo');

go

-- 
-- 
if(select count(*)
   from   [sys].servers
   where  name = N'Test02') > 0
  execute master.dbo.sp_dropserver
    @server = N'Test02';

go

exec master.dbo.sp_addlinkedserver
  @server = N'Test02',
  @srvproduct=N'Other data source',
  @provider =N'SQLNCLI',
  @datasrc =N'DALLAP84705B0GR\TEST02'

-- 
-- 
select *
from   test02.[chamomile].[synonyms_demo].[test_01];

-- 
--  It cannot be accessed across the linked server 
select *
from   test02.[test_01].dbo.sn_[test_01];

-- 
--  Even with openquery it cannot be accessed 
select *
from   openquery(test02
                 , 'SELECT * 
FROM   [test_01].dbo.sn_[test_01]');

-- 
--  Even though it is there! 
select *
from   test02.[test_01].[sys].[synonyms];

-- 
-- Functions cannot be accessed remotely either 
select test02.[test_01].[synonyms_demo].[get_test_01]();

-- 
-- Nor can tables including XML 
-- Msg 9514, Level 16, State 1, Line 3 
-- Xml data type is not supported in distributed queries. Remote object 'Test02.[test_01].[synonyms_demo].[test_01]' has xml column(s). 
select *
from   test02.[test_01].[synonyms_demo].[test_01]; 
