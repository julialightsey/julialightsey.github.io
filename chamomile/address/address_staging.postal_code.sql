if schema_id(N'address_staging') is null
  execute (N'create schema address_staging');

go

if object_id(N'[address_staging].[postal_code]'
             , N'U') is not null
  drop table [address_staging].[postal_code];

go

--http://www.unitedstateszipcodes.org/zip-code-database/
create table [address_staging].[postal_code]
  (
     [zip]                    [nvarchar](max)
     , [type]                 [nvarchar](max)
     , [primary_city]         [nvarchar](max)
     , [acceptable_cities]    [nvarchar](max)
     , [unacceptable_cities]  [nvarchar](max)
     , [state]                [nvarchar](max)
     , [county]               [nvarchar](max)
     , [timezone]             [nvarchar](max)
     , [area_codes]           [nvarchar](max)
     , [latitude]             [nvarchar](max)
     , [longitude]            [nvarchar](max)
     , [world_region]         [nvarchar](max)
     , [country]              [nvarchar](max)
     , [decommissioned]       [nvarchar](max)
     , [estimated_population] [nvarchar](max)
     , [notes]                [nvarchar](max)
  );

go 
