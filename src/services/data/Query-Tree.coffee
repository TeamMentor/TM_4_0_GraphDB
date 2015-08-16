
class Query_Tree

  constructor: (import_Service)->
    @.import_Service = import_Service
    @.graph_Find     = import_Service.graph_Find

  get_Query_Tree: (query_Id,callback)=>
    @.import_Service.query_Mappings.get_Query_Mappings query_Id, (query_Mappings)=>
      if not query_Mappings
        return callback null

      articles = query_Mappings.articles

      if query_Mappings['search-data']
        articles = (item.id for item in query_Mappings['search-data'])

      #log query_Mappings['search-data']

      if typeof(articles) is 'string'         # handle the case when there is one article in query_Mappings.articles
        articles = [articles]

      query_Tree =
        id          : query_Id
        title       : query_Mappings?.title
        resultsTitle: "Showing #{articles.size()} articles",
        containers  : []
        results     : []
        filters     : []

      if not query_Mappings
        callback query_Tree
      else
        for query in query_Mappings.queries
          container =
            id      : query?.id
            title   : query?.title
            size    : query?.articles.size()
            articles: query?.articles

          query_Tree.containers.add container

          query_Tree.containers = @.sort_Containers(query_Tree.containers)

        @get_Query_Tree_Filters articles, (filters)=>
          query_Tree.filters = filters
          @.import_Service.graph_Find.get_Subjects_Data articles, (data)=>
            for article_Id in articles
              article_Data = data[article_Id]
              if article_Data and article_Data.id and article_Data.title                  # enforces that id and title exist
                query_Tree.results.add data[article_Id]                                   # fixes https://github.com/TeamMentor/TM_4_0_Design/issues/742
            callback query_Tree

  get_Query_Tree_Filters: (articles_Ids, callback)=>

    @.import_Service.queries.map_Articles_Parent_Queries articles_Ids , (articles_Parent_Queries)=>
      filters = []
      map_Filter = (filter_Title)=>
        filter =
          title  : filter_Title
          results: []

        for query_Id in articles_Parent_Queries.queries.keys()
          query = articles_Parent_Queries.queries[query_Id]
          if query.title is filter_Title
            for child_Query_Id in query.child_Queries
              child_Query = articles_Parent_Queries.queries[child_Query_Id]
              result =
                id      : child_Query_Id
                title   : child_Query.title
                size    : child_Query.articles.size()
                articles: child_Query.articles

              filter.results.add result


        filters.add @.sort_Filter(filter)

      #map_Filter 'Category'
      map_Filter 'Technology'
      map_Filter 'Phase'
      map_Filter 'Type'

      callback filters

  get_Query_Tree_Filtered: (query_Id, filters, callback)=>
    @.get_Query_Tree query_Id, (query_Tree)=>
      if not filters
        callback query_Tree
      else
        @.apply_Query_Tree_Query_Id_Filter query_Tree, filters, callback

  apply_Query_Tree_Query_Id_Filter: (query_Tree, query_Ids, callback)=>
    @.import_Service.query_Mappings.get_Queries_Mappings (queries_Mappings)=>

      articles = []
      if query_Ids
        for query_Id in query_Ids.split(',')

          filter_Query     = queries_Mappings[query_Id]
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

      for result in query_Tree.results
        if articles.contains(result.id)
          filtered_Tree.results.add result

      #log query_Tree.containers.first()
      for container in query_Tree.containers
        container.size = 0
        for result in filtered_Tree.results
          if container.articles.contains(result.id)
            container.size++

      for filter in query_Tree.filters
        for filter_Result in filter.results
          filter_Result.size = 0
          for result in filtered_Tree.results
            if filter_Result.articles.contains(result.id)
              filter_Result.size++

      filtered_Tree.title = query_Tree.title
      callback filtered_Tree


  #The two sort methods below needs refactoring since there must be a much better way to do this

  sort_Filter: (filter)->
  #filter.results = (filter.results.sort (a,b)-> a.title.lower() - b.title.lower())  # this doesn't work

    titles = (result.title.lower() for result in filter.results).sort()
    sorted_Results = []
    for title in titles
      for result in filter.results
        if result.title.lower() is title
          sorted_Results.push result
          continue
    filter.results  = sorted_Results
    filter

  sort_Containers: (containers)->
    titles = (container.title.lower() for container in containers).sort()

    sorted_Containers = []
    for title in titles
      for container in containers
        if container.title.lower() is title
          sorted_Containers.push container
          continue
    sorted_Containers

module.exports = Query_Tree