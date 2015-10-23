require 'fluentnode'

Search = require './../../src/services/search/Search'

describe '| _content-tests | Search.content', ->

  it 'delete queries (.net and java)', ->
    using new Search(), ->
      delete_Search = (text)=>
        query_Id  = @.query_Id_From_Text(text)
        cache_Key = @.search_Query_Tree.cache_Key(query_Id, null)
        @.search_Query_Tree.data_Cache.delete(cache_Key).assert_True()
        @.search_Query_Tree.data_Cache.has_Key(cache_Key).assert_Is_False()
      delete_Search '.net'
      delete_Search 'java'


  it 'for (.net , .Net and .NET)', (done)->
    using new Search(), ->

      search_For = (text, expected_Id, expected_Size, next)=>
        @.for text, (query_Id,  query_Tree)=>
          query_Id.assert_Is expected_Id
          query_Tree.size.assert_Is expected_Size
          next()

      search_For '.net', 'search-.net', 346, ->
        search_For '.Net', 'search-.net', 346, ->
          search_For '.NET', 'search-.net', 346, ->
            done()

  it 'for (java , Java and JAVA)', (done)->
    using new Search(), ->

      search_For = (text, expected_Id, expected_Size, next)=>
        @.for text, (query_Id,  query_Tree)=>
          query_Id.assert_Is expected_Id
          query_Tree.size.assert_Is expected_Size
          next()


      search_For 'java', 'search-java', 326, ->
        search_For 'Java', 'search-java', 326, ->
          search_For 'JAVA', 'search-java', 326, ->
            done()

  it 'for Administrative Controls', (done)->
    using new Search(), ->
      @.for 'Administrative Controls', (query_Id,  query_Tree)=>
        query_Id.assert_Is 'search-administrative-controls'
        query_Tree.size.assert_Is 27
        done()

  it 'words_Score (CWE-22 full title)', (done)->
    title = "CWE-22: Improper Limitation of a Pathname to a Restricted Directory ('Path Traversal')"
    using new Search(), ->
      @.for title, (query_Id, query_Tree)->
        query_Id.assert_Is        'search-cwe-22--improper-limitation-of-a-pathname-to-a-restricted-directory---path-traversal--'
        query_Tree.title.assert_Is title
        query_Tree.size.assert_Is 1   # this is a bug
        done()


  it 'words_Score (CWE-250 full title)', (done)->
    title = "CWE-250: Execution with Unnecessary Privileges"
    #title = "cwe-250--execution-with-unnecessary-privileges"
    using new Search(), ->
      @.for title, (query_Id, query_Tree)->
        query_Id. assert_Is 'search-cwe-250--execution-with-unnecessary-privileges'
        query_Tree.title.assert_Is title
        query_Tree.size.assert_Is 1
        done()

  it.only 'words_Score (CWE-250 partial title)', (done)->
    title = "CWE 250"
    #title = "cwe-250--execution-with-unnecessary-privileges"
    using new Search(), ->
      @.for title, (query_Id, query_Tree)->
        query_Id. assert_Is 'search-cwe-250'
        query_Tree.title.assert_Is title
        query_Tree.size.assert_Is 1
        done()