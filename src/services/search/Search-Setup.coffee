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
    @.key_article_Root_Queries  = 'article_Root_Queries.json'
    @.key_Query_Mappings        = 'query_mappings.json'
    @.key_Tags_Mappings         = 'tags_mappings.json'


  _get_Or_Create_Mapping: (key, action, callback)=>
    if @.cache.has_Key key
      return callback @.cache.get(key)?.json_Parse()

    @.graph.exec_In_DB action, (data)=>
      if data
        @.cache.put key, data
      callback data

  create_Articles: (callback)=>                   # these create_* methods can be refactored since there is lots of repeated code
    action = (next)=>
      @.graph_Find.find_Using_Is 'Article', (articles_Ids)=>
        @.graph_Find.get_Subjects_Data articles_Ids, (data)=>
          next(data)

    @._get_Or_Create_Mapping @.key_Articles,
                             action,
                             callback

  create_Article_Root_Queries: (callback)=>
    @._get_Or_Create_Mapping @.key_article_Root_Queries,
      @.search_Data_Parsing.map_Article_Root_Queries,
      callback


  create_Query_Mappings: (callback)=>

    @._get_Or_Create_Mapping @.key_Query_Mappings,
                             @.query_Mappings.get_Queries_Mappings,
                             callback

  create_Tag_Mappings: (callback)=>

    @._get_Or_Create_Mapping @.key_Tags_Mappings,
                             @.graph_Find.find_Tags
                             callback

    return


    if @.cache.has_Key @.key_Tags_Mappings
      return callback @.cache.get(@.key_Tags_Mappings)?.json_Parse()

    action = (next)=>
      @.graph_Find.find_Tags (data)=>
        if data
          @.cache.put @.key_Tags_Mappings, data
        next data

    @.graph.exec_In_DB action, callback


module.exports = Search_Setup