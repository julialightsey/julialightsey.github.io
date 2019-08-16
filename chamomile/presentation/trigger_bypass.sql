/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
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
*/
--
-- code block begin
-------------------------------------------------
use [chamomile_oltp];

go

--
-------------------------------------------------
if schema_id(N'trigger_presentation') is null
  execute (N'create schema trigger_presentation');

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if object_id(N'[trigger_presentation].[data]'
             , N'U') is not null
  drop table [trigger_presentation].[data];

go

create table [trigger_presentation].[data]
  (
     [id]          [int] identity(1, 1)
     , [flower]    [sysname]
     , [timestamp] [datetime] default current_timestamp
  );

go

--
if object_id(N'[trigger_presentation].[audit]'
             , N'U') is not null
  drop table [trigger_presentation].[audit];

go

create table [trigger_presentation].[audit]
  (
     [action]      [sysname]
     , [id]        [int]
     , [flower]    [sysname]
     , [timestamp] [datetime]
  );

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if exists (select *
           from   sys.triggers
           where  object_schema_name([object_id]) = N'trigger_presentation'
                  and [name] = 'trigger_presentation.data.audit')
  drop trigger [trigger_presentation.data.audit];

go

create trigger [trigger_presentation].[trigger_presentation.data.audit]
on [trigger_presentation].[data]
for insert, update
as
  begin
      set nocount on;
      set xact_abort on;

      insert into [trigger_presentation].[audit]
                  ([action],
                   [id],
                   [flower],
                   [timestamp])
      select N'inserted'
             , [id]
             , [flower]
             , [timestamp]
      from   inserted;

      insert into [trigger_presentation].[audit]
                  ([action],
                   [id],
                   [flower],
                   [timestamp])
      select N'deleted'
             , [id]
             , [flower]
             , [timestamp]
      from   deleted;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
insert into [trigger_presentation].[data]
            ([flower])
values      (N'rose');

insert into [trigger_presentation].[data]
            ([flower])
values      (N'chamomile');

update [trigger_presentation].[data]
set    [flower] = N'peach'
where  [flower] = N'chamomile';

--
select *
from   [trigger_presentation].[data];

select *
from   [trigger_presentation].[audit];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- disable the trigger then insert a flower that will not be inserted into the audit table
-------------------------------------------------
set transaction isolation level serializable;

begin transaction trigger_test;

disable trigger [trigger_presentation].[trigger_presentation.data.audit] on [trigger_presentation].[data];

insert into [trigger_presentation].[data]
            ([flower])
values      (N'lily');

select *
from   [trigger_presentation].[data];

select *
from   [trigger_presentation].[audit];

enable trigger [trigger_presentation].[trigger_presentation.data.audit] on [trigger_presentation].[data];

commit transaction trigger_test;

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- reenable the trigger then insert a flower that will be inserted into the audit table
-------------------------------------------------
insert into [trigger_presentation].[data]
            ([flower])
values      (N'marigold');

select *
from   [trigger_presentation].[data];

select *
from   [trigger_presentation].[audit];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- disable the trigger then insert a flower that will not be inserted into the audit table
-------------------------------------------------
set transaction isolation level serializable;

begin transaction trigger_test;

disable trigger [trigger_presentation].[trigger_presentation.data.audit] on [trigger_presentation].[data];

insert into [trigger_presentation].[data]
            ([flower])
values      (N'tulip');

select *
from   [trigger_presentation].[data];

select *
from   [trigger_presentation].[audit];

--
-- stop here, run the code below in a separate window, then finish this code block
--
enable trigger [trigger_presentation].[trigger_presentation.data.audit] on [trigger_presentation].[data];

commit transaction trigger_test;

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- run this in a separate window
-------------------------------------------------
insert into [trigger_presentation].[data]
            ([flower])
values      (N'orchid');

select *
from   [trigger_presentation].[data];

select *
from   [trigger_presentation].[audit];
-------------------------------------------------
-- code block end
--
