/* 
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
	--------------------------------------------- 

	-- 
	--  description 
	--------------------------------------------- 
	Using the VALUES clause to build ad hoc data sets.

	-- 
	--  notes 
	---------------------------------------------
	This presentation is designed to be run incrementally a code block at a time.  
	
	Code blocks are delineated as: 

	-- 
	-- code block begin 
	-------------------------------------------------
	<code block>
	-------------------------------------------------
	-- code block end 
	-- 

	-- 
	-- references 
	---------------------------------------------
*/
-- 
-- code block begin 
-------------------------------------------------
-- 
-- building a simple data set
-------------------------------------------------
with [builder]
     as (select *
         from   ( values (N'rose',
                N'red'),
                         (N'tulip',
                N'white'),
                         (N'daffodil',
                N'blue') ) as [flower_type] ([flower], [color]))
select [flower]
       , [color]
from   [builder];

-------------------------------------------------
-- code block end 
-- 
-- 
-- code block begin 
-------------------------------------------------
-- 
--	Building a data set from parameters for a merge statement.
--	This is particularly useful for a procedure that uses a merge
--		with the input parameters being merged into a table.
-------------------------------------------------
declare @flower [sysname],
        @color  [sysname];
declare @flower_order as table
  (
     [flower]  [sysname]
     , [color] [sysname]
  );

--
select @flower = N'rose'
       , @color = N'red';

--
merge into @flower_order as target
using (values(@flower,
      @color)) as source ([flower], [color])
on target.[flower] = source.[flower]
   and target.color = source.[color]
when not matched then
  insert ([flower],
          [color])
  values ([flower],
          [color]);

--
select @flower = N'daffodil'
       , @color = N'blue';

--
merge into @flower_order as target
using (values(@flower,
      @color)) as source ([flower], [color])
on target.[flower] = source.[flower]
   and target.color = source.[color]
when not matched then
  insert ([flower],
          [color])
  values ([flower],
          [color]);

--
select [flower]
       , [color]
from   @flower_order;
-------------------------------------------------
-- code block end 
-- 
