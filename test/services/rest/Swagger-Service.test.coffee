TM_Server        = require '../../../src/TM-Server'
Swagger_Service  = require '../../../src/services/rest/Swagger-Service'
supertest        = require 'supertest'

describe '| services | rest | Swagger-Service.test', ->

  url_server     = null
  url_api_docs   = null
  server         = null
  swaggerService = null
  swaggerApi     = null

  before (done)->
    port     = 10000 + 10000.random()
    server  = new TM_Server({ port : port}).configure()
    options = { app: server.app ,  port : port}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    ping =
          spec              : { path : "/say/ping/", nickname : "ping"}
          action            : (req, res)-> res.send {'ping': 'pong'}
    swaggerService.addGet ping
    swaggerService.swagger_Setup()
    server.start()
    done()

  after (done)->
    server.stop ->
      done()
  it 'get_Client_Api', (done)->
    swaggerService.get_Client_Api 'say', (clientApi)->

      clientApi.assert_Is_Object()
      clientApi.operations.ping.assert_Is_Object()
      clientApi.ping (response)->
        response.obj.assert_Is { ping :'pong'}
        done()

  it 'check server', (done)->
    url_server   = server.url()
    url_api_docs = url_server + '/v1.0/api-docs'
    help = url_server + '/docs/?url=' + url_api_docs
    url_api_docs.GET (html)->
      html.assert_Is_String()
      done()

  it 'check url_api_docs',(done)->
    url_api_docs.GET_Json (apiDocs)->
        apiDocs.assert_Is_Object()
        apiDocs.apiVersion.assert_Is('1.0.0')
        apiDocs.swaggerVersion.assert_Is('1.2')
        #apiDocs.apis[0].path.assert_Is('/graphs')
        done()

  it '/docs' , (done)->
    supertest(server.app)
      .get('/docs')
      .end (error, response)->
        response.header.location.assert_Contains ['docs/?url','v1.0/api-docs']
        done()

  it '/docs' , (done)->
    supertest(server.app)
      .get('/docs/')
      .end (error, response)->
        response.text.assert_Contains [ 'swagger', 'api-docs' ]
        done()

  it '/v1.0/api-docs', (done)->
    supertest(server.app)
      .get('/v1.0/api-docs')
      .end (error, response)->
        #response.text.assert_Contains [ 'swagger', 'api-docs' ]
        json = response.text.json_Parse()
        json.apiVersion.assert_Is '1.0.0'
        json.info.title.assert_Is 'TeamMentor GraphDB 4.0',
        done()