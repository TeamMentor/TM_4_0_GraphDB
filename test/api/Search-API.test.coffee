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
    searchApi.assert_Is_Object()
    searchApi.options.area.assert_Is 'search'

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

  it 'article_summaries', (done)->
    clientApi.article_summaries (data)->
      summary = data.obj.assert_Not_Empty().first()
      summary.id.assert_Contains('article-')
      summary.summary.assert_Is_String()
      done()

  it 'query_titles', (done)->
    clientApi.query_titles (data)->
      title = data.obj.assert_Not_Empty().first()
      title.id.assert_Contains('query-')
      title.title.assert_Is_String()
      done()

  # see https://github.com/TeamMentor/TM_4_0_Design/issues/521
  # doesn't work until the search data is parsed and loaded. This should be fixed in an improved version of the search cache
  #it 'query_from_text_search', (done)->
  #  text = 'access'
  #  clientApi.query_from_text_search { text: text}, (data)->
  #    data.obj.assert_Is "search-#{text}"
  #    done()

  # see https://github.com/TeamMentor/TM_4_0_Design/issues/521
  # doesn't work until the search data is parsed and loaded. This should be fixed in an improved version of the search cache
  #it 'word_score', (done)->
  #  word = 'injection'
  #  clientApi.word_score { word: word}, (data)->
  #    log data.obj
  #    done()