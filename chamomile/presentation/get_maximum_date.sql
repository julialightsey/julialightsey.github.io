/* 
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
  --------------------------------------------- 

  -- 
  --  description 
  --------------------------------------------- 
  Using GROUP BY to get the maximum date for a record
  
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
*/
if object_id(N'tempdb..##flower_order'
             , N'U') is not null
  drop table ##flower_order;

go

create table ##flower_order
  (
     [id]       [int] identity(1, 1) not null
          constraint [flower.order.id.primary_key_clustered] primary key clustered ([id])
          , [date]   [date] not null
          , [flower] [sysname]
          , [color]  [sysname],
     constraint [flower.order.date.flower.unique] unique([date], [flower])
  );

go

insert into ##flower_order
            ([date],
             [flower],
             [color])
values      (N'20140101',
             N'tulip',
             N'red'),
            (N'20150101',
             N'rose',
             N'orange'),
            (N'20160606',
             N'tulip',
             N'white'),
            (N'20120101',
             N'tulip',
             N'green'),
            (N'20110101',
             N'rose',
             N'blue'),
            (N'20160101',
             N'rose',
             N'violet');

go

--
-- this gets just the max date for each flower
-------------------------------------------------  
select [flower]
       , max([date]) as [date]
from   ##flower_order
group  by [flower];

--
-- this gets the max date for each flower and joins back to the table
--	to get the color as well
-------------------------------------------------  
with [find_maximum_date_by_flower]
     as (select [flower]      as [flower]
                , max([date]) as [date]
         from   ##flower_order
         group  by [flower])
select [flower_order].[id]                      as [id]
       , [find_maximum_date_by_flower].[flower] as [flower]
       , [flower_order].[color]                 as [color]
       , [find_maximum_date_by_flower].[date]   as [maximum_date]
from   [find_maximum_date_by_flower] as [find_maximum_date_by_flower]
       join ##flower_order as [flower_order]
         on [flower_order].[date] = [find_maximum_date_by_flower].[date]
            and [flower_order].[flower] = [find_maximum_date_by_flower].[flower]; 
