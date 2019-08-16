use [chamomile];

go

if schema_id(N'math__test') is null
  execute (N'create schema math__test');

go

if object_id(N'[math__test].[divide__test_00]', N'P') is not null
  drop procedure [math__test].[divide__test_00];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema   [sysname] = N'math__test', @object [sysname] = N'divide__test_00';
	select quotename(object_schema_name([extended_properties].[major_id])) + N'.'
		   + case when object_name([objects].[parent_object_id]) is not null then quotename(object_name([objects].[parent_object_id]))
				+ N'.' + quotename(object_name([objects].[object_id]))
			   else quotename(object_name([objects].[object_id]))
					+ case when [parameters].[parameter_id] > 0 then N' ' + coalesce( [parameters].[name], N'')
						else N''
					  end
					+ case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1 then N' output'
						else N''
					  end
			 end                           as [object]
		   , case
			   when [extended_properties].[minor_id] = 0 then [objects].[type_desc]
			   else N'PARAMETER'
			 end                           as [type]
		   , [extended_properties].[name]  as [property]
		   , [extended_properties].[value] as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id] = [extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id] = [objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id] = [parameters].[object_id]
					 and [parameters].[parameter_id] = [extended_properties].[minor_id]
	where  [schemas].[name] = @schema and [objects].[name] = @object
	order  by [parameters].[parameter_id], [object], [type], [property]; 
*/
create procedure [math__test].[divide__test_00] @stack [xml] output
as
  begin
      declare @test_stack         [xml] = N'<test_stack subject="" object="" test_count="0" error_count="0" pass_count="0" return_code="" />'
              , @test_prototype   [xml] = N'<test test_sequence="0" test_name="{replace_me}" expected="pass" actual="fail" ><description /></test>'
              , @test             [xml]
              , @test_sequence    [int]
              , @test_value       [float]
              , @count            [int]
              , @return_code      [int] = 0
              , @message          [nvarchar](max)
              , @test_name        [sysname]
              , @test_description [nvarchar](max)
              , @pass             [sysname] = N'pass'
              , @fail             [sysname] = N'fail'
              , @object           [nvarchar](1000) = N'[math].[divide]'
              --
              -- a six part fqn is used to distinguish the complete fully qualified name of the object and where it is run.
              -- on a cluster, ComputerNamePhysicalNetBIOS is unique to the physical machine but MachineName is shared.
              --------------------------------------------
              , @this             [nvarchar](max) = quotename(isnull(lower(cast(serverproperty(N'ComputerNamePhysicalNetBIOS') as [sysname])), N'default'))
                + N'.'
                + quotename(isnull(lower(cast(serverproperty(N'MachineName') as [sysname])), N'default'))
                + N'.'
                + quotename(isnull(lower(cast(serverproperty(N'InstanceName') as [sysname])), N'default'))
                + N'.'
                + quotename(isnull(lower(cast(db_name() as [sysname])), N'default'))
                + N'.'
                + quotename(isnull(lower(cast(object_schema_name(@@procid) as [sysname])), N'default'))
                + N'.'
                + quotename(isnull(lower(cast(object_name(@@procid) as [sysname])), N'default'));

      set @test_stack.modify(N'replace value of (/*/@subject)[1] with sql:variable("@this")');
      set @test_stack.modify(N'replace value of (/*/@object)[1] with sql:variable("@object")');

      --
      -------------------------------------------
      begin
          select @test_sequence = 0
                 , @test_name = N'check_for_target_method_exist'
                 , @test_description = N'Check to see if the target method exists.'
                 , @test = @test_prototype;

          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

          if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
            set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
          else
            set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

          --
          ---------------------------------------
          if object_id(N'[math].[divide]', N'FN') is null
            begin
                select @message = N'Target function does not exist. No further testing will be performed.'
                       , @return_code = 1;

                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
                set @test_stack.modify(N'replace value of (/*/@return_code)[1] with sql:variable("@return_code")');

            end;
          else
            begin
                --
                -- the target method existed, so include that as the first test in the stack
                -------------------------------------
                set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
      end;

      --
      -------------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 1
                   , @test_name = N'return_value_is_numeric'
                   , @test_description = N'Normal operation, white box test, return value must be numeric'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                if isnumeric([math].[divide](3, 3)) = 1
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 2
                   , @test_name = N'divide_by_zero_returns_0'
                   , @test_description = N'Divide by zero returns 0. This may not be what you think would be the correct answer, but we are assuming it is what the business needs for this test.'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                if [math].[divide](3, 0) = 0
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 3
                   , @test_name = N'null_denominator_returns_0'
                   , @test_description = N'A NULL denominator returns 0. This may not be what you think would be the correct answer, but we are assuming it is what the business needs for this test.'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                if [math].[divide](3, null) = 0
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 4
                   , @test_name = N'null_numerator_returns_0'
                   , @test_description = N'A NULL numerator returns 0. This may not be what you think would be the correct answer, but we are assuming it is what the business needs for this test.'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                if [math].[divide](null, 3) = 0
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 5
                   , @test_name = N'zero_numerator_returns_0'
                   , @test_description = N'A zero numerator returns 0. This may not be what you think would be the correct answer, but we are assuming it is what the business needs for this test.'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                if [math].[divide](0, 3) = 0
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------
      if @return_code = 0
        begin
            select @test_sequence = 6
                   , @test_name = N'returns_value_rounded'
                   , @test_description = N'The returned value is rounded upwards to six places.'
                   , @test = @test_prototype;

            set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
            set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');

            if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
              set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
            else
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

            begin try
                set @test_value = [math].[divide](22, 7)

                if @test_value = 3.142857
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                else
                  begin
                      select @message = N'expected 3.142857, actual value returned was '
                                        + cast(@test_value as [sysname]) + N'';

                      set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                  end;
            end try
            begin catch
                select @message = error_message();
                set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            end catch;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      ----------------------------------------------
      set @count = @test_stack.value(N'count (//test)', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_stack;

      --
      return @return_code;
  end;

go

exec sys.sp_addextendedproperty @name         = N'execute_as'
                                , @value      = N'declare @stack [xml]; execute [math__test].[divide__test_00] @stack=@stack output; select @stack;'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'divide__test_00'
                                , @level2type = null
                                , @level2name =null;

go

exec sys.sp_addextendedproperty @name         = N'revision__20140906'
                                , @value      = N'KELightsey@gmail.com - Created.'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'divide__test_00'
                                , @level2type = null
                                , @level2name =null;

go

exec sys.sp_addextendedproperty @name         = N'revision__20180818'
                                , @value      = N'KELightsey@gmail.com - Updated to current naming convention. Clarified documentation and structure.'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'divide__test_00'
                                , @level2type = null
                                , @level2name =null;

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@stack [xml] output - The output of the test including aggregated results.'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'divide__test_00'
                                , @level2type = N'parameter'
                                , @level2name = N'@stack';

go 
