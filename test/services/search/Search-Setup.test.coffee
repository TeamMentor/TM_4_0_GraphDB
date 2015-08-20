Search_Setup = require '../../../src/services/search/Search-Setup'

describe 'Search-Setup', ->
  it 'constructor', ->
    using new Search_Setup(),->
      @.assert_Is_Instance_Of Search_Setup
      @.options            .assert_Is {}
      @.cache         .constructor.name.assert_Is 'CacheService'
      @.graph         .constructor.name.assert_Is 'Graph_Service'
      @.graph_Find    .constructor.name.assert_Is 'Graph_Find'
      @.query_Mappings.constructor.name.assert_Is 'Query_Mappings'

      @.key_Articles            .assert_Is 'articles.json'
      @.key_Article_Root_Queries.assert_Is 'article_Root_Queries.json'
      @.key_Query_Mappings      .assert_Is 'query_mappings.json'
      @.key_Tags_Mappings       .assert_Is 'tags_mappings.json'

      @.cache             .cacheFolder().assert_Folder_Exists()
      @.cache.area        .assert_Is 'search_cache'


  it 'create_Articles', (done)->
    @.timeout 3000
    using new Search_Setup(),->
      #@.cache.delete(key).assert_Is_True()
      @.create_Articles (data)=>
        data.keys().first().assert_Contains 'article-'
        data.keys().assert_Size_Is_Bigger_Than 2000
        @.cache.has_Key(@.key_Articles).assert_Is_True()
        done()


  it 'create_Article_Ids', (done)->
    @.timeout 3000
    using new Search_Setup(),->
      @.create_Article_Ids (data)=>
        data.first().assert_Contains 'article-'
        data.assert_Size_Is_Bigger_Than 2000
        @.cache.has_Key(@.key_Article_Ids).assert_Is_True()
        done()

  it 'create_Article_Root_Queries', (done)->
    @.timeout 3000
    using new Search_Setup(),->
      @.create_Article_Root_Queries (data)=>
        data.keys().first().assert_Contains 'article-'
        data.keys().assert_Size_Is_Bigger_Than 2000
        @.cache.has_Key(@.key_Article_Root_Queries).assert_Is_True()
        done()

  it 'create_Query_Mappings', (done)->
    using new Search_Setup(),->
      #@.cache.delete(key).assert_Is_True()
      @.create_Query_Mappings (data)=>
        data.keys().first().assert_Contains 'query-'
        data.keys().assert_Size_Is_Bigger_Than 250
        @.cache.has_Key(@.key_Query_Mappings).assert_Is_True()
        done()

  it 'create_Tag_Mappings', (done)->
    using new Search_Setup(),->
      #@.cache.delete(key).assert_Is_True()
      @.create_Tag_Mappings (data)=>
        data.keys().size().assert_Is 21
        @.cache.has_Key(@.key_Tags_Mappings).assert_Is_True()
        done()
