use [master]

GO

if object_id(N'[dbo].[sp__run__job]', N'P') is not null
  drop procedure [dbo].[sp__run__job];

go

set ANSI_NULLS on;

GO

set QUOTED_IDENTIFIER on;

GO

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema   [sysname] = N'dbo', @object [sysname] = N'sp__run__job';
	select quotename(object_schema_name([extended_properties].[major_id])) + N'.'
		   + case when object_name([objects].[parent_object_id]) is not null then quotename(object_name([objects].[parent_object_id]))
				+ N'.' + quotename(object_name([objects].[object_id]))
			   else quotename(object_name([objects].[object_id]))
					+ case when [parameters].[parameter_id] > 0 then N' ' + coalesce( [parameters].[name], N'')
						else N''
					  end
					+ case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1 then N' output'
						else N''
					  end
			 end                           as [object]
		   , case
			   when [extended_properties].[minor_id] = 0 then [objects].[type_desc]
			   else N'PARAMETER'
			 end                           as [type]
		   , [extended_properties].[name]  as [property]
		   , [extended_properties].[value] as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id] = [extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id] = [objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id] = [parameters].[object_id]
					 and [parameters].[parameter_id] = [extended_properties].[minor_id]
	where  [schemas].[name] = @schema and [objects].[name] = @object
	order  by [parameters].[parameter_id], [object], [type], [property]; 
*/
create procedure [dbo].[sp__run__job] @prefix                         [sysname]
                                      , @first_sequence               [int] = 1
                                      , @last_sequence                [int]=10000
                                      , @sequence_delay               [sysname]=N'00:00:15'
                                      , @process_delay                [sysname]=N'00:00:15'
                                      , @maximum_allowed_process_time [int] = 120
                                      , @log_output                   [bit] = 0
                                      , @log_id                       [bigint] = null output
                                      , @output                       [xml] = null output
                                      , @error                        [xml] = null output
