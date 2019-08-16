USE [utility]
GO

/****** Object:  UserDefinedFunction [utility].[scrub__data]    Script Date: 3/28/2019 10:52:40 AM ******/
DROP FUNCTION [utility].[scrub__data]
GO

/****** Object:  UserDefinedFunction [utility].[scrub__data]    Script Date: 3/28/2019 10:52:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
	select [utility].[scrub__data](N'Bad! to the BONE---', N'data__scrub.template.alphanumeric_with_dash');
*/
create function [utility].[scrub__data](@input      [nvarchar](512)
                                        , @template [nvarchar](450))
returns [nvarchar](512)
as
  begin;
      declare @alphanumeric [sysname] = [utility].[get__metadata](@template)
              , @return     [nvarchar](512) = @input ;

      while patindex(@alphanumeric, @return) > 0
        set @return = stuff(@return, patindex(@alphanumeric, @return), 1, '');

      return @return;
  end;

GO


