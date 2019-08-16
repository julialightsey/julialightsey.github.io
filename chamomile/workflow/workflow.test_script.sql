use [chamomile];

go

begin
    declare @output xml ([utility].[xsc_object_stack]);

    -----------------------------------------------------------------------------------------------
    -- first run
    execute [scheduling].[run]
      @output=@output output;

    execute [logging].[set_entry]
      @typed_entry =@output output;

    waitfor delay N'00:00:03';

    -----------------------------------------------------------------------------------------------
    -- second run
    execute [scheduling].[run]
      @output=@output output;

    execute [logging].[set_entry]
      @typed_entry =@output output;

    -----------------------------------------------------------------------------------------------
    -- view results
    begin
        declare @job_stack xml ([utility].[xsc_object_stack]);

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

        select @job_stack;
    end
end

go 
