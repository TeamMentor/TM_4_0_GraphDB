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
    @.article_Root_Queries   = @.search_Data.article_Root_Queries()

  cache_Key: (query_Id, filters)=>
    "query_tree_#{query_Id}#{if filters then '_'  else ''}#{filters || ''}.json"

  # in this mode the queries are calculated from the query_Mapping
  create_Query_Tree_For_Query_Id: (query_Id , callback)=>
    query_Mapping = @.query_Mappings[query_Id]
    if not query_Mapping
      return callback {}

    cache_Key    = @.cache_Key(query_Id, null)
    title        = query_Mapping.title
    article_Ids  = query_Mapping.articles
    articles     = @.map_Articles article_Ids
    containers   = @.map_Queries_For_Query query_Id
    filters      = @.map_Filters  article_Ids

    callback @.save_Query_Tree query_Id, title, containers, articles, filters, cache_Key

  # in this mode the queries are calculated from the articles
  create_Query_Tree_For_Articles: (query_Id, title, cache_Key, article_Ids, callback)=>
    articles    = @.map_Articles article_Ids
    containers  = @.map_Queries article_Ids
    filters     = @.map_Filters article_Ids
    callback @.save_Query_Tree query_Id, title, containers, articles, filters, cache_Key

  map_Articles: (article_Ids)=>
    articles = []
    for article_Id in article_Ids
      article = @.raw_Articles[article_Id]
      if article
        articles.push article
    return articles

  map_Queries_For_Query: (query_Id)=>
    queries = []
    query_Mapping = @.query_Mappings[query_Id]
    if query_Mapping
      for query in query_Mapping.queries
        queries.push { id : query.id , title: query.title, size: query.articles.size(), articles:query.articles }
    return @.sort_Queries queries


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

    articles     = []
    query_Titles = @.search_Data.query_Titles()

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
          technology[article.technology]?= []
          technology[article.technology].push article.id
        if article.type
          type[article.type]?= []
          type[article.type].push article.id
        if article.phase
          phase[article.phase]?= []
          phase[article.phase].push article.id

        raw_filters = { Technology: [] , Type: [] , Phase: []}
        for key,value of technology
          raw_filters.Technology.push { id: query_Titles[key], title: key, size: value.size() , articles: value}
        for key,value of type
          raw_filters.Type.push       { id: query_Titles[key], title: key, size: value.size(), articles: value}
        for key,value of phase
          raw_filters.Phase.push      { id: query_Titles[key], title: key, size: value.size() , articles: value}

        filters = []
        filters.push title: 'Technology', results: raw_filters.Technology
        filters.push title: 'Phase', results: raw_filters.Phase
        filters.push title: 'Type', results: raw_filters.Type

    return filters

  resolve_Query_From_Title: (title)=>
    return query_Titles[title]

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

  sort_Filter: (filter)->
    titles = (result.title.lower() for result in filter.results).sort()
    sorted_Results = []
    for title in titles
      for result in filter.results
        if result.title.lower() is title
          sorted_Results.push result
          continue
    filter.results  = sorted_Results
    filter

  sort_Queries: (queries)->
    titles = (query.title.lower() for query in queries).sort()

    sorted_Queries = []
    for title in titles
      for query in queries
        if query.title.lower() is title
          sorted_Queries.push query
          continue
    sorted_Queries


  apply_Query_Tree_Query_Id_Filter: (query_Tree, query_Ids, callback)=>
    articles = []
    if query_Ids
      for query_Id in query_Ids.split(',')

        filter_Query     = @.query_Mappings[query_Id]
        if filter_Query
          if articles.empty()
            articles = filter_Query.articles
          else
            articles = (article for article in articles when article in filter_Query.articles)


    if articles.empty()
      return callback {}

    @.apply_Query_Tree_Articles_Filter query_Tree, articles, callback

  apply_Query_Tree_Articles_Filter: (query_Tree, articles, callback)=>

    if not query_Tree
      return callback {}

    filtered_Tree =
      id         : query_Tree.id
      containers : query_Tree.containers
      results    : []
      filters    : query_Tree.filters

    if query_Tree.results
      for result in query_Tree.results
        if articles.contains(result.id)
          filtered_Tree.results.add result

    if query_Tree.containers
      for container in query_Tree.containers
        container.size = 0
        for result in filtered_Tree.results
          if container.articles.contains(result.id)
            container.size++

    if query_Tree.filters
      for filter in query_Tree.filters
        for filter_Result in filter.results
          filter_Result.size = 0
          for result in filtered_Tree.results
            if filter_Result.articles.contains(result.id)
              filter_Result.size++

    filtered_Tree.title = query_Tree.title
    callback filtered_Tree

module.exports = Search_Query_Tree