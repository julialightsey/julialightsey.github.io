if schema_id(N'address') is null
  execute (N'create schema address');

go

if object_id(N'[address].[get_prototype]'
             , N'P') is not null
  drop procedure [address].[get_prototype];

go

/*
	Gets address data prototype. For ISO country codes see http://www.iso.org/iso/country_codes.htm

	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'US';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [US]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'MX';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [MX]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'BR';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [BR]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'CA';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [CA];  
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'CL';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [CL];   
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'DE';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [DE];
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'ES';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [ES]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'FR';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [FR]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'GB';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [GB]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'PE';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [PE]; 
	
	declare @ISOCountryCode [nchar](2), @Prototype xml([address__secure].[XSC]);
	set @ISOCountryCode=N'VG';
	execute [address].[get_prototype] @ISOCountryCode=@ISOCountryCode, @Prototype=@Prototype output;
	select @Prototype as [VG]; 
*/
create procedure [address].[get_prototype] @isocountrycode [nchar](2)
                                           , @prototype    xml([address__secure].[xsc]) output
as
  begin
      set @prototype = case lower(@isocountrycode)
                         when N'us' then N'<kelightsey:address_us_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business">
							  <street1 label="name" description="street number and name | po box | rural route | building" />
							  <street2 label="name" description="street number and name | po box | rural route | building" />
							  <city_state_postal_code label="name" description="city, state 11111 | 11111-1111" />
							  <country label="name" description="ISO country code | verbose name"></country>
							</kelightsey:address_us_01>'
                         when N'mx' then N'<kelightsey:address_mx_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street number and name | apartment number" />
							  <village label="name" description="quarter | village" />
							  <postal_code_locality_province label="name" description="postal code locality, province abbr." />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_mx_01>'
                         when N'br' then N'<kelightsey:address_br_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street name and number | po box | community mailbox | sector, quadra, block, floor" />
							  <district label="name" description="district" />
							  <town_state label="name" description="town state abbr." />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_br_01>'
                         when N'ca' then N'<kelightsey:address_ca_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street number and name | po box | postal installation" />
							  <site label="name" description="site, compartment, lot/concession number" />
							  <installation label="name" description="RR + route no. + name of postal installation  | installation" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_ca_01>'
                         when N'cl' then N'<kelightsey:address_cl_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street name | street number | rest of address | P.O. Box + name of post office" />
							  <postal_code_commune label="name" description="site, compartment, lot/concession number" />
							  <region label="name" description="RR + route no. + name of postal installation  | installation" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_cl_01>'
                         when N'de' then N'<kelightsey:address_de_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street name and No. // apartment No. | P.O Box number." />
							  <customer_number label="name" description="personal customer number (6-10 digits) " />
							  <parcel_machine_number label="name" description="“Packstation” + parcel machine number" />
							  <postal_code_locality label="name" description="postcode + locality" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_de_01>'
                         when N'es' then N'<kelightsey:address_es_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street, premise, stairwell, floor + door. | street, premise, floor + door | sub-locality | po box" />
							  <building label="name" description="building" />
							  <postal_code_locality label="name" description="“Packstation” + parcel machine number" />
							  <province label="name" description="postcode + locality" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_es_01>'
                         when N'fr' then N'<kelightsey:address_fr_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <unit label="name" description="unit, addressee" />
							  <street1 label="name" description="house number and street name" />
							  <delivery_point label="name" description="additional delivery point information" />
							  <geography label="name" description="additional geographical information" />
							  <hamlet label="name" description="hamlet name" />
							  <postal_code_locality label="name" description="postal code + locality | postcode and CEDEX delivery office | PO box number + locality (only if geographical locality differs from CEDEX delivery office)" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_fr_01>'
                         when N'gb' then N'<kelightsey:address_gb_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <part_of_building label="name" description="part of building" />
							  <building label="name" description="building name" />
							  <thoroughfare label="name" description="thoroughfare" />
							  <locality label="name" description="dependent locality" />
							  <postal_code label="name" description="postal code" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_gb_01>'
                         when N'pe' then N'<kelightsey:address_pe_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <street1 label="name" description="street, premise, sub-locality" />
							  <postal_code label="name" description="postal code" />
							  <province label="name" description="province" />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_pe_01>'
                         when N'vg' then N'<kelightsey:address_vg_01 xmlns:kelightsey="http://www.kelightsey.com/" address_type="business" >
							  <po_box label="name" description="P.O. Box number" />
							  <building_thoroughfare label="name" description="building number + thoroughfare" />
							  <post_town_postal_code label="name" description="post town + postcode " />
							  <country label="name" description="ISO country code | verbose name" />
							</kelightsey:address_vg_01>'
                         else null
                       end;
  end

go

grant execute on [address].[get_prototype] to kelightsey;

go 
