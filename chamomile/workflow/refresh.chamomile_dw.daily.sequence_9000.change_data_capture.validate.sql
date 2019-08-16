USE [msdb]
GO

/****** Object:  Job [refresh.chamomile_dw.daily.sequence_9000.change_data_capture.validate]    Script Date: 09/01/2015 11:37:50 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'refresh.chamomile_dw.daily.sequence_9000.change_data_capture.validate')
EXEC msdb.dbo.sp_delete_job @job_id=N'ae5373fa-bc01-4b85-9663-e0193844dba8', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [refresh.chamomile_dw.daily.sequence_9000.change_data_capture.validate]    Script Date: 09/01/2015 11:37:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[DBAJobs]]]    Script Date: 09/01/2015 11:37:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[DBAJobs]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[DBAJobs]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'refresh.chamomile_dw.daily.sequence_9000.change_data_capture.validate')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'refresh.chamomile_dw.daily.sequence_9000.change_data_capture.validate', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[DBAJobs]', 
		@owner_login_name=N'PINNACLE\katherine.lightsey', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
/****** Object:  Step [execute [dbo]].[usp_rValidateChangeTableMining]] @total_row_count=@total_row_count output;]    Script Date: 09/01/2015 11:37:50 ******/
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'execute [dbo].[usp_rValidateChangeTableMining] @total_row_count=@total_row_count output;', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @total_row_count [int];
execute [dbo].[usp_rValidateChangeTableMining] @total_row_count=@total_row_count output;
select @total_row_count as [total_row_count];
if @total_row_count > 0 
	raiserror(N''Failed - Not all change tables were mined successfully.'', 16, 1);', 
		@database_name=N'DWMaster', 
		@flags=20
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


