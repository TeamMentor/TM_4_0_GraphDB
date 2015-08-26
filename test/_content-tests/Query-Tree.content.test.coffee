Query_Tree = require './../../src/services/query-tree/Query-Tree'
Search     = require './../../src/services/search/Search'

describe '| _content-tests | Query-Tree.content', ->

  it 'query_Tree (index)',   ()->
    using new Query_Tree(),->
      index_Id = 'query-6234f2d47eb7'
      console.time 'index-query'

      cache_Key = @.cache_Key(index_Id)                  # delete index_Id file
      #@.Search_Query_Tree.data_Cache.delete(cache_Key)

      @.get_Query_Tree (index_Id), (query_Tree)=>
        console.timeEnd 'index-query'
        query_Tree.id.assert_Is index_Id
        query_Tree.title.assert_Is 'Index'
        console.log 'done'

  it 'query_Tree (query-744ce901584b)', ()->        # this (used to be) one of most expensive queries
    using new Query_Tree(),->
      query_Id = 'query-744ce901584b'
      @.delete_Query (query_Id)
      @.get_Query_Tree (query_Id), (query_Tree)=>
        using query_Tree, ->
          @.id.assert_Is query_Id
          @.title.assert_Is 'Standards'
          @.size.assert_Is 483


  it 'query_Tree (query-4440ee60b313)',   ()->
    query_Id = 'query-4440ee60b313'
    using new Query_Tree(),->
      @.cache_Key(query_Id).assert_Is "query_tree_#{query_Id}.json"
      @.get_Query_Tree query_Id, (query_Tree)->
        using query_Tree,->
          @.id      .assert_Is 'query-4440ee60b313'
          @.title   .assert_Is 'Concurrency'
          using @.containers, ->
            @.assert_Size_Is 4
            @[0].assert_Is  "id": "query-47713f85c9d2", "title": "Do Not Cache Results of Security Checks", "size": 1, "articles": [ "article-3b1c76cc63ca" ]
            @[1].assert_Is  "id": "query-54bb2015d62e", "title": "Use Locks with Mutexes"                 , "size": 2, "articles": [ "article-2be0a8a337cf", "article-f3cb4117f676" ]
            @[2].assert_Is  "id": "query-68ca84b61578", "title": "Use Semaphores Correctly"               , "size": 2, "articles": [ "article-bb4d49c5d472", "article-c10b60e5c6a9" ]
            @[3].assert_Is  "id": "query-9580060e39dc", "title": "Create Temporary Files Carefully"       , "size": 4, "articles": [ "article-22493ddbbe9e", "article-293c9784332d", "article-9703ecf83706", "article-b99c29a20f7b" ]
          using @.results, ->
            @.assert_Size_Is 9
            @[0].assert_Is "tags": ".NET", "technology": ".NET", "is": "Article", "summary": "Check to ensure that multithreaded code does not cache the results of security checks as it is vulnerable.\r\n  If your multithreaded code caches the results of a security check, perhaps in a static var", "type": "Checklist Item", "phase": "Implementation", "title": "Multithreaded Code Does Not Cache the Results of Security Checks", "guid": "dadddf42-9855-46a8-983d-3b1c76cc63ca", "id": "article-3b1c76cc63ca"
            @[1].assert_Is "is": "Article","tags": "C++", "technology": "C++", "type": "Checklist Item", "phase": "Implementation", "title": "Locks Are Used with Mutexes to Avoid Deadlocks", "summary": "Verify that locks are used with mutexes, instead of manual locking and unlocking.Using std::lock_guard makes it simpler to prevent deadlocks, because it unlocks mutexes automaticaly when a function ex", "guid": "e75f4a58-8ee4-4fda-8ed0-2be0a8a337cf", "id": "article-2be0a8a337cf"
          using @.filters, ->
            @.assert_Size_Is 3
            @[0].assert_Is title: 'Technology', "results":[{"id":"query-8c511380a4f5","title":".NET","size":1,"articles":["article-3b1c76cc63ca"]},{"id":"query-671d16362ce4","title":"C++","size":8,"articles":["article-2be0a8a337cf","article-f3cb4117f676","article-bb4d49c5d472","article-c10b60e5c6a9","article-22493ddbbe9e","article-293c9784332d","article-9703ecf83706","article-b99c29a20f7b"]} ]
            @[1].assert_Is title :"Phase","results":[{"id":"query-66ed61faad6b","title":"Implementation","size":9,"articles":["article-3b1c76cc63ca","article-2be0a8a337cf","article-f3cb4117f676","article-bb4d49c5d472","article-c10b60e5c6a9","article-22493ddbbe9e","article-293c9784332d","article-9703ecf83706","article-b99c29a20f7b"]}]
            @[2].assert_Is title: "Type","results":[{"id":"query-766d8a5e743e","title":"Checklist Item","size":5,"articles":["article-3b1c76cc63ca","article-2be0a8a337cf","article-bb4d49c5d472","article-9703ecf83706","article-b99c29a20f7b"]},{"id":"query-454a626d5266","title":"Guideline","size":4,"articles":["article-f3cb4117f676","article-c10b60e5c6a9","article-22493ddbbe9e","article-293c9784332d"]}]


  it 'query_Tree (query-a14e68cb74b3)',   (done)->
    query_Id = 'query-a14e68cb74b3'
    using new Query_Tree(),->
      @.get_Query_Tree query_Id, (query_Tree)->
        using query_Tree,->
          query_Tree.assert_Is {}  # this is wrong
          console.log @
          done()

  it 'query-tree (query-4440ee60b313), check results are in alphabetical order',->
    query_Id = 'query-4440ee60b313'
    using new Query_Tree(),->
      @.get_Query_Tree query_Id, (query_Tree)->
        console.log query_Tree.containers.size().assert_Is 4
        titles = (container.title for container in query_Tree.containers)
        console.log titles
        titles.assert_Is [ 'Create Temporary Files Carefully',
                           'Do Not Cache Results of Security Checks',
                           'Use Locks with Mutexes',
                           'Use Semaphores Correctly' ]
        titles[1].assert_Is 'Do Not Cache Results of Security Checks'
        titles[2].assert_Is 'Use Locks with Mutexes'

  it 'query_tree_filtered (search-owasp , query-7d9a1b64c045)', (done)->
    search_Text = 'owasp'
    query_Id    = 'search-owasp'
    filters     = 'query-7d9a1b64c045'

    using new Query_Tree(), ->
      @.get_Query_Tree_Filtered query_Id, filters,(query_Tree)=>
        query_Tree.id.assert_Is query_Id
        query_Tree.results.assert_Size_Is 29
        query_Tree.containers.assert_Size_Is 15
        query_Tree.filters.assert_Size_Is 3
        done()

  it 'query_tree_filtered (search-owasp___query-d43fe5882bcd , query-7d9a1b64c045)', (done)->
    search_Text = 'owasp'
    query_Id    = 'search-owasp___query-d43fe5882bcd'
    filters     = 'query-7ff5431f1878'

    using new Query_Tree(), ->
      @.get_Query_Tree_Filtered query_Id, filters,(query_Tree)=>
        query_Tree.id.assert_Is query_Id
        console.log query_Tree.results
        query_Tree.results.assert_Size_Is 8
        query_Tree.containers.assert_Size_Is 0 #15
        #query_Tree.filters.assert_Size_Is 3
        done()

  it 'Open all Index queries ',   ()->                                      # takes 183ms to create, 84ms from cache
    using new Query_Tree(),->
      index_Id = 'query-6234f2d47eb7'
      console.time 'index-query'
      @.get_Query_Tree (index_Id), (query_Tree)=>                           # takes 68s to create , 16ms from cache
        console.timeEnd 'index-query'
        query_Tree.id.assert_Is index_Id
        query_Tree.title.assert_Is 'Index'
        query_Ids = (container.id for container in query_Tree.containers)
        for query_Id in query_Ids
          console.time query_Id
          @.get_Query_Tree (query_Id), (query_Tree)->                       # takes 1ms to 8ms to create 0ms to 3ms from cache
            console.timeEnd query_Id
            query_Tree.id.assert_Is query_Id

