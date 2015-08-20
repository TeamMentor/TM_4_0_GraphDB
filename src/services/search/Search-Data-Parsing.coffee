{Cache_Service} = require('teammentor')

class Search_Data_Parsing
  constructor: (options)->
    @.options                  = options || {}
    @.cache                    = @.options.cache || new Cache_Service("search_cache")
    @.key_Query_Mappings       = 'query_mappings.json'
    @.key_Articles             = 'articles.json'
    @.key_Article_Ids          = 'article_Ids.json'
    @.key_Article_Root_Queries = 'article_Root_Queries.json'
    @.index_Query_Id           = 'query-6234f2d47eb7'

  map_Article_Ids: (callback)=>
    if @.cache.has_Key(@.key_Articles) is false
      return callback null
    callback @.cache.get(@.key_Articles)?.json_Parse().keys()

  map_Article_Root_Queries: (callback)=>

    if @.cache.has_Key(@.key_Query_Mappings) is false
      return callback null
    query_Mappings = @.cache.get(@.key_Query_Mappings).json_Parse()

    article_Root_Queries = {}
    add_Article_Mapping =  (article_Id, query_Id, query_Title)->
      article_Root_Queries[article_Id] ?= []
      article_Root_Queries[article_Id].push( {query_Id: query_Id, query_Title } )

    for query_Id, query_Data of  query_Mappings
      if query_Data.parents?.first() is @.index_Query_Id
        for article_Id in query_Data.articles
          add_Article_Mapping article_Id, query_Id, query_Data.title

    callback article_Root_Queries



module.exports = Search_Data_Parsing