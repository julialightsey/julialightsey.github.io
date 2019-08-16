use [master];

go

if object_id(N'[dbo].[sp_run_test]', N'P') is not null
  drop procedure [dbo].[sp_run_test];

go

/*
    --
    -- All content is licensed as [chamomile] (https://github.com/KELightsey/chamomile) and 
    --	copyright Katherine Elizabeth Lightsey, 1959-2018 (aka; my life), all rights reserved,
    --	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
    ---------------------------------------------

    --
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'dbo'
		  , @object [sysname] = N'sp_run_test';

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
create procedure [dbo].[sp_run_test] @filter   [sysname] = null
                                     , @output [xml] output
as
  begin
      set nocount on;

      declare @test_tree                    [xml]
              , @application_message        [xml]
              , @sql                        [nvarchar](max)
              , @parameters                 [nvarchar](max)
              , @procedure                  [sysname]
              , @count                      [int]
              , @error_stack                [xml]
              , @error                      [xml]
              , @builder                    [xml]
              , @string                     [nvarchar](max)
              , @schema_filter              [sysname]
              , @procedure_filter           [sysname]
              , @object_fqn                 [nvarchar](1000)
              , @database                   [sysname] = db_name()
              , @object                     [sysname]
              , @test_stack                 [xml]
              , @timestamp_string           [sysname] = convert([sysname], current_timestamp, 126)
              , @this                       [nvarchar](1000) = (select quotename(db_name()) + N'.'
                        + quotename([schemas].[name]) + N'.'
                        + quotename([procedures].[name])
                 from   [sys].[procedures] as [procedures]
                        join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [procedures].[schema_id]
                 where  [procedures].[object_id] = @@procid)
              , @test_suite_builder         [xml] = N'<test_suite database="" filter="null" test_stack_count="0" test_count="0" pass_count="0" timestamp="" ><description /></test_suite>'
              , @test_suite                 [xml]
              , @stack_result_description   [nvarchar](max) = N'Individual results are contained within the tests. No aggregate result is expected for this stack.'
              , @default_test_schema_suffix [sysname] = N'_test'
              , @test_suite_description     [nvarchar](max) = N'an aggregation of all test stacks executed within this method, along with counts of all tests and results.';

      --
      -------------------------------------------
      begin
          select @test_suite = @test_suite_builder;

          if @filter is not null
            set @test_suite.modify(N'replace value of (/*/@filter)[1] with sql:variable("@filter")');

          set @test_suite.modify(N'replace value of (/*/@database)[1] with sql:variable("@database")');
          set @test_suite.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@this")');
          set @test_suite.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_suite_description")');
          set @test_suite.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
      end;

      --
      ------------------------------------------------------------------------------------------------
      declare [test_list] cursor for
        select N'['
               + object_schema_name([procedures].[object_id])
               + N'].['
               + object_name([procedures].[object_id])
               + N']'
        from   [sys].[procedures] as [procedures]
        where  object_schema_name([procedures].[object_id]) like coalesce(@filter, N'') + N'%'
                                                                 + @default_test_schema_suffix;

      begin
          open [test_list];

          fetch next from [test_list] into @procedure;

          while @@fetch_status = 0
            begin
                if object_id(@procedure, N'P') is not null
                  begin
                      set @test_stack = null;
                      set @sql = N'execute ' + @procedure
                                 + N' @output=@test_stack output;';
                      set @parameters = N'@test_stack [xml] output';

                      -- 
                      execute sp_executesql @sql          =@sql
                                            , @parameters =@parameters
                                            , @test_stack =@test_stack output;

                      --
                      if @test_stack is not null
                        set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');
                  end;

                fetch next from [test_list] into @procedure;
            end

          close [test_list];

          deallocate [test_list];

          --
          -- build totals
          -------------------------------------------
          begin
              set @count = @test_suite.value(N'count (//test_stack)', N'[int]');
              set @test_suite.modify(N'replace value of (/*/@test_stack_count)[1] with sql:variable("@count")');
              set @count = cast(@test_suite.value(N'count (//test)', N'[int]') as [int]);
              set @test_suite.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
              set @count = cast(@test_suite.value(N'sum (//@pass_count)', N'[float]') as [int]);
              set @test_suite.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
              set @count = cast(@test_suite.value(N'count (//error)', N'[int]') as [int])
                           + cast(@test_suite.value(N'sum (//@error_count)', N'[float]') as [int]);
              set @test_suite.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
          end;

          --
          set @output = @test_suite;
      end
  end

go

--
-------------------------------------------------
exec [sp_MS_marksystemobject] N'[dbo].[sp_run_test]';

go

--
-------------------------------------------------
exec sys.sp_addextendedproperty @name        =N'description'
                                , @value     =N'Executes the list of tests based on the filter passed in and totals the results.'
                                , @level0type=N'SCHEMA'
                                , @level0name=N'dbo'
                                , @level1type=N'procedure'
                                , @level1name=N'sp_run_test';

go

exec sys.sp_addextendedproperty @name        =N'revision_20140706'
                                , @value     =N'Katherine E. Lightsey - created.'
                                , @level0type=N'SCHEMA'
                                , @level0name=N'dbo'
                                , @level1type=N'procedure'
                                , @level1name=N'sp_run_test';

go

exec sys.sp_addextendedproperty @name        =N'revision_20180708'
                                , @value     =N'Katherine E. Lightsey - Removed typed xml output for demonstration. Converted to system stored procedure.'
                                , @level0type=N'SCHEMA'
                                , @level0name=N'dbo'
                                , @level1type=N'procedure'
                                , @level1name=N'sp_run_test';

go

exec sys.sp_addextendedproperty @name        =N'execute_as'
                                , @value     =N'declare @output xml = null, @filter [sysname] = N''account'';
execute [dbo].[sp_run_test] @filter=@filter, @output=@output output;
select @output as [test_suite];
/*all tests*/
declare @output xml = null;
execute [dbo].[sp_run_test] @output=@output output;
select @output as [test_suite]; '
                                , @level0type=N'SCHEMA'
                                , @level0name=N'dbo'
                                , @level1type=N'procedure'
                                , @level1name=N'sp_run_test';

go

exec sys.sp_addextendedproperty @name        =N'description'
                                , @value     =N'@output [xml] - The output of the tests which were run.'
                                , @level0type=N'schema'
                                , @level0name=N'dbo'
                                , @level1type=N'procedure'
                                , @level1name=N'sp_run_test'
                                , @level2type=N'parameter'
                                , @level2name=N'@output'; 
