/*
	Change to target database prior to running.
*/
if schema_id(N'job') is null
  execute (N'create schema job');

go

set ansi_nulls on;

go

set quoted_identifier on;

go

if object_id(N'[job].[get_history]'
             , N'P') is not null
  drop procedure [job].[get_history];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'job', @object [sysname] = N'get_history';
	--
	-------------------------------------------------
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end +
				case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  then N' output'
					else N''
				end
		end                                                                     as [object]
       ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
			else N'PARAMETER'
        end                                                                     as [type]
		   ,[extended_properties].[name]                                        as [property]
		   ,[extended_properties].[value]                                       as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and [objects].[name]=@object
	order  by [parameters].[parameter_id],[object],[type],[property]; 
*/
create procedure [job].[get_history] @prefix          [sysname]
                                     , @failed        [bit] = 1
                                     , @always_notify [bit] = 0
                                     , @start         [datetime] = null
                                     , @end           [datetime] = null
                                     , @recipients    [nvarchar] (max) = N'KLightsey@gmail.com'
                                     , @from_address  [nvarchar] (max) = N'KLightsey@gmail.com'
                                     , @profile_name  [sysname] = N'job_notification'
                                     , @output        [xml] = null output
as
  begin
      set nocount on;

      declare @failed_text         [sysname] = N'failed'
              , @job_controller    [nvarchar](1000) = @prefix + N'.controller'
              , @last_run_datetime [datetime]
              , @html_output       [nvarchar](max)
              , @current_timestamp [datetime] = current_timestamp
              , @timestamp         [sysname] = convert([sysname], current_timestamp, 126)
              , @this              [nvarchar](1000) = isnull(quotename(convert([sysname], serverproperty(N'ComputerNamePhysicalNetBIOS'))), N'[default]')
                + N'.'
                + isnull(quotename(convert([sysname], serverproperty(N'MachineName'))), N'[default]')
                + N'.'
                + isnull(quotename(convert([sysname], serverproperty(N'InstanceName'))), N'[default]')
                + N'.' + quotename(db_name(), N']') + N'.'
                + quotename(object_schema_name(@@procid), N']')
                + N'.'
                + quotename(object_name(@@procid), N']');

      select @end = coalesce(@end
                             , @current_timestamp);

      with [get_run]
           as (select [msdb].[dbo].[agent_datetime]([last_run_date]
                                                    , [last_run_time]) as [run_datetime]
               from   [msdb].[dbo].[sysjobs] as [sysjobs]
                      left join [msdb].[dbo].[sysjobsequences] as [sysjobsequences]
                             on [sysjobsequences].[job_id] = [sysjobs].[job_id]
               where  [sysjobs].[name] = @job_controller)
      select @last_run_datetime = max([run_datetime])
      from   [get_run];

      -- 
      ---------------------------------------------- 
      set @output = (select [sysjobsequences].[job_id]                      as [job_id]
                            , [sysjobsequences].[sequence_id]                   as [sequence_id]
                            , [msdb].[dbo].[agent_datetime](run_date
                                                            , run_time) as [run_datetime]
                            , [sysjobhistory].[message]                 as [message]
                     from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                            inner join [msdb].[dbo].[sysjobs] as [sysjobs]
                                    on [sysjobs].[job_id] = [sysjobhistory].[job_id]
                            inner join [msdb].[dbo].[sysjobsequences] as [sysjobsequences]
                                    on [sysjobsequences].[job_id] = [sysjobhistory].[job_id]
                                       and [sysjobsequences].[sequence_id] = [sysjobhistory].[sequence_id]
                     where  [sysjobhistory].[message] like case
                                                             when @failed = 1 then N'%' + @failed_text + N'%'
                                                             else N'%'
                                                           end
                            and ( [msdb].[dbo].[agent_datetime]([run_date]
                                                                , [run_time]) >= @start )
                            and ( [msdb].[dbo].[agent_datetime]([run_date]
                                                                , [run_time]) <= @end )
                     order  by [sysjobsequences].[job_id]
                               , [sysjobsequences].[sequence_id]
                               , [sysjobhistory].[run_date] desc
                               , [sysjobhistory].[run_time] desc
                     for xml path(N'job_sequence'), root(N'job_history'));

      -- 
      ---------------------------------------------- 
      if @output is not null
          or @always_notify = 1
        begin
            set @html_output = N'<notification timestamp="' + @timestamp
                               + N'"><procedure>' + @this + N'</procedure>'
                               + isnull(cast(@output as [nvarchar](max)), N'<no_result_set />')
                               + N'</notification>';

            exec [msdb].[dbo].[sp_send_dbmail]
              @recipients = @recipients,
              @from_address = @from_address,
              @profile_name = @profile_name,
              @subject = @this,
              @body = @html_output,
              @body_format = N'HTML';

            set @output = @html_output;
        end;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'todo'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'todo',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history';

