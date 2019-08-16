if schema_id(N'address_secure') is null
  execute (N'create schema address_secure');

go

--
-------------------------------------------------
if object_id(N'[address_secure].[state]'
             , N'U') is not null
  drop table [address_secure].[state];

go

create table [address_secure].[state]
  (
     [id]             [int] identity(1, 1) not null
     , [country]      [sysname]
     , [state]        [sysname]
     , [abbreviation] [nchar](2) not null,
     constraint [address_secure.state.id.clustered_primary_key] primary key clustered ([id]),
     constraint [address_secure.state.country.state.unique] unique ( [country], [state]),
     constraint [address_secure.state.country.abbreviation.unique] unique ( [country], [abbreviation]),
     constraint [address_secure.state.country.check] check ( [country] not like '%[^0-9a-zA-Z]%' and ( [country] like '%[a-z]%' and [country] not like '%[0-9]%') and ( len([country]) >= 2) and (len([country])<=5)),
     constraint [address_secure.state.state.check] check ( [state] not like '%[^0-9a-zA-Z ]%' and ( [state] like '%[a-z ]%' and [state] not like '%[0-9]%' )),
     constraint [address_secure.state.abbreviation.check] check ( [abbreviation] like N'[a-z][a-z]')
  );

go

--
-------------------------------------------------
if object_id ('[address_secure].[lock]'
              , 'TR') is not null
  drop trigger [address_secure].[lock];

go

create trigger [address_secure].[lock]
on [address_secure].[state]
after insert, update, delete
as
  begin
      raiserror ('The operations INSERT, UPDATE, and DELETE are not allowed for this table.',16,1);

      rollback transaction;

      return;
  end;

go

--
-------------------------------------------------
begin
    begin transaction;

    disable trigger [address_secure].[lock] on [address_secure].[state];

    set identity_insert [address_secure].[state] on;

    declare @state_list as table
      (
         [country]        [varchar](5)
         , [state]        [sysname]
         , [abbreviation] [char](2)
      );

    insert into @state_list
                ([country],
                 [state],
                 [abbreviation])
    values      ('USA',
                 'Alaska',
                 'AK'),
                ('USA',
                 'Alabama',
                 'AL'),
                ('USA',
                 'Arkansas',
                 'AR'),
                ('USA',
                 'Arizona',
                 'AZ'),
                ('USA',
                 'California',
                 'CA'),
                ('USA',
                 'Colorado',
                 'CO'),
                ('USA',
                 'Connecticut',
                 'CT'),
                ('USA',
                 'Washington DC',
                 'DC'),
                ('USA',
                 'Delaware',
                 'DE'),
                ('USA',
                 'Florida',
                 'FL'),
                ('USA',
                 'Georgia',
                 'GA'),
                ('USA',
                 'Hawaii',
                 'HI'),
                ('USA',
                 'Iowa',
                 'IA'),
                ('USA',
                 'Idaho',
                 'ID'),
                ('USA',
                 'Illinois',
                 'IL'),
                ('USA',
                 'Indiana',
                 'IN'),
                ('USA',
                 'Kansas',
                 'KS'),
                ('USA',
                 'Kentucky',
                 'KY'),
                ('USA',
                 'Louisiana',
                 'LA'),
                ('USA',
                 'Massachusetts',
                 'MA'),
                ('USA',
                 'Maryland',
                 'MD'),
                ('USA',
                 'Maine',
                 'ME'),
                ('USA',
                 'Michigan',
                 'MI'),
                ('USA',
                 'Minnesota',
                 'MN'),
                ('USA',
                 'Missouri',
                 'MO'),
                ('USA',
                 'Mississippi',
                 'MS'),
                ('USA',
                 'Montana',
                 'MT'),
                ('USA',
                 'North Carolina',
                 'NC'),
                ('USA',
                 'North Dakota',
                 'ND'),
                ('USA',
                 'Nebraska',
                 'NE'),
                ('USA',
                 'New Hampshire',
                 'NH'),
                ('USA',
                 'New Jersey',
                 'NJ'),
                ('USA',
                 'New Mexico',
                 'NM'),
                ('USA',
                 'Nevada',
                 'NV'),
                ('USA',
                 'New York',
                 'NY'),
                ('USA',
                 'Ohio',
                 'OH'),
                ('USA',
                 'Oklahoma',
                 'OK'),
                ('USA',
                 'Oregon',
                 'OR'),
                ('USA',
                 'Pennsylvania',
                 'PA'),
                ('USA',
                 'Rhode Island',
                 'RI'),
                ('USA',
                 'South Carolina',
                 'SC'),
                ('USA',
                 'South Dakota',
                 'SD'),
                ('USA',
                 'Tennessee',
                 'TN'),
                ('USA',
                 'Texas',
                 'TX'),
                ('USA',
                 'Utah',
                 'UT'),
                ('USA',
                 'Virginia',
                 'VA'),
                ('USA',
                 'Vermont',
                 'VT'),
                ('USA',
                 'Washington',
                 'WA'),
                ('USA',
                 'Wisconsin',
                 'WI'),
                ('USA',
                 'West Virginia',
                 'WV'),
                ('USA',
                 'Wyoming',
                 'WY');

    insert into [address_secure].[state]
                ([id],
                 [country],
                 [state],
                 [abbreviation])
    select dense_rank()
             over (
               order by [country], [state], [abbreviation]) as [id]
           , lower([country])
           , lower([state])
           , lower([abbreviation])
    from   @state_list
    order  by [country]
              , [state];

    set identity_insert [address_secure].[state] off;

    enable trigger [address_secure].[lock] on [address_secure].[state];

    commit;
end

go

if schema_id(N'address_secure') is null
  execute (N'create schema address_secure');

go 
