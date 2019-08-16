/*
	Katherine E. Lightsey
	20140313

	Rollback script for Address objects installation
*/
declare @error_count [int] = 0,
        @error_tree  [xml]= N'<error_tree />',
        @error       [xml];

--
-- [Address].[GetPrototype]
---------------------------------------------------------------------------------------------------
begin try
    if object_id(N'[Address].[GetPrototype]'
                 , N'P') is not null
      drop procedure [address].[getprototype];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address__secure].[Load]
---------------------------------------------------------------------------------------------------
begin try
    if object_id(N'[Address__secure].[Load]'
                 , N'P') is not null
      drop procedure [address__secure].[load];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address__secure].[Get]
---------------------------------------------------------------------------------------------------
begin try
    if object_id(N'[Address__secure].[Get]'
                 , N'P') is not null
      drop procedure [address__secure].[get];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address].[Data]
---------------------------------------------------------------------------------------------------
begin try
    if object_id(N'[Address].[Data]'
                 , N'V') is not null
      drop view [address].[data];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address__secure].[Data]
---------------------------------------------------------------------------------------------------
begin try
    if exists (select *
               from   [sys].[objects]
               where  [object_id] = object_id(N'[Address__secure].[Data]')
                      and [type] in ( N'U' ))
      drop table [address__secure].[data];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address__secure].[XSC]
---------------------------------------------------------------------------------------------------
begin try
    if exists (select *
               from   sys.xml_schema_collections c
                      , sys.schemas s
               where  c.schema_id = s.schema_id
                      and ( quotename(s.name) + '.' + quotename(c.name) ) = N'[Address__secure].[XSC]')
      drop xml schema collection [address__secure].[xsc];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address__secure]
---------------------------------------------------------------------------------------------------
begin try
    if exists(select *
              from   sys.schemas
              where  name = N'Address__secure')
      drop schema [address__secure];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- [Address]
---------------------------------------------------------------------------------------------------
begin try
    if exists(select *
              from   sys.schemas
              where  name = N'Address')
      drop schema [address];
end try

begin catch
    set @error_count = @error_count + 1;
    set @error = N'<error>' + error_message() + N'</error>';
    set @error_tree.modify(N'insert sql:variable("@error") as last into (/*)[1]');
end catch

--
-- Report
---------------------------------------------------------------------------------------------------
if ( @error_count > 0 )
  select @error_tree as [error_tree];
else
  select N'all objects successfully dropped'; 
