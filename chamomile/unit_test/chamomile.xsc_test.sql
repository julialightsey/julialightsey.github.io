use [chamomile];

go
if schema_id(N'chamomile') is null
  execute (N'create schema chamomile');

go

if exists (select [xml_collection_id]
           from   sys.[xml_schema_collections] as [xsc]
           where  [xsc].name = 'xsc_test'
                  and [xsc].[schema_id] = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[xsc_test];

go

create xml schema collection [chamomile].[xsc_test] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="http://www.chamomilesql.com/" targetNamespace="http://www.chamomilesql.com/">
  <xsd:element name="test">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
        <xsd:element name="test_detail" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
      </xsd:sequence>
      <xsd:attribute name="test_name" type="xsd:string" use="required" />
      <xsd:attribute name="pass" type="xsd:string" use="required" />
      <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
	 <xsd:anyAttribute processContents="lax" />
    </xsd:complexType>
  </xsd:element>
	
	<xsd:complexType name="any_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
</xsd:schema>';

go 
declare @test [xml]([chamomile].[xsc_test]) = N'
	 <chamomile:test xmlns:chamomile="http://www.chamomilesql.com/" test_name="validate_age_calculation_born_today" pass="true" timestamp="2018-06-24T15:50:19.3466667" date_of_birth="1998-06-24" expected_age="20" returned_age="20">
	   <description>This test validates that, for a person born today, the age calculate will return the correct age.</description>
	 </chamomile:test>';

go 
declare @test [xml]([chamomile].[xsc_test]) = N'
	 <chamomile:test xmlns:chamomile="http://www.chamomilesql.com/" test_name="validate_age_calculation_born_today" pass="true" timestamp="2018-06-24T15:50:19.3466667" date_of_birth="1998-06-24" expected_age="20" returned_age="20">
	   <description>This test validates that, for a person born today, the age calculate will return the correct age.</description>
	   <test_detail>
		  <any_valid_xml_goes_here />
	   </test_detail>
	 </chamomile:test>';

go 
/*
    <test_stack name="[chamomile].[person_test].[get_age]" test_count="2" pass_count="2" timestamp="2018-06-24T15:50:19.3466667">
	 <description>This test stack consists of tests which validate the functionality of the age calculation for a person.</description>

	 <test test_name="validate_age_calculation_born_today" pass="true" timestamp="2018-06-24T15:50:19.3466667" date_of_birth="1998-06-24" expected_age="20" returned_age="20">
	   <description>This test validates that, for a person born today, the age calculate will return the correct age.</description>
	 </test>

	 <test test_name="validate_age_calculation_born_tomorrow" pass="true" timestamp="2018-06-24T15:50:19.3633333" date_of_birth="1998-06-25" expected_age="19" returned_age="19">
	   <description>This test validates that, for a person born tomorrow, the age calculate will return the correct age. If the person were born tomorrow, 20 years ago, we expect the calculation to return an age of 19.</description>
	 </test>
    </test_stack>
*/
