if schema_id(N'address') is null
  execute (N'create schema address');

go

if object_id(N'[address].[set]'
             , N'P') is not null
  drop procedure [address].[set];

go

create procedure [address].[set] @address_01    [nvarchar](max)
                                 , @address_02  [nvarchar](max) = null
                                 , @city        [nvarchar](max)
                                 , @state       [nvarchar](max)
                                 , @postal_code [nvarchar](128)
as
  begin
      insert into [address_secure].[data]
                  ([address_01],
                   [address_02],
                   [city],
                   [state],
                   [postal_code])
      values      ( @address_01,
                    @address_02,
                    @city,
                    @state,
                    @postal_code);
  end

go 
