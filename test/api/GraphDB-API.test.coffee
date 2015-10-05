TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
GraphDB_API      = require '../../src/api/GraphDB-API'

describe '| api | GraphDB-API.test', ->

  tmServer       = null
  swaggerService = null
  clientApi      = null
  graphDbApi      = null

  @.timeout 5000
  
  beforeEach (done)->
    graphDbApi = new GraphDB_API()
    port       = 10000 + 10000.random()
    tmServer   = new TM_Server({ port : port}).configure()
    options    = { app: tmServer.app ,  port : tmServer.port}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    #swaggerService.setup()

    graphDbApi = new GraphDB_API({swaggerService: swaggerService}).add_Methods()
    swaggerService.swagger_Setup()
    tmServer.start()

    swaggerService.get_Client_Api 'graph-db', (swaggerApi)->
      clientApi = swaggerApi
      done()

  afterEach (done)->
    tmServer.stop ->
      done()

  it 'constructor', ->
    graphDbApi.assert_Is_Object()
    graphDbApi.options.area = 'graph-db'


  it 'check config section exists', (done)->
    swaggerService.url_Api_Docs.GET_Json (docs)->
      api_Paths = (api.path for api in docs.apis)
      #api_Paths.assert_Contains('/list')
      api_Paths.assert_Contains('/graph-db')

      swaggerService.url_Api_Docs.append("/graph-db").GET_Json (data)->
        data.apiVersion    .assert_Is('1.0.0')
        data.swaggerVersion.assert_Is('1.2')
        data.resourcePath  .assert_Is('/graph-db')
        clientApi.assert_Is_Object()
        done()

  it 'contents', (done)->
    clientApi.contents { value: 'iOs'}, (data)->
      data.obj.assert_Size_Is_Bigger_Than(1700)
      done()

  it 'subjects', (done)->
    clientApi.subjects (data)->
      data.obj.assert_Not_Empty()
      done()

  it 'predicates', (done)->
    clientApi.predicates (data)->
      data.obj.assert_Not_Empty()
      done()

  it 'objects', (done)->
    clientApi.objects (data)->
      data.obj.assert_Not_Empty()
      done()

  it 'subject', (done)->
    clientApi.subject { value: 'query-'}, (data)->
      data.obj.assert_Size_Is(0)
      done()

  it 'predicate', (done)->
    clientApi.predicate { value: 'title'}, (data)->
      data.obj.assert_Size_Is_Bigger_Than(200)
      done()

  it 'object', (done)->
    clientApi.predicate { value: 'title'}, (data)->
      value = data.obj.first().object
      clientApi.object { value: value}, (data)->
        data.obj.first().object.assert_Is value
        done()

  it 'pre_obj', (done)->
    clientApi.pre_obj { predicate: 'is' , object: 'Article'}, (data)->
      data.obj.assert_Not_Empty()
              .first().subject.assert_Contains 'article-'
      done()

  it 'sub_pre', (done)->
    clientApi.pre_obj { predicate: 'is' , object: 'Article'}, (data)->
      article_Id = data.obj.first().subject
      clientApi.sub_pre { subject: article_Id, predicate: 'is' }, (data)->
        data.obj.first().object.assert_Is 'Article'
        done()

  it 'status', (done)->
    clientApi.status (data)->
      console.log data.obj.assert_Is status: 'ok'
      done()

  it 'cache_path', (done)->
    clientApi.cache_path (data)->
      using data.obj.path, ->
        @.assert_Folder_Exists()
        @.files().file_Names().first().assert_Is 'tm-uno-loaded.flag'
        @.folders().file_Names().assert_Contains(['data_cache','tm-uno'])
        done()