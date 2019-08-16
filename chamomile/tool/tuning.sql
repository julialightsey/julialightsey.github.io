
-- https://msdn.microsoft.com/en-us/library/ms188748.aspx
-- https://msdn.microsoft.com/en-us/library/ms189573.aspx
checkpoint;

go

-- https://msdn.microsoft.com/en-us/library/ms187762.aspx
dbcc dropcleanbuffers;

go

-- https://msdn.microsoft.com/en-us/library/ms187781.aspx
dbcc freesessioncache;

go

-- https://msdn.microsoft.com/en-us/library/ms178529.aspx
dbcc freesystemcache (N'all');

go

-- https://msdn.microsoft.com/en-us/library/ms174283.aspx
dbcc freeproccache;

go 
