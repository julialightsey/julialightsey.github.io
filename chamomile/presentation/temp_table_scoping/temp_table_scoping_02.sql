--
-- A temp table is created in a parent procedure.
-- A temp table with the same name is created in a child procedure
-- Rows inserted in the parent are not available in the child
-- Rows inserted in the child are not available in the parent
-------------------------------------------------
IF schema_id(N'test') IS NULL
  EXECUTE (N'CREATE SCHEMA test');

go

IF object_id(N'[test].[kate_test_01_parent]', N'P') IS NOT NULL
  DROP PROCEDURE [test].[kate_test_01_parent];

go

CREATE PROCEDURE [test].[kate_test_01_parent]
AS
  BEGIN
      CREATE TABLE #kate_test_01
        (
           [id]     INT IDENTITY(1, 1)
           , [name] SYSNAME
        );

      INSERT INTO #kate_test_01
                  ([name])
      VALUES      (N'cat'),
                  (N'dog');

      EXECUTE [test].[kate_test_01_child];

      SELECT [name] AS [parent_name]
      FROM   #kate_test_01;
  END;

go

IF object_id(N'[test].[kate_test_01_child]', N'P') IS NOT NULL
  DROP PROCEDURE [test].[kate_test_01_child];

go

CREATE PROCEDURE [test].[kate_test_01_child]
AS
  BEGIN
      CREATE TABLE #kate_test_01
        (
           [id]     INT IDENTITY(1, 1)
           , [name] SYSNAME
        );

      INSERT INTO #kate_test_01
                  ([name])
      VALUES      (N'lily'),
                  (N'rose');

      SELECT [name] AS [child_name]
      FROM   #kate_test_01;
  END;

go

EXECUTE [test].[kate_test_01_parent]; 
