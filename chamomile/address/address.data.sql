if schema_id(N'address') is null
  execute (N'create schema address');

go

if object_id(N'[address].[data]'
             , N'V') is not null
  drop view [address].[data];

go

create view [address].[data]
as
  select [id]
         ,
         --
         isnull([entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[1],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[2],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[3],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[4],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[5],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[6],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[7],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[8],', 'sysname'), N'')
           +
           --
           isnull(N', ' +[entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/*)[9],', 'sysname'), N'')
           +
           --
           isnull([entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/country)[1],', 'sysname'), N'') as [address]
         ,
         --
         isnull([entry].value('declare namespace kelightsey="http://www.kelightsey.com/"; (./*/@address_type)[1],'
                                , 'sysname')
                  , N'')                                                                                                         as [address_type]
         ,
         --
         [entry]
  from   [address__secure].[data];

go

--grant execute on [address].[data] to kelightsey;
go 
