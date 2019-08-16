use [chamomile];

go

if object_id(N'[scheduling].[run]'
             , N'P') is not null
  drop procedure [scheduling].[run];

go

create procedure [scheduling].[run] @output xml ([utility].[xsc_object_stack]) output
as
  begin
      ---------------------------------------------------------------------------------------------------
      -- retrieve job stack and get information for run
      declare @job_stack  xml ([utility].[xsc_object_stack]),
              @job        xml,
              @result     xml,
              @object     xml,
              @sql        [nvarchar](max),
              @parameters [nvarchar](max),
              @builder    xml;

      ---------------------------------------------------------------------------------------------------
      -- get job
      begin
          set @job_stack = N'<chml:object_stack xmlns:chml="http://sourceforge.net/projects/chamomile/" stack_type="result" timestamp="'
                           + convert([sysname], current_timestamp, 126)
                           + N'">
  <object_signature>
    <object_fqn name="[computer_name_physical_netbios].[machine_name].[instance_name].[chamomile].[scheduling].[object_to_be_run_01]" />
    <subject_fqn name="[computer_name_physical_netbios].[machine_name].[instance_name].[chamomile].[scheduling].[run]" />
  </object_signature>
</chml:object_stack>';

          execute [logging].[get_entry]
            @typed_entry =@job_stack output;

          set @builder = @job_stack;
          set @parameters = @builder.value(N'declare namespace chml="http://sourceforge.net/projects/chamomile/"; (/chml:object_stack/object[@name="sp_executesql"]/parameters/text())[1]'
                                           , N'[nvarchar](max)');
          set @sql = @builder.value(N'declare namespace chml="http://sourceforge.net/projects/chamomile/"; (/chml:object_stack/object[@name="sp_executesql"]/sql/text())[1]'
                                    , N'[nvarchar](max)');
      end

      ---------------------------------------------------------------------------------------------------
      -- run job
      begin
          execute sp_executesql
            @sql =@sql,
            @parameters =@parameters,
            @result =@result output;

          set @object = N'<object object_type="result" name="sp_executesql" timestamp="'
                        + convert([sysname], current_timestamp, 126)
                        + '" />';
          set @object.modify(N'insert sql:variable("@result") as last into (/object)[1]');
          set @job_stack.modify(N'declare namespace chml="http://sourceforge.net/projects/chamomile/"; insert sql:variable("@object") as last into (/chml:object_stack)[1]');
          set @output = @job_stack;
      end
  end

go 
