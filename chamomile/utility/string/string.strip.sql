USE [utility]
GO

EXEC sys.sp_dropextendedproperty @name=N'revision_20140706' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_dropextendedproperty @name=N'revision_20140527' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_dropextendedproperty @name=N'execute_as' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_dropextendedproperty @name=N'description' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_dropextendedproperty @name=N'description' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@remove'
GO

EXEC sys.sp_dropextendedproperty @name=N'description' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@filter'
GO

EXEC sys.sp_dropextendedproperty @name=N'description' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@input'
GO
 
DROP FUNCTION [utility].[strip__string]
GO 


/* 
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	declare @schema   [sysname] = N'utility'
			, @object [sysname] = N'strip__string';
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
create function [utility].[strip__string](@input  [nvarchar](max),
                                          @filter [sysname],
                                          @prefix [sysname],
                                          @remove [bit] = 0)
returns [nvarchar](max)
as
  begin
      --
      -- handle prefix ignore
      --------------------------------------------------------------------
      if ( substring(@input, 0, len(@prefix) + 1) = @prefix )
        set @input = substring(@input, len(@prefix) + 1, len(@input));

      --
      -- if (@remove = 1) remove characters from @input that exist in @filter
      -- if (@remove = 0) leave only characters from @input that exist in @filter
      --------------------------------------------------------------------
      if ( @remove = 1 )
        set @filter = '%[' + @filter + ']%'
      else
        set @filter = N'%[^' + @filter + N']%';

      --
      --------------------------------------------------------------------
      while patindex(@filter, @input) > 0
        set @input = stuff(@input, patindex(@filter, @input), 1, '');

      --
      -- replace prefix if required
      --------------------------------------------------------------------
      if ( @prefix is not null )
        set @input=@prefix + @input;

      return @input;
  end

GO

EXEC sys.sp_addextendedproperty @name=N'description', @value=N'@input [nvarchar](max) - the input string that is strip__stringped to only the 
		characters in @filter or with only the filter characters remaining dependent upon 
		the setting for @remove.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@input'
GO

EXEC sys.sp_addextendedproperty @name=N'description', @value=N'@filter [sysname] - the input filter which includes all the characters 
		that will be allowed in the output.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@filter'
GO

EXEC sys.sp_addextendedproperty @name=N'description', @value=N'@remove [bit]=0 - if default (0), the filter characters are the only characters 
	remaining in the input string. If set to 1, the filter characters are removed from the input string.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string', @level2type=N'PARAMETER',@level2name=N'@remove'
GO

EXEC sys.sp_addextendedproperty @name=N'description', @value=N'If (@remove = 1) remove characters from @input that exist in @filter. 
	If (@remove = 0) leave only characters from @input that exist in @filter. Review the 
		test cases thoroughly. The regular expression functionality in Transact SQL is 
		very limited, and some characters must be in certain order!' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_addextendedproperty @name=N'execute_as', @value=N'see [utility_test].[strip__string] for sample cases.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_addextendedproperty @name=N'revision_20140527', @value=N'Katherine E. Lightsey - streamlined code.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO

EXEC sys.sp_addextendedproperty @name=N'revision_20140706', @value=N'Katherine E. Lightsey - created.' , @level0type=N'SCHEMA',@level0name=N'utility', @level1type=N'FUNCTION',@level1name=N'strip__string'
GO


