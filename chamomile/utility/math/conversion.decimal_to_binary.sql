if schema_id(N'conversion') is null
  execute (N'create schema conversion');

go

if exists (select *
           from   [sys].[objects]
           where  [object_id] = OBJECT_ID(N'[conversion].[decimal_to_binary]')
                  and [type] in ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  drop function [conversion].[decimal_to_binary];

GO

-- select [conversion].[decimal_to_binary] (8);
-- Converting Between Base 2, 10 and 16 in T-SQL, Mark S. Rasmussen 
-- https://improve.dk/converting-between-base-2-10-and-16-in-t-sql/
-------------------------------------------------
create function [conversion].[decimal_to_binary] (@input bigint)
RETURNS varchar(255)
as
  begin
      declare @output nvarchar(255) = '';

      while @input > 0
        begin
            set @output = @output + CAST((@input % 2) as varchar);
            set @input = @input / 2;

        end

      return REVERSE(@output);

  end

go 
