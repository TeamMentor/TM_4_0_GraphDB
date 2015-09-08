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
      @.key_Query_Titles        .assert_Is 'query_titles.json'
      @.key_Search_Text_Data    .assert_Is 'search_text_data.json'
      @.key_Search_Text_Articles.assert_Is 'search_text_articles.json'
      @.key_Tags_Mappings       .assert_Is 'tags_mappings.json'

      @.cache             .cacheFolder().assert_Folder_Exists()
      @.cache.area        .assert_Is 'search_cache'

  it 'build_All', (done)->                        # takes 13,706 ms to build, 1,350 ms from cache
    @.timeout 20000
    using new Search_Setup(),->
      #@.clear_All()
      @.build_All =>
        @.cache.has_Key(@.key_Articles            ).assert_Is_True()  # check in the order they were built
        @.cache.has_Key(@.key_Article_Ids         ).assert_Is_True()
        @.cache.has_Key(@.key_Query_Mappings      ).assert_Is_True()
        @.cache.has_Key(@.key_Query_Titles        ).assert_Is_True()
        @.cache.has_Key(@.key_Article_Root_Queries).assert_Is_True()
        @.cache.has_Key(@.key_Search_Text_Data    ).assert_Is_True()
        @.cache.has_Key(@.key_Tags_Mappings       ).assert_Is_True()
        done()


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

  it 'create_Query_Titles', (done)->
    using new Search_Setup(),->
      @.create_Query_Titles (data)=>
        data.keys().first().assert_Not_Contains 'query-'
        data[data.keys().first()].assert_Contains 'query-'
        data.keys().assert_Size_Is_Bigger_Than 250
        @.cache.has_Key(@.key_Query_Mappings).assert_Is_True()
        done()

  it 'create_Search_Text_Data', (done)->
    using new Search_Setup(),->
      @.create_Search_Text_Data (data)=>
        words = (word for word of data)
        words.assert_Size_Is_Bigger_Than 11000     # 11083
        @.cache.has_Key(@.key_Search_Text_Data).assert_Is_True()
        done()

  it.only 'create_Search_Text_Articles', (done)->
    using new Search_Setup(),->
      @.cache.delete @.key_Search_Text_Articles
      @.create_Search_Text_Articles (data)=>
        console.log data
        using data['administrative controls'], ->
          @.text.assert_Is   'Administrative Controls'
          @.source.assert_Is 'article-title'
          @.articles.assert_Is ['article-0899cfd472a6']
        words = (word for word of data)
        console.log words.size()
        words.assert_Size_Is_Bigger_Than 1000     # 11083
        @.cache.has_Key(@.key_Search_Text_Articles).assert_Is_True()
        done()

  it 'create_Tag_Mappings', (done)->
    using new Search_Setup(),->
      #@.cache.delete(key).assert_Is_True()
      @.create_Tag_Mappings (data)=>
        data.keys().size().assert_Is 21
        @.cache.has_Key(@.key_Tags_Mappings).assert_Is_True()
        done()
