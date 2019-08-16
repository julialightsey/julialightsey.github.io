use [chamomile];

go

if schema_id(N'math') is null
  execute (N'create schema math');

go

if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];

go

create function [math].[divide] (@numerator     [int]
                                 , @denominator [int]
)
returns [decimal](10, 6)
as
  begin
      declare @return [decimal](10, 6);

      if @numerator is null
          or @denominator is null
          or @denominator = 0
        set @return = 0;
      else
        set @return = Round(Cast (@numerator as [float]) / Cast(@denominator as [float]), 6);

      return @return;
  end;

go 
