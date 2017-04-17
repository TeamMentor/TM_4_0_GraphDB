class Queries

  import_Service = null

  constructor: (import_Service)->
    @.import_Service = import_Service

  get_Articles_Queries: (callback)=>
    @.import_Service.query_Mappings.get_Queries_Mappings (queries_Mappings)=>
      articles_Queries = {}

      for query_Id in queries_Mappings.keys_Own()
        query = queries_Mappings[query_Id]
        for article_Id in  query.articles
          articles_Queries[article_Id] ?= []
          query = queries_Mappings[query_Id]
          articles_Queries[article_Id].add(query_Id) #[query_Id] = { title: query.title , is: query.is }

      callback articles_Queries, queries_Mappings

  map_Articles_Parent_Queries:  (article_Ids, callback)=>

    result = { articles:{} , queries: {} }

    @get_Articles_Queries (articles_Queries,queries_Mappings)=>
      for article_Id in article_Ids
        @map_Article_Parent_Queries articles_Queries,queries_Mappings , result, article_Id

      #remove duplicate mappings
      for key in result.queries.keys_Own()
        using result.queries[key],->
          @.articles       = @.articles      .unique()
          @.parent_Queries = @.parent_Queries.unique()
          @.child_Queries  = @.child_Queries .unique()

      callback result


  map_Article_Parent_Queries:  (articles_Queries,queries_Mappings, result, article_Id)=> # making this run async had massive performance issues

    result = result || { articles:{} , queries: {} }
    get_Query_Node = (query_Id)=>
      if result.queries[query_Id]
        result.queries[query_Id]
      else
        query = queries_Mappings[query_Id]
        result.queries[query_Id] = { title: query.title, articles:[] , parent_Queries: [], child_Queries: []}

    map_Query_Ids = (article_Id, query_Ids ,source) =>
      if query_Ids
        for query_Id in query_Ids
          map_Query_Id article_Id, query_Id, source

    map_Query_Id = (article_Id, query_Id, source) =>
      target_Node = get_Query_Node query_Id
      parents = queries_Mappings[query_Id].parents
      #log "[#{source}] : #{query_Id}: #{target_Node.title} = #{queries_Mappings[query_Id].parents}";
      if source
        child_Node = get_Query_Node source
        child_Node.parent_Queries.add query_Id
        child_Node.articles.push article_Id
        target_Node.child_Queries.add source

      target_Node.articles.push article_Id
      map_Query_Ids article_Id, parents, query_Id


    parent_Queries              = articles_Queries[article_Id]
    result.articles[article_Id] = { parent_Queries: parent_Queries}

    map_Query_Ids article_Id, parent_Queries, null

    #log result.queries.keys().size()
    #for key in result.queries.keys()
    #  using result.queries[key],->
    #    @.articles       = @.articles      .unique()
    #    @.parent_Queries = @.parent_Queries.unique()
    #    @.child_Queries  = @.child_Queries .unique()

    result

module.exports = Queries