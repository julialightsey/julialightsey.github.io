/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		[first_law] - Well written software can be re-factored, poorly written software can only 
			be tolerated. Well written software in a properly designed architecture with thorough 
			tests can be re-factored for performance, its utility expanded and extended, and will 
			continue to be used over many generations of implementations continuously improving 
			its return on investment.
 
		The quality, not the longevity, of one's life is what is important. Martin Luther King, Jr.
 
		Poorly written software lacking in design and tests will never be re-factored, expanded 
			or extended and will continue to demand increasing levels of support while being 
			limited to its original vision or less, continuously costing additional time and money 
			for ever decreasing utility.
 
		It is the little, pathetic attempts at Quality that kill. Robert M. Pirsig, Zen and the 
			Art of Motorcycle Maintenance.

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
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'presentation') is null
  execute (N'create schema presentation');

go

/*  
  ugly code 
   
  results in a massively complex query for a simple operation. 
  42 lines required to select the data 
  business logic is completely obscured by data scrubbing operation 
*/
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
if object_id(N'[presentation].[test_without_constraints]') is not null
  drop table [presentation].[test_without_constraints];

create table [presentation].[test_without_constraints]
  (
     [id]       [int] identity(1, 1) not null,
          constraint [presentation.test_without_constraints.id.primary_key.clustered] primary key clustered ([id])
     , [amount] [money] null
     , [status] [sysname] not null
     , [due]    [datetime] null
     , [phone]  [nvarchar](128) null
     , [added]  [datetime] not null
  );

alter table [presentation].[test_without_constraints]
  add constraint [presentation.test_without_constraints.added.default] default (current_timestamp) for [added];

go

insert into [presentation].[test_without_constraints]
            ([amount],
             [status],
             [due],
             [phone])
values      (null,
             N'on_time',
             null,
             null),
            (12,
             N'on_time',
             N'20140101',
             N'2155551212'),
            (30,
             N'late',
             N'20140103',
             N'2155551212'),
            (563,
             N'on_time',
             N'20150201',
             N'(215) 555-1212'),
            (22,
             N'coerced',
             N'20150101',
             N'215.555.1212'),
            (375,
             N'planned',
             N'20150201',
             N'(215) 555-1212');

go

-- 
-------------------------------------------------------------------------- 
select [id]                                     as [id]
       , case
           when [amount] < 25 then 0
           else [amount]
         end                                    as [amount]
       , case
           when lower([status]) not in ( N'on_time', N'late', N'coerced' ) then
             case
               when isnull([due]
                           , dateadd(dd
                                     , 30
                                     , current_timestamp)) > current_timestamp then N'late'
               else N'on_time'
             end
           else [status]
         end                                    as [status]
       , isnull([due]
                , dateadd(dd
                          , 30
                          , current_timestamp)) as [due]
       , replace(replace(replace(replace(replace([phone]
                                                 , N'.'
                                                 , N'')
                                         , N')'
                                         , N'')
                                 , N'('
                                 , N'')
                         , N' '
                         , N'')
                 , N'-'
                 , N'')                         as [phone]
       , [added]                                as [added]
from   [chamomile].[presentation].[test_without_constraints]
where  [due] > cast(N'20130101' as [datetime])
       and [amount] > 25;

go

/*  
  clean - preferred method 
  1. fix the table - add proper constraints to restrict the data. 
  2. build in calculated fields for routine operations. 
   
  results in the simplest possible query 
  9 lines required to select the data 
  business logic is clearly exposed, although table constraints are not considered 'business logic' in this scenario. 
*/
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
if object_id(N'[presentation].[test_with_constraints]') is not null
  drop table [presentation].[test_with_constraints];

create table [presentation].[test_with_constraints]
  (
     [id]       [int] identity(1, 1) not null,
          constraint [presentation.test_with_constraints.id.primary_key.clustered] primary key clustered ([id])
          , [amount] [money] null
          , [amount_floor] as case
                 when [amount] < 25 then 0
                 else [amount]
               end
          , [status] [sysname] not null,
          constraint [presentation.test_with_constraints.type.check] check (lower([status]) in (N'on_time', N'late', N'coerced'))
     , [status_test] as case
            when isnull([due]
                        , dateadd(dd
                                  , 30
                                  , current_timestamp)) > current_timestamp then N'on_time'
            else N'late'
          end
     , [due]    [datetime] null
     , [phone]  [nvarchar](128) null constraint [presentation.test_with_constraints.phone.check] check (isnumeric(isnull([phone], 0))=1)
     , [added]  [datetime] not null
  );

alter table [presentation].[test_with_constraints]
  add constraint [presentation.test_with_constraints.added.default] default (current_timestamp) for [added];

go

insert into [presentation].[test_with_constraints]
            ([amount],
             [status],
             [due],
             [phone])
values      (null,
             N'on_time',
             null,
             null),
            (12,
             N'on_time',
             N'20140101',
             N'2155551212'),
            (30,
             N'late',
             N'20130201',
             N'2155551212'),
            (563,
             N'late',
             N'20150201',
             N'2155551212'),
            (22,
             N'coerced',
             N'20150101',
             N'2155551212'),
            (375,
             N'late',
             N'20150201',
             N'2155551212');

go

-- 
-------------------------------------------------------------------------- 
declare @due [datetime] = N'20130101';

select [id]
       , [amount]
       , [status_test] as [status]
       , [due]
       , [phone]
       , [added]
from   [presentation].[test_with_constraints]
where  [due] > @due
       and [amount_floor] > 0;

go

/* 
  clean - second best method 
  1. use a cte to scrub the data. 
  2. use utility functions to perform repetitive and complex operations. 
   
  results in a simpler query, with data scrubbing clearly separated from business logic. 
   
  37 lines required to select the data 
  9 lines required to state the business logic 
  28 lines required to scrub the data 
*/
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
declare @due [datetime] = N'20130101';

with [data_scrubber]
     as (select [id]
                , [amount]
                , case
                    when lower([status]) not in ( N'on_time', N'late', N'coerced' ) then
                      case
                        when isnull([due]
                                    , dateadd(dd
                                              , 30
                                              , current_timestamp)) > current_timestamp then N'late'
                        else N'on_time'
                      end
                    else [status]
                  end                                    as [status]
                , isnull([due]
                         , dateadd(dd
                                   , 30
                                   , current_timestamp)) as [due]
                , [utility].[strip]([phone]
                                    , N'0-9'
                                    , null
                                    , null)              as [phone]
                , [added]
         from   [presentation].[test_without_constraints])
select [id]
       , [amount]
       , [status]
       , [due]
       , [phone]
       , [added]
from   [data_scrubber]
where  [due] > @due
       and [amount] > 25;

go 
