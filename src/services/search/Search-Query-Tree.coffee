{Cache_Service} = require('teammentor')
Search_Data     = require './Search-Data'

# this creates the query-tree objects which are then used by the main index ui
class Search_Query_Tree
  constructor: (options)->
    @.options       = options || {}
    @.data_Cache        = @.options.data_Cache   || new Cache_Service("data_cache")
    @.search_Cache      = @.options.search_Cache || new Cache_Service("search_cache")
    @.search_Data       = new Search_Data()

    @.raw_Articles           = @.search_Data.articles()
    @.query_Mappings         = @.search_Data.query_Mappings()
    @article_Root_Queries    = @.search_Data.article_Root_Queries()

  cache_Key: (query_Id, filters)=>
    "query_tree_#{query_Id}#{if filters then '_'  else ''}#{filters || ''}.json"

  create_Query_Tree_For_Articles: (query_Id, title, cache_Key, article_Ids, callback)=>

    containers = []
    articles   = []
    filters    = []

    for article_Id in article_Ids
      article = @.raw_Articles[article_Id]
      if article
        articles.push article

    containers = @.map_Queries article_Ids

    filters    = @.map_Filters article_Ids

    callback @.save_Query_Tree query_Id, title, containers, articles, filters, cache_Key

  map_Queries: (article_Ids)=>

    queries = {}
    for article_Id in article_Ids
      root_Queries = @.article_Root_Queries[article_Id]
      if root_Queries
        for root_Query in root_Queries

          id   = root_Query.query_Id
          title = root_Query.query_Title
          queries[id] ?= { id: id, title: title,  size: 0 }
          queries[id].size++

    return queries.values()

  map_Filters: (article_Ids)=>
    articles = []

    for article_Id in article_Ids
      article = @.raw_Articles[article_Id]
      if article
        articles.push article

    technology = {}
    type  = {}
    phase = {}

    for article in articles
      if article
        if article.technology
          technology[article.technology]?= 0
          technology[article.technology]++
        if article.type
          type[article.type]?= 0
          type[article.type]++
        if article.phase
          phase[article.phase]?= 0
          phase[article.phase]++

        raw_filters = { Technology: [] , Type: [] , Phase: []}
        for key,value of technology
          query = @.resolve_Query_From_Title(key) || {}
          raw_filters.Technology.push { id: query.id, title: key, size: value}
        for key,value of type
          query = @.resolve_Query_From_Title(key) || {}
          raw_filters.Type.push { id:  query.id , title: key, size: value}
        for key,value of phase
          query = @.resolve_Query_From_Title(key) || {}
          raw_filters.Phase.push { id: query.id, title: key, size: value}

        filters = []
        filters.push title: 'Technology', results: raw_filters.Technology
        filters.push title: 'Phase', results: raw_filters.Phase
        filters.push title: 'Type', results: raw_filters.Type

    return filters

  resolve_Query_From_Title: (title)=>
    for query_Id, query of @.query_Mappings
      if query.title is title
        return query

    return null

  save_Query_Tree: (query_Id,  title, containers, articles, filters, key)=>
    query_Tree =
      id        : query_Id
      title     : title
      size      : articles?.size()
      containers: containers
      results   : articles
      filters   : filters

    @.data_Cache.put key, query_Tree
    return query_Tree


module.exports = Search_Query_Tree