go

exec sys.sp_addextendedproperty
  @name = N'todo',
  @value = N'<ul>
	<li>Add job history (sequence_id=0).</li>
	<li>Get template for @html_output from metadata.</li>
	<li>Get default values for parameters and variables from metadata.</li>
	<li>Change input parameter defaults to email addresses for groups.</li>
	<li>Add optional logging.</li>
  </ul>',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'[job].[get_history] gets sequences... TODO',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150810'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150810',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150810',
  @value = N'KLightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_workflow'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_workflow',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history';

go

exec sys.sp_addextendedproperty
  @name = N'package_workflow',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
  <ul>
	<li>
	  declare @output [xml];
	  execute [job].[get_history] @output=@output output;
	  select @output as [@output];
	</li>
	<li>
	  declare @output [xml];
	  execute [job].[get_history] 
		  @failed=1
		  , @always_notify=1
		  , @start=N''20150801''
		  , @end=N''20150805''
		  , @recipients=N''to@domain.com;to_also@domain.com''
		  , @from_address=N''from@domain.com''
		  , @profile_name=N''job_notification''
		  , @output=@output output;
	  select @output as [@output];
	</li>
  </ul>',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@failed'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@failed';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@failed [bit]=1 - Defaults to 1. If 1, only messages with "failed" in the text are returned. If 0, all messages are returned.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@failed';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@always_notify'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@always_notify';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@always_notify [bit]=0 - Defaults to 0. If 0 and no messages are found that match, then no notification is performed. If 1, notification is performed whether messages are found or not. This is used so that, if @failed=1 and no messages are found, a notification will occur stating that no failed jobs were found.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@always_notify';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@start'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@start';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@start [datetime] = null - defaults to null. If null, set to one day prior. Only messages with a run date and time >= to @start will be returned.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@start';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@end'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@end';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@end [datetime] = null - defaults to null. If null, set to current_timestamp. Only messages with a run date and time <= to @end will be returned.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@end';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@recipients'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@recipients';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@recipients [nvarchar](max) = N''KLightsey@gmail.com'' - [ @recipients = ] ''recipients''
Is a semicolon-delimited list of e-mail addresses to send the message to. The recipients list is of type varchar(max). Although this parameter is optional, at least one of @recipients, @copy_recipients, or @blind_copy_recipients must be specified, or sp_send_dbmail returns an error.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@recipients';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@from_address'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@from_address';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@from_address  [nvarchar](max) = N''KLightsey@gmail.com'' - [ @from_address = ] ''from_address''
Is the value of the ''from address'' of the email message. This is an optional parameter used to override the settings in the mail profile. This parameter is of type varchar(MAX). SMTP security settings determine if these overrides are accepted. If no parameter is specified, the default is NULL.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@from_address';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@profile_name'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@profile_name';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@profile_name  [sysname] = N''job_notification'' - [ @profile_name = ] ''profile_name''
Is the name of the profile to send the message from. The profile_name is of type sysname, with a default of NULL. The profile_name must be the name of an existing Database Mail profile. When no profile_name is specified, sp_send_dbmail uses the default private profile for the current user. If the user does not have a default private profile, sp_send_dbmail uses the default public profile for the msdb database. If the user does not have a default private profile and there is no default public profile for the database, @profile_name must be specified.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@profile_name';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'get_history'
                                          , N'parameter'
                                          , N'@output'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'get_history',
    @level2type = N'parameter',
    @level2name = N'@output';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@output [xml] output - The output parameter for the procedure. Returns the value of @html_output which is the output of the found messages with a wrapper.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'get_history',
  @level2type = N'parameter',
  @level2name = N'@output';

go 
