use [chamomile];

go
-- http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions/ProductModelManuInstructions.xsd
-- https://docs.microsoft.com/en-us/sql/t-sql/xml/replace-value-of-xml-dml?view=sql-server-2017


if schema_id(N'Production') is null
  execute (N'create schema Production');

go
if object_id(N'[test].[production_schema]', N'U') is not null
  drop table [test].[production_schema];

go


if exists (select [xml_collection_id]
           from   sys.[xml_schema_collections] as [xsc]
           where  [xsc].name = 'ManuInstructionsSchemaCollection'
                  and [xsc].[schema_id] = schema_id(N'Production'))
  drop xml schema collection [Production].[ManuInstructionsSchemaCollection];

go
--select xml_schema_namespace(N'Production',N'ManuInstructionsSchemaCollection');
create xml schema collection [Production].[ManuInstructionsSchemaCollection] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="https://github.com/KELightsey/chamomile" targetNamespace="https://github.com/KELightsey/chamomile" elementFormDefault="qualified">

  <xsd:element name="test_stack">
    <xsd:complexType mixed="true">
      <xsd:complexContent mixed="true">
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="description" type="xsd:string" />
            <xsd:element name="test" type="chamomile:test_complex_type" minOccurs="0" maxOccurs="unbounded" />
            <xsd:element name="test3" type="chamomile:test3_complex_type" minOccurs="0" maxOccurs="unbounded" />

            <xsd:element name="test2" maxOccurs="unbounded">
              <xsd:complexType mixed="true">
                <xsd:complexContent mixed="true">
                  <xsd:restriction base="xsd:anyType">
                    <xsd:sequence>
                      <xsd:element name="step" type="chamomile:any_complex_type" maxOccurs="unbounded" />
                    </xsd:sequence>
                    <xsd:attribute name="LocationID" type="xsd:integer" use="required" />
                    <xsd:attribute name="SetupHours" type="xsd:decimal" />
                    <xsd:attribute name="MachineHours" type="xsd:decimal" />
                    <xsd:attribute name="LaborHours" type="xsd:decimal" />
                    <xsd:attribute name="LotSize" type="xsd:decimal" />
                  </xsd:restriction>
                </xsd:complexContent>
              </xsd:complexType>
            </xsd:element>

          </xsd:sequence>
          <xsd:attribute name="name" type="xsd:string" use="required" />
          <xsd:attribute name="test_count" type="xsd:int" use="required" />
          <xsd:attribute name="pass_count" type="xsd:int" use="required" />
          <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
          <xsd:anyAttribute processContents="lax" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>

	<xsd:complexType name="test3_complex_type" mixed="true">
	<xsd:complexContent mixed="true">
		<xsd:restriction base="xsd:anyType">
		<xsd:sequence>
			<xsd:element name="step" type="chamomile:any_complex_type" maxOccurs="unbounded" />
		</xsd:sequence>
		<xsd:attribute name="LocationID" type="xsd:integer" use="required" />
		<xsd:attribute name="SetupHours" type="xsd:decimal" />
		<xsd:attribute name="MachineHours" type="xsd:decimal" />
		<xsd:attribute name="LaborHours" type="xsd:decimal" />
		<xsd:attribute name="LotSize" type="xsd:integer" />
		<xsd:attribute name="pass" type="xsd:string" />
		</xsd:restriction>
	</xsd:complexContent>
	</xsd:complexType>

  <xsd:complexType name="any_complex_type" mixed="true">
    <xsd:complexContent mixed="true">
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:any processContents="lax" minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
        <xsd:anyAttribute processContents="lax" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>

  <xsd:complexType name="test_complex_type" mixed="true">
    <xsd:complexContent mixed="true">
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="description" type="xsd:string" />
          <xsd:element name="test_detail" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
        <xsd:attribute name="name" type="xsd:string" use="required" />
        <xsd:attribute name="pass" type="xsd:string" use="required" />
        <xsd:attribute name="LotSize" type="xsd:decimal" />
        <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
       <!-- <xsd:anyAttribute processContents="lax" />-->
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>

</xsd:schema>'; 
go


if exists (select [xml_collection_id]
           from   sys.[xml_schema_collections] as [xsc]
           where  [xsc].name = 'xsc_test'
                  and [xsc].[schema_id] = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[xsc_test];

go
--select xml_schema_namespace(N'chamomile',N'xsc_test');
create xml schema collection [chamomile].[xsc_test] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="https://github.com/KELightsey/chamomile" targetNamespace="https://github.com/KELightsey/chamomile" elementFormDefault="qualified">

  <xsd:element name="test">
    <xsd:complexType mixed="true">
      <xsd:complexContent mixed="true">
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="description" type="xsd:string" />
            <xsd:element name="detail" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />

          </xsd:sequence>
          <xsd:attribute name="name" type="xsd:string" use="required" />
        <xsd:attribute name="pass" type="xsd:string" use="required" />
        <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
          <xsd:anyAttribute processContents="lax" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>


  <xsd:complexType name="any_complex_type" mixed="true">
    <xsd:complexContent mixed="true">
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:any processContents="lax" minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
        <!-- <xsd:anyAttribute processContents="lax" /> -->
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>


</xsd:schema>'; 

go

declare @test [xml]([chamomile].[xsc_test]) = N'
	 <chamomile:test xmlns:chamomile="https://github.com/KELightsey/chamomile" name="validate_age_calculation_born_today" pass="true" timestamp="2018-06-24T15:50:19.3466667" date_of_birth="1998-06-24" expected_age="20" returned_age="20">
	   <chamomile:description>This test validates that, for a person born today, the age calculate will return the correct age.</chamomile:description>
	 </chamomile:test>';

go