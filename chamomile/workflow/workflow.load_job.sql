use [chamomile];

go

declare @job_stack  xml,
        @job        xml,
        @result     xml,
        @object     xml,
        @sql        [nvarchar](max),
        @parameters [nvarchar](max),
        @builder    xml;

---------------------------------------------------------------------------------------------------
-- build job stack
set @job_stack = N'<object_stack stack_type="result" timestamp="'
                 + convert([sysname], current_timestamp, 126)
                 + N'">
  <object_signature>
    <object_fqn name="[computer_name_physical_netbios].[machine_name].[instance_name].[chamomile].[scheduling].[object_to_be_run_01]" />
    <subject_fqn name="[computer_name_physical_netbios].[machine_name].[instance_name].[chamomile].[scheduling].[run]" />
  </object_signature>
</object_stack>'
set @job = N'<object object_type="meta_data" name="sp_executesql" timestamp="'
           + convert([sysname], current_timestamp, 126)
           + '">
			  <parameters>@result xml output</parameters>
			  <sql>set @result = (select object_schema_name([obj].[object_id]) as N''@schema'',
                      [obj].[name]                          as N''@name'',
                      [obj].[type_desc]                     as N''@type''
               from   [sys].[objects] as [obj]
               for xml path(N''object''), root(N''object_tree''))</sql>
			  </object>';
set @job_stack.modify(N'declare namespace chml="http://sourceforge.net/projects/chamomile/"; insert sql:variable("@job") after (/chml:object_stack/object_signature)[1]');

select @job_stack;

go 
