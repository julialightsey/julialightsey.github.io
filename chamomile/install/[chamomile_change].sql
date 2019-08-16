use [master];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		 drop and install the [chamomile] database.
*/
if db_id(N'chamomile_change') is not null
  drop database [chamomile_change];

if db_id(N'chamomile_change') is null
  create database chamomile_change;

go

alter authorization on database::[chamomile_change] to [sa];

go

alter database [chamomile_change]

set allow_snapshot_isolation on

go

alter database [chamomile_change]

set read_committed_snapshot on;

go

alter database [chamomile_change]

set enable_broker;

go

use [chamomile_change];

go

if schema_id(N'repository_secure') is null
  execute(N'create schema repository_secure');

go

if object_id(N'[repository_secure].[change]'
             , N'U') is not null
  drop table [repository_secure].[change];

go

create table [repository_secure].[change]
  (
     [id]          [uniqueidentifier] not null
     , [change]    [xml] not null
     , [timestamp] [datetime]
  );

go

alter table [repository_secure].[change]
  add constraint [repository_secure.change.timestamp.default] default (current_timestamp) for [timestamp];

go

if not exists (select *
               from   dbo.sysobjects
               where  id = object_id(N'[repository_secure].[repository_secure.change.id.default]')
                      and type = 'D')
  alter table [repository_secure].[change]
    add constraint [repository_secure.change.id.default] default (newsequentialid()) for [id];

go 
