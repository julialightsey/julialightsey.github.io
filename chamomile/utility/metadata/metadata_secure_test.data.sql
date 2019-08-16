use [chamomile]

go

truncate table [metadata_secure].[data];

go

insert into [metadata_secure].[data]
            ([category],
             [class],
             [type],
             [value],
             [entry],
             [active],
             [expire],
             [description])
values      (N'category',
             N'class',
             N'type',
             N'value',
             N'<entry />',
             N'20160101',
             N'20160301',
             N'description'),
            (N'category',
             N'class',
             N'type',
             N'value',
             N'<entry />',
             N'20160303',
             null,
             N'description');

go

begin try
    insert into [metadata_secure].[data]
                ([category],
                 [class],
                 [type],
                 [value],
                 [entry],
                 [active],
                 [expire],
                 [description])
    values      (N'category',
                 N'class',
                 N'type',
                 N'value',
                 N'<entry />',
                 N'20160302',
                 N'20160401',
                 N'description');
end try

begin catch
    print N'pass';
end catch; 
