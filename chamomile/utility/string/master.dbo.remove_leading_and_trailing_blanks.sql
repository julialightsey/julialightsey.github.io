use [master];

go

if object_id(N'[dbo].[sp_remove_leading_and_trailing_blanks]', N'FN') is not null
  drop function [dbo].[sp_remove_leading_and_trailing_blanks];

go

/*
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	declare @schema   [sysname] = N'dbo'
			, @object [sysname] = N'sp_remove_leading_and_trailing_blanks';
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

create function [sp_remove_leading_and_trailing_blanks](@input                        [nvarchar](max)
                                                              , @return_null_on_zero_length [bit])
returns [nvarchar](max)
as
  begin
      declare @output               [nvarchar](max)
              , @whitespace_pattern as nvarchar(100) = N'%[^' + nchar( 0x0020 ) + nchar( 0x00A0 )
                + nchar( 0x1680 ) + nchar( 0x2000 ) + nchar( 0x2001 )
                + nchar( 0x2002 ) + nchar( 0x2003 ) + nchar( 0x2004 )
                + nchar( 0x2005 ) + nchar( 0x2006 ) + nchar( 0x2007 )
                + nchar( 0x2008 ) + nchar( 0x2009 ) + nchar( 0x200A )
                + nchar( 0x202F ) + nchar( 0x205F ) + nchar( 0x3000 )
                + nchar( 0x2028 ) + nchar( 0x2029 ) + nchar( 0x0009 )
                + nchar( 0x000A ) + nchar( 0x000B ) + nchar( 0x000C )
                + nchar( 0x000D ) + nchar( 0x0085 ) + N']%';

      --
      set @return_null_on_zero_length = coalesce(@return_null_on_zero_length, 1);

      --
      with [counter]
           as (select @input                                               as [input]
                      , DataLength(@input) / DataLength(nchar(42))         as [input_length]
                      , PatIndex(@whitespace_pattern, @input) - 1          as [left_whitespace_count]
                      , PatIndex(@whitespace_pattern, Reverse(@input)) - 1 as [right_whitespace_count])
         , [trimmer]
           as (select case
                        when [input] is null then null
                        when @return_null_on_zero_length = 1
                             and len([input]) = 0 then null
                        when [left_whitespace_count] = -1 then N''
                        else Substring([input], [left_whitespace_count] + 1, [input_length] - [left_whitespace_count] - [right_whitespace_count])
                      end as [trimmed_string]
               from   [counter])
      select @output = [trimmed_string]
      from   [trimmer];

      --
      return @output;
  end;

go

exec [sp_MS_marksystemobject]
  N'sp_remove_leading_and_trailing_blanks';

go

exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'Removes leading and trailing blanks from the input string. Built from example re: https://stackoverflow.com/questions/35245812/whats-a-good-way-to-trim-all-whitespace-characters-from-a-string-in-t-sql-witho/35247507#35247507.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'function'
  , @level1name = N'sp_remove_leading_and_trailing_blanks';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'declare @return_null_on_zero_length [bit] = 0, @input [nvarchar](max) = N'' ''; 
select N''->'' + [master].[dbo].[sp_remove_leading_and_trailing_blanks](@input, @return_null_on_zero_length) + N''<-'';
select N''->'' + [master].[dbo].[sp_remove_leading_and_trailing_blanks](@input, null) + N''<-'';'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'function'
  , @level1name = N'sp_remove_leading_and_trailing_blanks';

go 
