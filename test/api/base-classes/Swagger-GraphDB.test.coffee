{Cache_Service}  = require('teammentor')
Swagger_GraphDB  = require '../../../src/api/base-classes/Swagger-GraphDB'
Import_Service   = require '../../../src/services/data/Import-Service'

describe '| api | base-classes | Swagger-GraphDB.test |', ->

  tmp_Cache = null

  before ->
    tmp_Cache = new Cache_Service("tmp_Cache")

  after ->
    tmp_Cache.delete_CacheFolder()

  it 'constructor', ->
    using new Swagger_GraphDB(), ->
      @.options      .assert_Is {}
      @.cache.area   .assert_Is 'data_cache'
      @.cache_Enabled.assert_Is_True()
      @.db_Name      .assert_Is 'tm-uno'

  it 'constructor (with options)', ->
    options =
      cache          : tmp_Cache
      cache_Enabled  : false
      db_Name        : 'cccc',
      area           : 'dddd'
      swaggerService : 'eeee'

    using new Swagger_GraphDB(options), ->
      @.options       .assert_Is options
      @.cache         .assert_Is options.cache
      @.cache_Enabled .assert_Is_False()
      @.db_Name       .assert_Is options.db_Name
      @.area          .assert_Is options.area
      @.swaggerService.assert_Is options.swaggerService

  it 'close_Import_Service_and_Send', (done)->
    temp_Data     = {article_Id:'data_'.add_5_Letters()}
    temp_Key      = 'key_'.add_5_Letters()
    importService =
      graph:
        closeDb: (callback)=>
          callback()
    res =
      send: (data)=>
        data.json_Parse().json_Str().assert_Is (temp_Data.json_Str())
        tmp_Cache.get(temp_Key).json_Parse().json_Str().assert_Is (temp_Data.json_Str())
        done()

    options =
      cache: tmp_Cache

    using new Swagger_GraphDB(options), ->
      @.close_Import_Service_and_Send importService, res, temp_Data, temp_Key

  it 'save_To_Cache',->
    using new Swagger_GraphDB(cache: tmp_Cache), ->
      tmp_Cache.has_Key('a').assert_False()
      tmp_Cache.has_Key('b').assert_False()
      tmp_Cache.has_Key('c').assert_False()
      tmp_Cache.has_Key('d').assert_False()
      @.save_To_Cache('a', 123)
      @.save_To_Cache('b', '123')
      @.save_To_Cache('c', {key:'value'})
      @.save_To_Cache('d', ['0','1','2'])
      tmp_Cache.get('a').assert_Is 123
      tmp_Cache.get('b').assert_Is '123'
      tmp_Cache.get('c').json_Parse().assert_Is {key:'value'}
      tmp_Cache.get('d').json_Parse().assert_Is ['0','1','2']

  it 'save_To_Cache (empty data)',->
    key   = 'a_'.add_5_Letters()
    value = 'aaa'.add_5_Letters()
    tmp_Cache.put key, value

    check_Value = ()->
      tmp_Cache.get(key).assert_Is(value)

    using new Swagger_GraphDB(cache: tmp_Cache), ->
      check_Value(@.save_To_Cache key)
      check_Value(@.save_To_Cache key, null)
      check_Value(@.save_To_Cache key, undefined)
      check_Value(@.save_To_Cache key, [])
      check_Value(@.save_To_Cache key, {})

describe '| api | base-classes | Swagger-GraphDB.test | open_Import_Service', ->

  importService = null
  options       = null
  swagger_DB    = null
  tmp_Cache     = null

  before ->
    tmp_Cache = new Cache_Service("tmp_Cache")
    options  =
      cache: tmp_Cache
      db_Name: 'temp-db'
    swagger_DB = new Swagger_GraphDB(options)

  afterEach (done)->
    importService.graph.deleteDb ->
        done()

  it 'sending data not in cache', (done)->

    temp_Data     = {article_Id:'data_'.add_5_Letters()}
    temp_Key      = 'key_'.add_5_Letters()

    res =
      send: (data)=>
        data.json_Parse().json_Str().assert_Is(temp_Data.json_Str())
        tmp_Cache.get(temp_Key).json_Parse().json_Str().assert_Is (temp_Data.json_Str())
        done()

    swagger_DB.open_Import_Service res, temp_Key, (_importService)->
      importService = _importService
      swagger_DB.close_Import_Service_and_Send importService, res, temp_Data, temp_Key

  it 'Invalid articles should not be created in cache', (done)->

    temp_Data     = 'data_'.add_5_Letters()
    temp_Key      = 'key_'.add_Random_Letters (1000);

    res =
      send: (data)=>
        data.json_Parse().json_Str().assert_Is(temp_Data.json_Str())
        tmp_Cache.has_Key(temp_Key).assert_Is_False()
        done()

    swagger_DB.open_Import_Service res, temp_Key, (_importService)->
      importService = _importService
      swagger_DB.close_Import_Service_and_Send importService, res, temp_Data, temp_Key

  it 'Invalid articles (NULL) should not be created in cache', (done)->

    temp_Data     = undefined
    temp_Key      = 'key_'.add_Random_Letters (1000);

    res =
      send: (data)=>
        data?.assert_Is_Undefined()
        tmp_Cache.has_Key(temp_Key).assert_Is_False()
        done()

    swagger_DB.open_Import_Service res, temp_Key, (_importService)->
      importService = _importService
      swagger_DB.close_Import_Service_and_Send importService, res, temp_Data, temp_Key

  it 'sending data in cache', (done)->

    temp_Data     = 'data_'.add_5_Letters()
    temp_Key      = 'key_'.add_5_Letters()

    res =
      send: (data)=>
        data                   .assert_Is temp_Data   # there is a small variation with the previous test (which could cause probs when strings are saved)
        tmp_Cache.get(temp_Key).assert_Is temp_Data
        done()

    tmp_Cache.put temp_Key, temp_Data

    swagger_DB.open_Import_Service res, temp_Key

  it 'when GraphDB is not avaiable', (done)->

    temp_Key      = 'key_'.add_5_Letters()

    res =
      status: (value)->
        value.assert_Is 503
        @
      send: (data)->
        data.assert_Is error: { message: 'GraphDB is busy, please try again' }
        import_Service.graph.deleteDb ->
          done()

    using swagger_DB.graph_Options, ->
      @.db_Lock_Tries = 2
      @.db_Lock_Delay = 10

    import_Service = new Import_Service(options)
    import_Service.graph.openDb (status)->
      status.assert_Is_True()
      swagger_DB.open_Import_Service res, temp_Key


  it 'when GraphDB is not avaiable but key was added to cache', (done)->

    temp_Data     = 'data_'.add_5_Letters()
    temp_Key      = 'key_'.add_5_Letters()

    res =
      send: (data)->
        data                   .assert_Is temp_Data
        tmp_Cache.get(temp_Key).assert_Is temp_Data
        import_Service.graph.deleteDb ->
          done()

    using swagger_DB.graph_Options, ->
      @.db_Lock_Tries = 2
      @.db_Lock_Delay = 10

    import_Service = new Import_Service(options)
    import_Service.graph.openDb (status)->
      status.assert_Is_True()
      swagger_DB.open_Import_Service res, temp_Key

    20.wait ->
      tmp_Cache.put temp_Key, temp_Data
