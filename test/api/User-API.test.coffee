TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
User_API         = require '../../src/api/User-API'

describe '| api | User-API.test', ->

  tmServer       = null
  swaggerService = null
  clientApi      = null
  userApi        = null

  before (done)->
    port      = 10000 + 10000.random()
    tmServer  = new TM_Server({ port : port}).configure()
    options   = { app: tmServer.app ,  port : tmServer.port}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()

    userApi = new User_API({swaggerService: swaggerService}).add_Methods()

    swaggerService.swagger_Setup()
    tmServer.start()

    swaggerService.get_Client_Api 'user', (swaggerApi)->
      clientApi = swaggerApi
      done()

  after (done)->
    tmServer.stop ->
      done()

  it 'constructor', ->
    User_API.assert_Is_Function()

  it 'setup', ->
    using userApi.target_Folder, ->
      @.assert_Contains ['.tmCache' , '.user_Searches']
      @.assert_Folder_Exists()

  it 'log_search_valid', (done)->
    clientApi.log_search_valid {user:'abc', value:'valid search'}, (data)->
      data.assert_Is_Object()
      done()

  it 'log_search_empty', (done)->
    clientApi.log_search_empty {user:'abc', value:'empty search'}, (data)->
      data.assert_Is_Object()
      done()