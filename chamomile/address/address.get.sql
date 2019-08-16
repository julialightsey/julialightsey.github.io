if schema_id(N'address') is null
  execute (N'create schema address');

go

if object_id(N'[address].[get]'
             , N'P') is not null
  drop procedure [address].[get];

go

create procedure [address].[get] @id [int] = null
as
  begin
      select [id]
             , [entry]
      from   [address_secure].[data]
      where  ( @id = [id] )
              or ( @id is null );
  end;

go

grant execute on [address].[get] to kelightsey;

go 
