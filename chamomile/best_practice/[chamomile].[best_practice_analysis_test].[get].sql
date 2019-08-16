use [chamomile]

go

if schema_id(N'best_practice_analysis_test') is null
  execute (N'create schema best_practice_analysis_test');

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'best_practice_analysis'
            , @object [sysname] = N'get';
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


	warning - oltp tables should have less than 3 indexes
	warning - oltp table should have narrow indexes

	select object_schema_name(object_id), name, * from sys.tables;
	drop table best_practice_analysis_test.test

*/
set nocount on;
set transaction isolation level serializable;

--
-- 
declare @bcp_command      [nvarchar](max),
        @documentation    [nvarchar](max),
        @sequence         [int],
        @test_name        [nvarchar](max),
        @test_description [nvarchar](max),
        @return_code      [int],
        @count            [int],
        @stack            [xml],
        @test_stack       [xml],
        @sql              [nvarchar](max),
        @object_fqn       [nvarchar](max),
        @object           [sysname],
        @schema           [sysname];

--
-------------------------------------------------
begin
    select @sequence = 1
           , @test_name = N'correctly_configured_oltp_table'
           , @test_description = N'table is configured correctly and should throw no violations.'
           , @return_code = 0
           , @schema = N'best_practice_analysis_test'
           , @object = N'valid_table_01';

    set @object_fqn = N'[' + @schema + N'].[' + @object + N']';

    --
    -------------------------------------------------
    execute [dbo].[sp_get_best_practice_analysis]
      @object_fqn =@object_fqn,
      @status =N'force_refresh',
      @timestamp_output = 0,
      @output_as =N'html',
      @test_stack = @test_stack output;

    --
    -------------------------------------------------
    select @test_stack.value(N'count(//violation)'
                             , N'[int]')   as N'total violation count'
           , @test_stack.value(N'count(//warning)'
                               , N'[int]') as N'total warning count'
           , @test_stack.value(N'count(//test)'
                               , N'[int]') as N'total test count'
           , @test_stack.value(N'count(//missing_table_documentation_violation//violation)'
                               , N'[int]') as N'missing_table_documentation_violation count'
           , @test_stack.value(N'count(//missing_column_documentation_violation//violation)'
                               , N'[int]') as N'missing_column_documentation_violation count'
           , @test_stack.value(N'count(//primary_key_naming_violation//violation)'
                               , N'[int]') as N'primary_key_naming_violation'
           , @test_stack.value(N'count(//unique_constraint_naming_violation//violation)'
                               , N'[int]') as N'unique_constraint_naming_violation'
           , @test_stack.value(N'count(//no_primary_key_violation//violation)'
                               , N'[int]') as N'no_primary_key_violation count'
           , @test_stack.value(N'count(//no_identity_column_violation//violation)'
                               , N'[int]') as N'no_identity_column_violation count'
           , @test_stack.value(N'count(//no_unique_constraint_violation//violation)'
                               , N'[int]') as N'no_unique_constraint_violation count'
           , @test_stack
end;

--
-------------------------------------------------
begin
    select @sequence = 2
           , @test_name = N'incorrectly_configured_oltp_table'
           , @test_description = N'table is not configured correctly and should throw both violations and warnings.'
           , @return_code = 0
           , @schema = N'best_practice_analysis_test'
           , @object = N'invalid_table_01';

    set @object_fqn = N'[' + @schema + N'].[' + @object + N']';

    --
    -------------------------------------------------
    execute [dbo].[sp_get_best_practice_analysis]
      @object_fqn =@object_fqn,
      @status =N'force_refresh',
      @timestamp_output = 0,
      @output_as =N'html',
      @test_stack = @test_stack output;

    --
    -------------------------------------------------
    select @test_stack.value(N'count(//violation)'
                             , N'[int]')   as N'total violation count'
           , @test_stack.value(N'count(//warning)'
                               , N'[int]') as N'total warning count'
           , @test_stack.value(N'count(//test)'
                               , N'[int]') as N'total test count'
           , @test_stack.value(N'count(//missing_table_documentation_violation//violation)'
                               , N'[int]') as N'missing_table_documentation_violation count'
           , @test_stack.value(N'count(//missing_column_documentation_violation//violation)'
                               , N'[int]') as N'missing_column_documentation_violation count'
           , @test_stack.value(N'count(//primary_key_naming_violation//violation)'
                               , N'[int]') as N'primary_key_naming_violation'
           , @test_stack.value(N'count(//unique_constraint_naming_violation//violation)'
                               , N'[int]') as N'unique_constraint_naming_violation'
           , @test_stack.value(N'count(//no_primary_key_violation//violation)'
                               , N'[int]') as N'no_primary_key_violation count'
           , @test_stack.value(N'count(//no_identity_column_violation//violation)'
                               , N'[int]') as N'no_identity_column_violation count'
           , @test_stack.value(N'count(//no_unique_constraint_violation//violation)'
                               , N'[int]') as N'no_unique_constraint_violation count'
           , @test_stack
end; 
