{Cache_Service} = require('teammentor')
Swagger_Common  = require './Swagger-Common'
Import_Service  = require '../../services/data/Import-Service'
Search_Service  = require '../../services/data/Search-Service'

class Swagger_GraphDB extends Swagger_Common

  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("data_cache")
    @.cache_Enabled = true
    @.cache_Enabled = false if @.options.cache_Enabled is false
    @.db_Name       = @.options.db_Name || 'tm-uno'
    @.graph_Options = name: @.db_Name
    super(options)

  close_Import_Service_and_Send: (importService, res, data, key)=>
    if (data?.article_Id)
      @.save_To_Cache(key,data)
    importService.graph.closeDb =>
      res.send data?.json_pretty()

  open_Import_Service: (res, key ,callback)=>

    @.send_From_Cache res,key, ()=>                         # see if the value already exists on the cache
      import_Service = new Import_Service(@.graph_Options)  # if not
      import_Service.graph.openDb (status)=>                #   open the Db (which now has the wait_For_Unlocked_DB capability)
        if status                                           # if db was opened ok
          callback import_Service                           #   call callback with Import_Service obj as param
        else                                                # if db could not be opened
          @.send_From_Cache res,key, =>                     #   see if value has been placed on cache (since first check)
            res.status(503)                                 #   and if the value is still not of the cache, send a 503 error
              .send { error : message : 'GraphDB is busy, please try again'}

  save_To_Cache: (key,data)=>
    if @.cache_Enabled
      if key and data                                     # check that both values are set
        if data instanceof Array and data.empty()         # if array, check if not empty
          return
        if data instanceof Object and data.keys().empty() # if object, check if not empty
          return
        try
          @.cache.put key,data                              # save data into cache
        catch message
          logger?.error "Got #{message} when saving cache key #{key}"

  send_From_Cache: (res, key, callback)=>
    if @.cache_Enabled
      if (key and @.cache.has_Key(key))
        return res.send @.cache.get(key)

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