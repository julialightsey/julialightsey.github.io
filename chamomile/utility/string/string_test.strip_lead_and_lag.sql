use [chamomile];

go

if object_id(N'[utility_test].[strip_lead_and_lag]'
             , N'P') is not null
  drop procedure [utility_test].[strip_lead_and_lag];

go

/*
	declare @stack [xml];
	execute  [utility_test].[strip_lead_and_lag] @stack=@stack output;
	select @stack;
*/
create procedure [utility_test].[strip_lead_and_lag] @stack [xml] output
as
  begin
      declare @test_stack     [xml] = N'<test_stack test_count="0" pass_count="0" error_count="0" />',
              @test_prototype [xml]=N'<test test_sequence="0" test_name="replace_me" actual="fail">
					<input />
					<output />
					<expected />
				</test>',
              @test_name      [sysname],
              @lead           [sysname],
              @lag            [sysname],
              @test_sequence  [int],
              @count          [int],
              @test           [xml],
              @return         [nvarchar](max),
              @pass           [sysname] = N'pass',
              @input          [nvarchar](max),
              @expected       [nvarchar](max);

      --
      -------------------------------------------
      begin
          select @test_name = N'[test_bracketed_string]'
                 , @test_sequence = 1
                 , @input = N'[this].[and].[that]'
                 , @expected = N'this].[and].[that'
                 , @lead = N'['
                 , @lag = N']'
                 , @test = @test_prototype;

          --
          set @test.modify(N'insert text {sql:variable("@input")} as last into (/*/input)[1]');
          set @test.modify(N'insert text {sql:variable("@expected")} as last into (/*/expected)[1]');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          --
          set @return = (select [utility].[strip_lead_and_lag](@input
                                                               , @lead
                                                               , @lag));
          set @test.modify(N'insert text {sql:variable("@return")} as last into (/*/output)[1]');

          if @return = @expected
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      begin
          select @test_name = N'[test_lead_bracketed_string_with_trailing_space]'
                 , @test_sequence = 2
                 , @input = N'[this].[and].[that '
                 , @expected = N'this].[and].[that'
                 , @lead = N'['
                 , @lag = N' '
                 , @test = @test_prototype;

          --
          set @test.modify(N'insert text {sql:variable("@input")} as last into (/*/input)[1]');
          set @test.modify(N'insert text {sql:variable("@expected")} as last into (/*/expected)[1]');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          --
          set @return = (select [utility].[strip_lead_and_lag](@input
                                                               , @lead
                                                               , @lag));
          set @test.modify(N'insert text {sql:variable("@return")} as last into (/*/output)[1]');

          if @return = @expected
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      begin
          select @test_name = N'[test_lead_bracketed_string_with_multiple_trailing_spaces]'
                 , @test_sequence = 3
                 , @input = N'[this].[and].[that   '
                 , @expected = N'this].[and].[that'
                 , @lead = N'['
                 , @lag = N'   '
                 , @test = @test_prototype;

          --
          set @test.modify(N'insert text {sql:variable("@input")} as last into (/*/input)[1]');
          set @test.modify(N'insert text {sql:variable("@expected")} as last into (/*/expected)[1]');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          --
          set @return = (select [utility].[strip_lead_and_lag](@input
                                                               , @lead
                                                               , @lag));
          set @test.modify(N'insert text {sql:variable("@return")} as last into (/*/output)[1]');

          if @return = @expected
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      begin
          select @test_name = N'[test_lead_bracketed_string_with_complex_trailing]'
                 , @test_sequence = 4
                 , @input = N'[this].[and].[that remove this'
                 , @expected = N'this].[and].[that'
                 , @lead = N'['
                 , @lag = N' remove this'
                 , @test = @test_prototype;

          --
          set @test.modify(N'insert text {sql:variable("@input")} as last into (/*/input)[1]');
          set @test.modify(N'insert text {sql:variable("@expected")} as last into (/*/expected)[1]');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          --
          set @return = (select [utility].[strip_lead_and_lag](@input
                                                               , @lead
                                                               , @lag));
          set @test.modify(N'insert text {sql:variable("@return")} as last into (/*/output)[1]');

          if @return = @expected
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      begin
          select @test_name = N'[test_bracketed_string_with_multiple_leading_spaces]'
                 , @test_sequence = 5
                 , @input = N'  this].[and].[that]'
                 , @expected = N'this].[and].[that'
                 , @lead = N'  '
                 , @lag = N']'
                 , @test = @test_prototype;

          --
          set @test.modify(N'insert text {sql:variable("@input")} as last into (/*/input)[1]');
          set @test.modify(N'insert text {sql:variable("@expected")} as last into (/*/expected)[1]');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
          --
          set @return = (select [utility].[strip_lead_and_lag](@input
                                                               , @lead
                                                               , @lag));
          set @test.modify(N'insert text {sql:variable("@return")} as last into (/*/output)[1]');

          if @return = @expected
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      ----------------------------------------------
      set @count=@test_stack.value(N'count (/*/test)'
                                   , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count=@test_stack.value(N'count (/*/test[@actual="pass"])'
                                   , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      set @count=@test_stack.value(N'count (/*/test[@actual="fail"])'
                                   , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      --
      set @stack = @test_stack;
  end;

go 
