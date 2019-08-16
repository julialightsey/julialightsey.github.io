if schema_id(N'conversion') is null
  execute (N'create schema conversion');

go

if exists (select *
           from   [sys].[objects]
           where  [object_id] = OBJECT_ID(N'[conversion].[binary_to_decimal]')
                  and [type] in ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  drop function [conversion].[binary_to_decimal];

GO

-- select [conversion].[binary_to_decimal] (N'101');
-- Converting Between Base 2, 10 and 16 in T-SQL, Mark S. Rasmussen 
-- https://improve.dk/converting-between-base-2-10-and-16-in-t-sql/
-------------------------------------------------
create function [conversion].[binary_to_decimal] (@input varchar(255))
RETURNS bigint
as
  begin
      declare @count    tinyint = 1
              , @length tinyint = LEN(@input);
      declare @output bigint = CAST(SUBSTRING(@input, @length, 1) as bigint);

      while ( @count < @length )
        begin
            set @output = @output
                          + POWER(CAST(SUBSTRING(@input, @length - @count, 1) * 2 as bigint), @count);
            set @count = @count + 1;
        end;

      return @output;
  end;

GO 
