Search_Data = require '../../../src/services/search/Search-Data'

describe 'Search-Data', ->
  it 'constructor', ->
    using new Search_Data(),->
      @.assert_Is_Instance_Of Search_Data
      @.cache.cacheFolder().assert_Folder_Exists()
      @.cache.area.assert_Is 'search_cache'

  it 'get_Data', ->
    using new Search_Data(),->
      @.get_Data('aaa').assert_Is {}

  it 'articles', ->
    using new Search_Data(),->
      using @.articles(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 2000
        @.keys().first()  .assert_Contains 'article-'
        @.values().first().title.assert_Is_String()

  it 'query_Mappings', ->
    using new Search_Data(),->
      using @.query_Mappings(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 20
        @.keys().first()  .assert_Contains 'query-'
        @.values().first().title.assert_Is_String()

  it 'tag_Mappings', ->
    using new Search_Data(),->
      @.tag_Mappings().keys() .assert_Size_Is_Bigger_Than 20
      @.tag_Mappings()['java'].assert_Size_Is_Bigger_Than 300