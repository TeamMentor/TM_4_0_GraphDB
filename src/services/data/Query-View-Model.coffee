{Cache_Service} = require('teammentor')
Import_Service  = require './Import-Service'

class Query_View_Model
  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("data_cache")
    @.db_Name       = @.options.db_Name || 'tm-uno'
    @.graph_Options = name: @.db_Name

  get_Articles: (query_Id, filters, from, to, callback)->
    @.query_Tree_Filtered query_Id, filters, (data)->
      articles = data?.results?.slice from, to
      callback articles

  get_Queries: (query_Id, filters, callback)->
    @.query_Tree_Filtered query_Id, filters, (data)->
      queries = []
      if data?.containers
        for query in data.containers
          if query.size
            queries.push id : query.id, title: query.title, size: query.size
      callback queries

  get_Filters: (query_Id, filters, callback)->
    @.query_Tree_Filtered query_Id, filters, (data)->
      filters = []
      if data?.filters
        for filter in data.filters
          results = []
          filters.push title: filter.title, results: results
          for result in filter.results
            if result.size
              results.push { id: result.id, title: result.title, size: result.size }
      callback filters

  get_View_Model: (query_Id, filters, from, to, callback)=>
    @.query_Tree_Filtered query_Id, filters, (query_tree)=>
      view_Model = {}
      @.get_Articles query_Id, filters, from, to, (data_Articles)=>
        @.get_Filters query_Id, filters, (data_Filters)=>
          @.get_Queries query_Id, filters, (data_Queries)=>
            using view_Model, ->
              @._id      = query_Id
              @._filters = filters
              @._from    = from
              @._to      = to
              @.id       = query_tree.id
              @.title    = query_tree.title
              @['articles'] = data_Articles
              @['filters' ] = data_Filters
              @['queries' ] = data_Queries
              callback view_Model



  query_Tree_Filtered: (query_Id, filters, callback)=>
    @.query_Tree_Filtered_from_Cache query_Id, filters, (data)=>
      if data
        callback data
      else
        @.query_Tree_Filtered_from_GraphDB query_Id, filters, callback

  query_Tree_Filtered_from_Cache: (query_Id, filters, callback)=>
    cache_Key = "query_tree__#{query_Id}_#{filters || ''}.json"
    callback @.cache.get(cache_Key)?.json_Parse()


  query_Tree_Filtered_from_GraphDB: (query_Id, filters, callback)=>
    cache_Key = "query_tree__#{query_Id}_#{filters || ''}.json"
    @.open_Import_Service (import_Service)=>
      if import_Service
        if @.cache.has_Key cache_Key                                    # in case the query ID has been added to the cache while wait_For_Unlocked_DB was running
          import_Service.graph.closeDb =>                              # close the DB and
            @.query_Tree_Filtered_from_Cache query_Id, filters, callback              # send the data from the cache
        else
          import_Service.query_Tree.get_Query_Tree_Filtered query_Id, filters, (data)=>
            import_Service.graph.closeDb =>
              if data and data.id
                @.cache.put cache_Key,data
              callback data
      else callback null

  open_Import_Service: (callback)=>
      import_Service = new Import_Service(@.graph_Options)
      unlock_Ok = ->
        import_Service.graph.openDb (status)=>
          status = true
          if status
            callback import_Service
          else
            callback null
      unload_Fail = ->
        callback null
      import_Service.graph.wait_For_Unlocked_DB unlock_Ok, unload_Fail

module.exports = Query_View_Model