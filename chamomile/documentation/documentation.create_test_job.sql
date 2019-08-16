use [msdb]

go

if exists (select *
           from   [msdb].[dbo].[sysjobs]
           where  [name] = N'demonstration_job')
  exec msdb.dbo.sp_delete_job
    @job_name =N'demonstration_job',
    @delete_unused_schedule=1;

go

begin
    begin transaction;

    declare @returncode int;

    select @returncode = 0;

    if not exists (select name
                   from   msdb.dbo.syscategories
                   where  name = N'[Uncategorized (Local)]'
                          and category_class = 1)
      begin
          exec @returncode = msdb.dbo.sp_add_category
            @class =N'JOB',
            @type=N'LOCAL',
            @name=N'[Uncategorized (Local)]'

          if ( @@error <> 0
                or @returncode <> 0 )
            goto quitwithrollback;
      end;

    declare @jobid binary(16);

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_job
      @job_name =N'demonstration_job',
      @enabled =1,
      @notify_level_eventlog=0,
      @notify_level_email =0,
      @notify_level_netsend =0,
      @notify_level_page =0,
      @delete_level =0,
      @description =N'This job runs the change table scrubber.',
      @category_name =N'[Uncategorized (Local)]',
      @owner_login_name =N'TORCHMARKCORP\KELIGHTSEY',
      @job_id = @jobid output

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_jobstep
      @job_id =@jobid,
      @step_name =N'get_change',
      @step_id =1,
      @cmdexec_success_code=0,
      @on_success_action =3,
      @on_success_step_id =0,
      @on_fail_action =2,
      @on_fail_step_id =0,
      @retry_attempts =0,
      @retry_interval =5,
      @os_run_priority =0,
      @subsystem =N'TSQL',
      @command =N'execute [repository].[get_change];',
      @database_name =N'chamomile',
      @flags =0;

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_jobstep
      @job_id =@jobid,
      @step_name =N'step 2',
      @step_id =2,
      @cmdexec_success_code=0,
      @on_success_action =3,
      @on_success_step_id =0,
      @on_fail_action =2,
      @on_fail_step_id =0,
      @retry_attempts =0,
      @retry_interval =0,
      @os_run_priority =0,
      @subsystem =N'TSQL',
      @command =N'select * from sys.tables;',
      @database_name =N'chamomile',
      @flags =0

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_jobstep
      @job_id =@jobid,
      @step_name =N'last step',
      @step_id =3,
      @cmdexec_success_code=0,
      @on_success_action =1,
      @on_success_step_id =0,
      @on_fail_action =2,
      @on_fail_step_id =0,
      @retry_attempts =0,
      @retry_interval =0,
      @os_run_priority =0,
      @subsystem =N'TSQL',
      @database_name =N'master',
      @flags =0

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback

    exec @returncode = msdb.dbo.sp_update_job
      @job_id = @jobid,
      @start_step_id = 1

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_jobschedule
      @job_id =@jobid,
      @name =N'schedule',
      @enabled =1,
      @freq_type =4,
      @freq_interval =1,
      @freq_subday_type =4,
      @freq_subday_interval =5,
      @freq_relative_interval=0,
      @freq_recurrence_factor=0,
      @active_start_date =20140711,
      @active_end_date =99991231,
      @active_start_time =0,
      @active_end_time =235959,
      @schedule_uid =N'37810263-6c55-4f85-aab5-253cb8d1c6bf'

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    exec @returncode = msdb.dbo.sp_add_jobserver
      @job_id = @jobid,
      @server_name = N'(local)'

    if ( @@error <> 0
          or @returncode <> 0 )
      goto quitwithrollback;

    --
    -------------------------------------------------
    commit transaction;
end;

goto endsave;

quitwithrollback:

if ( @@trancount > 0 )
  rollback transaction

endsave:

go 
