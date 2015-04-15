GraphDB_API          = require '../../src/api/GraphDB-API'
Swagger_GraphDB      = require './base-classes/Swagger-GraphDB'
Article              = require '../graph/Article'


class Data_API extends Swagger_GraphDB
  constructor: (options)->
    @.options  = options || {}
    @.options.area = 'data'
    super(options)

  article: (req,res)=>
    ref        = req.params.ref
    cache_Key = "article_#{ref}.json"
    @.open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.find_Article ref, (article_Id)=>
        if (article_Id?)
          data = { article_Id: article_Id}
          @close_Import_Service_and_Send import_Service, res, data, cache_Key
        else
          import_Service.graph.closeDb =>
          res.send data?.json_pretty()

  articles: (req,res)=>
    cache_Key = 'articles.json'
    @.using_Graph_Find res, cache_Key, (send)->
      @.find_Using_Is 'Article', (articles_Ids)=>
        @.get_Subjects_Data articles_Ids, send

  article_Html: (req,res)=>
    id        = req.params.id
    cache_Key = "article_Html_#{id}.json"

    @.using_Import_Service res, cache_Key, (send)->
      new Article(@).html id, (html)->
        data = { html: html }
        send data

  articles_parent_queries: (req,res)=>
    id        = req.params.id
    cache_Key = "articles_parent_queries_#{id}.json"
    @.using_Import_Service res, cache_Key, (send)->
      query_Ids = id.split(',')
      @.queries.map_Articles_Parent_Queries query_Ids, send

  articles_queries: (req,res)=>
    id        = req.params.id
    cache_Key = "articles_queries.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.queries.get_Articles_Queries (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key


  id: (req,res)=>
    id        = req.params.id
    cache_Key = "id_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.get_Subjects_Data [id], (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  library: (req,res)=>
    cache_Key = "library.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.library_Import.library (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  library_Query: (req,res)=>
    @.using_Graph res, 'library_Query.json' , (send)->
      @.search undefined, 'is', 'Library', (data)=>
        send { queryId: data?.first()?.subject }

  queries: (req,res)=>
    cache_Key = "queries.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.find_Queries (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_articles: (req,res)=>
    id        = req.params.id
    cache_Key = "query_articles_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.find_Query_Articles id, (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_queries: (req,res)=>
    id        = req.params.id
    cache_Key = "query_queries_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.find_Query_Queries id, (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_parent_queries: (req,res)=>
    id        = req.params.id
    cache_Key = "query_parent_queries_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.graph_Find.find_Query_Parent_Queries id, (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  queries_mappings: (req,res)=>
    cache_Key = "queries_mappings.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.query_Mappings.get_Queries_Mappings (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_mappings: (req,res)=>
    id        = req.params.id
    cache_Key = "query_mappings_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.query_Mappings.get_Query_Mappings id, (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_tree: (req,res)=>
    id        = req.params.id
    cache_Key = "query_tree_#{id}.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.query_Tree.get_Query_Tree id, (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key

  query_tree_filtered: (req,res)=>
    id       = req.params.id
    filters  = req.params.filters
    cache_Key = "query_tree_filtered_#{id}_#{filters}.json"
    #cache_Key = null
    @.using_Query_Tree res, cache_Key, (send)->
      @.get_Query_Tree id, (query_Tree)=>
        @.apply_Query_Tree_Query_Id_Filter query_Tree, filters, (data)=>
          send data

  root_queries: (req,res)=>
    cache_Key = "root_queries.json"
    @open_Import_Service res, cache_Key, (import_Service)=>
      import_Service.query_Mappings.find_Root_Queries (data)=>
        @close_Import_Service_and_Send import_Service, res, data, cache_Key


  add_Methods: ()=>
    @add_Get_Method 'article'                 , ['ref']
    @add_Get_Method 'articles'                , [     ]
    @add_Get_Method 'article_Html'            , ['id' ]
    @add_Get_Method 'articles_queries'        , [     ]
    @add_Get_Method 'articles_parent_queries' , ['id' ]
    @add_Get_Method 'id'                      , ['id' ]
    @add_Get_Method 'library'                 , [     ]
    @add_Get_Method 'library_Query'           , [     ]
    @add_Get_Method 'query_articles'          , ['id' ]
    @add_Get_Method 'query_mappings'          , ['id' ]
    @add_Get_Method 'query_queries'           , ['id' ]
    @add_Get_Method 'query_parent_queries'    , ['id' ]
    @add_Get_Method 'queries'                 , [     ]
    @add_Get_Method 'queries_mappings'        , [     ]
    @add_Get_Method 'query_tree'              , ['id' ]
    @add_Get_Method 'query_tree_filtered'     , ['id','filters' ]
    @add_Get_Method 'root_queries'            , [     ]
    @


module.exports = Data_API
