USE [msdb]
GO

/****** Object:  Job [maintenance__defrag__all]    Script Date: 12/11/2018 4:54:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [maintenance]    Script Date: 12/11/2018 4:54:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'maintenance__defrag__all', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Defragment all indexes in all databases', 
		@category_name=N'maintenance', 
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[AxDB] defragment]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[AxDB] defragment', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'AxDB', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[AxDW] defragment]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[AxDW] defragment', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'AxDW', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[DynamicsAxReportServer] defragment]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[DynamicsAxReportServer] defragment', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'DynamicsAxReportServer', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[DynamicsAxReportServerTempDB] defragment and update statistics]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[DynamicsAxReportServerTempDB] defragment and update statistics', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'DynamicsAxReportServerTempDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[DYNAMICSXREFDB] defragment and update statistics]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[DYNAMICSXREFDB] defragment and update statistics', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'DYNAMICSXREFDB', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[FinancialReportingDb] defragment and update statistics]    Script Date: 12/11/2018 4:54:46 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[FinancialReportingDb] defragment and update statistics', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set quoted_identifier on;

go

declare @maximum_fragmentation          [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.fragmentation.maximum''), 10)
        , @minimum_page_count           [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.page_count.minimum''), 100)
        , @fillfactor                   [int] = null
        , @rebuild__on                  [bit] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.rebuild.on''), 0)
        , @reorganize_demarcation       [int] = coalesce([utility].[utility].[get__metadata](N''maintenance.defrag.reorganize.demarcation''), 25)
        , @defrag_count_limit           [int] = [utility].[utility].[get__metadata](N''maintenance.defrag.count.maximum'')
        , @output                       [xml] = null
        , @schema                       [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N''defragment'';
--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
  from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, ''LIMITED'') as [dm_db_index_physical_stats]
         join [sys].[indexes] as [indexes]
           on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
              and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
         join [sys].[tables] as [tables]
           on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
         join [sys].[schemas] as [schemas]
           on [schemas].[schema_id] = [tables].[schema_id]
  where  [indexes].[name] is not null
         and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
         and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
  order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
            , [schemas].[name]
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( ( @defrag_count < @defrag_count_limit )
                 or ( @defrag_count_limit = 0 ) )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
             and @rebuild__on = 1
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] rebuild '';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + '' with (fillfactor=''
                                 + cast(@fillfactor as [sysname]) + '')'';
                  end;

                set @sql = @sql + '' ; '';
            end;
          else if @average_fragmentation_before <= @reorganize_demarcation
            begin
                set @sql = ''alter index ['' + @index + N''] on ['' + @schema
                           + N''].['' + @table + ''] reorganize'';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                execute (@sql);
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

go

execute sp_updatestats;

go 
', 
		@database_name=N'FinancialReportingDb', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


