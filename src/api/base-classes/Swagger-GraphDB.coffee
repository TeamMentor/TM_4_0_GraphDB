{Cache_Service} = require('teammentor')
Swagger_Common  = require './Swagger-Common'
Import_Service  = require '../../services/data/Import-Service'
Search_Service  = require '../../services/data/Search-Service'

local_Cache    = {}

class Swagger_GraphDB extends Swagger_Common

  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("data_cache")
    @.cache_Enabled = true
    @.cache_Enabled = false if @.options.cache_Enabled is false
    @.db_Name       = @.options.db_Name || 'tm-uno'
    @.graph_Options = name: @.db_Name
    super(options)

  cache_Has_Key: (key)=>
    @.cache_Enabled and key and @.cache.has_Key(key)

  close_Import_Service_and_Send: (importService, res, data, key)=>
    @.save_To_Cache(key,data)
    importService.graph.closeDb =>
      res.json data

  open_Import_Service: (res, key ,callback)=>
    @.send_From_Cache res,key, ()=>                             # see if the value already exists on the cache
      import_Service = new Import_Service(@.graph_Options)      # if not a new Import_Service object with openDB will need to be opened

      after_Wait_For_Unlocked_DB = ()=>                         # wait for Db to be available (will happen on multiple requests to same resource)
        if @.cache_Has_Key(key)                                 # if key is now available
          @.send_From_Cache res,key                             # send it
        else
          import_Service.graph.openDb (status)=>                #  open the Db (which now has the wait_For_Unlocked_DB capability)
            if status                                           # if db was opened ok
                callback import_Service                         #   call callback with Import_Service obj as param
            else                                                # if db could not be opened
              @.send_From_Cache res,key, =>                     #   see if value has been placed on cache (since first check)
                res.status(503)                                 #   and if the value is still not of the cache, send a 503 error
                   .json { error : message : 'GraphDB is busy, please try again'}
      import_Service.graph.wait_For_Unlocked_DB after_Wait_For_Unlocked_DB, after_Wait_For_Unlocked_DB

  save_To_Cache: (key,data)=>
    if @.cache_Enabled
      if key and data                                     # check that both values are set
        if data instanceof Array and data.empty()         # if array, check if not empty
          return
        if data instanceof Object and data.keys_Own().empty?() # if object, check if not empty
          return
        try
          @.cache.setup()                                   # ensures cache folder exists
          @.cache.put key,data                              # save data into cache
        catch message
          logger?.error "Got #{message} when saving cache key #{key}"

  send_From_Cache: (res, key, callback)=>
    #if local_Cache[key]                                   # use in memory cache if data has been loaded before
    #  return res.json local_Cache[key]

    if @.cache_Has_Key(key)
      data = @.cache.get(key)?.json_Parse()               # although this is only reading from the file system, it will take an extra 5 to 10ms per request (or larger file)
      local_Cache[key] = data
      return res.json data

    callback()

  using_Import_Service: (res, key, callback)=>
    @.open_Import_Service res, key, (import_Service)=>
      callback.call import_Service, (data)=>
        @.close_Import_Service_and_Send import_Service, res,data, key

  using_Graph: (res, key, callback)=>
    @.using_Import_Service res, key, (send)->
      callback.call @.graph, send

  using_Graph_Find: (res, key, callback)=>
    @.using_Import_Service res, key, (send)->
      callback.call @.graph_Find, send

  using_Search_Service: (res, key, callback)=>
    @.using_Import_Service res, key, (send)->
      search_Service = new Search_Service( importService: @ )
      callback.call search_Service, send

  using_Query_Tree: (res, key, callback)=>
    @.using_Import_Service res, key, (send)->
      callback.call @.query_Tree, send


module.exports = Swagger_GraphDB
