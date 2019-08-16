use [chamomile];

go

if object_id(N'[utility].[strip_lead_and_lag]'
             , N'FN') is not null
  drop function [utility].[strip_lead_and_lag];

go

/*
	declare @expected [nvarchar](max) = N'this].[and].[that';
    declare @return [nvarchar](max) = (select [utility].[strip_lead_and_lag](N'[this].[and].[that]', N'[', N']'));
    if @return = @expected
      select N'pass'
             , @return
             , N'-' + @return + N'-';
    else
      select N'fail'
             , @return
             , N'-' + @return + N'-';
    --
    set @return = (select [utility].[strip_lead_and_lag](N'[this].[and].[that ', N'[', N' '));
    if @return = @expected
      select N'pass'
             , @return
             , N'-' + @return + N'-';
    else
      select N'fail'
             , @return
             , N'-' + @return + N'-';
    --
    set @return = (select [utility].[strip_lead_and_lag](N'.[this].[and].[that .', N'.[', N' .'));
    if @return = @expected
      select N'pass'
             , @return
             , N'-' + @return + N'-';
    else
      select N'fail'
             , @return
             , N'-' + @return + N'-';
    --
    set @return = (select [utility].[strip_lead_and_lag](N'strip_methis].[and].[thatlose this', N'strip_me', N'lose this'));
    if @return = @expected
      select N'pass'
             , @return
             , N'-' + @return + N'-';
    else
      select N'fail'
             , @return
             , N'-' + @return + N'-';
*/
create function [utility].[strip_lead_and_lag] (@input  [nvarchar](max)
                                                , @lead [sysname]
                                                , @lag  [sysname])
returns [nvarchar](max)
as
  begin
      declare @return      [nvarchar](max),
              @lag_length  [int] = datalength(@lag) / 2,
              @lead_length [int] = datalength (@lead) / 2,
              @lag_mark    [int] = ( datalength(@input) - datalength(@lag) ) / 2;

      if charindex(@lead
                   , @input
                   , 0) = 1
        set @return = substring(@input
                                , @lead_length + 1
                                , datalength(@input) / 2);

      if charindex(@lag
                   , @input
                   , @lag_mark) > 0
        set @return = substring(@return
                                , 0
                                , ( ( datalength(@return) - datalength(@lag) ) / 2 ) + 1);

      return @return;
  end;

go 
