if object_id(N'[address_secure].[postal_code]'
             , N'U') is not null
  drop table [address_secure].[postal_code];

go

set ansi_nulls on;

go

set quoted_identifier on;

go

create table [address_secure].[postal_code]
  (
     [zip]                    [nvarchar](max) null
     , [type]                 [nvarchar](max) null
     , [primary_city]         [nvarchar](max) null
     , [acceptable_cities]    [nvarchar](max) null
     , [unacceptable_cities]  [nvarchar](max) null
     , [state]                [nvarchar](max) null
     , [county]               [nvarchar](max) null
     , [timezone]             [nvarchar](max) null
     , [area_codes]           [nvarchar](max) null
     , [latitude]             [nvarchar](max) null
     , [longitude]            [nvarchar](max) null
     , [world_region]         [nvarchar](max) null
     , [country]              [nvarchar](max) null
     , [decommissioned]       [nvarchar](max) null
     , [estimated_population] [nvarchar](max) null
     , [notes]                [nvarchar](max) null
  );

go 
