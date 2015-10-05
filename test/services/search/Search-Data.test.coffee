Search_Data = require '../../../src/services/search/Search-Data'

describe 'Search-Data', ->
  it 'constructor', ->
    using new Search_Data(),->
      @.assert_Is_Instance_Of Search_Data
      @.cache.cacheFolder().assert_Folder_Exists()
      @.cache.area.assert_Is 'search_cache'

      @.key_Article_Root_Queries.assert_Is 'article_Root_Queries.json'

  it 'get_Data', ->
    using new Search_Data(),->
      @.get_Data('aaa').assert_Is {}

  it 'article', ->
    using new Search_Data(),->
      article_Id =  @.article_Ids().first()
      using @.article(article_Id), ->
        @.id.assert_Is article_Id
        @.title.assert_Is_String()

      using @.article('article-fc9facd5e6ff'), ->
        @.title     .assert_Is 'Unusual Activity Is Logged'
        @.guid      .assert_Is 'c45bfc8a-0b24-43ad-993f-fc9facd5e6ff'
        @.type      .assert_Is 'Checklist Item'
        @.technology.assert_Is 'PHP'
        @.phase     .assert_Is 'Design'
        @.id        .assert_Is 'article-fc9facd5e6ff'

  it 'articles', ->
    using new Search_Data(),->
      using @.articles(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 2000
        @.keys().first()  .assert_Contains 'article-'
        @.values().first().title.assert_Is_String()

  it 'article_Ids', ->
    using new Search_Data(),->
      using @.article_Ids(), ->
        @          .assert_Size_Is_Bigger_Than 2000
        @.first()  .assert_Contains 'article-'
  it 'article_Root_Queries', ->
    using new Search_Data(),->
      using @.article_Root_Queries(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 2000
        @.keys().first()  .assert_Contains 'article-'
        @.values().first().first().query_Id.assert_Contains 'query-'

  it 'query_Mappings', ->
    using new Search_Data(),->
      using @.query_Mappings(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 20
        @.keys().first()  .assert_Contains 'query-'
        @.values().first().title.assert_Is_String()

  it 'query_Titles', ->
    using new Search_Data(),->
      using @.query_Titles(), ->
        @.keys()          .assert_Size_Is_Bigger_Than 20
        @.keys().first()  .assert_Not_Contains 'query-'
        @.values().first().assert_Contains 'query-'

  it 'search_Text_Data', ->
    using new Search_Data(),->
      using @.search_Text_Data(),->
        words = (word for word of @)
        words.assert_Size_Is_Bigger_Than 11000     # 11083


  it 'tag_Mappings', ->
    using new Search_Data(),->
      @.tag_Mappings().keys() .assert_Size_Is_Bigger_Than 20
      @.tag_Mappings()['java'].assert_Size_Is_Bigger_Than 300