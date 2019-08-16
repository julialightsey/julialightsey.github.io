if schema_id(N'address') is null
  execute (N'create schema address');

go

if exists (select *
           from   sys.xml_schema_collections c,
                  sys.schemas s
           where  c.schema_id = s.schema_id
                  and ( QUOTENAME(s.name) + '.' + QUOTENAME(c.name) ) = N'[address].[xsc]')
  drop xml schema collection [address].[xsc];

go

/*
	Katherine E. Lightsey
	20140313

	The XML Schema Collection used to type Address data. For ISO country codes see http://www.iso.org/iso/country_codes.htm
*/
if not exists (select *
               from   sys.xml_schema_collections c,
                      sys.schemas s
               where  c.schema_id = s.schema_id
                      and ( QUOTENAME(s.name) + '.' + QUOTENAME(c.name) ) = N'[address].[xsc]')
  create xml schema collection [address].[xsc] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:KELightsey="http://www.nKELightsey.com/" targetNamespace="http://www.nKELightsey.com/" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" attributeFormDefault="qualified" elementFormDefault="qualified">
  
	<!-- -->
	<!-- BR -->
	<xsd:element name="address_br_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="district" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="town_state" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- CA -->
	<xsd:element name="address_ca_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="site" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="installation" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- CL -->
	<xsd:element name="address_cl_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="postal_code_commune" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="region" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- DE -->
	<xsd:element name="address_de_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="customer_number" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="parcel_machine_number" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="postal_code_locality" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- ES -->
	<xsd:element name="address_es_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="building" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="postal_code_locality" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="province" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- FR -->
	<xsd:element name="address_fr_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="unit" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="delivery_point" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="geography" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="hamlet" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="postal_code_locality" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
	
	<!-- -->
	<!-- GB -->
	<xsd:element name="address_gb_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="part_of_building" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="building" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="thoroughfare" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="locality" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="postal_code" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
  
	<!-- -->
	<!-- MX -->
	<xsd:element name="address_mx_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="village" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="postal_code_locality_province" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="city_state_postal_code_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
  
	<!-- -->
	<!-- PE -->
	<xsd:element name="address_pe_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="postal_code" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="province" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>

	<!-- -->
	<!-- US -->
	<xsd:element name="address_us_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="street1" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="street2" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street2_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="city_state_postal_code" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="city_state_postal_code_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>
  
	<!-- -->
	<!-- VG -->
	<xsd:element name="address_vg_01" msdata:Prefix="KELightsey">
	<xsd:complexType>
	
		<xsd:sequence>

		<xsd:element name="po_box" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="building_thoroughfare" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>

		<xsd:element name="post_town_postal_code" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="street1_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		<xsd:element name="country" form="unqualified" nillable="true">
			<xsd:complexType>
			<xsd:simpleContent msdata:ColumnName="country_Text" msdata:Ordinal="1">
				<xsd:extension base="xsd:string">
				<xsd:attribute name="label" form="unqualified" type="xsd:string" />
				<xsd:attribute name="description" form="unqualified" type="xsd:string" />
				</xsd:extension>
			</xsd:simpleContent>
			</xsd:complexType>
		</xsd:element>
		
		</xsd:sequence>
		<xsd:attribute name="address_type" form="unqualified" type="xsd:string" />
	</xsd:complexType>
	</xsd:element>

</xsd:schema>';

go

grant execute on xml schema collection::[address].[xsc] to kelightsey;
go 
