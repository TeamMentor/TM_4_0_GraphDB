Search_Setup = require '../../../src/services/search/Search-Setup'

describe.only 'Search-Setup', ->
  it 'constructor', ->
    using new Search_Setup(),->
      @.assert_Is_Instance_Of Search_Setup
      @.cache.cacheFolder().assert_Folder_Exists()
      @.cache.area.assert_Is 'search_cache'

  it 'create_Tag_Mappings', (done)->
    using new Search_Setup(),->

      @.create_Tag_Mappings (data)->
        data.keys().size().assert_Is 21
        done()
