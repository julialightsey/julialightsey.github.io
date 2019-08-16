if schema_id(N'address_secure') is null
  execute (N'create schema address_secure');

go

if object_id(N'[address_secure].[load]'
             , N'P') is not null
  drop procedure [address_secure].[load];

go

create procedure [address_secure].[load] @id      [int] = null output
                                         , @entry xml ([address_secure].[xsc])
as
  begin
      declare @output as table
        (
           [action] [sysname]
           , [id]   [int]
        );

      merge into [address_secure].[data] as target
      using (select @id      as [id]
                    , @entry as [entry]) as source
      on target.[id] = source.[id]
      when matched then
        update set target.[entry] = source.[entry]
      when not matched then
        insert ([entry])
        values ([entry])
      output $action
             , isnull(inserted.[id]
                    , deleted.[id])
      into @output ([action], [id]);

      set @id = (select top(1) [id]
                 from   @output);
  end

go

grant execute on [address_secure].[load] to kelightsey;

go 
