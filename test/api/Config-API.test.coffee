TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Config_API       = require '../../src/api/Config-API'

describe '| api | Config-API.test', ->

    tmServer       = null
    swaggerService = null
    clientApi      = null
    configApi      = null

    before (done)->
      port     = 10000 + 10000.random()
      tmServer = new TM_Server({ port : port}).configure()
      options  = { app: tmServer.app ,  port : tmServer.port}
      swaggerService = new Swagger_Service options
      swaggerService.set_Defaults()

      configApi = new Config_API({swaggerService: swaggerService}).add_Methods()

      swaggerService.swagger_Setup()
      tmServer.start()

      swaggerService.get_Client_Api 'config', (swaggerApi)->
        clientApi = swaggerApi
        done()

    after (done)->
      tmServer.stop ->
        done()

    it 'constructor', ->
      Config_API.assert_Is_Function()

    it 'check config section exists', (done)->
      swaggerService.url_Api_Docs.GET_Json (docs)->
        api_Paths = (api.path for api in docs.apis)
        api_Paths.assert_Contains('/config')

        swaggerService.url_Api_Docs.append("/config").GET_Json (data)->
          data.apiVersion    .assert_Is('1.0.0')
          data.swaggerVersion.assert_Is('1.2')
          data.resourcePath  .assert_Is('/config')
          clientApi.assert_Is_Object()
          clientApi.file.assert_Is_Function()
          clientApi.contents.assert_Is_Function()
          done()

    it 'file', (done)->
      clientApi.file (data)->
        data.obj.assert_Is configApi.configService.config_File_Path()
        done()

    it 'contents', (done)->
      clientApi.contents (data)->
        data.obj.assert_Is_Object()
        done()

    it 'delete_data_cache', (done)->
      tmp_Cache_Root = '.tmp_Cache_Folder'
      using configApi.cache, ->
        @._cacheFolder = tmp_Cache_Root
        @.cacheFolder().folder_Create().assert_Folder_Exists()
        @.cacheFolder().path_Combine('test_file.txt').file_Create('aaaa')
        @.cacheFolder().files().assert_Not_Empty()
        clientApi.delete_data_cache (data)=>
          @.cacheFolder().files().assert_Empty()
          data.obj.assert_Is "deleted all files from folder #{@.cacheFolder()}"
          tmp_Cache_Root.folder_Delete_Recursive()
          tmp_Cache_Root.assert_Folder_Not_Exists()
          done()