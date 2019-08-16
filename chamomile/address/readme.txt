Katherine E. Lightsey
20140313
Address objects

SCHEMAS
- Address__secure 	- data objects and primary methods
- Address			- public interface to Address_secure

OBJECTS (install in order without modifications)
- [Address__secure].[XSC]		- (xml schema collection/type) The XML type.

- [Address__secure].[Data]		- (table/object) The primary data table.

- [Address].[Data]				- (view/facade) The public interface to [Address__secure].[Data]. All objects should use this with the exception of the primary accessors and mutators. Returns all data.

- [Address__secure].[Get]		- (procedure/adapter) 
- [Address__secure].[Load]		- (procedure/adapter) 

- [Address].[GetPrototype]		- (prototype) Returns a prototype of the XML needed for each address type along with a lable and description for use in the interface.

TESTS
- load_test_data.sql	- Loads test records into the primary table.
- test.sql				- Test scripts.

DESIGN NOTES
- Unique Constraints - There is no attempt made at setting a unique constraint on the table. This is a violation of the rules of normalization in theory. There is a unique [ID] on each record which creates unique records. The address is of such complexity that attempting to create uniqueness may not be beneficial for this business object.

- Use of Facade Objects - Access to the [Address_secure] schema is done only through designated objects to facilitate future refactoring if required.

- Capitalization - All XML objects, types, accessors, etc. are lowercase to minimize errors due to case sensitivity. It is highly recommended that all objects be named using lowercase to facilitate the use in internationalized applications. However, shop practices have been followed. Effectively, business objects have been named using Pascal notation while system objects have been named using all lowercase. These objects have been developed on a database using a case sensitive collation to ensure that these methods perform correctly in that context.

- Type Separators - In naming, a double underscore "__" had been used to separate the name of an object from its type. For example; the business object for "Payment Methods" would be named [PaymentMethod] in accordance with shop standards, while the secure schema for [PaymentMethod] would be named [PaymentMethod__secure].

- Redundancy in Naming - Redundancies have not been used in naming. For example; the address data table and ID column are named [Address__secure].[Data].[ID] rather than [Address__secure].[Address].[AddressID]. This is common practice in all hierarchical naming systems.

- Address Object Naming - Address objects have been named for commonality. For example; "postal_code" is used in all cases even where the national format may refer to this as "postal_zone". This is done to facilitate data extraction as can be seen in the method [Address].[Data]. Similarly, all addresses contain a "street1" even in addresses where there is only one line for street.

- Test Data - Additional test data can be inserted using the script "load_test_data.sql" as an example.

- Performance Testing - Performance testing is not considered necessary at this time due to low volume. In the future, as volume increases, performance testing will be used to determine indexing strategies for the XML data. However, should management desire, I can readily load a data set of 100 to 500 million records and perform testing and analysis. This is expected to take two to three days. While the results of said testing might be interesting, the design of the system facilitates refactoring and tuning as required so the testing is not considered necessary at this time by the engineer.