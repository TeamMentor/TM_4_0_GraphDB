TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Convert_API      = require '../../src/api/Convert-API'

describe '| api | Convert-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      convertApi     = null

      before (done)->
        port     = 10000.add(10000.random())
        tmServer = new TM_Server({ port : port}).configure()
        options  = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service(options)
        swaggerService.set_Defaults()

        convertApi = new Convert_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'convert', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        convertApi.assert_Is_Object()
        convertApi.swaggerService.assert_Is swaggerService
        convertApi.options.area.assert_Is 'convert'


      it 'check convert section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/convert')

          swaggerService.url_Api_Docs.append("/convert").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')      # ERROR IS HERE
            data.resourcePath  .assert_Is('/convert')
            clientApi.assert_Is_Object()
            done()

      it 'to_ids (bad data)', (done)->
        @.timeout 20000                     # since this is the first test to hit the DB, if the db doesn't exist this will trigger a reload
        check = (send, expect, next)->
          clientApi.to_ids {values: send }, (data)->
            data.obj.assert_Is expect
            next()

        check 'abcdefg' , { abcdefg : { } }, ->
          check 'abcdefg , 123456 ' , { abcdefg: {} , 123456: {} }, ->
            done()

      it 'to_Ids (one value)', (done)->
        values = 'Technology'
        clientApi.to_ids {values: values }, (data)->
          using data.obj[values], ->
            @.id.assert_Is_String()
            @.title.assert_Is values
            query_Id = @.id
            clientApi.to_ids {values: query_Id }, (data)->
              using data.obj[query_Id], ->
                @.id.assert_Is query_Id
                @.title.assert_Is values
                done()

      it 'to_Ids (multiple values data)', (done)->
        values = 'aaa, Technology, Type, Category, Phase, bbb'
        clientApi.to_ids {values: values }, (data)->
          result = data.obj
          result.keys().assert_Size_Is values.split(',').size()
          result['aaa'].assert_Is {}
          result['bbb'].assert_Is {}
          result['Technology'].title.assert_Is    ('Technology')
          result['Phase'     ].title.assert_Is_Not('Technology')
          done()