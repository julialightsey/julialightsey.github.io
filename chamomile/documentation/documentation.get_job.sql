use [chamomile];

go

if object_id(N'[documentation].[get_job]'
             , N'P') is not null
  drop procedure [documentation].[get_job];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'documentation'
            , @object [sysname] = N'get_job';
    select [schemas].[name]                as [schema]
           , [objects].[name]              as [object]
           , [extended_properties].[name]  as [property]
           , [extended_properties].[value] as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[objects] as [objects]
             on [objects].[object_id] = [extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [objects].[schema_id] = [schemas].[schema_id]
    where  [schemas].[name] = @schema
           and [objects].[name] = @object;
*/
create procedure [documentation].[get_job] @object_fqn         [nvarchar](max)
                                           , @status           [sysname]= N'allow_stale'
                                           , @timestamp_output [bit]= 1
                                           , @bcp_command      [nvarchar](max) = null output
                                           , @documentation    [nvarchar](max) output
as
  begin
      set nocount on;

      declare @instance           [sysname] = cast(serverproperty(N'InstanceName') as [sysname]),
              @step               [int],
              @step_name          [sysname],
              @start              [datetime] = current_timestamp,
              @elapsed            [decimal](9, 4),
              @step_list          [nvarchar](max),
              @job_details        [nvarchar](max),
              @sequence           [int],
              @stack              [xml],
              @timestamp          [sysname] = convert([sysname], current_timestamp, 126),
              @builder            [xml],
              @subject_fqn        [nvarchar](max),
              @server             [sysname],
              @job_description    [nvarchar](max),
              @step_documentation [nvarchar](max),
              @log_prototype      [xml],
              @xml_builder        [xml],
              @message            [nvarchar](max),
              @stripped_timestamp [sysname],
              @job_name           [sysname] = parsename(@object_fqn
                          , 1),
              @description        [nvarchar](max) = N'test log entry';
      declare @output as table
        (
           [step]            [int]
           , [sequence]      [int]
           , [name]          [sysname]
           , [documentation] [nvarchar](max)
        );

      --
      ------------------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @subject_fqn=@builder.value(N'(/*/fqn/@fqn)[1]'
                                      , N'[nvarchar](1000)');

      --
      -------------------------------------------------
      -- job description
      select @job_details = N'<job_details><details><summary>[job_details]</summary>
            			   <table>
						   <tr><td>id</td><td>'
                            + cast([job_id] as [sysname])
                            + N'</td></tr>
						   <tr><td>originating server </td><td>'
                            + cast([servers].[name] as [sysname])
                            + N'</td><tr>
            			   <tr><td>description </td><td>'
                            + [sysjobs].[description]
                            + N'</td><tr>
            			   <tr><td>' + case when [sysjobs].[enabled]=1 then N'enabled</td><td></td><tr> ' else N'disabled</td><td></td><tr>' end
                            + N'<tr><td>starts on step</td><td>'
                            + cast([sysjobs].[start_step_id] as [sysname])
                            + N'</td><tr>
						   <tr><td>owner</td><td>'
                            + cast(suser_sname([sysjobs].[owner_sid]) as [sysname])
                            + N'</td><tr>
						   <tr><td>job category</td><td>'
                            + cast([syscategories].[name] as [sysname])
                            + N'</td><tr>
						   <tr><td>created</td><td>'
                            + cast([sysjobs].[date_created] as [sysname])
                            + N'</td><tr>
						   <tr><td>modified</td><td>'
                            + cast([sysjobs].[date_modified] as [sysname])
                            + N'</td><tr>
                           <tr><td>version</td><td>'
                            + cast([sysjobs].[version_number] as [sysname])
                            + N'</td><tr>'
                            + N'</table></details></job_details>'
      from   [msdb].[dbo].[sysjobs] as [sysjobs]
             join [msdb].[sys].[servers] as [servers]
               on [sysjobs].[originating_server_id] = [servers].[server_id]
             join [msdb].[dbo].[syscategories] as [syscategories]
               on [sysjobs].[category_id] = [syscategories].[category_id]
      where  [sysjobs].[name] = @job_name;

      --
      -------------------------------------------------
      insert into @output
                  ([step],
                   [sequence],
                   [name],
                   [documentation])
      -- step command
      select [step_id]
             , 0
             , [sysjobsteps].[step_name]
             , N'<command>command {'
               + [sysjobsteps].[command] + N'}</command>'
      from   [msdb].[dbo].[sysjobs] as [sysjobs]
             left join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                    on [sysjobsteps].[job_id] = [sysjobs].[job_id]
      where  [sysjobs].[name] = @job_name

      --
      -------------------------------------------------
      begin
          set @job_description = N'<job_description><div id="seventh_indent"><details><summary>[step_documentation]</summary><div id="first_indent"><table>';

          select @job_description = coalesce(@job_description, N' ', N'')
                                    + N'<tr><td>>' + [documentation] + N'</td></tr>'
          from   @output
          where  [step] = 0
                 and [documentation] is not null;

          set @job_description = @job_description
                                 + N'</table></div></job_description>';
      end;

      --
      -------------------------------------------------
      begin
          declare get_job cursor for
            select distinct [step]
                            , [name]
            from   @output
            order  by [step] asc;

          open get_job

          fetch next from get_job into @step, @step_name;

          while @@fetch_status = 0
            if @step is not null
              begin
                  set @step_documentation = null;

                  select @step_documentation = coalesce(@step_documentation, N' ', N'')
                                               + [documentation]
                  from   @output
                  where  [step] = @step
                         and [documentation] is not null
                         and [step] != 0
                  order  by [sequence];

                  select @step_documentation = N'<div id="sixth_indent"><details><summary>step="'
                                               + cast(@step as [sysname]) + N'" name="'
                                               + @step_name + '"</summary>'
                                               + N'<div id="seventh_indent"><li>'
                                               + @step_documentation + N'</li></div>'
                                               + N'</details></div>';

                  select @step_list = coalesce(@step_list, N' ', N'')
                                      + isnull(N'<ol>' + @step_documentation + N'</ol>', N'');

                  fetch next from get_job into @step, @step_name;
              end;

          close get_job;

          deallocate get_job;
      end;

      --
      -------------------------------------------
      set @documentation = N'<job_documentation><div id="sixth_indent"><details><summary>'
                           + @object_fqn + + N'</summary>'
                           + isnull(N'<div id="seventh_indent">'+@job_details + N'</div>', N'')
                           + isnull(@job_description, N'')
                           + isnull(@step_list, N'')
                           --
                           + N'<p class="timestamp">built by {'
                           + @subject_fqn + N'} timestamp {' + @timestamp
                           + N'} elapsed_time(s) {'
                           + cast(@elapsed as [sysname]) + N'}</p>'
                           + N'</details></div></job_documentation>';

      --
      -- load documentation into repository and create bcp extraction command
      -------------------------------------------
      begin
          set @log_prototype =[chamomile].[utility].[get_prototype](N'[chamomile].[log].[stack].[prototype]');
          set @description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis]');
          set @log_prototype.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
          set @log_prototype.modify(N'replace value of (/log/description/text())[1] with sql:variable("@documentation")');

          --
          -------------------------------------------
          execute [chamomile].[utility].[set_log]
            @object_fqn = @object_fqn,
            @log = @log_prototype,
            @description = @description,
            @stack = @stack output;

          --
          -------------------------------------------
          if @timestamp_output = 1
            set @message = N'_' + @stripped_timestamp;
          else
            set @message = N'';

          --
          -------------------------------------------
          set @bcp_command = N'BCP "select [utility].[get_log_text](N'''
                             + @object_fqn + N''');" queryout '
                             + @subject_fqn + '_' + @object_fqn + @message
                             + N'.sql' + N' -t, -T -c -d ' + db_name() + N' -S '
                             + @server + N';';
      end;
  end;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'builds and returns documentatio for a job, based both on sys views and by extracting documentation from the repository.',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'declare @documentation [nvarchar](max), @bcp_command [nvarchar](max);
    execute [documentation].[get_job]
      @object_fqn     = N''[chamomile].[msdb].[7efc4311-a80f-4748-ac98-e599fd8fc40a].[demonstration_job]''
      , @status       = N''force_refresh''
      , @output_as    = N''html''
      , @bcp_command  =@bcp_command output
      , @documentation=@documentation output;
    select @bcp_command as N''@bcp_command'', @documentation as N''@documentation'';',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job';

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , N'parameter'
                                            , N'@object_fqn'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job',
    @level2type=N'parameter',
    @level2name=N'@object_fqn';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@object_fqn [nvarchar](max) - todo',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job',
  @level2type=N'parameter',
  @level2name=N'@object_fqn';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , N'parameter'
                                            , N'@status'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job',
    @level2type=N'parameter',
    @level2name=N'@status';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@status [status] - if "allow_stale", retrieves stale documentation from the repository.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job',
  @level2type=N'parameter',
  @level2name=N'@status';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , N'parameter'
                                            , N'@timestamp_output'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job',
    @level2type=N'parameter',
    @level2name=N'@timestamp_output';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@timestamp_output [bit] - if 1, the output is timestamped as "{output_name}_{timestamp}.{extension}. if 0, the timestamp is omitted and prior documentation is overwritten.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job',
  @level2type=N'parameter',
  @level2name=N'@timestamp_output';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , N'parameter'
                                            , N'@bcp_command'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job',
    @level2type=N'parameter',
    @level2name=N'@bcp_command';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@bcp_command [nvarchar](max) - the bcp command to be run at the command line to extract the documentation to a *.sql file.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job',
  @level2type=N'parameter',
  @level2name=N'@bcp_command';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'get_job'
                                            , N'parameter'
                                            , N'@documentation'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'get_job',
    @level2type=N'parameter',
    @level2name=N'@documentation';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@documentation [nvarchar](max) - the text content of the documentation. due to limitations in the ssms output window, this value may be truncated dependent on its length.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'get_job',
  @level2type=N'parameter',
  @level2name=N'@documentation'; 
