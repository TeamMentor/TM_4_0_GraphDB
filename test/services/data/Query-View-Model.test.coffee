Query_View_Model = require '../../../src/services/data/Query-View-Model'

describe '| services | data | Query-View-Model', ->

  it 'constructor', ->
    using new Query_View_Model(), ->
      @.options           .assert_Is {}
      @.cache             .cacheFolder().assert_Folder_Exists()
      @.search_Query_Tree.constructor.name.assert_Is 'Search_Query_Tree'
      #@.db_Name      .assert_Is 'tm-uno'
      #@.graph_Options.assert_Is name : 'tm-uno'

  it 'get_Articles', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    from    = 0
    to      = 10
    using new Query_View_Model(), ->
      @.get_Articles query_Id, filters, from, to, (articles)->
        articles.assert_Size_Is to - from
        done()

  it 'get_Articles (with filters)', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = 'query-8c511380a4f5'   # '.NET' filter
    from    = 0
    to      = 10
    using new Query_View_Model(), ->
      @.get_Articles query_Id, filters, from, to, (articles)->
        articles.assert_Size_Is to - from
        done()

  it 'get_Filters', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    using new Query_View_Model(), ->
      @.get_Filters query_Id, filters, (filters)->
        filters['Technology'].first().assert_Is id: 'query-8c511380a4f5', title: '.NET'           , size: 14
        filters['Type'      ].first().assert_Is id: 'query-766d8a5e743e', title: 'Checklist Item' , size: 21
        filters['Phase'     ][2].assert_Is id: 'query-28b25f1c32d5', title: 'Deployment'     , size: 5
        done()

  it 'get_Filters (with filters)', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = 'query-8c511380a4f5'   # '.NET' filter
    using new Query_View_Model(), ->
      @.get_Filters query_Id, filters, (filters)->
        filters['Technology'].first().assert_Is id: 'query-8c511380a4f5', title: '.NET'           , size: 14
        filters['Type'      ].first().assert_Is id: 'query-766d8a5e743e', title: 'Checklist Item' , size: 5
        filters['Phase'     ].second().assert_Is id: 'query-7ff5431f1878', title: 'Design'         , size: 1
        done()

  it 'get_Queries', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    using new Query_View_Model(), ->
      @.get_Queries query_Id, filters, (queries)->
        queries.size().assert_Is 6
        queries.first().assert_Is { id: 'query-8796dadb178e', title: 'Check Authorization for All Operations', size: 29 }
        done()

  it 'get_Queries (with filters)', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = 'query-8c511380a4f5'   # '.NET' filter
    using new Query_View_Model(), ->
      @.get_Queries query_Id, filters, (queries)->
        queries.size().assert_Is 6
        queries.first().assert_Is { id: 'query-8796dadb178e', title: 'Check Authorization for All Operations', size: 4 }
        done()

  it 'get_View_Model', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    from    = 0
    to      = 10
    using new Query_View_Model(), ->
      @.get_View_Model query_Id, filters, from, to, (view_Model)->
        view_Model.assert_Is_Object()
        using view_Model, ->
          @._filters .assert_Is filters
          @._from    .assert_Is from
          @._to      .assert_Is to
          @.size     .assert_Is 71
          @.articles.assert_Size_Is to - from
          @.filters.keys().assert_Is ['Technology', 'Phase', 'Type']
          @.queries.assert_Size_Is 6
          done()

  it 'get_View_Model (bad query)', (done)->
    using new Query_View_Model(), ->
      @.get_View_Model 'aaaa1234', null, null, null, (view_Model)->
        view_Model.assert_Is cache_Key: 'query_tree_aaaa1234.json'
        done()

  it 'query_Tree_Filtered', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    using new Query_View_Model(), ->
      @.query_Tree_Filtered query_Id, filters, (data)->
        data.id.assert_Is query_Id
        done()

  it 'query_Tree_Filtered_from_Cache', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    using new Query_View_Model(), ->
      @.query_Tree_Filtered_from_Cache query_Id, filters, (data)->
        data.id.assert_Is query_Id
        done()

  it 'query_Tree_Filtered_from_Query_Id', (done)->
    query_Id = 'query-2416c5861783'  # 'Authorization' query
    filters = ''
    using new Query_View_Model(), ->
      @.query_Tree_Filtered_from_Query_Id query_Id, filters, (data)->
        console.log data
        done()

  it.only 'get_View_Model', (done)->

    done()

