/*
	All content is licensed as [chamomile] (http://www.ChamomileSQL.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		Performs insert, update, or delete operations on a target table based on the results of a 
			join with a source table. For example, you can synchronize two tables by inserting, 
			updating, or deleting rows in one table based on differences found in the other table.
		Applies to: SQL Server (SQL Server 2008 through current version), Windows Azure SQL Database 
			(Initial release through current release).

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
		MERGE (Transact-SQL) - http://msdn.microsoft.com/en-us/library/bb510625.aspx
		Inserting, Updating, and Deleting Data by Using MERGE - http://technet.microsoft.com/en-us/library/bb522522(v=sql.105).aspx
		Merge (SQL) - http://en.wikipedia.org/wiki/Merge_(SQL)
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'presentation') is null
  execute (N'create schema merge_staging_into_target');

go

-- code block end
if exists (select *
           from   sys.objects
           where  object_id = object_id(N'[presentation].[merge_staging_into_target]')
                  and type in ( N'P', N'PC' ))
  drop procedure [presentation].[merge_staging_into_target]

go

set ansi_nulls on

go

set quoted_identifier on

go

create procedure [presentation].[merge_staging_into_target]
as
    select [id] as N'##target - before'
           , [animal]
           , [color]
           , [sound]
           , [created]
           , [archive]
    from   ##target
    order  by [animal]
              , [archive];

    select null   as N'##staging - before'
           , [animal]
           , [color]
           , [sound]
           , null as [created]
           , null as [archive]
    from   ##staging
    order  by [animal];

    waitfor delay N'00:00:00.50';

    declare @timestamp [datetime] = current_timestamp;
    declare @delete [datetime] = dateadd(day
              , 0 - 5
              , @timestamp);

    if ( (select count(*)
          from   ##staging) > 0 )
      with [records_to_update] ([id], [animal], [color], [sound], [created], [archive], [action])
           as (select [tgt].[id]
                      , [tgt].[animal]
                      , null
                      , null
                      , [tgt].[created]
                      , @timestamp
                      , N'archive_existing_no_source'
               from   ##target as [tgt]
               where  [tgt].[animal] not in (select [animal]
                                             from   ##staging as [stg])
                      and [tgt].[archive] is null
                      and [tgt].[created] > @delete
               union
               select [tgt].[id]
                      , [tgt].[animal]
                      , null
                      , null
                      , [tgt].[created]
                      , @timestamp
                      , N'archive_existing_update'
               from   ##target as [tgt]
                      join ##staging as [stg]
                        on [stg].[animal] = [tgt].[animal]
               where  ( [stg].[color] != [tgt].[color]
                         or [stg].[sound] != [tgt].[sound] )
                      and [tgt].[archive] is null
               union
               select null
                      , [stg].[animal]
                      , [stg].[color]
                      , [stg].[sound]
                      , @timestamp
                      , null
                      , N'insert_record_modification'
               from   ##target as [tgt]
                      join ##staging as [stg]
                        on [stg].[animal] = [tgt].[animal]
               where  ( [stg].[color] != [tgt].[color]
                         or [stg].[sound] != [tgt].[sound] )
                      and [tgt].[archive] is null
               union
               select null
                      , [stg].[animal]
                      , [stg].[color]
                      , [stg].[sound]
                      , @timestamp
                      , null
                      , N'insert_record_new'
               from   ##staging as [stg]
               where  [stg].[animal] not in (select [animal]
                                             from   ##target as [tgt]
                                             where  [archive] is null)),
           [records_to_retain] ([id], [animal], [color], [sound], [created], [archive], [action])
           as (select [tgt].[id]
                      , [tgt].[animal]
                      , null
                      , null
                      , @timestamp
                      , [tgt].[archive]
                      , N'records_to_retain_active'
               from   ##target as [tgt]
               where  [tgt].[animal] in (select [animal]
                                         from   ##staging as [stg])
                      and [tgt].[animal] not in (select [animal]
                                                 from   [records_to_update])
               union
               select [tgt].[id]
                      , [tgt].[animal]
                      , null
                      , null
                      , [tgt].[created]
                      , [tgt].[archive]
                      , N'records_to_retain_archived'
               from   ##target as [tgt]
               where  [tgt].[archive] is not null
               union
               select [id]
                      , [animal]
                      , [color]
                      , [sound]
                      , [created]
                      , [archive]
                      , [action]
               from   [records_to_update])
      merge into ##target as target
      using [records_to_retain] as source
      on target.[id] = source.[id]
      when matched then
        update set target.[created] = source.[created],
                   target.[archive] = source.[archive]
      when not matched by target then
        insert ([animal],
                [color],
                [sound],
                [created])
        values ([animal],
                [color],
                [sound],
                @timestamp)
      when not matched by source then
        delete
      output $action
             , inserted.[id] as N'deleted record->'
             , deleted.[animal]
             , deleted.[color]
             , deleted.[sound]
             , deleted.[created]
             , deleted.[archive]
             , inserted.[id] as N'inserted record->'
             , inserted.[animal]
             , inserted.[color]
             , inserted.[sound]
             , inserted.[created]
             , inserted.[archive];

    select [id] as N'##target - after'
           , [animal]
           , [color]
           , [sound]
           , [created]
           , [archive]
    from   ##target
    order  by [animal]
              , [created] desc
              , [archive] desc;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'presentation'
                                            , N'PROCEDURE'
                                            , N'merge_staging_into_target'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'presentation',
    @level1type=N'PROCEDURE',
    @level1name=N'merge_staging_into_target'

go

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'SCHEMA'
                                            , N'presentation'
                                            , N'PROCEDURE'
                                            , N'merge_staging_into_target'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'SCHEMA',
    @level0name=N'presentation',
    @level1type=N'PROCEDURE',
    @level1name=N'merge_staging_into_target'

go

if not exists (select *
               from   ::fn_listextendedproperty(N'todo'
                                                , N'SCHEMA'
                                                , N'presentation'
                                                , N'PROCEDURE'
                                                , N'merge_staging_into_target'
                                                , null
                                                , null))
  exec sys.sp_addextendedproperty
    @name =N'todo',
    @value =N'Modify logic to leave [id] the same for an existing unique constraint.',
    @level0type=N'SCHEMA',
    @level0name=N'presentation',
    @level1type=N'PROCEDURE',
    @level1name=N'merge_staging_into_target'

go

if not exists (select *
               from   ::fn_listextendedproperty(N'description'
                                                , N'SCHEMA'
                                                , N'presentation'
                                                , N'PROCEDURE'
                                                , N'merge_staging_into_target'
                                                , null
                                                , null))
  exec sys.sp_addextendedproperty
    @name =N'description',
    @value =N'expected actions: 
1. Insert new records from ##staging when they are not found in ##target. 
2. Perform no action when there are zero records in ##staging. 
3. Update [created] on records in ##target when there is a matching record in ##staging. 
4. Delete records from ##target that are older than [n] days. 
5. Archive records in ##target not found in ##staging. 
6. Archive records in ##target prior to inserting update from ##staging. 
7. De-archive records when a matching source record appears in ##staging. 
8. Update [created] when de-archiving a record. 
9. De-archive only the most recent record if multiple archived records exist in ##target. 
10. Update [created] on records in ##target when there is a matching record in ##source. 
11. Update create date for records older than [n] days rather than deleting them. 
12. Do not update [created] when archiving records. 
13. Maintain prior record entries when de-archiving a record.',
    @level0type=N'SCHEMA',
    @level0name=N'presentation',
    @level1type=N'PROCEDURE',
    @level1name=N'merge_staging_into_target'

go 
