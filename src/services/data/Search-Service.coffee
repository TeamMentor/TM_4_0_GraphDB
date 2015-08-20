Import_Service        = require './Import-Service'
Search_Text_Service   = require '../text-search/Search-Text-Service'
Search_Build          = require './Search-Build'
Guid                  = require('teammentor').Guid

class Search_Service

  constructor: (options)->
    @.options       = options || {}
    @.importService = @.options.importService || new Import_Service(name:'tm-uno')
    @.graph         = @.importService.graph

  article_Titles: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data
  article_Summaries: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('summary').as('summary')
                             .solutions (err,data) ->
                                callback data

  query_Titles: (callback)=>
    @.graph.db.nav('Query').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data

  search_Using_Text: (text, callback)=>
    text = text.lower()
    new Search_Text_Service(importService:@.importService).words_Score text, (results)->
      callback results

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  map_Text_Search_Articles: (text, callback)=>
    query_Id = @query_Id_From_Text text

    @.importService.graph_Find.get_Subject_Data query_Id, (data)=>
      if data.is
        callback data.id
        return
      #"[search] calculating search for: #{text}".log()
      # add check if search query already exists
      @.search_Using_Text text, (results)=>
        if results.empty()
          callback null
          return
        article_Ids = (result.id for result in results)

        articles_Nodes = [{ subject:query_Id , predicate:'is'         , object:'Query' }
                          { subject:query_Id , predicate:'is'         , object:'Search' }
                          { subject:query_Id , predicate:'title'      , object: text }
                          { subject:query_Id , predicate:'id'         , object: query_Id }
                          { subject:query_Id , predicate:'search-data', object: results }]


        for article_Id in article_Ids
          articles_Nodes.push { subject:query_Id , predicate:'contains-article'  , object:article_Id }
        @graph.db.put articles_Nodes, =>
          @.importService.graph_Add_Data.add_Is query_Id, 'Query', =>
            @importService.graph_Add_Data.add_Is query_Id, 'Search', =>
              @importService.graph_Add_Data.add_Title query_Id, text, =>
                @importService.query_Mappings.update_Query_Mappings_With_Search_Id query_Id, =>
                  callback(query_Id)

  map_Search_Parent_Queries: (query_id, callback)=>
    if not query_id
      return callback()
    @.importService.query_Tree.get_Query_Tree query_id, (data)=>
      article_Ids = (result.id for result in data.results)
      filters = []
      for filter in data.filters
        for result in filter.results
          filters.push result.title

      ignore_Titles = filters

      @.importService.queries.map_Articles_Parent_Queries article_Ids, (data)->

        matches = []
        for key,query of data.queries
          if key.indexOf('query-') > -1
            query_Data = data.queries[key]
            #if query_Data.child_Queries.size() is 0
            #if query_Data.parent_Queries.size() is 1
            if query_Data.parent_Queries?.first() is 'query-6234f2d47eb7'
              if ignore_Titles.indexOf(query_Data.title) is -1
                matches.push { id: key,  title: query_Data.title, articles: query_Data.articles , size: query_Data.articles.size()}

        callback matches


  create_Search_Parent_Queries_Nodes: (parent_Query, matches, callback)=>
    if not parent_Query
      return callback()

    new_Short_Guid  = (title, guid)->
      new Guid(title, guid).short

    data =  []

    add_Triplet = (subject, predicate, object)->
      data.push({ subject:subject , predicate:predicate  , object:object })

    queries = []

    for match in  matches
      query_id = new_Short_Guid('query')
      add_Triplet query_id, 'is', 'Query'
      add_Triplet query_id, 'title', match.title
      for article in match.articles
        add_Triplet query_id, 'contains-article',article

      add_Triplet parent_Query, 'contains-query', query_id
      queries.push query_id


    @graph.db.put data, =>
      @.importService.query_Mappings.get_Query_Mappings parent_Query, (query_Mappings)=>
        @.importService.graph_Find.get_Subjects_Data queries, (queries_Data)=>
          query_Mappings.queries = queries_Data.values()

          for query_Data in query_Mappings.queries
            query_Data.articles = query_Data['contains-article']
            #delete query_Data['contains-article']

          #console.log query_Mappings.queries
          callback()

  get_Query_Tree: (id, callback)->
    @.importService.query_Tree.get_Query_Tree id, callback


  query_From_Text_Search: (text, callback)=>
    query_Id = @query_Id_From_Text text
    new Search_Build().create_Search_TreeView text, ->
      callback query_Id

    return
    @.map_Text_Search_Articles text, (query_Id)=>
      @.map_Search_Parent_Queries query_Id, (data)=>
        @.create_Search_Parent_Queries_Nodes query_Id, data, ()=>
          callback query_Id




module.exports = Search_Service