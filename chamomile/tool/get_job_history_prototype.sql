use [dwreporting]

go

set ansi_nulls on;

go

set quoted_identifier on;

go

if object_id(N'[dbo].[usp_rGetJobHistory]'
             , N'P') is not null
  drop procedure [dbo].[usp_rgetjobhistory];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'dbo', @object [sysname] = N'usp_rGetJobHistory';
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
create procedure [dbo].[usp_rgetjobhistory] @failed   [bit] = null
                                            , @output [xml] output
as
  begin
      set nocount on;

      select [sysjobs].[name]
             , [sysjobsteps].job_id
             , [sysjobsteps].[step_id]
             , [sysjobhistory].[run_date]
             , [sysjobhistory].[run_time]
             , [sysjobhistory].[message]
      from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
             join [msdb].[dbo].[sysjobs] as [sysjobs]
               on [sysjobs].[job_id] = [sysjobhistory].[job_id]
             --and  [sysjobhistory].[step_id]=0 
             join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
               on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                  and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
      where  message like N'%failed%'
      order  by [sysjobhistory].[run_date] desc
                , [sysjobhistory].[run_time] desc;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'usp_rGetJobHistory'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'usp_rGetJobHistory';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'[dbo].[usp_rGetJobHistory] is a job scheduling utility. It looks for jobs named 
  "<header>.step_<step_number>". Jobs with the same step number are run in parallel. Each iteration
  does not run until all jobs with that header name prefix complete, so while jobs with the same
  step number are run in parallel, each step is run separate from the others. The steps are run in 
  order from 1 to 1000.
  ',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'usp_rGetJobHistory';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150810'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'usp_rGetJobHistory'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150810',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'usp_rGetJobHistory';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150810',
  @value = N'KLightsey@hcpnv.com – created.',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'usp_rGetJobHistory';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_refresh'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'usp_rGetJobHistory'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_refresh',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'usp_rGetJobHistory';

go

exec sys.sp_addextendedproperty
  @name = N'package_refresh',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'usp_rGetJobHistory';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'usp_rGetJobHistory'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'usp_rGetJobHistory';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
  declare @header [sysname]=N''refresh.DWReporting.daily'';
  execute [dbo].[usp_rGetJobHistory] @header=@header;',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'usp_rGetJobHistory';

go 
