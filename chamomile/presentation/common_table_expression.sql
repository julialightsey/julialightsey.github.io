/*
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		COMMON TABLE EXPRESSION
			[ WITH <common_table_expression> [ ,...n ] ]

			<common_table_expression>::=
				expression_name [ ( column_name [ ,...n ] ) ]
				AS
				( CTE_query_definition )

			The following clauses cannot be used in the CTE_query_definition: 
				ORDER BY (except when a TOP clause is specified)
				INTO 
				OPTION clause with query hints
				FOR XML
				FOR BROWSE
			A common table expression (CTE) can be thought of as a temporary result set that is defined within the execution scope 
			of a single SELECT, INSERT, UPDATE, DELETE, or CREATE VIEW statement. A CTE is similar to a derived table in that 
			it is not stored as an object and lasts only for the duration of the query. Unlike a derived table, a CTE can be 
			self-referencing and can be referenced multiple times in the same query.
			Using a CTE offers the advantages of improved readability and ease in maintenance of complex queries. The query 
			can be divided into separate, simple, logical building blocks. These simple blocks can then be used to build 
			more complex, interim CTEs until the final result set is generated. 

			CTEs can be defined in user-defined routines, such as functions, stored procedures, triggers, or views.

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
		Recursive Queries Using Common Table Expressions: http://msdn.microsoft.com/en-us/library/ms186243.aspx
		WITH common_table_expression (Transact-SQL): http://msdn.microsoft.com/en-us/library/ms175972.aspx

*/
--
-- code block begin
--------------------------------------------
use [chamomile];

go

if schema_id(N'flower') is null
  execute('create schema flower');

go

-------------------------------------------------
if object_id(N'[flower].[order]'
             , N'U') is not null
  drop table [flower].[order];

go

create table [flower].[order]
  (
     [id]       int identity(1, 1) not null constraint [flower.order.id.clustered_primary_key] primary key clustered
     , [flower] nvarchar(128)
     , [color]  nvarchar(128)
     , [count]  int
  );

insert into [flower].[order]
            ([flower],
             [color],
             [count])
values      (N'rose',
             N'red',
             5),
            (N'rose',
             N'red',
             3),
            (N'rose',
             N'red',
             2),
            (N'rose',
             N'red',
             1),
            (N'rose',
             N'red',
             9),
            (N'marigold',
             N'yellow',
             2),
            (N'marigold',
             N'yellow',
             9),
            (N'marigold',
             N'yellow',
             4),
            (N'chamomile',
             N'amber',
             9),
            (N'chamomile',
             N'amber',
             4),
            (N'lily',
             N'white',
             12);

--
select [id]
       , [flower]
       , [color]
       , [count]
from   [flower].[order];

--------------------------------------------
-- code block end
--
--
-- code block begin
--------------------------------------------
--
-- Select only those records from a table where the count is greater than the average count for that color
-------------------------------------------------
select [color]                         as [color]
       , avg(cast([count] as [float])) as [average]
from   [flower].[order]
group  by [color];

--
with [grouper]
     as (select [color]                         as [color]
                , avg(cast([count] as [float])) as [average]
         from   [flower].[order]
         group  by [color])
--
select [flower].[flower]
       , [flower].[color]
       , [flower].[count]
from   [flower].[order] as [flower]
       join [grouper] as [grouper]
         on [grouper].[color] = [flower].[color]
where  [flower].[count] > [grouper].[average]
group  by [flower]
          , [flower].[color]
          , [flower].[count];

--------------------------------------------
-- code block end
--
--
-- code block begin
--------------------------------------------
--
-- Using an alias list to give the columns in the cte appropriate labels
--	note that the alias list overrides an alias declared in the cte body
--------------------------------------------
with [alias_list] ([purple_spotted_kitty_cats], [green_and_yellow_striped_puppy_dogs])
     as (select [color]                               as [you_will_not_even_see_this]
                , avg(cast([count] as decimal(5, 2))) as [cannot_use_this]
         from   [flower].[order]
         group  by [color])
--
select [flower].[flower]
       , [alias_list].[purple_spotted_kitty_cats]
       , [flower].[count]
from   [flower].[order] as [flower]
       join [alias_list] as [alias_list]
         on [alias_list].[purple_spotted_kitty_cats] = [flower].[color]
where  [flower].[count] > [alias_list].[green_and_yellow_striped_puppy_dogs]
group  by [flower]
          , [alias_list].[purple_spotted_kitty_cats]
          , [flower].[count];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  multiple cte's
--    note that you can access any cte in the cte chain from the select, and
--    you can access any cte from within a cte chain if the refereced cte is
--    above it, aka, already declared. For example; you cannot access the 
--    second cte from the first!
-------------------------------------------------
with [first_cte]
     as (select [flower]
                , [color]
                , count(*) as [more_than_3]
         from   [flower].[order]
         group  by [flower]
                   , [color]
         having count(*) > 3),
     [second_cte]
     as (select [flower]
                , [color]
                , count(*) as [yellowish]
         from   [flower].[order]
         where  [color] in ( N'amber', N'yellow' )
         group  by [flower]
                   , [color])
