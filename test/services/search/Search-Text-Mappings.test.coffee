require 'fluentnode'

Search_Text_Mappings = require './../../../src/services/search/Search-Text-Mappings'

describe '| services | search | Search-Text-Mappings ', ->
  it 'constructor',->
    using new Search_Text_Mappings(), ->
      @.options     .assert_Is {}
      @.search_Cache.constructor.name.assert_Is 'CacheService'
      assert_Is_Null @.folder_Lib_UNO_Json

  it 'folder_Raw_Search_Data', ->
    using new Search_Text_Mappings(), ->
      @.folder_Raw_Search_Data().assert_Folder_Exists()

#  it 'search_Mappings', (done)->
#    @.timeout 5000
#    using new Search_Text_Mappings(), ->
#      @.search_Mappings_Raw (search_Mappings)->
#        words_List = (word for word of search_Mappings)
#        #console.log search_Mappings['security'].keys()
#        done()

  it 'search_Words_All', (done)->                         # takes 3384 ms to create , 24ms from cache
    @.timeout 5000
    using new Search_Text_Mappings(), ->
      cache_File = @.search_Cache.cacheFolder().path_Combine(@.key_Search_Words_All)
      @.search_Words_All (search_Words_All)=>
        cache_File.assert_File_Exists()
        search_Words_All.assert_Size_Is_Bigger_Than 30000 # 31917

        done()

  it 'search_Words', (done)->                           # takes 3384 ms to create , 24ms from cache
    @.timeout 5000
    using new Search_Text_Mappings(), ->
      cache_File = @.search_Cache.cacheFolder().path_Combine(@.key_Search_Words)
      @.search_Words (search_Words)=>
        cache_File.assert_File_Exists()
        search_Words.assert_Size_Is_Bigger_Than 11000     # 11083
        done()

  it 'search_Text_Data', (done)->
    @.timeout 12000
    using new Search_Text_Mappings(), ->
      cache_File = @.search_Cache.cacheFolder().path_Combine(@.key_Search_Text_Data)
      @.get_Search_Text_Data (search_Text_Data)=>
        cache_File.assert_File_Exists()
        words = (word for word of search_Text_Data)
        words.assert_Size_Is_Bigger_Than 11000     # 11083
        done()

  it 'search_Text_Articles (Cross Site Scripting)', (done)->
    key        = "cross site scripting";
    using new Search_Text_Mappings(), ->
      @.get_Search_Text_Articles (search_Text_Articles)=>
        search_Text_Articles[key].assert_Is_Not_Null()
        search_Text_Articles[key].source.assert_Is('article-title')
        search_Text_Articles[key].article_Ids.assert_Is_Not_Null()
        search_Text_Articles[key].article_Ids.size().assert_Is 4    #4 articles foe cross site scripting
        done()

  it 'search_Text_Articles (cross site request forgery)', (done)->
    key        = "cross site request forgery";
    using new Search_Text_Mappings(), ->
      @.get_Search_Text_Articles (search_Text_Articles)=>
        search_Text_Articles[key].assert_Is_Not_Null()
        search_Text_Articles[key].source.assert_Is('article-title')
        search_Text_Articles[key].article_Ids.assert_Is_Not_Null()
        search_Text_Articles[key].article_Ids.size().assert_Is 4    #4 articles foe cross site scripting
        done()