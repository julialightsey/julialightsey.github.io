use [chamomile];

go
IF schema_id(N'workflow') IS NULL
    EXECUTE(N'CREATE SCHEMA workflow');

go

IF object_id(N'[workflow].[run_job]', N'P') IS NOT NULL
    DROP PROCEDURE [workflow].[run_job];

go

/*
	-- 
    -- EXTRACT DOCUMENTATION
    ---------------------------------------------
    DECLARE @schema   [SYSNAME] = N'workflow'
            , @object [SYSNAME] = N'run_job';
    
    SELECT [extended_properties].[name]
           , [extended_properties].[class_desc]
           , [extended_properties].[value]
    FROM   [sys].[extended_properties] AS [extended_properties]
           JOIN [sys].[objects] AS [objects]
             ON [objects].[object_id] = [extended_properties].[major_id]
           JOIN [sys].[schemas] AS [schemas]
             ON [schemas].[schema_id] = [objects].[schema_id]
           LEFT JOIN [sys].[parameters] AS [parameters]
                  ON [extended_properties].[major_id] = [parameters].[object_id]
                     AND [parameters].[parameter_id] = [extended_properties].[minor_id]
    WHERE  [schemas].[name] = @schema
           AND [objects].[name] = @object
    ORDER  BY [extended_properties].[class_desc]
              , [extended_properties].[name]
              , [extended_properties].[value]; 
*/
CREATE PROCEDURE [workflow].[run_job] @header          [SYSNAME]
                                      , @first_step    [INT] = 1
                                      , @last_step     [INT]=1000
                                      , @step_delay    [SYSNAME]=N'00:00:15'
                                      , @process_delay [SYSNAME]=N'00:00:15'
AS
    BEGIN
        SET nocount ON;

        --
        -----------------------------------------
        DECLARE @step_name [SYSNAME]=N'step_'
                , @job     [NVARCHAR](1000)
                , @step    [INT] = @first_step;

        --
        -----------------------------------------
        IF @first_step > @last_step
            BEGIN;
                THROW 51000, N'Parameter @first_step must be < parameter @last_step', 1;
            END;

        --
        -----------------------------------------
        WHILE @step <= @last_step
            BEGIN
                --
                -- delay between steps so that each step is executed independently
                -- disallows running next step while any step in the job (as defined by @header)
                --	is still running.
                -------------------------------------
                WHILE EXISTS
                      (SELECT *
                       FROM   [msdb].[dbo].[sysjobactivity] AS [sysjobactivity]
                              LEFT JOIN [msdb].[dbo].[sysjobhistory] AS [sysjobhistory]
                                     ON [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                              JOIN [msdb].[dbo].[sysjobs] AS [sysjobs]
                                ON [sysjobactivity].[job_id] = [sysjobs].[job_id]
                              JOIN [msdb].[dbo].[sysjobsteps] AS [sysjobsteps]
                                ON [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
                                   AND isnull([sysjobactivity].[last_executed_step_id], 0)
                                       + 1 = [sysjobsteps].[step_id]
                       WHERE  [sysjobactivity].[session_id] =
                              (SELECT TOP (1) [session_id]
                               FROM   [msdb].[dbo].[syssessions]
                               ORDER  BY [agent_start_date] DESC)
                              AND [start_execution_date] IS NOT NULL
                              AND [stop_execution_date] IS NULL
                              AND [sysjobs].[name] LIKE @header + N'%'
                              AND [sysjobs].[name] != @header + N'.controller')
                    WAITFOR delay @step_delay;

                --
                -- run all jobs with the same "sequence_" in parallel 
                -------------------------------------
                DECLARE [job_cursor] CURSOR FOR
                    SELECT [sysjobs].[name]
                    FROM   [msdb].[dbo].[sysjobs] AS [sysjobs]
                    WHERE  [sysjobs].[name] LIKE @header + N'.' + @step_name
                                                 + RIGHT(N'0000'+cast(@step AS [SYSNAME]), 3)
                                                 + N'%'
                           AND
                           (
                               [sysjobs].[name] != @header + N'.controller'
                            )
                ;

                --
                OPEN [job_cursor];

                FETCH next FROM [job_cursor] INTO @job;

                WHILE @@FETCH_STATUS = 0
                    BEGIN
                        PRINT N'starting job: ' + @job + N'. Step: '
                              + cast(@step AS [SYSNAME]);

                        --
                        EXECUTE [msdb].[dbo].[sp_start_job]
                            @job;

                        --
                        -- delay to give job time to start prior to starting next cycle
                        -------------------------------
                        WAITFOR delay @process_delay;

                        --
                        FETCH next FROM [job_cursor] INTO @job;
                    END

                CLOSE [job_cursor];

                DEALLOCATE [job_cursor];
            END;

        --
        -------------------------------------
        SET @step = @step + 1;
    END;

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
    @name = N'description_controller'
    , @value = N'The controller job, <header>.controller, is the job that contains the call to this stored procedure and the schedule for when to run it. Because of this it is excluded from running within this procedure.'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'run_job';

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
    @name = N'description_running_a_range_of_steps'
    , @value = N'Use the parameters @first_step and @last_step to run a range of steps. To run a single step, set the @first_step and @last_step both to the desired step.'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'run_job';

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
    @name = N'description'
    , @value = N'[workflow].[run_job] is a job scheduling utility. It looks for jobs named "<header>.step_<step_number>". Jobs with the same step number are run in parallel. Each iteration does not run until all jobs with that header name prefix complete, so while jobs with the same step number are run in parallel, each step is run separate from the others. The steps are run in order from 1 to 1000.'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'run_job';

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
    @name = N'revision_20150810'
    , @value = N'KLightsey@gmail.com – created.'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'run_job';

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
    @name = N'package_workflow'
    , @value = N'label_only'
    , @level0type = N'schema'
    , @level0name = N'workflow'
    , @level1type = N'procedure'
    , @level1name = N'run_job';

go

--
------------------------------------------------- 
EXEC sys.sp_addextendedproperty
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
EXEC sys.sp_addextendedproperty
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
EXEC sys.sp_addextendedproperty
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
EXEC sys.sp_addextendedproperty
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
EXEC sys.sp_addextendedproperty
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
