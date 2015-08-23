# this class will build all the required search artifacts and put them in the search_cache

{Cache_Service}     = require('teammentor')
Graph_Service       = require '../graph/Graph-Service'
Graph_Find          = require '../graph/Graph-Find'
Query_Mappings      = require '../data/Query-Mappings'
Search_Data_Parsing = require './Search-Data-Parsing'

class Search_Setup
  constructor: (options)->
    @.options             = options || {}
    @.cache               = @.options.cache || new Cache_Service("search_cache")
    @.graph               = new Graph_Service name: 'tm-uno'
    @.graph_Find          = new Graph_Find(@.graph)
    @.search_Data_Parsing = new Search_Data_Parsing()
    @.query_Mappings      = new Query_Mappings( graph_Find : @.graph_Find )

    @.key_Articles              = 'articles.json'
    @.key_Article_Ids           = 'article_Ids.json'
    @.key_Article_Root_Queries  = 'article_Root_Queries.json'
    @.key_Query_Mappings        = 'query_mappings.json'
    @.key_Query_Titles          = 'query_titles.json'
    @.key_Tags_Mappings         = 'tags_mappings.json'

  # takes about 3 secs if not of the files exists, and 50ms if they exist
  build_All: (callback)=>
    @.create_Articles =>
      @.create_Article_Ids =>
        @.create_Query_Mappings =>
          @.create_Query_Titles =>
            @.create_Article_Root_Queries =>
              @.create_Tag_Mappings =>
                callback()

  clear_All: ()=>
    @.cache.delete @.key_Articles
    @.cache.delete @.key_Article_Ids
    @.cache.delete @.key_Article_Root_Queries
    @.cache.delete @.key_Query_Mappings
    @.cache.delete @.key_Query_Titles
    @.cache.delete @.key_Tags_Mappings

  create_Articles            : (callback)=> @.get_Or_Create_Mapping @.key_Articles             , @.graph_Find.get_Articles_Data                , callback
  create_Article_Ids         : (callback)=> @.get_Or_Create_Mapping @.key_Article_Ids          , @.search_Data_Parsing.map_Article_Ids         , callback
  create_Article_Root_Queries: (callback)=> @.get_Or_Create_Mapping @.key_Article_Root_Queries , @.search_Data_Parsing.map_Article_Root_Queries, callback
  create_Query_Mappings      : (callback)=> @.get_Or_Create_Mapping @.key_Query_Mappings       , @.query_Mappings.get_Queries_Mappings         , callback
  create_Query_Titles        : (callback)=> @.get_Or_Create_Mapping @.key_Query_Titles         , @.query_Mappings.get_Query_Titles             , callback
  create_Tag_Mappings        : (callback)=> @.get_Or_Create_Mapping @.key_Tags_Mappings        , @.graph_Find.find_Tags                        , callback

  get_Or_Create_Mapping: (key, action, callback)=>
    if @.cache.has_Key key
      return callback @.cache.get(key)?.json_Parse()

    @.graph.exec_In_DB action, (data)=>
      if data
        @.cache.cacheFolder().folder_Create()       # todo this shouldn't be needed
        @.cache.put key, data                       # the @.cache put should create the cache folder if needed
      callback data

module.exports = Search_Setup