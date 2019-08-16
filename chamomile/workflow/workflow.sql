use [chamomile];

go

if schema_id(N'scheduling') is null
  execute (N'create schema scheduling');

go

if exists(select *
          from   fn_listextendedproperty(N'description'
                                         , N'SCHEMA'
                                         , N'scheduling'
                                         , default
                                         , default
                                         , default
                                         , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'scheduling',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Used for objects that manage and provide scheduling for system and business objects.',
  @level0type = N'SCHEMA',
  @level0name = N'scheduling',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists(select *
          from   fn_listextendedproperty(N'get_license'
                                         , N'SCHEMA'
                                         , N'scheduling'
                                         , default
                                         , default
                                         , default
                                         , default))
  exec sys.sp_dropextendedproperty
    @name = N'get_license',
    @level0type = N'SCHEMA',
    @level0name = N'scheduling',
    @level1type = default,
    @level1name = default,
    @level2type = default,
    @level2name = default;

go

exec sys.sp_addextendedproperty
  @name = N'get_license',
  @value = N'execute [scheduling].[get_license];',
  @level0type = N'SCHEMA',
  @level0name = N'scheduling',
  @level1type = default,
  @level1name = default,
  @level2type = default,
  @level2name = default;

go 