--
select [flower]
       , [color]
       , [more_than_3] as [count]
from   [first_cte]
union
select [flower]
       , [color]
       , [yellowish] as [count]
from   [second_cte]
order  by [flower]
          , [color];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Remove duplicates from a table
--   Note that the records are ONLY managed by the unique definition. Variations outside that are ignored.
--   Note that the records are deleted directly from the CTE rather than from the table!
-------------------------------------------------
--
-- many duplicates
-------------------------------------------------
select [flower]
       , [color]
from   [flower].[order];

--
-------------------------------------------------
with [duplicate_finder]([name], [color], [sequence])
     as (select [flower]
                , [color]
                , row_number()
                    over (
                      partition by [flower], [color]
                      order by [flower] desc) as [sequence]
         from   [flower].[order])
delete from [duplicate_finder]
where  [sequence] > 1;

--
-- no duplicates
-------------------------------------------------
select [flower]
       , [color]
from   [flower].[order];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- using a cte to build a merge source table
--
-- persistent records
-- note that the merge is directly into the cte!
-------------------------------------------------
truncate table [flower].[order];

go

alter table [flower].[order]
  add [persistent] [sysname] default( N'false'), [fulfilled] [datetime];

go

-------------------------------------------------
insert into [flower].[order]
            ([flower],
             [color],
             [count])
values      (N'rose',
             N'red',
             5),
            (N'rose',
             N'red',
             3),
            (N'rose',
             N'red',
             2),
            (N'rose',
             N'red',
             1),
            (N'rose',
             N'red',
             9),
            (N'marigold',
             N'yellow',
             2),
            (N'marigold',
             N'yellow',
             9),
            (N'marigold',
             N'yellow',
             4),
            (N'chamomile',
             N'amber',
             9),
            (N'chamomile',
             N'amber',
             4),
            (N'lily',
             N'white',
             12);

insert into [flower].[order]
            ([flower],
             [color],
             [count],
             [persistent])
values      (N'rose',
             N'red',
             12,
             N'true'),
            (N'chamomile',
             N'amber',
             36,
             N'true');

--
select [id]
       , [flower]
       , [color]
       , [count]
       , [fulfilled]
       , [persistent]
from   [flower].[order];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- use a cte to build a merge target table as a subordinate data set
--	note that:
--		the merge is directly into the cte!
--		you would typically select a subset, such as filtering
--			by where [fulfilled] is null. This has not been done here to 
--			reinforce that the action is accomplished by the "when matched"
--			clause of the merge.
--		this is a useful construct in a scenario where you wish to update
--			the records in a table, but keep the prior record as a "history"
-------------------------------------------------
with [non_persistent]
     as (select [id]
                , [fulfilled]
                , [persistent]
         from   [flower].[order]
         where  [persistent] = N'false')
merge into [non_persistent] as target
using (select [id]
              , cast(current_timestamp as [date])
              , [persistent]
       from   [flower].[order]) as source ([id], [fulfilled], [persistent])
on target.[id] = source.[id]
when matched then
  update set target.[fulfilled] = source.[fulfilled];

--
select *
from   [flower].[order];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--  cte recursion
/*
		"Guidelines for Defining and Using Recursive Common Table Expressions
			The following guidelines apply to defining a recursive common table expression:
			The recursive CTE definition must contain at least two CTE query definitions, an anchor member and a recursive 
			member. Multiple anchor members and recursive members can be defined; however, all anchor member query definitions 
			must be put before the first recursive member definition. All CTE query definitions are anchor members unless they 
			reference the CTE itself.
			Anchor members must be combined by one of these set operators: UNION ALL, UNION, INTERSECT, or EXCEPT. UNION ALL 
			is the only set operator allowed between the last anchor member and first recursive member, and when combining 
			multiple recursive members."

		"An incorrectly composed recursive CTE may cause an infinite loop. For example, if the recursive member 
			query definition returns the same values for both the parent and child columns, an infinite loop is created. 
			To prevent an infinite loop, you can limit the number of recursion levels allowed for a particular statement 
			by using the MAXRECURSION hint and a value between 0 and 32,767 in the OPTION clause of the INSERT, UPDATE, DELETE, 
			or SELECT statement. This lets you control the execution of the statement until you resolve the code problem that 
			is creating the loop. The server-wide default is 100. When 0 is specified, no limit is applied. Only one MAXRECURSION 
			value can be specified per statement."
*/
-------------------------------------------------
--
-- reference: http://stackoverflow.com/questions/2647/how-do-i-split-a-string-so-i-can-access-item-x/25391776#25391776
-------------------------------------------------
declare @input     [nvarchar](max) =N'split _ this _ string _ on _ the _ space _ underscore _ space',
        @separator [sysname] =N' _ ';
--
-- use datalength so you can handle any character, such as spaces
declare @separator_length [int]= datalength(@separator) / 2;