as
  begin
      set nocount on;

      declare @sequence_prefix    [sysname]=N'sequence_'
              , @job              [nvarchar](1000)
              , @sequence         [int] = @first_sequence
              , @timestamp        [datetime] = current_timestamp
              , @timestamp_string [sysname]
              , @message          [nvarchar](max)
              , @parameter_list   [xml] = N'<parameter_list />'
              , @job_start        [datetime] = current_timestamp
              , @start_time       [datetime]
              , @job_detail       [xml]
              , @builder          [xml]
              , @reference_list   [xml]
              , @run_status       [int]
              , @count            [int]
              , @return_code      [int]
              , @error_count      [int] = 0
              , @this             [nvarchar](1000) = quotename(db_name()) + N'.' + quotename(object_schema_name(@@procid)) + N'.' + quotename(object_name(@@procid));

      --
      -- todo: get from metadata
      -------------------------------------------
      set @output = coalesce(@output, N'<output ><job_list /></output>');

      --
      -- Validate parameters
      -------------------------------------------
      if @prefix is null
        begin
            set @message = N'@prefix is a required parameter.';

            throw 51000, @message, 1;
        end;

      --
      -- buid output
      -------------------------------------------
      begin
          set @timestamp_string = convert(sysname, @timestamp, 126);
          --
          set @parameter_list.modify(N'insert attribute prefix {sql:variable("@prefix")} as last into (/*)[1]');
          set @parameter_list.modify(N'insert attribute first_sequence {sql:variable("@first_sequence")} as last into (/*)[1]');
          set @parameter_list.modify(N'insert attribute last_sequence {sql:variable("@last_sequence")} as last into (/*)[1]');
          set @parameter_list.modify(N'insert attribute sequence_delay {sql:variable("@sequence_delay")} as last into (/*)[1]');
          set @parameter_list.modify(N'insert attribute process_delay {sql:variable("@process_delay")} as last into (/*)[1]');
          set @parameter_list.modify(N'insert attribute maximum_allowed_process_time {sql:variable("@maximum_allowed_process_time")} as last into (/*)[1]');
          --
          set @reference_list = N'<reference_list>
			<reference table="[msdb].[dbo].[syssessions]" name="dbo.syssessions (Transact-SQL)" url="https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-syssessions-transact-sql?view=sql-server-2017" />
			<reference table="[msdb].[dbo].[sysjobs]" name="dbo.sysjobs (Transact-SQL)" url="https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobs-transact-sql?view=sql-server-2017" />
			<reference table="[msdb].[dbo].[sysjobactivity]" name="dbo.sysjobactivity (Transact-SQL)" url="https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobactivity-transact-sql?view=sql-server-2017" />
			<reference table="[msdb].[dbo].[sysjobhistory]" name="dbo.sysjobhistory (Transact-SQL)" url="https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql?view=sql-server-2017" />
		  </reference_list>';
          --
          set @output.modify(N'insert attribute subject {sql:variable("@this")} as first into (/*)[1]');
          set @output.modify(N'insert attribute return_code {1} as last into (/*)[1]');
          set @output.modify(N'insert attribute timestamp {sql:variable("@timestamp_string")} as last into (/*)[1]');
          set @output.modify(N'insert sql:variable("@parameter_list") as first into (/*)[1]');
          set @output.modify(N'insert sql:variable("@reference_list") as last into (/*)[1]');
      end;

      --
      -- run all jobs with the same sequence number in parallel if there are no errors
      -- if there are errors, skip and allow the code to fall through to build final output
      -------------------------------------------
      while @sequence <= @last_sequence
            and @error_count = 0
        begin
            --  
            -- Delay between sequences so that each sequence is executed independently  
            --   disallows running next sequence while any jobs (as defined by @prefix) 
            --   are still running, other than the ".controller". 
            ------------------------------------- 
            while exists (select *
                          from   [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
                                 left join [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                                        on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                                 join [msdb].[dbo].[sysjobs] as [sysjobs]
                                   on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                          where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                  from   [msdb].[dbo].[syssessions]
                                                                  order  by [agent_start_date] desc)
                                 and [start_execution_date] is not null
                                 and [stop_execution_date] is null
                                 --and [sysjobs].[name] like @prefix + N'%'
                                 and [sysjobs].[name] like @prefix + N'.' + @sequence_prefix + right(N'0000'+cast(@sequence-1 as [sysname]), 4) + N'%'
                                 and [sysjobs].[name] != @prefix + N'.controller'
                                 and [sysjobs].[enabled] = 1)
              waitfor delay @sequence_delay;

            --  
            -- If any job in the batch fails, do not continue processing.
            ------------------------------------- 
            begin
                if exists (select *
                           from   [msdb].[dbo].[sysjobs] as [sysjobs]
                                  join [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
                                    on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                                  left join [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                                         on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                           where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                   from   [msdb].[dbo].[syssessions]
                                                                   order  by [agent_start_date] desc)
                                  and [sysjobactivity].[start_execution_date] > @job_start
                                  and [sysjobs].[name] like @prefix + N'%'
                                  and [sysjobs].[name] != @prefix + N'.controller'
                                  and [sysjobhistory].[run_status] <> 1
                                  and [sysjobs].[enabled] = 1)
                  begin
                      set @return_code = 1;
                      set @error_count = @error_count + 1;
                  end;
            end;

            --  
            -- run all jobs with the same sequence number in parallel if there are no errors
            -- if there are errors, skip and allow the code to fall through to build final output
            ------------------------------------- 
            if @error_count = 0
              begin
                  declare [job_cursor] cursor for
                    select [sysjobs].[name]
                    from   [msdb].[dbo].[sysjobs] as [sysjobs]
                    where  [sysjobs].[name] like @prefix + N'.' + @sequence_prefix + right(N'0000'+cast(@sequence as [sysname]), 4) + N'%'
                           and ( [sysjobs].[name] != @prefix + N'.controller' )
                           and [sysjobs].[enabled] = 1
                    order  by [sysjobs].[name] asc;

                  --  
                  open [job_cursor];

                  fetch next from [job_cursor] into @job;

                  while @@fetch_status = 0
                    begin
                        --  
                        set @start_time = current_timestamp;

                        execute @return_code = [msdb].[dbo].[sp_start_job]
                          @job;

                        --
                        -- from: https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql?view=sql-server-2017
                        -- NOTE: Data is updated only after the jobstep completes.
                        -- This WHILE loop waits until the [run_status] is available before it continues.
                        -- The @maximum_allowed_process_time check is included here to prevent a dead process. 
                        -------------------------
                        while (select [sysjobhistory].[run_status]
                               from   [msdb].[dbo].[sysjobs] as [sysjobs]
                                      left join [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
                                             on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                                      left join [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                                             on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                               where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                       from   [msdb].[dbo].[syssessions]
                                                                       order  by [agent_start_date] desc)
                                      and [sysjobs].[name] = @job) is null
                          begin
                              waitfor delay @process_delay;

                              if datediff(minute, @timestamp, current_timestamp) > @maximum_allowed_process_time
                                begin
                                    set @message = @this + N': Maximum time exceeded.';

                                    throw 51000, @message, 1;
                                end;
                          end;

                        --
                        -- pick up the timestamp used to mark as completed here as we know the jobstep has completed (see above note)
                        -------------------------
                        set @timestamp_string = convert(sysname, current_timestamp, 126);

                        --
                        select @job_detail = (select *
                                              from   [msdb].[dbo].[sysjobs] as [sysjobs]
                                                     left join [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
                                                            on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                                                     left join [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                                                            on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                                                     left join [msdb].[dbo].[syssessions] as [syssessions]
                                                            on [syssessions]. [session_id] = [sysjobactivity].[session_id]
                                              where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                                      from   [msdb].[dbo].[syssessions]
                                                                                      order  by [agent_start_date] desc)
                                                     and [sysjobs].[name] = @job
                                              for xml path(N'job_detail'), root(N'job_detail_list'));

                        set @job_detail = @job_detail.query(N'(/job_detail_list/job_detail)[1]');
                        set @run_status = @job_detail.value(N'(/job_detail/run_status/text())[1]', N'[int]');
                        --
                        -- get job step entry from [msdb].[dbo].[sysjobstepslogs]
                        -------------------------
                        set @builder = (select top(1) [log].[id]
                                                      , [log].[entry]
                                                      , replace(replace([sysjobstepslogs].[log], N' ', N''), N'-', N'') as [sysjobstepslogs__message]
                                                      , [log].[created]
                                        from   [utility].[log] as [log]
                                               left join [msdb].[dbo].[sysjobs] as [sysjobs]
                                                      on [sysjobs].[name] = [log].[application]
                                               left join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                                                      on [sysjobs].[job_id] = [sysjobsteps].[job_id]
                                               left join [msdb].[dbo].[sysjobstepslogs] as [sysjobstepslogs]
                                                      on [sysjobsteps].[step_uid] = [sysjobstepslogs].[step_uid]
                                        where  [log].[application] = @job
                                        order  by [log].[created] desc
                                        for xml path(N'sysjobstepslogs'), root(N'sysjobstepslogs_list'));
                        set @builder = @builder.query(N'(/sysjobstepslogs_list/sysjobstepslogs)[1]');
                        set @job_detail.modify(N'insert sql:variable("@builder") as last into (/*)[1]');

                        --
                        -- [run_status], int, Status of the job execution: 0 = Failed, 1 = Succeeded, 2 = Retry, 3 = Canceled, 4 = In Progress
                        -- https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql?view=sql-server-2017
                        -------------------------
                        if @run_status <> 1
                          begin
                              set @return_code = 1;
                              set @error_count = @error_count + 1;
                          end;

                        set @job_detail.modify(N'insert attribute return_code {sql:variable("@return_code")} as first into (/*)[1]');
                        set @job_detail.modify(N'insert attribute name {sql:variable("@job")} as first into (/*)[1]');
                        set @job_detail.modify(N'insert attribute completed {sql:variable("@timestamp_string")} as first into (/*)[1]');
                        --  
                        set @output.modify(N'insert sql:variable("@job_detail") as last into (/output/job_list)[1]');

                        --  
                        waitfor delay @process_delay;

                        --  
                        fetch next from [job_cursor] into @job;
                    end;

                  -- 
                  --------------------------------- 
                  close [job_cursor];

                  deallocate [job_cursor];
              end;

            --  
            -------------------------------------  
            set @sequence = @sequence + 1;
        end;

      --
      -- build output and evaluate for overall pass/fail
      -------------------------------------------
      begin
          set @count = @output.value(N'count (//*/job_detail)', N'int');
          set @output.modify(N'insert attribute job_count {sql:variable("@count")} as last into (/*)[1]');
          set @count = @output.value('count (/*/job_list//*[@return_code="0"])[1]', N'[int]');
          set @output.modify(N'insert attribute pass_count {sql:variable("@count")} as last into (/*)[1]');
          set @count = @output.value('count (/*/job_list//*[@return_code="1"])[1]', N'[int]');
          set @output.modify(N'insert attribute fail_count {sql:variable("@count")} as last into (/*)[1]');
          --
          set @timestamp_string = convert(sysname, current_timestamp, 126);
          set @output.modify(N'insert attribute timestamp__complete {sql:variable("@timestamp_string")} as last into (/*)[1]');

          --
          -- If there are jobs with return_code = 1 or there are jobs in the failed_job list
          --  set @return_code = 1 (fail)
          ---------------------------------------
          if @output.value(N'(/*/@fail_count)[1]', N'[int]') <> 0
              or @error_count > 0
            set @return_code = 1;
          else
            set @return_code = 0;

          set @output.modify(N'replace value of (/*/@return_code)[1] with sql:variable("@return_code")');
      end;

      --
      -- log output if required
      -------------------------------------------
      if @log_output = 1
        begin
            execute [utility].[utility].[set__log]
              @entry=@output
              , @application = @this
              , @id = @log_id output;
        end;

      --
      -------------------------------------------
      return ( @return_code );
  end;

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description_controller'
  , @value =
N'The controller job, <header>.controller, is the job that contains the call to this stored procedure and the schedule for when to run it. Because of this it is excluded from running within this procedure.'
, @level0type = N'schema'
, @level0name = N'workflow'
, @level1type = N'procedure'
, @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description_running_a_range_of_steps'
  , @value = N'Use the parameters @first_step and @last_step to run a range of steps. To run a single step, set the @first_step and @last_step both to the desired step.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value =
N'[workflow].[run_job] is a job scheduling utility. It looks for jobs named "<header>.step_<step_number>". Jobs with the same step number are run in parallel. Each iteration does not run until all jobs with that header name prefix complete, so while jobs with the same step number are run in parallel, each step is run separate from the others. The steps are run in order from 1 to 1000.'
, @level0type = N'schema'
, @level0name = N'workflow'
, @level1type = N'procedure'
, @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'revision_20150810'
  , @value = N'KLightsey@gmail.com – created.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'package_workflow'
  , @value = N'label_only'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'
  declare @header [sysname]=N''refresh.<label>.daily'';
  execute [workflow].[run_job] @header=@header;'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@header [sysname]'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job'
  , @level2type = N'parameter'
  , @level2name = N'@header';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@last_step [int]=1000 - defaults to 999 maximum steps (<@last_step). Increase to add additional jobs or decrease
	to only run a subset of the jobs. For example; to run all jobs except for the defragment and refresh statistics jobs, pass in @last_step=900.
	As the defragment and refresh statistics jobs are "900" jobs they would not run.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job'
  , @level2type = N'parameter'
  , @level2name = N'@last_step';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@step_delay [sysname]=N''00:00:15'' -  the delay between steps, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job'
  , @level2type = N'parameter'
  , @level2name = N'@step_delay';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@process_delay [sysname]=N''00:00:15'' - the delay after each job is started, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.'
  , @level0type = N'schema'
  , @level0name = N'workflow'
  , @level1type = N'procedure'
  , @level1name = N'run_job'
  , @level2type = N'parameter'
  , @level2name = N'@process_delay';

go 
