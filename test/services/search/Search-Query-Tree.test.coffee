Search_Query_Tree = require '../../../src/services/search/Search-Query-Tree'

describe '| services | Search_Query_Tree', ->
  it 'constructor', ->
    using new Search_Query_Tree(),->
      @.assert_Is_Instance_Of Search_Query_Tree
      @.options                   .assert_Is {}
      @.data_Cache  .cacheFolder().assert_Folder_Exists()
      @.search_Cache.cacheFolder().assert_Folder_Exists()
      @.search_Cache.cacheFolder().files().assert_Not_Empty()
      @.search_Data.constructor.name.assert_Is 'Search_Data'
      @.search_Data.article_Root_Queries().keys().assert_Size_Is_Bigger_Than  2000

  it 'cache_Key' , ->
    using new Search_Query_Tree(),->
      @.cache_Key('aa'     ).assert_Is 'query_tree_aa.json'
      @.cache_Key('aa','bb').assert_Is 'query_tree_aa_bb.json'
      @.cache_Key(null,'bb').assert_Is 'query_tree_null_bb.json'

  it.only 'create_Query_Tree_For_Articles', ->
    using new Search_Query_Tree(),->
      article_Id = "article-fc9facd5e6ff"
      article    = @.search_Data.article(article_Id)

      article_Ids = [article_Id, @.search_Data.article_Ids().first()]

      query_Id    = 'search-test'
      query_Title = 'an search test'
      cache_Key   = @.cache_Key(query_Id)
      @.create_Query_Tree_For_Articles query_Id, query_Title, cache_Key, article_Ids, (query_Tree)=>
        using (query_Tree),->
          @.id   .assert_Is query_Id
          @.title.assert_Is query_Title
          @.results.first().id.assert_Is article_Id
          @.containers.first().articles.assert_Is [article_Id]

        @.data_Cache.has_Key(cache_Key).assert_Is_True()

  it.only 'create_Child_Queries_Using_Articles', (done)->
    using new Search_Query_Tree(),->
      article_Ids = ["article-fc9facd5e6ff"]
      query_Id    = 'search-test'
      query_Title = 'an search test'
      cache_Key   = @.cache_Key(query_Id)
      @.create_Query_Tree_For_Articles query_Id, query_Title, cache_Key, article_Ids, (query_Tree)=>
        using query_Tree.containers[0], ->
          @._original_id.assert_Is_String()
          @.id.assert_Is "#{query_Id}___#{@._original_id}"
          done()

  it 'map_Queries_For_Query', ->
    query_Id = 'query-4440ee60b313'
    using new Search_Query_Tree(),->
      queries = @.map_Queries_For_Query query_Id
      queries.size().assert_Is 4
      queries[0].id   .assert_Is 'query-47713f85c9d2'
      queries[0].title.assert_Is 'Do Not Cache Results of Security Checks'
      queries[0].size .assert_Is 1

  it 'map_Queries', ->
    using new Search_Query_Tree(),->
      article_Id = "article-fc9facd5e6ff"
      article_Ids = [article_Id, @.search_Data.article_Ids().first()]
      queries = @.map_Queries(article_Ids)
      queries.size().assert_Is 2

  it 'map_Filters', ->
    using new Search_Query_Tree(),->
      article_Id = "article-fc9facd5e6ff"
      #target_Articles = [raw_Articles[article_Id], raw_Articles.values().first()]
      article_Ids = [article_Id, @.search_Data.article_Ids().first()]
      filters = @.map_Filters(article_Ids)
      using filters[0], ->
        @.title.assert_Is 'Technology'
        using @.results[0], ->
          @.id.assert_Is 'query-8abb89a8b279'
          @.title.assert_Is 'PHP'


  it 'resolve_Query_From_Title', ->
    using new Search_Query_Tree(),->
      @.resolve_Query_From_Title('Java').title.assert_Is 'Java'
      @.resolve_Query_From_Title('.NET').title.assert_Is '.NET'

      assert_Is_Null @.resolve_Query_From_Title('aaaaaa')

  it 'save_Query_Tree', ->
    using new Search_Query_Tree(),->
      id          = 'an-id'
      title       = 'an title'
      containers  = ['a']
      results     = ['b']
      filters     = ['c']
      key = @.cache_Key 'id', 'filters'

      @.save_Query_Tree id, title, containers, results, filters, key

      @.data_Cache.has_Key(key).assert_Is_True()

      using @.data_Cache.get(key).json_Parse(), ->
        @.id           .assert_Is id
        @title        .assert_Is title
        @.containers  .assert_Is containers
        @.results     .assert_Is results
        @.filters     .assert_Is filters

      @.data_Cache.cacheFolder()
                  .path_Combine(key) .assert_File_Exists()
                  .assert_File_Deleted()

      @.data_Cache.has_Key(key).assert_Is_False()


  it 'create_Query_Tree_For_Query_Id', (done)->
    query_Id = 'query-4440ee60b313'
    using new Search_Query_Tree(),->
      @.create_Query_Tree_For_Query_Id query_Id, (data)->
        data.id.assert_Is query_Id
        done()