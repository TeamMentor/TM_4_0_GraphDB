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


  it.only 'for (.net , .Net and .NET)', (done)->
    using new Search(), ->

      search_For = (text, expected_Id, expected_Size, next)=>
        @.for text, (query_Id,  query_Tree)=>
          query_Id.assert_Is expected_Id
          query_Tree.size.assert_Is expected_Size
          next()


      search_For '.net', 'search-.net', 12, ->
        search_For '.Net', 'search-.net', 12, ->
          search_For '.NET', 'search-.net', 346, ->
            done()

  it 'for (java , Java and JAVA)', (done)->
    using new Search(), ->

      search_For = (text, expected_Id, expected_Size, next)=>
        @.for text, (query_Id,  query_Tree)=>
          query_Id.assert_Is expected_Id
          query_Tree.size.assert_Is expected_Size
          next()


      search_For 'java', 'search-java', 441, ->
        search_For 'Java', 'search-java', 441, ->
          search_For 'JAVA', 'search-java', 441, ->
            done()

  it.only 'for Administrative Controls', (done)->
    using new Search(), ->
      @.for 'Administrative Controls', (query_Id,  query_Tree)=>
        query_Id.assert_Is 'search-administrative-controls'
        query_Tree.size.assert_Is 1
        done()