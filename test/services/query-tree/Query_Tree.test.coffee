Query_Tree = require './../../../src/services/query-tree/Query-Tree'

describe '| services | query-tree | Query-Tree', ->
  it 'construtor', ->
    using new Query_Tree(),->
      @.assert_Instance_Of Query_Tree
      @.options.assert_Is {}
      @.data_Cache       .constructor.name.assert_Is 'CacheService'
      @.search           .constructor.name.assert_Is 'Search'
      @.search_Query_Tree.constructor.name.assert_Is 'Search_Query_Tree'

      @.get_Query_Tree.assert_Is_Function()
      @.get_Query_Tree_Filtered.assert_Is_Function()

  it 'create_Query_Tree (no filters)', ()->
    using new Query_Tree(),->
      query_Id = 'query-4440ee60b313'
      @.create_Query_Tree query_Id, null,(query_Tree)->
        query_Tree.id.assert_Is query_Id

      query_Id = 'search-xss-jsp'
      @.create_Query_Tree query_Id, null,(query_Tree)->
        query_Tree.id.assert_Is query_Id

      @.create_Query_Tree 'query-AAAAAAABBBB', null,(query_Tree)->
        query_Tree.assert_Is {}

      @.create_Query_Tree null, null,(query_Tree)->
        query_Tree.assert_Is {}

    it.only 'create_Query_Tree (with filters)', ()->
    using new Query_Tree(),->
      query_Id = 'search-xss-jsp'
      filters  = 'query-7d9a1b64c045'
      @.create_Query_Tree query_Id, filters,(query_Tree)->
        query_Tree.id.assert_Is query_Id
        console.log query_Tree.results.size()
        console.log query_Tree



  it 'get_Query_Tree', (done)->
    query_Id = 'query-4440ee60b313'
    using new Query_Tree(),->
      @.get_Query_Tree query_Id, (data)->
        data.id.assert_Is query_Id
        done()

  it 'get_Query_Tree_Filtered', (done)->
    query_Id = 'query-4440ee60b313'
    using new Query_Tree(),->
      @.get_Query_Tree_Filtered query_Id, null, (data)->
        data.id.assert_Is query_Id
        done()