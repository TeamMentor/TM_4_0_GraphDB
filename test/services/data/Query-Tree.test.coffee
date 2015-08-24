#Import_Service = require('./../../../src/services/data/Import-Service')
Search_Query_Tree = require './../../../src/services/search/Search-Query-Tree'
Query_Tree        = require './../../../src/services/query-tree/Query-Tree'

describe '| services | data | Query-Tree.test', ->

  @timeout 5000

  importService  = null
  graph_Find     = null
  query_Mappings = null
  query_Tree     = null

#  before (done)->
#    using new Import_Service(name:'tm-uno'), ->
#      importService  = @
#      graph_Find     = @.graph_Find
#      query_Mappings = @.query_Mappings
#      query_Tree     = @.query_Tree
#      importService.graph.openDb ->
#        done()
#
#  after (done)->
#    importService.graph.closeDb ->
#      done()

  it 'apply_Query_Tree_Query_Id_Filter', (done)->
    using new Query_Tree(), ->
      #query_Id = root_Queries.queries.second().id
      query_Id = 'query-5f606f7d111b'   # Automatically Lock Inactive Accounts
      @.get_Query_Tree query_Id, (query_Tree)=>
        filter = query_Tree.filters.first().results.first()
        using new Search_Query_Tree(), ->
          @.apply_Query_Tree_Query_Id_Filter query_Tree, filter.id, (filtered_Query_Tree)->
            filtered_Query_Tree.results.size().assert_Is(filter.size)
            done();


  it 'get_Query_Tree', (done)->
    using new Query_Tree(), ->
      query_Id = 'query-e93aac2084fe'  # Require Authentication for All Sensitive Operations
      @.get_Query_Tree query_Id, (query_Tree)->
        query_Tree.results.assert_Size_Is_Bigger_Than 14
        query_Tree.id.assert_Is query_Id

        done()

  #TO DO (was failing in travis)
  xit 'get_Query_Tree (search-security)', (done)->
    using importService, ->
      query_Id = 'search-security'
      @.query_Tree.get_Query_Tree query_Id, (query_Tree)->
        log query_Tree.results
        query_Tree.results.assert_Size_Is_Bigger_Than 10
        query_Tree.id.assert_Is query_Id

        done()

  #TO DO
  xit 'get_Query_Tree (confirm containers and filters are alphabetically sorted', (done)->
    using importService, ->
      @.query_Mappings.find_Root_Queries (root_Queries)=>
        query_Id = root_Queries.queries.second().id
        @.query_Tree.get_Query_Tree query_Id, (query_Tree)->
          query_Tree.results = []

          #log query_Tree

          container_Titles = (query.title for query in query_Tree.containers)
          for filter in query_Tree.filters
            filter_Titles = (result.title for result in filter.results )


          #log container_Titles

            log '*************************'
            log filter_Titles
            log '----'
            log filter_Titles.sort()
            log '----'
            log filter_Titles.sort().reverse()
            log '----'
          done()

  xit 'get_Query_Tree_Filters', (done)->
    using importService, ->
      @.graph_Find.find_Articles (articles)=>
        article_Ids = [articles.first(), articles.second()]
        @.query_Tree.get_Query_Tree_Filters article_Ids, (filters)->
          filters.assert_Size_Is 3
          using filters.first(),->
            @.title.assert_Is 'Technology'
            @.results.assert_Not_Empty()
            using @.results.first(), ->
              @.id.assert_Is_String()
              @.title.assert_Is_String()
              @.size .assert_Is_Number()

          done()



  #it.only 'map_Query_Tree', (done)->
  #  using importService, ->
  #    @.find_Root_Queries (queries)=>
  #      @.map_Query_Tree queries.first(), (queryTree)=>
  #        log queryTree
  #        done()
