class Search_Build
  {Cache_Service} = require('teammentor')

  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("data_cache")

  add_To_Cached_Query_Tree_Filtered: (id, title, containers, articles, filters)->
    search_Data =
      id        : id
      title     : title
      containers: containers
      results   : articles
      filters   : filters
    key = @.query_Tree_Cache_Key(id)
    @.cache.put key, search_Data

  map_Articles: (results)->
    articles_Data = @.cache.get('articles.json').json_Parse()

    article_Ids = (result.id for result in results)

    articles = []
    for article_Id in article_Ids
      if articles_Data[article_Id]
        articles.push articles_Data[article_Id]
    return articles

  map_Filters: (articles)->
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
          raw_filters.Technology.push { id: '...' + key, title: key, size: value}
        for key,value of type
          raw_filters.Type.push { id: '...' + key, title: key, size: value}
        for key,value of phase
          raw_filters.Phase.push { id: '...' + key, title: key, size: value}

        filters = []
        filters.push title: 'Technology', results: raw_filters.Technology
        filters.push title: 'Phase', results: raw_filters.Phase
        filters.push title: 'Type', results: raw_filters.Type

    return filters

  create_Search_TreeView: (text, callback)=>
    console.log "[create_Search_TreeView] for #{text}"
    text = text.lower()



    Search_Text_Service   = require '../text-search/Search-Text-Service'
    search_Service = new Search_Text_Service()
    search_Service.words_Score text, (results)=>

      articles = @.map_Articles results
      filters = @.map_Filters(articles)

      @.add_To_Cached_Query_Tree_Filtered "search-#{text}", text, [],articles, filters

      callback('done')

  query_Tree_Cache_Key: (query_Id, filters)=>
    "query_tree__#{query_Id}#{if filters then '_'  else ''}#{filters || ''}.json"

module.exports = Search_Build