/*
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------

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
		SQL ISNULL(), NVL(), IFNULL() and COALESCE() Functions - http://www.w3schools.com/sql/sql_isnull.asp
		COALESCE vs. ISNULL - http://sqlmag.com/t-sql/coalesce-vs-isnull
		COALESCE (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms190349.aspx
		Differences between ISNULL and COALESCE - http://blogs.msdn.com/b/sqltips/archive/2008/06/26/differences-between-isnull-and-coalesce.aspx
		Deciding between COALESCE and ISNULL in SQL Server - http://www.mssqltips.com/sqlservertip/2689/deciding-between-coalesce-and-isnull-in-sql-server/
		ISNULL() and COALESCE(): http://archive.msdn.microsoft.com/SQLExamples/Wiki/View.aspx?title=ISNULL_COALESCE 
		ISNULL (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms184325.aspx 
		COALESCE (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms190349.aspx 
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'coalesce_demonstration') is null
  execute (N'create schema coalesce_demonstration');

go

if object_id(N'tempdb..##case_isnull_coalesce_table'
             , N'U') is not null
  drop table ##case_isnull_coalesce_table;

go

create table ##case_isnull_coalesce_table
  (
     [id]       [int] identity(1, 1) not null primary key clustered
     , [flower] [sysname] null
     , [color]  [sysname] null
  );

insert into ##case_isnull_coalesce_table
            ([flower],
             [color])
values      (null,
             null),
            (null,
             char(0)),
            (N'rose',
             N'red'),
            (N'lily',
             N'yellow');

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
-- demonstrate difference between replace, isnull, case, and coalesce
-------------------------------------------------
select [id]
       , [flower]
       , [color]
       , replace([flower]
                 , char(0)
                 , N'')  as [replace_id]
       , replace([color]
                 , char(0)
                 , N'')  as [replace_value]
       , isnull(cast([flower] as [sysname])
                , N'')   as [isnull]
       , isnull([color]
                , '')    as [isnull_value]
       , coalesce(cast([flower] as [sysname])
                  , N'') as [coalesce]
       , coalesce([color]
                  , '')  as [coalesce_value]
       , case
           when [flower] is null then N''
           else [flower]
         end             as [case_value]
from   ##case_isnull_coalesce_table
order  by [id];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
/*
	ISNULL  Is not ANSI Standard 
	ISNULL() accepts two parameters. The first is evaluated, and if the value is null, the 
		second value is returned  (regardless of whether or not it is null).  
	ISNULL constrains the result of a comparison of parameters to the datatype of the first value.  
	It is generally accepted that ISNULL is slightly quicker than COALESCE, but not sufficiently 
		to outweigh it's inherent limitations. 
*/
select isnull(null
              , 1.45);

select isnull(null
              , null);

declare @c1 [sysname]=null,
        @c2 [sysname]=null;

select isnull(@c1
              , @c2);

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
/* 
	COALESCE Is part of the ANSI Standard 
	Coalesce returns the first non-null expression in a list of expressions. The list 
		can contain two or more items,  and each item can be of a different data type.  
*/
--
-------------------------------------------------
select coalesce(null
                , 1.45
                , null
                , 3);

--
--  "At least one of the arguments to COALESCE must be an expression that is not the 
--		NULL constant." 
--	Note that this fails before it hits the catch block!
-------------------------------------------------
begin try
    select coalesce(null
                    , null
                    , null);
end try

begin catch
    select error_message() + N'here';
end catch;

--	But this is just fine!
-------------------------------------------------
declare @c1 [sysname]=null,
        @c2 [sysname]=null,
        @c3 [sysname]=null;

select coalesce(@c1
                , @c2
                , @c3);

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--  COALESCE is equivalent to (implemented as) a CASE statement 
-------------------------------------------------
declare @v1 [int],
        @v2 [int],
        @v3 [int],
        @v4 [int] = 4;

select coalesce(@v1
                , @v2
                , @v3
                , @v4);

--  Is equivalent to: 
-------------------------------------------------
select case
         when ( @v1 is not null ) then @v1
         when ( @v2 is not null ) then @v2
         when ( @v3 is not null ) then @v3
         else @v4
       end;

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @field1 [nvarchar](3),
        @field2 [sysname] = 'Some Long String';

-- 
-- Returns 'Som' (ISNULL constrains the result of a comparison of parameters to 
--	the datatype of the first value. ) 
-------------------------------------------------
select isnull(@field1
              , @field2);

