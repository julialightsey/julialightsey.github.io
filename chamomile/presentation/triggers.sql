/*
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	--
	--	description
	---------------------------------------------
		demonstrates the capability of a trigger to determine whether to allow an object to be modified
			based on the return value of a test.

		using this technique allows the creation of unbreakable code (http://www.katherinelightsey.com/#!unbreakablecode/c90f)
	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--


	--
	-- references
	---------------------------------------------
	CREATE TRIGGER (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms189799.aspx
	disallow results from triggers Server Configuration Option - http://msdn.microsoft.com/en-us/library/ms186337.aspx
		select value
        from   sys.configurations
        where  name = 'disallow results from triggers' 

		execute sp_configure 'disallow results from triggers', 1; 
		reconfigure;
		go
        



		Use the disallow results from triggers option to control whether triggers return result sets. Triggers that return result sets may cause unexpected behavior in applications that are not designed to work with them.
		Important note Important
		This feature will be removed in the next version of Microsoft SQL Server. Do not use this feature in new development work, and modify applications that currently use this feature as soon as possible. We recommend that you set this value to 1.
		When set to 1, the disallow results from triggers option is set to ON. The default setting for this option is 0 (OFF). If this option is set to 1 (ON), any attempt by a trigger to return a result set fails, and the user receives the following error message:
		"Msg 524, Level 16, State 1, Procedure <Procedure Name>, Line <Line#>
		"A trigger returned a resultset and the server option 'disallow_results_from_triggers' is true."
		The disallow results from triggers option is applied at the Microsoft SQL Server instance level, and it will determine behavior for all existing triggers within the instance.
		The disallow results from triggers option is an advanced option. If you are using the sp_configure system stored procedure to change the setting, you can change disallow results from triggers only when show advanced options is set to 1. The setting takes effect immediately without a server restart.
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'presentation') is null
  execute (N'create schema presentation');

go

if schema_id(N'presentation_test') is null
  execute (N'create schema presentation_test');

go

if exists (select *
           from   sys.triggers
           where  parent_class = 0
                  and name = 'test_trigger')
  drop trigger [test_trigger] on database;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create test object
-------------------------------------------------
if object_id(N'[presentation_test].[trigger_test]'
             , N'P') is not null
  drop procedure [presentation_test].[trigger_test];

go

create procedure [presentation_test].[trigger_test] @stack [xml] output
as
  begin
      set @stack= N'<stack name="['
                  + object_schema_name(@@procid) + N'].['
                  + object_name(@@procid)
                  + N']" variable="1" />'
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create business object
-------------------------------------------------
if object_id(N'[presentation].[trigger_test]'
             , N'P') is not null
  drop procedure [presentation].[trigger_test];

go

create procedure [presentation].[trigger_test] @stack [xml] output
as
  begin
      select 1;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if exists (select *
           from   sys.triggers
           where  parent_class = 0
                  and name = 'test_trigger')
  drop trigger [test_trigger] on database;

go

--
-- create lock trigger
-------------------------------------------------
create trigger [test_trigger]
on database
after alter_function, drop_function, alter_procedure, drop_procedure, alter_table, drop_table
as
  begin
      declare @event_data [xml] = eventdata()
      declare @schema      [sysname] = @event_data.value(N'(/*/SchemaName/text())[1]'
                                  , N'[sysname]'),
              @object      [sysname] = @event_data.value(N'(/*/ObjectName/text())[1]'
                                  , N'[sysname]'),
              @object_type [sysname] = @event_data.value(N'(/*/ObjectType/text())[1]'
                                  , N'[sysname]'),
              @stack       [xml],
              @variable    [int],
              @sql         [nvarchar](max) = N'execute [presentation_test].[trigger_test] @stack=@stack output',
              @parameters  [nvarchar](max) = N'@stack [xml] output';

      execute sp_executesql
        @sql =@sql,
        @parameters=@parameters,
        @stack =@stack output;

      set @variable = @stack.value(N'(/*/@variable)[1]'
                                   , N'[int]');

      if @variable != 0
        rollback;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- attempt to drop business object
-- select object_id(N'[presentation].[trigger_test]', N'P');
-------------------------------------------------
begin try
    if object_id(N'[presentation].[trigger_test]'
                 , N'P') is not null
      drop procedure [presentation].[trigger_test];
end try

begin catch
    select case
             when object_id(N'[presentation].[trigger_test]'
                            , N'P') is null then N'Error! The object was dropped, but it should not have been!'
             else N'The object was not dropped based on output from [presentation_test].[trigger_test]!'
           end as [exists];
end catch;

go
-------------------------------------------------
-- code block end
--
