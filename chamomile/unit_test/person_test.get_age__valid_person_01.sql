use [chamomile];

go

if schema_id(N'person_test') is null
  execute (N'create schema person_test');

go

--
-- create test for accessor object
-------------------------------------------------
-------------------------------------------------
if object_id(N'[person_test].[get_age__valid_person_01]', N'P') is not null
  drop procedure [person_test].[get_age__valid_person_01];

go

/*
	--
     -- Execute script for documentation on live objects
     ---------------------------------------------
     declare @schema   [sysname] = N'person_test'
             , @object [sysname] = N'get_age__valid_person_01';
     
     select quotename([schemas].[name]) + N'.'
            + quotename([objects].[name])        as [object]
            , [extended_properties].[name]       as [property]
            , [extended_properties].[class_desc] as [type]
            , [extended_properties].[value]      as [value]
     from   [sys].[extended_properties] as [extended_properties]
            join [sys].[objects] as [objects]
              on [objects].[object_id] = [extended_properties].[major_id]
            join [sys].[schemas] as [schemas]
              on [schemas].[schema_id] = [objects].[schema_id]
            left join [sys].[parameters] as [parameters]
                   on [parameters].[object_id] = [extended_properties].[major_id]
                      and [parameters].[parameter_id] = [extended_properties].[minor_id]
     order  by [extended_properties].[class_desc],[extended_properties].[name]; 
     
*/
create procedure [person_test].[get_age__valid_person_01] @output  [xml] output
                                                          , @error [xml] = null output
as
  begin
      set transaction isolation level snapshot;

      declare @test_stack_builder [xml] = N'<test_stack name="" test_count="0" pass_count="0" timestamp="" ><description /></test_stack>'
              , @test_builder     [xml] = N'<test test_name="" pass="false" timestamp="" ><description /></test>'
              , @true             [sysname] = N'true'
              , @false            [sysname] = N'false';
      --
      declare @test_stack         [xml]
              , @test             [xml]
              , @test_description [nvarchar](max)
              , @message          [nvarchar](max)
              , @timestamp        [datetime2](7) = current_timestamp
              , @timestamp_string [sysname]
              , @this             [nvarchar](1000) = (select quotename(db_name()) + N'.'
                        + quotename([schemas].[name]) + N'.'
                        + quotename([procedures].[name])
                 from   [sys].[procedures] as [procedures]
                        join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [procedures].[schema_id]
                 where  [procedures].[object_id] = @@procid)
              , @transaction_id   [bigint]
              , @test_name        [sysname]
              , @id               [int]
              , @age              [int] = null
              , @first_name       [sysname]
              , @last_name        [sysname]
              , @date_of_birth    [date]
              , @count            [int]
              , @pass             [sysname];

      --
      begin
          select @timestamp_string = convert(sysname, @timestamp, 126);

          set @test_stack_builder.modify(N'replace value of (/*/@name)[1] with sql:variable("@this")');
          set @test_stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
          set @message = N'This test stack consists of tests which validate that the get_age method will return NULL if the person does not exist.';
          set @test_stack_builder.modify(N'insert text{sql:variable("@message")} as first into (/*/description)[1]');
          --
          set @test_stack = @test_stack_builder;
      end;

      --
      -- TEST
      -------------------------------------------
      -------------------------------------------
      -------------------------------------------
      begin
          select @test_name = N'validate_person_not_found'
                 , @test_description = N'This test validates that the get_age method will return NULL if the person does not exist.'
                 , @timestamp = current_timestamp
                 , @first_name = convert(sysname, newid())
                 , @last_name = convert(sysname, newid())
                 , @date_of_birth = dateadd(year, -20, current_timestamp)
                 , @test = @test_builder;

          select @timestamp_string = convert(sysname, @timestamp, 126);

          --
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@false")');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
          set @test.modify(N'insert attribute date_of_birth {sql:variable("@date_of_birth")} as last into (/*)[1]');

          if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
            set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
          else
            set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

          --
          begin
              begin transaction;

              set @transaction_id = CURRENT_TRANSACTION_ID();

              --
              -- To test that a non-existent person (based on the identity column) will return a NULL for age,
              --  get a non-existent value for [id] by get MAX plus 1.
              -----------------------------------
              select @id = (select max([id])
                            from   [person].[primary])
                           + 1;

              -- 
              begin
                  execute [person].[get_age] @id    = @id
                                             , @age = @age output;

                  set @message = coalesce(convert([sysname], @age), N'NULL');
                  set @test.modify(N'insert attribute returned_age {sql:variable("@message")} as last into (/*)[1]');

                  if @age is null
                    set @pass = @true;

                  else
                    set @pass = @false;
              end;

              --
              if exists (select *
                         from   sys.[dm_tran_active_transactions]
                         where  [transaction_id] = @transaction_id)
                rollback transaction;
          end;

          --
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@pass")');
          --
          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

      end;

      --
      begin
          set @count = @test_stack.value('count (/*/test)', '[int]');
          set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
          --
          set @count = @test_stack.value(N'count (//test[@pass=sql:variable("@true")])', N'[int]');
          set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      end;

      --
      select @output = @test_stack;

      --
      return 0;
  end;

go

-- 
-------------------------------------------------
execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'@output [xml] output - The output stack of the test procedure.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_person_01'
                                       , @level2type = N'parameter'
                                       , @level2name = N'@output';

go

execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'@error [xml] = null output - The error information for the procedure, if any. Optional parameter.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_person_01'
                                       , @level2type = N'parameter'
                                       , @level2name = N'@error';

go

--
-------------------------------------------------
execute [sys].[sp_addextendedproperty] @name         = N'execute_as'
                                       , @value      = N'
declare @output        [xml]  = null
        , @error       [xml] = null
        , @return_code [int] = null
        , @test_count  [int] = 0
        , @pass_count  [int] = 0;

execute @return_code = [person_test].[get_age__valid_person_01] @output = @output output;

if @return_code <> 0
    or @error is not null
  begin
      select @return_code as [return_code]
             , @error     as [error]
             , @output    as [output];
  end;
else
  begin
      select @test_count = @output.value(''(/test_stack/@test_count)[1]'', N''int'')
             , @pass_count = @output.value(''(/test_stack/@pass_count)[1]'', N''int'');

      if @pass_count = @test_count
        begin
            select N''All tests passed.'' as [result]
                   , @output            as [output]
                   , @test_count        as [test_count]
                   , @pass_count        as [pass_count];
        end;
      else
        begin
            select N''Not all tests passed. Inspect @output for failed tests and conditions.'' as [result]
                   , @output                                                                 as [output]
                   , @test_count                                                             as [test_count]
                   , @pass_count                                                             as [pass_count];
        end;
  end; 
'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_person_01'
                                       , @level2type = null
                                       , @level2name = null;

go

execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'This test procedure consists of tests which validate the functionality of the age calculation for a person.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_person_01'
                                       , @level2type = null
                                       , @level2name = null;

go

execute [sys].[sp_addextendedproperty] @name         = N'revision_20180624'
                                       , @value      = N'Created - KELightsey@gmail.com'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_person_01'
                                       , @level2type = null
                                       , @level2name = null;

go 