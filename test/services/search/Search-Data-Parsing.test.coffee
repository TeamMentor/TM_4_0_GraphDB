
Search_Data_Parsing  = require '../../../src/services/search/Search-Data-Parsing'

describe '| services | search | Search-Data-Parsing', ->
  it 'constructor', ->
    using new Search_Data_Parsing(), ->
      @.assert_Instance_Of Search_Data_Parsing
      @.options            .assert_Is {}
      @.cache         .constructor.name.assert_Is 'CacheService'

  it 'map_Article_Ids', ->
    using new Search_Data_Parsing , ->
      @.map_Article_Ids (article_Ids)->
        article_Ids.assert_Size_Is_Bigger_Than 2000

  it 'map_Article_Root_Queries', ->
    using new Search_Data_Parsing , ->
      @.map_Article_Root_Queries (article_Root_Queries)->
        using article_Root_Queries, ->
          @.keys().assert_Size_Is_Bigger_Than 2000
          @.keys().first().assert_Contains 'article-'
          @.values().first().first().query_Id.assert_Contains 'query-'