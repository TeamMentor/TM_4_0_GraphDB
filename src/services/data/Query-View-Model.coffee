{Cache_Service} = require('teammentor')
#Import_Service  = require './Import-Service'
Search_Query_Tree= require '../search/Search-Query-Tree'
Query_Tree       = require '../query-tree/Query-Tree'

class Query_View_Model
  constructor: (options)->
    @.options           = options || {}
    @.cache             = @.options.cache || new Cache_Service("data_cache")
    @.search_Query_Tree = new Search_Query_Tree()
    @.query_Tree        = new Query_Tree()
    #@.db_Name       = @.options.db_Name || 'tm-uno'
    #@.graph_Options = name: @.db_Name

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
    @.query_Tree_Filtered query_Id, filters, (query_Tree)=>
      if not query_Tree?.id or query_Tree.id isnt query_Id
        return callback { cache_Key: @.query_Tree_Cache_Key(query_Id, filters) }

      view_Model = {}

      @.get_Articles query_Id, filters, from, to, (data_Articles)=>
        @.get_Filters query_Id, filters, (data_Filters)=>
          @.get_Queries query_Id, filters, (data_Queries)=>
            using view_Model, ->
              @._filters = filters
              @._from    = from
              @._to      = to

              @.id       = query_Tree.id
              @.title    = query_Tree.title
              @.size     = query_Tree.results?.size()

              @.queries  = data_Queries
              @.articles = data_Articles
              @.filters  = data_Filters

              callback view_Model

  query_Tree_Cache_Key: (query_Id, filters)=>
    "query_tree_#{query_Id}#{if filters then '_'  else ''}#{filters || ''}.json"

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