use [utility];

go

if object_id(N'[utility].[running_job_list]', N'V') is not null
  drop view [utility].[running_job_list];

go

/*
    --
    -- run script for documentation
    ---------------------------------------------
    declare @schema [sysname]=N'utility', @object [sysname]=N'running_job_list';
    select [columns].[name] as [column]
	   , [extended_properties].[name]
	   , [extended_properties].[value]
    from [master].[sys].[extended_properties] as [extended_properties]
    join [master].[sys].[views] as [views] 
	   on [views].[object_id] = [extended_properties].[major_id]
    join [master].[sys].[schemas] as [schemas] 
	   on [schemas].[schema_id] = [views].[schema_id]
    left join [master].[sys].[columns] as [columns]
	   on [columns].[object_id] = [views].[object_id]
		  and [columns].[column_id] = [extended_properties].[minor_id]
    where [schemas].[name] = @schema and [views].[name] = @object
    order by [columns].[name], [extended_properties].[name];
*/
create view [utility].[running_job_list]
as
  select [sysjobactivity].[job_id]                 as [job_id]
         , [sysjobs].[name]                        as [job_name]
         , [sysjobactivity].[start_execution_date] as [start_execution_date]
         , isnull([sysjobactivity].[last_executed_step_id], 0)
           + 1                                     as [current_executed_step_id]
         , [sysjobsteps].[step_name]               as [step_name]
  from   [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
         join [msdb].[dbo].[sysjobs] as [sysjobs]
           on [sysjobactivity].[job_id] = [sysjobs].[job_id]
         join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
           on [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
              and isnull([sysjobactivity].[last_executed_step_id], 0)
                  + 1 = [sysjobsteps].[step_id]
  where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                          from   [msdb].[dbo].[syssessions]
                                          order  by [agent_start_date] desc)
         and [start_execution_date] is not null
         and [stop_execution_date] is null;

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'[msdb].[utility].[sysjobactivity].[job_id]'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = N'column'
  , @level2name = N'job_id';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'[msdb].[utility].[sysjobs].[name]'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = N'column'
  , @level2name = N'job_name';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'[msdb].[utility].[sysjobactivity].[start_execution_date]'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = N'column'
  , @level2name = N'start_execution_date';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'[msdb].[utility].[sysjobactivity].[last_executed_step_id] -- isnull([sysjobactivity].[last_executed_step_id], 0) + 1'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = N'column'
  , @level2name = N'current_executed_step_id';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'[msdb].[utility].[sysjobsteps].[step_name]'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = N'column'
  , @level2name = N'step_name';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'select [job_id], [job_name], [start_execution_date], [current_executed_step_id], [step_name] from [running_job_list];'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = null
  , @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'Returns a list of running jobs on the instance.'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = null
  , @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'revision_20180729'
  , @value = N'Katherine E. Lightsey - created.'
  , @level0type = N'schema'
  , @level0name = N'utility'
  , @level1type = N'view'
  , @level1name = N'running_job_list'
  , @level2type = null
  , @level2name =null;

go 