#  it 'query_Tree_from_GraphDB', (done)->
#    query_Id = 'query-2416c5861783'  # 'Authorization' query
#    filters = ''
#    using new Query_View_Model(), ->
#      @.query_Tree_Filtered_from_GraphDB query_Id, filters, (data)->
#        using data,->
#          @.id.assert_Is query_Id
#          @.title.assert_Is 'Authorization'
#          @.containers.assert_Not_Empty()
#          @.results.assert_Not_Empty()
#          @.filters.assert_Not_Empty()
#          done()

#  it 'query_Tree (bad @.open_Import_Service)', (done)->
#    using new Query_View_Model(), ->
#      @.open_Import_Service = (callback)-> callback null
#      @.query_Tree_Filtered_from_GraphDB null ,null, (data)=>
#        assert_Is_Null data
#        done()


#  it 'open_Import_Service', (done)->
#    using new Query_View_Model(), ->
#      @.open_Import_Service (importService)=>
#        importService.graph.db.assert_Is_Object()
#        importService.graph.closeDb ->
#          done()
#
#  it 'open_Import_Service (graphDB not available)', (done)->
#    query_View_Model =  new Query_View_Model()
#
#    query_View_Model.open_Import_Service (importService_1)=>
#      assert_Is_Not_Null importService_1
#      query_View_Model.graph_Options.db_Lock_Tries = 2
#      query_View_Model.graph_Options.db_Lock_Delay = 10
#      query_View_Model.open_Import_Service (importService_2)=>
#        assert_Is_Null importService_2
#        importService_1.graph.closeDb ->
#          done()



  # search stuff
  it 'query_Tree_Cache_Key', ->
    using new Query_View_Model(), ->
      @.query_Tree_Cache_Key('aa'      ).assert_Is 'query_tree_aa.json'
      @.query_Tree_Cache_Key('aa', null).assert_Is 'query_tree_aa.json'
      @.query_Tree_Cache_Key('aa','bb' ).assert_Is 'query_tree_aa_bb.json'
      @.query_Tree_Cache_Key(null      ).assert_Is 'query_tree_null.json'


#  add_To_Cached_Query_Tree_Filtered = (id, title, containers, articles, filters)->
#    using new Query_View_Model(), ->
#
#      search_Data =
#        id        : id
#        title     : title
#        containers: containers
#        results   : articles
#        filters   : filters
#      key = @.query_Tree_Cache_Key(id)
#      @.cache.put key, search_Data
#
#  create_Search_Queries = ->
#    containers =
#      [
#        {
#          "id": "search-abc-a14e68cb74b3",
#          "title": "Administrative Controls",
#          "size": 1,
#          "articles": [
#            "article-cd025261450d"
#          ]
#        } ]
#
#    filters = []
#
#    #filters.push  title: 'Technology', results: [ { "id": "query-8c511380a4f5", "title": ".NET", "size": 1 , articles: [ "article-c1fda766a7f8"] }, { "id": "query-7d9a1b64c045", "title": "Java"  , "size": 75 , "articles": [ "article-56b13408793d","article-675c7336a2e8"] } ] ,
#    filters.push  title: 'Technology' ,results: [ { "id": "query-8c511380a4f5", "title": ".NET",  "size": 1 , articles: [ "article-c1fda766a7f8"] } , { "id": "query-7d9a1b64c045", "title": "Java"  , "size": 75 } ]
#    filters.push  title: 'Phase'     , results: [ { "id": "query-28b25f1c32d5", "title": "Deployment", "size": 6 , articles: [ "article-c1fda766a7f8"] }, { "id": "query-7ff5431f1878", "title": "Design"    , "size": 19 }]
#
#    #console.log filters
#
#    articles = [ { id: 'article-f19862f736d4' , title: 'How to Test for Server-Side Code Injection in Java', summary: 'summary goes here', type: "Checklist Item", phase: "Implementation", "technology": "Java" }
#                 { id: 'article-9cff045cc1c4' , title: 'Directory Browsing Is Disabled'                    , summary: 'another goes here', type: "Guideline"     , phase: "Implementation", "technology": "Java" }]
#
#    add_To_Cached_Query_Tree_Filtered 'search-abc', 'Search ABC 2', containers, articles , filters
#
#    add_To_Cached_Query_Tree_Filtered 'search-abc-a14e68cb74b3', 'Administrative Controls', [], articles , filters
#
#  it.only 'Test dynamic search results', (done)->
#    using new Query_View_Model(), ->
#      create_Search_Queries()
#      search_Id = 'search-abc'
#      filters     = "query_7d9a1b64c045"
#      @.query_Tree_Filtered search_Id, filters, (data)=>
#        console.log data
#        done()
