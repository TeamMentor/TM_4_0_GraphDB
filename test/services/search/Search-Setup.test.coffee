Search_Setup = require '../../../src/services/search/Search-Setup'

describe.only 'Search-Setup', ->
  it 'constructor', ->
    using new Search_Setup(),->
      @.assert_Is_Instance_Of Search_Setup
      console.log @.cache.cacheFolder()
      console.log @.cache.cacheFolder().files().file_Names()

  it 'create_Tag_Mappings', ->
