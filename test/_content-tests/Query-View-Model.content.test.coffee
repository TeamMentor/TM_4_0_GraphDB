Query_View_Model = require '../../src/services/data/Query-View-Model'

describe '| _content-tests | Query-View-Model.content', ->


  it 'get_View_Model (query-9cbfa10fee54, query-b439376de44c)', ()->
    using new Query_View_Model(), ->
      @.get_View_Model 'query-9cbfa10fee54', '', 0, 2, (view_Model)->
        using view_Model, ->
          @._query_Id.assert_Is 'query-9cbfa10fee54'
          @.title    .assert_Is 'Use Role-based Authorization'

      @.get_View_Model 'query-b439376de44c', '', 0, 2, (view_Model)->
        using view_Model, ->
          @._query_Id.assert_Is 'query-b439376de44c'
          @.title    .assert_Is 'Allow Managing Access Controls'

  it 'get_View_Model (query-4440ee60b313)', (done)->
    # check values so that refactoring of query_view_model calculation has no side effects
    query_Id = 'query-4440ee60b313'  # 'Authorization' query
    using new Query_View_Model(), ->
      @.get_View_Model query_Id, '', 0, 2, (view_Model)->
        using view_Model,->
          @._filters  .assert_Is ''
          @._from     .assert_Is 0
          @_to        .assert_Is 2
          @._query_Id .assert_Is 'query-4440ee60b313'
          @.title     .assert_Is 'Concurrency'
          @.size      .assert_Is 9
          @.queries   .assert_Size_Is 4
          @.queries[0].assert_Is  "id": "query-9580060e39dc", "title": "Create Temporary Files Carefully"       , "size": 4
          @.queries[1].assert_Is  "id": "query-47713f85c9d2", "title": "Do Not Cache Results of Security Checks", "size": 1
          @.queries[2].assert_Is  "id": "query-54bb2015d62e", "title": "Use Locks with Mutexes"                 , "size": 2
          @.queries[3].assert_Is  "id": "query-68ca84b61578", "title": "Use Semaphores Correctly"               , "size": 2
          @.articles .assert_Size_Is 2
          @.articles[0].assert_Is "tags": ".NET", "technology": ".NET", "is": "Article", "summary": "Check to ensure that multithreaded code does not cache the results of security checks as it is vulnerable.\r\n  If your multithreaded code caches the results of a security check, perhaps in a static var", "type": "Checklist Item", "phase": "Implementation", "title": "Multithreaded Code Does Not Cache the Results of Security Checks", "guid": "dadddf42-9855-46a8-983d-3b1c76cc63ca", "id": "article-3b1c76cc63ca"
          @.articles[1].assert_Is "is": "Article","tags": "C++", "technology": "C++", "type": "Checklist Item", "phase": "Implementation", "title": "Locks Are Used with Mutexes to Avoid Deadlocks", "summary": "Verify that locks are used with mutexes, instead of manual locking and unlocking.Using std::lock_guard makes it simpler to prevent deadlocks, because it unlocks mutexes automaticaly when a function ex", "guid": "e75f4a58-8ee4-4fda-8ed0-2be0a8a337cf", "id": "article-2be0a8a337cf"
          @.filters.keys().assert_Size_Is 3
          @.filters.Technology.assert_Is [ { "id": "query-8c511380a4f5", "title": ".NET", "size": 1 }, { "id": "query-671d16362ce4", "title": "C++", "size": 8 }]
          @.filters.Phase     .assert_Is [ { "id": "query-66ed61faad6b", "title": "Implementation", "size": 9 } ]
          @.filters.Type      .assert_Is [ { "id": "query-766d8a5e743e", "title": "Checklist Item", "size": 5 }, { "id": "query-454a626d5266", "title": "Guideline", "size": 4 } ]
          done()

  it 'query_view_model (search-owasp , query-7d9a1b64c045)', (done)->
    using new Query_View_Model(), ->
      query_Id = 'search-owasp'
      filters  = 'query-7d9a1b64c045'
      @.get_View_Model query_Id, filters, 0,2,(view_Model)=>
        view_Model.id.assert_Is query_Id
        view_Model.size.assert_Is 29
        done()

  it 'get_View_Model', (done)->
    using new Query_View_Model(), ->
      query_Index = "query-6234f2d47eb7"
      @.get_View_Model query_Index, null, 0,2,(view_Model)=>
        view_Model.assert_Is_Not 	{ error: 'no query tree filtered' }
        view_Model._query_Id.assert_Is query_Index
        query_Authorization = "query-2416c5861783"
        @.get_View_Model query_Authorization, null, 0,2,(view_Model)=>
          view_Model.assert_Is_Not	{ error: 'no query tree filtered' }
          view_Model._query_Id.assert_Is query_Authorization

          done()


  it 'Query_View_Model for all Index queries ',   ()->                                             # takes 498 ms to create, 366 ms from cache
    using new Query_View_Model(), ->
      index_Id = 'query-6234f2d47eb7'
      console.time 'index-query'
      @.get_View_Model (index_Id), '', 0,2,(view_Model)=>                           # takes 146s to create , 101ms from cache
        console.timeEnd 'index-query'
        view_Model._query_Id.assert_Is index_Id
        view_Model.title.assert_Is 'Index'
        query_Ids = (query.id for query in view_Model.queries)

        for query_Id in query_Ids
          console.time query_Id
          @.get_View_Model (query_Id), null, 0,2, (view_Model)->                   # takes 1 ms to 15ms to create 1 ms to 20ms from cache
            console.timeEnd query_Id
            view_Model._query_Id.assert_Is query_Id

