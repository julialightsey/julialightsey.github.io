/*
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html)
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		"You can use the PIVOT and UNPIVOT relational operators to change a table-valued expression into another table. PIVOT  
		rotates a table-valued expression by turning the unique values from one column in the expression into multiple columns  
		in the output, and performs aggregations where they are required on any remaining column values that are wanted in the  
		final output. UNPIVOT performs the opposite operation to PIVOT by rotating columns of a table-valued expression into  
		column values." 

		SELECT , 
		[first pivoted column] AS , 
		[second pivoted column] AS , 
		... 
		[last pivoted column] AS  
		FROM 
		()  
		AS  
		PIVOT ( 
		() 
		FOR  
		[]  
		IN ( [first pivoted column],  
		[second pivoted column], 
		...   
		[last pivoted column]) 
		) AS  
		; 
	
	--
	-- references
	----------------------------------------------------------------------
		Using PIVOT and UNPIVOT - http://msdn.microsoft.com/en-us/library/ms177410(v=sql.105).aspx
		dynamic sql for non-fixed fields - https://stackoverflow.com/questions/47698749/tsql-transpose-rows-to-columns-grouping-by-a-column
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'pivot_unpivot') is null
  execute (N'create schema pivot_unpivot');

go

-- code block end
-- PIVOT 
-- 
select [foreign_key_constraint]
       , [default_constraint]
       , [sql_scalar_function]
       , [sql_stored_procedure]
from   (select [type_desc]
        from   [sys].[objects]) as [source_table]
       pivot (count([type_desc])
             for [type_desc] in ([foreign_key_constraint],
                                 [default_constraint],
                                 [sql_scalar_function],
                                 [sql_stored_procedure])) as [pivot_table];

-- 
-- 
select [dbo]
       , [sys]
from   (select object_schema_name([object_id]) as [sch]
        from   [sys].[objects]) as [source_table]
       pivot (count ([sch])
             for [sch] in ([dbo],
                           [sys])) as [pivot_table];

-- 
-- 
declare @datasource as table
  (
     [cdatasource] [varchar](250)
  );

insert into @datasource
            ([cdatasource])
values      ('gettington'),
            ('fingerhut');

declare @datasourcelist varchar(1000);

select @datasourcelist = coalesce(@datasourcelist + ', ', '') + ''''
                         + [cdatasource] + ''''
from   @datasource;

select @datasourcelist;

--************************************************************************************************************************** 
--************************************************************************************************************************** 
--  UNPIVOT 
-- 
if object_id(N'tempdb..##animals'
             , N'U') is not null
  drop table ##animals;

go

create table ##animals
  (
     family     nvarchar(50)
     , species1 nvarchar(50)
     , species2 nvarchar(50)
     , species3 nvarchar(50)
     , species4 nvarchar(50)
     , species5 nvarchar(50)
  );

go

insert into ##animals
            (family,
             species1,
             species2,
             species3,
             species4,
             species5)
values      (N'bird',
             N'cardinal',
             N'parakeet',
             N'finch',
             N'crow',
             N'hawk'),
            (N'cat',
             N'siamese',
             N'burmese',
             N'persian',
             N'maine coon',
             N'manx'),
            (N'dog',
             N'pekinese',
             N'german shepherd',
             N'collie',
             N'chihuahua',
             N'bull dog');

go

select family
       , breed
from   (select family
               , species1
               , species2
               , species3
               , species4
               , species5
        from   ##animals) as [source]
       unpivot (breed
               for breeds in (species1,
                              species2,
                              species3,
                              species4,
                              species5)) as [unpivot]

--************************************************************************************************************************** 
--  Get the edit history of a record 
-- 
if object_id(N'tempdb..##colors'
             , N'U') is not null
  drop table ##colors;

go

create table ##colors
  (
     color      nvarchar(50)
     , created  datetime
     , modified datetime
  );

go

insert into ##colors
            (color,
             created,
             modified)
values      (N'red',
             N'2013-01-01',
             null),
            (N'green',
             N'2013-02-02',
             N'2013-02-01'),
            (N'blue',
             N'2013-03-03',
             N'2013-03-04');

-- 
-- Get the edit history of a record 
select color
       , edit_history
from   ##colors
       unpivot (edit_history
               for pivot_date in (created,
                                  modified)) as unpivot_table
where  color = N'blue'
order  by color
          , edit_history;

-- 
-- Select the last edited date for any item between the two columns 
select max(last_edit)
from   ##colors
       unpivot (last_edit
               for pivot_date in (created,
                                  modified)) as unpivot_table;

--**************************************************************************************************************************   
-- Using VALUES to select each record with the maximum of the two dates 
-- 
select color
       , (select max(v)
          from   (values (created),
                         (modified)) as value(v)) as [maxdate]
from   ##colors; 
