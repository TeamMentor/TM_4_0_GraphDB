TM_Server = require('./../src/TM-Server')
expect    = require('chai').expect
request   = require('request')
supertest = require('supertest')

describe '| test-Server |',->

  @timeout 5000
  
  server  = null
  port    = null

  before ->
    port = 10000 + 10000.random()
    server = new TM_Server({ port : port} ).configure()

  it 'check ctor', ->
      expect(TM_Server     ).to.be.an('function')
      expect(server        ).to.be.an('object'  )
      expect(server.app    ).to.be.an('function')
      expect(server.port   ).to.be.an('number'  )
      expect(server._server).to.equal(null)

      #expect(server.addRoutes    ).to.be.an('function')
      #expect(server.addControlers).to.be.an('function')

  it 'start and stop', (done)->
      expect(server.start  ).to.be.an('function')
      expect(server.stop   ).to.be.an('function')

      request  server.url(), (error, response, data)->
        do(()->done();return)    if (error == null)  # means the server is already running

        expect(server.start()).to.equal(server)

        expect(server._server.close         ).to.be.an('function')
        expect(server._server.getConnections).to.be.an('function')

        request  server.url() + '/404', (error, response,data)->
            expect(error).to.equal(null)
            expect(response.statusCode).to.equal(404)

            server.stop ->
                request server.url(), (error, response,data)->
                  error.message.assert_Contains 'connect ECONNREFUSED'
                  assert_Is_Undefined response
                  done()

  it 'url',->
      expect(server.url()).to.equal("http://localhost:#{port}")


  it 'routes', ->
      expect(server.routes         ).to.be.an('function')
      expect(server.routes()       ).to.be.an('array')
      expect(server.routes().size()).to.be.equal(1)

  it 'Check expected paths', ->
    expectedPaths = [ '/' ]
                      #'/test'
                      #'/data'
                      #'/data/:name'
                      #'/data/:dataId/:queryId/filter/:filterId'
                      #'/data/:dataId/:queryId'
                      #'/lib/vis.js'
                      #'/lib/vis.css'
                      #'/lib/jquery.min.js'
                      #'/data/graphs/scripts/:script.js'
                      #'/data/:dataId/:queryId/:graphId'
                    #]
    expect(server.routes()).to.deep.equal(expectedPaths)

  describe '| using supertest',->

    tmServer = null
    mock_app = null

    before ->
      tmServer = new TM_Server({ port : 30000.random()}).configure()
      mock_app = supertest(tmServer.app)

    after ->
      tmServer.logging_Service.restore_Console()

    it '/', (done)->
      mock_app.get('/')
              .end (err,res)->
                res.text.assert_Is 'Moved Temporarily. Redirecting to docs'
                done()

      #swaggerService.set_Defaults()