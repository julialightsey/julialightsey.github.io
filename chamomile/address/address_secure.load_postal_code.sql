insert into [address_secure].[postal_code]
            ([iso_country_code],
             [postal_code],
             [place_name],
             [state_01],
             [state_02],
             [county_province_01],
             [county_province_02],
             [community_01],
             [community_02],
             [latitude],
             [longitude],
             [accuracy])
select [country_code]
       , [postal_code]
       , [place_name]
       , [admin_name1]
       , [admin_code1]
       , [admin_name2]
       , [admin_code2]
       , [admin_name3]
       , [admin_code3]
       , [latitude]
       , [longitude]
       , [accuracy]
from   [address_staging].[postal_code]

go 
