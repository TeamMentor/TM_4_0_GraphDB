TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Search_API       = require '../../src/api/Search-API'

describe '| api | Search-API.test', ->

  tmServer       = null
  swaggerService = null
  clientApi      = null
  searchApi      = null

  before (done)->
    port      = 10000 + 10000.random()
    tmServer  = new TM_Server({ port : port}).configure()
    options   = { app: tmServer.app ,  port : tmServer.port}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    #swaggerService.setup()

    searchApi = new Search_API({swaggerService: swaggerService}).add_Methods()
    swaggerService.swagger_Setup()
    tmServer.start()

    swaggerService.get_Client_Api 'search', (swaggerApi)->
      clientApi = swaggerApi
      done()

  after (done)->
    tmServer.stop ->
      done()

  it 'constructor', ->
    using new Search_API(), ->
      @.options.area            .assert_Is 'search'
      @.search.constructor.name .assert_Is 'Search'

      # inherired from Swagger_GraphDB
      @.cache.area              .assert_Is 'data_cache'
      @.cache_Enabled           .assert_Is_True()
      @.db_Name                 .assert_Is 'tm-uno'
      @.graph_Options           .assert_Is name : 'tm-uno'

      # inherited from Swagger_Common
      @.area                    .assert_Is 'search'
      assert_Is_Undefined @.swaggerService




  it 'check search section exists', (done)->
    swaggerService.url_Api_Docs.GET_Json (docs)->
      api_Paths = (api.path for api in docs.apis)
      api_Paths.assert_Contains('/search')

      swaggerService.url_Api_Docs.append("/search").GET_Json (data)->
        data.apiVersion    .assert_Is('1.0.0')
        data.swaggerVersion.assert_Is('1.2')
        data.resourcePath  .assert_Is('/search')
        clientApi.assert_Is_Object()
        done()

  it 'article_titles', (done)->
    clientApi.article_titles (data)->
      title = data.obj.assert_Not_Empty().first()
      title.id.assert_Contains('article-')
      title.title.assert_Is_String()
      done()

#  it 'article_summaries', (done)->
#    clientApi.article_summaries (data)->
#      summary = data.obj.assert_Not_Empty().first()
#      summary.id.assert_Contains('article-')
#      summary.summary.assert_Is_String()
#      done()

  it 'query_titles', (done)->
    clientApi.query_titles (data)->
      title = data.obj.assert_Not_Empty().first()
      title.id.assert_Contains('query-')
      title.title.assert_Is_String()
      done()


  it 'query_from_text_search', (done)->
    search_Query_Tree = searchApi.search.search_Query_Tree

    text     = 'java'
    query_Id  = 'search-java'
    cache_Key = search_Query_Tree.cache_Key query_Id

    search_Query_Tree.data_Cache.delete cache_Key
    search_Query_Tree.data_Cache.has_Key(cache_Key).assert_Is_False()


    clientApi.query_from_text_search text: text, (data)->
      data.obj.assert_Is query_Id
      search_Query_Tree.data_Cache.has_Key(cache_Key).assert_Is_True()
      done()

  it 'word_score', (done)->
    word = 'java'
    clientApi.word_score { word: word}, (data)->
      data.obj.assert_Size_Is_Bigger_Than 300
      done()