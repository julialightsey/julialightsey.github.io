/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------

	--
	--	notes
	----------------------------------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	----------------------------------------------------------------------
		Database normalization - http://en.wikipedia.org/wiki/Database_normalization
		Database Normalization Basics - http://databases.about.com/od/specificproducts/a/normalization.htm
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'customer') is null
  execute (N'create schema customer');

go

-- code block end
-- 
-- denormalized
--------------------------------------------------------------------------
if object_id(N'[customer].[contact]'
             , N'U') is not null
  drop table [customer].[contact];

go

create table [customer].[contact]
  (
     [name]           [nvarchar](250)
     , [address]      [nvarchar](250)
     , [home_phone]   [bigint]
     , [work_phone]   [bigint]
     , [cell_phone]   [bigint]
     , [other_phone]  [bigint]
     , [work_email]   [nvarchar](250)
     , [home_email]   [nvarchar](250)
     , [other1_email] [nvarchar](250)
     , [other2_email] [nvarchar](250)
  );

--
-- normalized
--------------------------------------------------------------------------
if object_id(N'[customer].[contact]'
             , N'U') is not null
  drop table [customer].[contact];

go

create table [customer].[contact]
  (
     [id]            [int] identity(1, 1)
     , [prefix]      [nvarchar](250)
     , [first_name]  [nvarchar](250)
     , [middle_name] [nvarchar](250)
     , [last_name]   [nvarchar](250)
     , [suffix]      [nvarchar](250),
     constraint [unique_customer_contact] unique ( [prefix], [first_name], [middle_name], [last_name], [suffix])
  );

create table [customer].[contact_address]
  (
     [fk_contact]   [int]
     , [fk_address] [int],
     constraint [unique_customer_contact_address] unique ([fk_contact], [fk_address])
  );

create table [utility].[address]
  (
     [id]            [int] identity(1, 1)
     , [designation] [nvarchar](250)
     , [street]      [nvarchar](250)
     , [fk_zip]      [int]
     , [fk_city]     [int]
     , [fk_state]    [int]
     constraint [unique_utility_address_designation_street_city_zip] unique ( [designation], [street], [fk_zip], [fk_city], [fk_state])
  );

create table [utility].[city]
  (
     [id]     [int] identity(1, 1)
     , [city] [nvarchar](250)
     constraint [unique_utility_city] unique ([city])
  );

create table [utility].[state]
  (
     [id]      [int] identity(1, 1)
     , [state] [nvarchar](250)
     constraint [unique_utility_state] unique ([state])
  );

create table [utility].[zip]
  (
     [id]        [int] identity(1, 1)
     , [zip]     [nvarchar](250)
     , [fk_city] [int],
     constraint [unique_utility_zip] unique ([zip])
  );

create table [utility].[phone]
  (
     [id]       [int] identity(1, 1)
     , [type]   [nvarchar](250)
     , [number] [bigint],
     constraint [unique_phone] unique ([number])
  );

create table [customer].[contact_email]
  (
     [fk_contact] [int]
     , [fk_email] [int],
     constraint [unique_customer_contact_email] unique ([fk_contact], [fk_email])
  );

create table [utility].[email]
  (
     [id]      [int] identity(1, 1)
     , [type]  [nvarchar](250)
     , [email] [nvarchar](250),
     constraint [unique_utility_type_email] unique ([type], [email])
  ); 
