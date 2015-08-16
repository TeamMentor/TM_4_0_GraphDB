
Search_Artifacts_Service = require './../../../src/services/text-search/Search-Artifacts-Service'

describe '| services | text-search | Search-Artifacts-Service.test', ->
  article          = null
  import_Service   = null
  library_Data     = null
  search_Artifacts = null
  #article_Ids      = null

  before (done)->
    search_Artifacts = new Search_Artifacts_Service()
    import_Service = search_Artifacts.import_Service
    using import_Service, ()->
      import_Service.graph.openDb =>
        #search_Artifacts.article.ids (_article_Ids)->
        #  article_Ids = _article_Ids
          done()

  after (done)->
    import_Service.graph.closeDb ->
      done()

  it 'constructor',->
    search_Artifacts               .constructor.name.assert_Is 'Search_Artifacts_Service'
    search_Artifacts.import_Service.constructor.name.assert_Is 'ImportService'
    search_Artifacts.article       .constructor.name.assert_Is 'Article'

  it 'create_Tag_Mappings', (done)->
    search_Artifacts. create_Tag_Mappings (tag_Mappings_File)->
      search_Artifacts.cache_Search.path_Key 'tags_mappings.json'
                      .assert_File_Exists()
      done()