--
with [splitter]
     as (
        --
        -- this is the anchor cte
        -- cast to [bigint] to handle strings longer than 4000 characters
        -- note that you only have to do this in the first cte, the others are implicitly cast to the same type
        -----------------------------------------
        select cast(@separator_length as [bigint]) as [index]
               , cast(1 as [bigint])               as [next_split_value]
               , charindex(@separator
                           , @input)               as [split_location]
         union all
         --
         -- this is the recursive cte
         ----------------------------------------
         select [index] + 1                                         as [index]
                , [split_location] + @separator_length              as [next_split_value]
                , charindex(@separator
                            , @input
                            , [split_location] + @separator_length) as [split_location]
         from   [splitter]
         where  [split_location] > 0)
--
select [index] - @separator_length as [index]
       , substring(@input
                   , [next_split_value]
                   , case
                       when [split_location] > 0 then [split_location] - [next_split_value]
                       else len(@input)
                     end)          as [node]
from   [splitter];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- using a cte to build up a complex source for a merge statement
-- using a default (template) record
-------------------------------------------------
truncate table [flower].[order];

go

--
insert into [flower].[order]
            ([flower],
             [color],
             [count])
values      (N'rose',
             N'red',
             12),
            (N'marigold',
             N'yellow',
             24),
            (N'chamomile',
             N'amber',
             36),
            (N'lily',
             N'white',
             3);

--
select [flower]
       , [color]
       , [count]
       , [fulfilled]
from   [flower].[order];

--
-------------------------------------------------
declare @flower [sysname]=N'marigold',
        @color  [sysname]=N'purple',
        @count  [int] = 5;

--
with [build_fulfilled]
     as (select null                  as [id]
                , [flower]            as [flower]
                , coalesce(@color
                           , [color]) as [color]
                , coalesce(@count
                           , [count]) as [count]
                , current_timestamp   as [fulfilled]
         from   [flower].[order]
         where  [flower] = @flower)
--
merge into [flower].[order] as target
using [build_fulfilled] as source
on source.[id] = target.[id]
--
when not matched then
  insert ([flower],
          [color],
          [count],
          [fulfilled])
  values ([flower],
          [color],
          [count],
          [fulfilled]);

go

--
select [id]
       , [flower]
       , [color]
       , [count]
       , [fulfilled]
from   [flower].[order];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- using a cte to build up a complex source for a merge statement
-- leaving a "history" record in the table
-- note that the original [id], the "order id" remains unchanged for the active record
--  while the history record gets a new id
-------------------------------------------------
truncate table [flower].[order];

go

alter table [flower].[order]
  add [scheduled] [datetime], [delete] [bit] default (0), [modified] [datetime];

go

alter table [flower].[order]
  add constraint [flower.order.flower.color.delete.modified.unique] unique ([flower], [color], [delete], [modified]);

--
insert into [flower].[order]
            ([flower],
             [color],
             [count],
             [scheduled])
values      (N'rose',
             N'red',
             12,
             current_timestamp),
            (N'marigold',
             N'yellow',
             24,
             current_timestamp),
            (N'chamomile',
             N'amber',
             36,
             current_timestamp),
            (N'lily',
             N'white',
             3,
             current_timestamp);

--
select [flower]
       , [color]
       , [count]
       , [scheduled]
       , [delete]
from   [flower].[order];

--
-------------------------------------------------
declare @flower    [sysname]=N'marigold',
        @color     [sysname]=N'yellow',
        @count     [int] = 444,
        @scheduled [datetime] = dateadd(day
                  , 1
                  , current_timestamp);

with [build_history]
     as (select null          as [id]
                , [flower]    as [flower]
                , [color]     as [color]
                , [count]     as [count]
                , [scheduled] as [scheduled]
                , 1           as [delete]
         from   [flower].[order]
         where  [flower] = @flower
                and [color] = @color
                and [delete] = 0),
     [build_current]
     as (select [id]                      as [id]
                , [flower]                as [flower]
                , [color]                 as [color]
                , coalesce(@count
                           , [count])     as [count]
                , coalesce(@scheduled
                           , [scheduled]) as [scheduled]
                , [delete]                as [delete]
         from   [flower].[order]
         where  [flower] = @flower
                and [color] = @color
                and [delete] = 0),
     [build_source]
     as (select *
         from   [build_history]
         union
         select *
         from   [build_current])
merge into [flower].[order] as target
using [build_source] as source
on source.[id] = target.[id]
when matched then
  update set target.[count] = source.[count],
             target.[scheduled] = source.[scheduled],
             target.[delete] = source.[delete],
             target.[modified] = current_timestamp
when not matched by target then
  insert ([flower],
          [color],
          [count],
          [scheduled],
          [delete],
          [modified])
  values ([flower],
          [color],
          [count],
          [scheduled],
          [delete],
          current_timestamp);

go

--
select [id]
       , [flower]
       , [color]
       , [count]
       , [scheduled]
       , [delete]
from   [flower].[order];

go
-------------------------------------------------
-- code block end
--
