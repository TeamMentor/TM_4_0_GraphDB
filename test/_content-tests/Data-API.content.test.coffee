TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Data_API         = require '../../src/api/Data-API'
async            = require 'async'

describe '| api | Data-API.content', ->
  tmServer       = null
  swaggerService = null
  clientApi      = null
  dataApi      = null

  beforeEach (done)->
    port     = 10000 + 10000.random()
    tmServer = new TM_Server({ port : port}).configure()
    options  = { app: tmServer.app ,  port : tmServer.port}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()

    dataApi = new Data_API({swaggerService: swaggerService}).add_Methods()
    swaggerService.swagger_Setup()
    tmServer.start()

    swaggerService.get_Client_Api 'data', (swaggerApi)->
      clientApi = swaggerApi
      done()

  afterEach (done)->
    tmServer.stop ->
      done()

  it 'query_tree (query-6234f2d47eb7)', (done)->
    query_Id = 'query-6234f2d47eb7'
    clientApi.query_tree id:query_Id, (data)->
      using data.obj, ->
        @.id.assert_Is query_Id
        @.title.assert_Is 'Index' # this is the Library query
        done()

  it 'query_tree (query-9cbfa10fee54)', (done)->
    query_Id = 'query-9cbfa10fee54'
    clientApi.query_tree id:query_Id, (data)->
      using data.obj, ->
        @.id.assert_Is query_Id
        @.title.assert_Is 'Use Role-based Authorization'
        done()

  it 'query_tree_filtered (query-0941197a4d6a , query-0d038ede8cf8)', (done)->
    query_Id = 'query-0941197a4d6a'
    filters  = 'query-0d038ede8cf8'
    clientApi.query_tree_filtered id:query_Id, filters: filters , (data)->
      data.obj.id.assert_Is query_Id
      data.obj.title.assert_Is 'Security Engineering'
      done()

  it 'query_view_model (query-6234f2d47eb7)', (done)->
    query_Id = 'query-6234f2d47eb7'
    clientApi.query_view_model { id:query_Id, from:0, to:2 }, (data)->
      using data.obj, ->
        @.id.assert_Is query_Id
        @.title.assert_Is 'Index' # this is the Library query
        @.articles.assert_Size_Is 2
        done()


  it.only 'Open Index queries - via query_tree', (done)->
    @.timeout 10000         # takes 7 secs when calculations are needed and 1.8s secs when cache files exist
    last_Query_Tree = null
    open_Query = (id, next)->
      clientApi.query_view_model { id:id, from:0, to:2 }, (data)->
        using data.obj, ->
          @.id.assert_Is id
          last_Query_Tree = @
          next()
    open_Query 'query-6234f2d47eb7', (data)->
      query_Ids = (query.id for query in last_Query_Tree.queries)
      console.log 'making ' + query_Ids.size()
      console.log 'making ' + query_Ids.unique().size() + ' requests'
      async.each query_Ids, open_Query, ->
        done()


