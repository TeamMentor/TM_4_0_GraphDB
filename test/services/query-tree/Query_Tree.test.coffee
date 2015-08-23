Query_Tree = require './../../../src/services/query-tree/Query-Tree'

describe '| services | query-tree | Query-Tree', ->
  it 'construtor', ->
    using new Query_Tree(),->
      @.assert_Instance_Of Query_Tree
      @.options.assert_Is {}
      @.get_Query_Tree.assert_Is_Function()
      @.get_Query_Tree_Filtered.assert_Is_Function()

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