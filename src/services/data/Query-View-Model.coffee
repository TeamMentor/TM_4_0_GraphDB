{Cache_Service} = require('teammentor')
Search_Query_Tree= require '../search/Search-Query-Tree'
Query_Tree       = require '../query-tree/Query-Tree'

class Query_View_Model
  constructor: (options)->
    @.options           = options || {}

    @.data_Cache        = @.options.cache || new Cache_Service("data_cache")
    @.search_Query_Tree = new Search_Query_Tree()
    @.query_Tree        = new Query_Tree()


  cache_Key: (query_Id, filters, from, to)=>
    "query_view_model_#{query_Id}#{if filters then '_'  else ''}#{filters || ''}_#{from}_#{to}.json"

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
      filters = {}
      if data?.filters
        for filter in data.filters
          if filter
            filters[filter.title] =  []
            if filter.results
              for result in filter.results
                if result.size
                  filters[filter.title].push { id: result.id, title: result.title, size: result.size }
      callback filters

  get_View_Model: (query_Id, filters, from, to, callback)=>

    cache_Key = @.cache_Key query_Id, filters, from, to

    if false and @.data_Cache.has_Key cache_Key
      return callback @.data_Cache.get(cache_Key)?.json_Parse()

    @.query_Tree_Filtered query_Id, filters, (query_Tree)=>
      if query_Tree?.id isnt query_Id
        return callback { error: 'no query tree filtered' }

      view_Model = {}

      @.get_Articles query_Id, filters, from, to, (data_Articles)=>
        @.get_Filters query_Id, filters, (data_Filters)=>
          @.get_Queries query_Id, filters, (data_Queries)=>
            using view_Model, ->
              @._cache_Key = cache_Key
              @._query_Id  = query_Tree?.id
              @._filters   = filters
              @._from      = from
              @._to        = to
              @.id         = query_Tree?.id
              @.title      = query_Tree?.title
              @.size       = query_Tree?.results?.size()

              @.queries  = data_Queries
              @.articles = data_Articles
              @.filters  = data_Filters

            @.data_Cache.put cache_Key, view_Model
            callback view_Model

  query_Tree_Filtered: (query_Id, filters, callback)=>
    @.query_Tree.get_Query_Tree_Filtered query_Id, filters, callback

#    @.query_Tree_Filtered_from_Cache query_Id, filters, (data)=>
#      if data
#        callback data
#      else
#        callback()
#        #@.query_Tree_Filtered_from_GraphDB query_Id, filters, callback

#  query_Tree_Filtered_from_Cache: (query_Id, filters, callback)=>
#    cache_Key = @.query_Tree_Cache_Key query_Id, filters
#    callback @.cache.get(cache_Key)?.json_Parse()
#
#  query_Tree_Filtered_from_Query_Id: (query_Id, filters, callback)=>
#    @.search_Query_Tree.create_Query_Tree_For_Query_Id query_Id , (data)=>
#      console.log data
#      callback data

#  query_Tree_Filtered_from_GraphDB: (query_Id, filters, callback)=>
#    cache_Key = @.query_Tree_Cache_Key query_Id, filters
#    @.open_Import_Service (import_Service)=>
#      if import_Service
#        if @.cache.has_Key cache_Key                                    # in case the query ID has been added to the cache while wait_For_Unlocked_DB was running
#          import_Service.graph.closeDb =>                              # close the DB and
#            @.query_Tree_Filtered_from_Cache query_Id, filters, callback              # send the data from the cache
#        else
#          import_Service.query_Tree.get_Query_Tree_Filtered query_Id, filters, (data)=>
#            import_Service.graph.closeDb =>
#              if data and data.id
#                @.cache.put cache_Key,data
#              callback data
#      else callback null

#  open_Import_Service: (callback)=>
#      import_Service = new Import_Service(@.graph_Options)
#      unlock_Ok = ->
#        import_Service.graph.openDb (status)=>
#          status = true
#          if status
#            callback import_Service
#          else
#            callback null
#      unload_Fail = ->
#        callback null
#      import_Service.graph.wait_For_Unlocked_DB unlock_Ok, unload_Fail


module.exports = Query_View_Model