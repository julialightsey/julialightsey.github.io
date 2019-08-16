if schema_id(N'chamomile') is null
  execute (N'create schema chamomile');

go

set nocount on;

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
	drop procedure repository_test.get_list;
  drop procedure [test_test].[trigger_test];
  drop function documentation.get_function_list
	drop procedure [documentation].[set]
	drop procedure documentation.get_procedure_list
	drop procedure documentation.get_schema_list
	drop procedure documentation.get_schema
	drop procedure documentation.get_job_list
	drop procedure utility_test.get_meta_data
	drop procedure [unbreakable_code_test].[set_flower]
	drop procedure utility.set_log
	drop function repository.get
	drop function repository.get_list
	drop table [repository_secure].[data]
	drop procedure [repository].[set]
	drop procedure [repository_test].[set] 
	drop procedure [test].[run]
	drop procedure [repository_test].[get]
	drop procedure [utility].[set_prototype];
	drop procedure [utility].[set_meta_data];
	drop procedure [utility].[handle_error];
	drop procedure utility_test.handle_error;
*/
if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsc'
                  and xsc.schema_id = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[xsc];

go

/*
	--
	-- License
	----------------------------------------------------------------------
	Katherine E. Lightsey
	http://www.katherinelightsey.com
	
	All content is copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
	licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
		
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	select objtype
		   , objname
		   , name
		   , value
	from   fn_listextendedproperty (null
									, 'schema'
									, 'chamomile'
									, 'xml schema collection'
									, 'xsc'
									, default
									, default);
*/
create xml schema collection [chamomile].[xsc] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="http://www.katherinelightsey.com/" targetNamespace="http://www.katherinelightsey.com/">

    <xsd:element name="stack" type="chamomile:stack_type" />

		<!-- todo - finish validating this -->
			<xsd:element name="server_information" type="chamomile:server_information_complex_type" />

    <xsd:complexType name="stack_type">
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
			<xsd:element name="subject" type="chamomile:subject_complex_type" minOccurs="1" maxOccurs="1" />
            <xsd:element name="object" type="chamomile:object_complex_type" minOccurs="1" maxOccurs="1" />
            <xsd:element name="result" type="chamomile:result_complex_type" minOccurs="0" maxOccurs="1" />
          </xsd:sequence>
          <xsd:attribute name="persistent" type="chamomile:boolean_enumeration" default="false" />
          <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
		  <xsd:anyAttribute processContents="lax" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>

	<xsd:complexType name="subject_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="0" maxOccurs="1" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>

	<xsd:complexType name="object_complex_type">
		<xsd:sequence>
			<xsd:choice minOccurs="0" maxOccurs="unbounded">			
				<xsd:element name="error_suite" type="chamomile:error_suite_complex_type" />
				<xsd:element name="error_stack" type="chamomile:error_stack_complex_type" />
								
				<xsd:element name="test_suite" type="chamomile:test_suite_complex_type" />
				<xsd:element name="test_stack" type="chamomile:test_stack_complex_type" />
				
				<xsd:element name="command_stack" type="chamomile:command_stack_complex_type" />

				<xsd:element name="documentation_stack" type="chamomile:documentation_stack_complex_type" />

				<xsd:element name="log_stack" type="chamomile:log_entry_complex_type" />
				
				<xsd:element name="meta_data" type="chamomile:meta_data_complex_type" />
				
				<xsd:element name="data" type="chamomile:any_complex_type" />
			</xsd:choice>
		</xsd:sequence>
    </xsd:complexType>
	
	<xsd:complexType name="log_entry_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="log" type="chamomile:log_complex_type" />
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
	<xsd:complexType name="log_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="sequence" type="xsd:int" default="1"/>
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
	<xsd:element name="documentation" type="chamomile:documentation_stack_complex_type" />
	<xsd:complexType name="documentation_stack_complex_type">
		<xsd:choice minOccurs="0" maxOccurs="unbounded">
			<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
			<xsd:element name="text" type="chamomile:text_complex_type" minOccurs="1" maxOccurs="unbounded" />
			<xsd:element name="html" type="chamomile:html_complex_type" minOccurs="1" maxOccurs="unbounded" />
           <xsd:element name="data" type="chamomile:data_complex_type" />
		</xsd:choice>  
		<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
        <xsd:attribute name="stale" type="chamomile:boolean_enumeration" default="false" />
        <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
		<xsd:anyAttribute processContents="lax" />
    </xsd:complexType>
	
	<xsd:complexType name="data_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="sequence" type="xsd:int" default="0"/>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
	<xsd:complexType name="html_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="sequence" type="xsd:int" default="0"/>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>

    <xsd:complexType name="text_complex_type">
      <xsd:simpleContent>
        <xsd:extension base="xsd:string">
		<xsd:attribute name="sequence" type="xsd:int" default="0"/>
		<xsd:anyAttribute processContents="lax" />
        </xsd:extension>
      </xsd:simpleContent>
    </xsd:complexType>
	
	<xsd:complexType name="result_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>

	<xsd:complexType name="error_suite_complex_type"> 
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="error_stack" type="chamomile:test_stack_complex_type" minOccurs="0" maxOccurs="unbounded" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="error_count" type="xsd:int" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	

	<xsd:complexType name="error_stack_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="test" type="chamomile:test_complex_type" minOccurs="0" maxOccurs="unbounded" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="error_count" type="xsd:int" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
	<xsd:complexType name="error_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="error_message" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="application_message" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="schema" type="chamomile:sysname_pattern" use="required" />
				<xsd:attribute name="procedure" type="chamomile:sysname_pattern" use="required" />
				<xsd:attribute name="error_number" type="xsd:int" use="required" />
				<xsd:attribute name="error_line" type="xsd:int" use="required" />
				<xsd:attribute name="error_severity" type="xsd:int" use="required" />
				<xsd:attribute name="error_state" type="xsd:int" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>


	<xsd:complexType name="test_suite_complex_type"> 
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="test_stack" type="chamomile:test_stack_complex_type" minOccurs="0" maxOccurs="unbounded" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="stack_count" type="xsd:int" use="required" />
				<xsd:attribute name="test_count" type="xsd:int" use="required" />
				<xsd:attribute name="pass_count" type="xsd:int" use="required" />
				<xsd:attribute name="error_count" type="xsd:int" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	

	<xsd:complexType name="test_stack_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="test" type="chamomile:test_complex_type" minOccurs="0" maxOccurs="unbounded" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="test_count" type="xsd:int" use="required" />
				<xsd:attribute name="pass_count" type="xsd:int" use="required" />
				<xsd:attribute name="error_count" type="xsd:int" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>

	<xsd:complexType name="test_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:element name="object" type="chamomile:any_complex_type" minOccurs="1" maxOccurs="1" />
					<xsd:element name="result" type="chamomile:result_complex_type" minOccurs="1" maxOccurs="1" />
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:attribute name="sequence" type="xsd:int" use="required" />
				<xsd:attribute name="expected" type="chamomile:pass_fail_enumeration" use="required" />
				<xsd:attribute name="actual" type="chamomile:pass_fail_enumeration" use="required" />
				<xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
    <xsd:complexType name="meta_data_complex_type" >
		<xsd:choice minOccurs="0" maxOccurs="unbounded">
			<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
			<xsd:element name="value" type="xsd:string" minOccurs="0" maxOccurs="1" />		
			<xsd:element name="constraint" type="xsd:string" minOccurs="0" maxOccurs="1" />			  
			<xsd:element name="data" type="chamomile:prototype_complex_type" minOccurs="0" maxOccurs="1" />
		</xsd:choice>    
		<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
		<xsd:anyAttribute processContents="lax" />
    </xsd:complexType>
	
	<xsd:complexType name="prototype_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
	<xsd:complexType name="any_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
    <xsd:complexType name="command_complex_type" >
		<xsd:choice minOccurs="2" maxOccurs="2">
			<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
            <xsd:element name="sql" type="xsd:string" minOccurs="0" maxOccurs="1" />
            <xsd:element name="parameters" type="xsd:string" minOccurs="0" maxOccurs="1" />
		</xsd:choice>    
		<xsd:attribute name="frequency" type="xsd:unsignedLong" />
        <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
		<xsd:anyAttribute processContents="lax" />
    </xsd:complexType>
	
	<xsd:complexType name="command_stack_complex_type">
		<xsd:choice minOccurs="0" maxOccurs="unbounded">
			<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
			<xsd:element name="command" type="chamomile:command_complex_type" minOccurs="0" maxOccurs="1" />
			<xsd:element name="command_stack" type="chamomile:command_stack_complex_type" minOccurs="0" maxOccurs="1" />
		</xsd:choice>    
	  <xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" use="required" />
	  <xsd:attribute name="recursion_level" type="xsd:int" use="required" />
	  <xsd:anyAttribute processContents="lax" />
    </xsd:complexType>

	<xsd:complexType name="server_information_complex_type">
		<xsd:sequence>
			<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
			<xsd:element name="complete" minOccurs="0" maxOccurs="unbounded">
				<xsd:complexType>
				<xsd:attribute name="major_version" type="xsd:int" />
				<xsd:attribute name="minor_version" type="xsd:int" />
				<xsd:attribute name="milli_version" type="xsd:int" />
				<xsd:attribute name="product_version" type="xsd:int" />
				<xsd:attribute name="product_level" type="xsd:string" />
				<xsd:attribute name="edition" type="xsd:string" />
				<xsd:attribute name="netbios" type="xsd:string" />
				<xsd:attribute name="machine" type="xsd:string" />
				<xsd:attribute name="instance" type="xsd:string" />
				<xsd:attribute name="database" type="xsd:string" />
				<xsd:attribute name="schema" type="xsd:string" />
				<xsd:attribute name="procedure" type="xsd:string" />
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="fqn" minOccurs="0" maxOccurs="unbounded">
				<xsd:complexType>
				<xsd:attribute name="fqn" type="chamomile:fqn_pattern_enumeration" />
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="server" minOccurs="0" maxOccurs="unbounded">
				<xsd:complexType>
				<xsd:attribute name="fqn" type="xsd:string" />
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="normalized_server" minOccurs="0" maxOccurs="unbounded">
				<xsd:complexType>
				<xsd:attribute name="fqn" type="xsd:string" />
				</xsd:complexType>
			</xsd:element>
		</xsd:sequence>
		<xsd:attribute name="timestamp" type="xsd:string" use="required" />
	</xsd:complexType>

  <xsd:simpleType name="meta_data_constraint_pattern">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="(\|{1}([a-z0-9 ._-])*)+\|{1}" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="type_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="error" />
      <xsd:enumeration value="result" />
      <xsd:enumeration value="test" />
      <xsd:enumeration value="command" />
      <xsd:enumeration value="command_stack" />
      <xsd:enumeration value="documentation" />
      <xsd:enumeration value="meta_data" />
      <xsd:enumeration value="prototype" />
      <xsd:enumeration value="example" />
      <xsd:enumeration value="ad_hoc" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="boolean_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="true" />
      <xsd:enumeration value="false" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="pass_fail_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="pass" />
      <xsd:enumeration value="fail" />
    </xsd:restriction>
  </xsd:simpleType>

  <!-- an fqn can be either: -->
  <!-- three part:	[category].[class].[type] - typically used for object names -->
  <!-- four part:	[database].[schema].[object.][minor_object] - typically used for column or parameter names -->
  <!-- six part:	[computer_physical_netbios].[machine].[instance].[database].[schema].[object] - typically used for subject names -->
  <!-- seven part:	[computer_physical_netbios].[machine].[instance].[database].[schema].[object].[minor_object] - typically used for column and parameter names -->
  <xsd:simpleType name="fqn_pattern_enumeration">
    <xsd:restriction base="xsd:string">
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
    </xsd:restriction> 
  </xsd:simpleType>

  <xsd:simpleType name="sysname_pattern">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[a-z0-9._-]{0,128}" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="object_name_pattern">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[a-z]{1}[a-z0-9._-]{0,128}" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:element name="email_address">
  <xsd:simpleType>
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[A-Za-z0-9_]+([-+.''][A-Za-z0-9_]+)*@[A-Za-z0-9_]+([-.][A-Za-z0-9_]+)*\.[A-Za-z0-9_]+([-.][A-Za-z0-9_]+)*"/>
    </xsd:restriction>
  </xsd:simpleType>
</xsd:element>

</xsd:schema>';

go 
