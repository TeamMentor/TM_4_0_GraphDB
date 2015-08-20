async        = require 'async'

Local_Cache  = { Queries_Mappings : null }

class Query_Mappings

  constructor: (import_Service)->
    @.import_Service = import_Service
    @.graph_Find     = import_Service.graph_Find

  find_Root_Queries: (callback)=>               #rename to something else than 'find_'
    @get_Queries_Mappings (queries_Mappings)=>
      root_Queries =
        id      : 'Root-Queries'
        title   : 'Root Queries'
        queries : []
        articles: []

      check_Query = (query_Id, next)=>
        @graph_Find.find_Query_Parent_Queries query_Id, (parentQueries)=>
          if parentQueries.empty()
            query_Mappings = queries_Mappings[query_Id]
            root_Queries.queries.add query_Mappings #/ [query_Id]= query_Mappings
            #for now don't include these since this needs to be normalize (and was taking too long to map (due to too many articles)
            #root_Queries.articles = root_Queries.articles.concat query_Mappings.articles
            next()
          else
            next()

      add_Root_Queries_To_Queries_Mappings =  ()=>
        queries_Mappings[root_Queries.id] = root_Queries
        callback root_Queries

      @.graph_Find.find_Queries (queries)->
        async.each queries, check_Query, ->
          add_Root_Queries_To_Queries_Mappings()

  get_Queries_Mappings: (callback)=>
    if (Local_Cache.Queries_Mappings)
      return callback(Local_Cache.Queries_Mappings)

    @.graph_Find.find_Queries (query_Ids)=>
      @.graph_Find.get_Subjects_Data query_Ids, (queries)=>

        map_Contains_Article = (article_Ids, target)->
            if article_Ids
              if typeof article_Ids is 'string'
                article_Ids = [article_Ids]
              for article_Id in article_Ids || []
                target.push(article_Id + '')          #note: the weird concat at the end is needed so that (somehow) this string is now seen as an array (in some cases)

        for query_Id in query_Ids
          query = queries[query_Id]
          query.id       ?= query_Id
          query.queries  ?= []
          query.articles ?= []

          child_Query_Ids = query['contains-query']
          if child_Query_Ids
            if typeof child_Query_Ids is 'string'
              child_Query_Ids = [child_Query_Ids]

          for child_Query_Id in child_Query_Ids || []
            child_Query = queries[child_Query_Id]
            #child_Query.id = child_Query_Id
            query.queries.add(child_Query)
            child_Query.parents ?= []
            child_Query.parents.add(query_Id)
            map_Contains_Article child_Query['contains-article'],query.articles


          map_Contains_Article query['contains-article'],query.articles

        # remote 'contains-query' and 'contains-article'
        # add childs to parent
        for query_Id in query_Ids
          query = queries[query_Id]
          delete query['contains-query']
          delete query['contains-article']
          if query.parents
            for parent_Id in query.parents
              queries[parent_Id].articles = queries[parent_Id].articles.concat query.articles

        #ensure article lists is unique
        for query_Id in query_Ids
          query = queries[query_Id]
          query.articles = query.articles.unique()

        # ensure parents articles match child articles (see https://github.com/TeamMentor/TM_4_0_Design/issues/787)
        for query_Id in query_Ids
          query = queries[query_Id]
          if query.queries.not_Empty()
            articles = []
            for child_Query in query.queries
              articles = articles.concat(child_Query.articles)
            if articles.unique().size() isnt query.articles.size()
              "[get_Queries_Mappings] Fixed parent articles for query #{query.id}".log()
              query.articles = articles.unique()

        Local_Cache.Queries_Mappings = queries

        callback(queries)

  get_Query_Mappings: (query_Id,callback)=>
    @.get_Queries_Mappings (queries_Mappings)=>
      callback queries_Mappings[query_Id]

  update_Query_Mappings_With_Search_Id: (query_Id, callback)=>
    @get_Queries_Mappings (queries_Mappings)=>
      @.graph_Find.get_Subject_Data query_Id, (query_Data)=>
        query_Data.articles = query_Data['contains-article']
        query_Data.queries  = query_Data.queries || []
        delete query_Data['contains-article']
        queries_Mappings[query_Id]=query_Data
        callback()

module.exports = Query_Mappings