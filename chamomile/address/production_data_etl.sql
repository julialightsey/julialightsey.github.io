use [test_01]

go

with [address_builder]
     as (select [address].[addressid]                                  as [address_id]
                , [address_type].[addresstypename]                     as [address_type]
                , [address].[streetname]                               as [street1]
                , convert([sysname], [address].[outsideaddressnumber]) as [outside_address_number]
                , convert([sysname], [address].[insideaddressnumber])  as [inside_address_number]
                , [address].[betweenstreets]                           as [between_streets]
                , [state].[statecode]                                  as [state]
                , [township].[townshipname]                            as [township_name]
                , [suburb].[suburbname]                                as [suburb_name]
                , [city].[cityname]                                    as [city]
                , [postal_zone].[postalzone]                           as [postal_code]
                , [country].[majorregioncode]                          as [country]
         --[address_purpose_type].[AddressPurposeTypeName]
         --[address].[PartyID],
         --[address].[PartyRoleID],
         --[address].[PreferredMethodOfContact]
         from   [dbo].[address] as [address]
                left join [dbo].[addresstype] as [address_type]
                       on [address_type].[addresstypeid] = [address].[addresstypeid]
                left join [dbo].[country] as [country]
                       on [country].[isocountrycode] = [address].[countrycode]
                left join [dbo].[state] as [state]
                       on [state].[stateid] = [address].[stateid]
                left join [dbo].[city] as [city]
                       on [city].[cityid] = [address].[cityid]
                left join [dbo].[postalzone] as [postal_zone]
                       on [postal_zone].[postalzoneid] = [address].[postalzoneid]
                left join [dbo].[addresspurposetype] as [address_purpose_type]
                       on [address_purpose_type].[addresspurposetypeid] = [address].[addresspurposetypeid]
                left join [dbo].[township] as [township]
                       on [township].[townshipid] = [address].[townshipid]
                left join [dbo].[suburb] as [suburb]
                       on [suburb].[suburbid] = [address].[suburbid])
insert into [address__secure].[data]
            ([id],
             [entry])
select [address_id] as [id]
       , case
           when ( [township_name] is null )
         --
--begin_no_format
       then convert([xml], N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="'
                           + isnull([address_type], N'') + N'" >'
                           + N'<street1>' + isnull([street1], N'') + N'</street1>'
						   + N'<quarter>' + isnull([township_name], N'') + N'</quarter>'
                           + N'<postal_code_locality_province>'
							   + isnull([postal_code] + N', ', N'')
							   + isnull([city] + N', ', N'')
							   + isnull([state], N'')
                           + N'</postal_code_locality_province>'
                           + N'<country>' + isnull([country], N'') + N'</country>'
                           + N'</kelightsey:address_mexico_01>')
         else convert([xml], N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="' + isnull([address_type], N'') + N'" >'
                             + N'<street1>' + isnull([street1], N'') + N'</street1>'
							 + N'<village>' + isnull([suburb_name], N'') + N'</village>'
                             + N'<postal_code_locality_province>'
								 + isnull([postal_code] + N', ', N'')
								 + isnull([city] + N', ', N'')
								 + isnull([state], N'')
                             + N'</postal_code_locality_province>'
                             + N'<country>' + isnull([country], N'') + N'</country>'
                             + N'</kelightsey:address_mexico_01>')
       end as [entry]
	   --end_no_format

from   [address_builder];

/*
	Urión 30					street number and name 
	Col. Tlatilco				name of quarter (colonia) 
	02860 MEXICO, D.F.			postcode + locality name, province abbrev. 
	MEXICO

	Super Manzana 3 – 403		street number and name – apartment no. 
	Puerto Juarez				village 
	77520 CANCUN, Q. ROO		postcode + locality name, province abbrev. 
	MEXICO
*/
declare @example_01_pdf xml = N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
	<!-- street number and name -->
	<street1>Urión 30</street1>
	<!-- name of quarter (colonia) -->
	<quarter>Col. Tlatilco</quarter>
	<!-- postcode + locality name, province abbrev. -->
	<postal_code>77520 MEXICO, D.F.</postal_code>
	<country>MEXICO</country>
</kelightsey:address_mexico_01>';
declare @example_01_gbm xml = N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
</kelightsey:address_mexico_01>';
declare @example_02_pdf xml = N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
	<!-- street number and name – apartment no. -->
	<street1>Super Manzana 3 – 40</street1>
	<!-- village -->
	<village>Puerto Jaurez</village>
	<!-- postcode + locality name, province abbrev. -->
	<postal_code>77520 CANCUN, Q. ROO</postal_code>
	<country>Mexico</country>
</kelightsey:address_mexico_01>';
declare @example_02_gbm xml = N'<kelightsey:address_mexico_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
</kelightsey:address_mexico_01>';

select @example_01_pdf
       , @example_02_pdf; 
