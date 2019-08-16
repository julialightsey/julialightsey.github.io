/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		[second_law](http://www.katherinelightsey.com/#!nobaddata/c1irw) 
		There is no such thing as "bad" data. A well designed and executed program should  
		handle both expected and unexpected data professionally and gracefully, using it,  
		cleansing it, or reporting and rejecting it. The string N'abc' is neither good nor  
		bad. It may be unexpected if it is being inserted into a column defined as  
		[col1] [int]. But it is not bad. Data is just data. Similarly, tools are not  
		inherently bad. Upholstery hammers aren't bad, but a carpenter who attempts to  
		use one to drive a tenpenney nail into a wall joist will be disappointed in the  
		result. To blame the hammer for the carpenters poor judgement is both idiotic  
		and deceitful.  

		Steel can be any shape you want if you are skilled enough, and any shape but the one  
		you want if you are not. Robert M. Pirsig. 

		The objective of virtually every software program ever written is and has been to  
		manipulate data. Handling data is what a software program does! Bad data and bad  
		tools are myths invented and promoted by bad software architects and bad developers  
		who write bad programs using bad software development practices. Both are the bane  
		of the incompetent. 

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

if schema_id(N'unbreakable_code') is null
  execute (N'create schema unbreakable_code');

go

-- code block end
use [chamomile];

go

if schema_id(N'documentation') is null
  execute(N'create schema documentation');

go

-- 
-- bad design, not bad data 
-- a typical design fails when an attempt to insert "unexpected" data is made. 
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
if object_id(N'[documentation].[test_without_constraints]') is not null
  drop table [documentation].[test_without_constraints];

create table [documentation].[test_without_constraints]
  (
     [id]       [int] identity(1, 1) not null,
          constraint [documentation.test_without_constraints.id.primary_key.clustered] primary key clustered ([id])
     , [amount] [money] null
     , [status] [sysname]
     , [due]    [datetime] null
     , [phone]  [nvarchar](128) null
     , [added]  [datetime] not null
  );

alter table [documentation].[test_without_constraints]
  add constraint [documentation.test_without_constraints.added.default] default (current_timestamp) for [added];

go

begin try
    insert into [documentation].[test_without_constraints]
                ([amount],
                 [status],
                 [due],
                 [phone])
    values      (null,
                 N'on_time',
                 null,
                 null),
                (N'Randy Johnson',
                 N'on_time',
                 N'20140101',
                 N'2155551212'),
                (12,
                 N'on_time',
                 N'tomorrow',
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
end try

begin catch
    select N'this fails due to attempts to insert character strings into the [money] field and non-date strings into the [date] field.'
           , error_message() as [error_message];
end catch

go

/* 
  this method scrubs the data prior to an attempt to insert, resulting in no failure. An  
  intermediary table is used as a staging location where a common table expression can  
  extract the data, scrub it, and then insert it into the table. 
*/
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
declare @builder as table
  (
     [amount]   [nvarchar](128) null
     , [status] [nvarchar](128) null
     , [due]    [nvarchar](128) null
     , [phone]  [nvarchar](128) null
  );

insert into @builder
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
             N'tomorrow',
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

insert into @builder
            ([amount],
             [status],
             [due],
             [phone])
values      (null,
             N'on_time',
             null,
             null),
            (N'Randy Johnson',
             N'on_time',
             N'20140101',
             N'2155551212');

with [data_scrubber]
     as (select [amount]
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
                  end                       as [status]
                , [due]
                , [utility].[strip]([phone]
                                    , N'0-9'
                                    , null
                                    , null) as [phone]
         from   @builder
         where  isnumeric([amount]) = 1
                and isdate([due]) = 1)
insert into [documentation].[test_without_constraints]
            ([amount],
             [status],
             [due],
             [phone])
select [amount]
       , [status]
       , [due]
       , [phone]
from   [data_scrubber];

go

select *
from   [documentation].[test_without_constraints];

go

/*  
  table constraints prevent bad data from loading, but still cause failures. table  
  constraints are not a substitute for data scrubbing routines. 
*/
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
if object_id(N'[documentation].[test_with_constraints]') is not null
  drop table [documentation].[test_with_constraints];

create table [documentation].[test_with_constraints]
  (
     [id]       [int] identity(1, 1) not null,
          constraint [documentation.test_with_constraints.id.primary_key.clustered] primary key clustered ([id])
          , [amount] [money] null
          , [amount_floor] as case
                 when [amount] < 25 then 0
                 else [amount]
               end
          , [status] [sysname],
          constraint [documentation.test_with_constraints.type.check] check (lower([status]) in (N'on_time', N'late', N'coerced'))
     , [status_test] as case
            when isnull([due]
                        , dateadd(dd
                                  , 30
                                  , current_timestamp)) > current_timestamp then N'on_time'
            else N'late'
          end
     , [due]    [datetime] null
     , [phone]  [nvarchar](128) null constraint [documentation.test_with_constraints.phone.check] check (isnumeric(isnull([phone], 0))=1)
     , [added]  [datetime] not null
  );

alter table [documentation].[test_with_constraints]
  add constraint [documentation.test_with_constraints.added.default] default (current_timestamp) for [added];

go

begin try
    insert into [documentation].[test_with_constraints]
                ([amount],
                 [status],
                 [due],
                 [phone])
    values      (null,
                 N'on_time',
                 null,
                 null),
                (N'Randy Johnson',
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
end try

begin catch
    select N'this fails due to attempts to insert character strings into the [money] field and non-date strings into the [date] field.'
           , error_message() as [error_message];
end catch

go

/* 

*/
-- 
-- prevent duplicates using a merge 
-------------------------------------------------------------------------- 
-------------------------------------------------------------------------- 
if object_id(N'[documentation].[test_without_constraints]') is not null
  drop table [documentation].[test_without_constraints];

create table [documentation].[test_without_constraints]
  (
     [id]        [int] identity(1, 1) not null,
          constraint [documentation.test_without_constraints.id.primary_key.clustered] primary key clustered ([id])
          , [amount]  [money] null
          , [account] [bigint] not null,
          constraint [documentation.test_without_constraints.account.unique] unique ([account])
     , [status]  [sysname]
     , [due]     [datetime] null
     , [phone]   [nvarchar](128) null
     , [added]   [datetime] not null
  );

alter table [documentation].[test_without_constraints]
  add constraint [documentation.test_without_constraints.added.default] default (current_timestamp) for [added];

go

insert into [documentation].[test_without_constraints]
            ([amount],
             [account],
             [status],
             [due],
             [phone])
values      (null,
             1,
             N'on_time',
             null,
             null),
            (30,
             2,
             N'late',
             N'20130201',
             N'2155551212'),
            (563,
             3,
             N'late',
             N'20150201',
             N'2155551212'),
            (375,
             4,
             N'late',
             N'20150201',
             N'2155551212');

go

begin try
    insert into [documentation].[test_without_constraints]
                ([amount],
                 [account],
                 [status],
                 [due],
                 [phone])
    values      (30,
                 2,
                 N'late',
                 N'20130201',
                 N'2155551212'),
                (30,
                 8,
                 N'late',
                 N'20130201',
                 N'2155551212');
end try

begin catch
    select N'this fails due to attempts to insert duplicate data into the [account] field.'
           , error_message() as [error_message];
end catch

go

-- 
-- using a merge prevents inserting duplicate data, and can be used to update the data. 
-------------------------------------------------------------------------- 
declare @staging as table
  (
     [amount]    [money] null
     , [account] [bigint] not null
     , [status]  [sysname]
     , [due]     [datetime] null
     , [phone]   [nvarchar](128) null
  );

insert into @staging
            ([amount],
             [account],
             [status],
             [due],
             [phone])
values      (30,
             2,
             N'late',
             N'20130201',
             N'2155551212'),
            (30,
             8,
             N'late',
             N'20130201',
             N'2155551212');

merge into [documentation].[test_without_constraints] as target
using (select [amount]
              , [account]
              , [status]
              , [due]
              , [phone]
       from   @staging) as source
on source.[account] = target.[account]
when not matched then
  insert ([amount],
          [account],
          [status],
          [due],
          [phone])
  values ([amount],
          [account],
          [status],
          [due],
          [phone] );

go

select [id]
       , [amount]
       , [account]
       , [status]
       , [due]
       , [phone]
       , [added]
from   [documentation].[test_without_constraints];

go 
