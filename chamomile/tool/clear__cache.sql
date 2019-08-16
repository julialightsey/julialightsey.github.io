--
checkpoint;

go

dbcc dropcleanbuffers;

go

dbcc freesessioncache;

go

dbcc freesystemcache (N'all');

go

dbcc freeproccache;

go 