--Returns 'Some Long String' 
-------------------------------------------------
select coalesce(@field1
                , @field2);

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--  In other situations, COALESCE will produce unexpected results. COALESCE by nature promotes it's arguments to the  
--    highest datatype among compatable arguments (arguments which are not explicitly case, and which aren't  
--    compatable, will of course throw an error). When using COALESCE on an integer and a datetime, in that  
--    order, COALESCE will cast the integer as a datetime.  
--  The following will not return 5, it will return 1900-01-06 00:00:00.000 (5 as a datetime). 
select coalesce(5
                , current_timestamp);

--
--  This returns "Error converting data type nvarchar to numeric".
------------------------------------------------- 
select coalesce(N'five'
                , 0.11);

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @decimal [decimal](5, 2) = 3.45,
        @integer [int] = 4;

--
--  Note that the integer is promoted to a [decimal] 
-------------------------------------------------
select coalesce(@integer
                , null
                , @decimal);

--
--  But the [decimal] is not demoted to an [int] 
-------------------------------------------------
select coalesce(@decimal
                , null
                , @integer);

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- demonstrate performance differences
-- todo - this no longer works... performance improvements in 2014??
-------------------------------------------------
if object_id (N'tempdb..##timer'
              , N'U') is not null
  drop table ##timer;

create table ##timer
  (
     [method] [sysname]
     , [time] [int]
  );

go

declare @run_count         [int] = 0,
        @big_loop_count    [int] = 0,
        @run_count_maximum [int] = 100,
        @timestamp         [datetime2](7),
        @result            [bigint];

set @big_loop_count = 0;

while @big_loop_count < @run_count_maximum
  begin
      set @timestamp = current_timestamp;
      set @run_count=0;

      while @run_count < @run_count_maximum
        begin
            select isnull([principal_id]
                          , [object_id])
            from   [sys].[objects];

            set @run_count = @run_count + 1
        end

      insert into ##timer
                  ([method],
                   [time])
      values      (N'isnull',
                   datediff(nanosecond
                            , @timestamp
                            , current_timestamp));

      set @timestamp = current_timestamp;
      set @run_count=0;

      while @run_count < @run_count_maximum
        begin
            select coalesce([principal_id]
                            , [object_id])
            from   [sys].[objects];

            set @run_count = @run_count + 1
        end

      insert into ##timer
                  ([method],
                   [time])
      values      (N'coalesce',
                   datediff(nanosecond
                            , @timestamp
                            , current_timestamp));

      set @big_loop_count = @big_loop_count + 1;
  end;

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--  ISNULL 162 
--  COALESCE 293 
--  There is a performance difference
select [method]
       , avg([time]) / 1000 as [microseconds]
from   ##timer
group  by [method];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- using coalesce to build a list - useful for building procedures, etc.
-------------------------------------------------
if object_id(N'[coalesce_demonstration].[flower]'
             , N'U') is not null
  drop table [coalesce_demonstration].[flower];

go

create table [coalesce_demonstration].[flower]
  (
     [id]            [int] identity(1, 1) not null primary key clustered
     , [flower]      [sysname]
     , [color]       [nvarchar](30)
     , [petal_count] [int]
  );

declare @list [nvarchar](max);

select @list = coalesce(@list + N', ', N'') + N'['
               + [columns].[name] + N'] [' + [types].[name]
               + N'] ' +
               --
               case when [types].[name]=N'nvarchar' then N'(' + cast ([columns].[max_length]/2 as [sysname]) + N')'
               --
               else N''
               --
               end
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
       join [sys].[types] as [types]
         on [types].[user_type_id] = [columns].[user_type_id]
where  object_schema_name([tables].[object_id]) = N'coalesce_demonstration'
       and [tables].[name] = N'flower';

select @list;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- order as placed in the table
-------------------------------------------------
declare @list [nvarchar](max);

select @list = coalesce(@list + N', ', N'')
               + N'[letters_interface].[' + [name]
               + N'] as N''@' + [name] + N''''
from   [sys].[columns] as [columns]
where  object_schema_name([object_id]) = N'coalesce_demonstration'
       and object_name([object_id]) = N'flower'
order  by [column_id];

select @list;

go

--
-- order alphabetically
-------------------------------------------------
declare @list [nvarchar](max);

select @list = coalesce(@list + N', ', N'')
               + N'[letters_interface].[' + [name]
               + N'] as N''@' + [name] + N''''
from   [sys].[columns] as [columns]
where  object_schema_name([object_id]) = N'coalesce_demonstration'
       and object_name([object_id]) = N'flower'
order  by [name];

select @list;

go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
