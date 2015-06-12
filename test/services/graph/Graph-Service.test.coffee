expect        = require('chai'         ).expect
Graph_Service  = require('./../../../src/services/graph/Graph-Service')

describe '| services | graph | Graph-Service.test |', ->
  describe 'core |', ->
    it 'check ctor', ->
      using new Graph_Service(), ->
        @.dbName.assert_Contains '_tmp_db'
        @.dbPath.assert_Contains '.tmCache/_tmp_db'
        @.db_Lock_Tries.assert_Is 20
        @.db_Lock_Delay.assert_Is 250
        @.dbPath.folder_Delete_Recursive().assert_True()
        assert_Is_Null @.db


      using new Graph_Service(name: 'aaaa'),->
        @.dbName.assert_Is 'aaaa'
        @.dbPath.assert_Is '.tmCache/aaaa'
        @.dbPath.folder_Delete_Recursive().assert_Is_True()

    it 'openDb and closeDb', (done)->
      graphService  = new Graph_Service(name: 'aaaa')

      expect(graphService.openDb).to.be.an('function')
      expect(graphService.closeDb).to.be.an('function')

      expect(graphService.dbPath.folder_Exists()).to.equal(false)
      expect(graphService.db                    ).to.equal(null)
      graphService.openDb ->
        expect(graphService.db                    ).to.not.equal(null)

        graphService.closeDb ->
          expect(graphService.dbPath.folder_Delete_Recursive()).to.equal(true)
          expect(graphService.db                              ).to.equal(null)
          done()

    it 'wait_For_Unlocked_DB', (done)->
      using new Graph_Service() , ->
        @.wait_For_Unlocked_DB done, done
        70.wait =>
          console.log 'setting lock'
          @.locked = true


    #xit 'deleteDb', (done) ->
    #  using new Graph_Service(),->
    #    @.openDb =>
    #      #process.nextTick =>
    #      10.wait ()=>
    #        @.dbPath.assert_File_Exists()
    #        @.deleteDb =>
    #          @.dbPath.assert_File_Not_Exists()
    #          done()

  describe 'load TM_Uno data |', ->

    it '@.ensure_TM_Uno_Is_Loaded', (done)->
      @.timeout 30000
      using new Graph_Service(name:'tm-uno'),->
        @.openDb =>                               # this will trigger @.ensure_TM_Uno_Is_Loaded
          @.allData (data)=>
            data.assert_Size_Is_Bigger_Than 20000
            @.closeDb ->
              done()

  describe 'data operations |', ->
    graphService  = null

    before (done) ->
      graphService = new Graph_Service()
      graphService.openDb (status)->
        status.assert_True
        done()

    after (done) ->
      graphService.deleteDb done

    it 'add', (done)->
      expect(graphService.add).to.be.an('function')
      graphService.allData (data)->
        expect(data).to.be.empty
        graphService.add "a","b","c", ->
          graphService.query  "subject", "a", (data)->
            expect(data                  ).to.not.equal(null)
            expect(data                  ).to.be.an('array')
            expect(data.first()          ).to.be.an('object')
            expect(data.first().subject  ).to.equal('a')
            expect(data.first().predicate).to.equal('b')
            expect(data.first().object   ).to.equal('c')
            done()

    it 'get_Subject', (done)->
      expect(graphService.get_Subject).to.be.an('function')
      graphService.get_Subject "a", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Subject "b", (data)->
          expect(data).to.deep.equal []
          done()

    it 'get_Predicate', (done)->
      expect(graphService.get_Predicate).to.be.an('function')
      graphService.get_Predicate "b", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Predicate "a", (data)->
          expect(data).to.deep.equal []
          done()

    it 'get_Object', (done)->
      expect(graphService.get_Object).to.be.an('function')
      graphService.get_Object "c", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Object "a", (data)->
          expect(data).to.deep.equal []
          done()

    it 'alldata', (done)->
      expect(graphService.allData).to.be.an('Function')
      graphService.allData  (data) ->
        expect(data.length).to.equal(1)
        expect(data       ).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        done()

    it 'del',(done)->
      graphService.del "a","b","c", ->
        graphService.allData  (data) ->
          expect(data.length).to.equal(0)
          done()

    it 'query', (done)->
      using graphService,->
        @.query "all",null, (data)=>
          size = data.size()
          @.add '1','2','3', => @.add '10','20','30', => @.add '100','200','300', =>
            @.query "all",null, (data)=>
              data.size().assert_Is(size+3)
              @.query "subject","1", (data)=>
                data.assert_Is([ { subject: '1', predicate: '2', object: '3' } ])
                @.query "predicate","20", (data)=>
                  data.assert_Is([ { subject: '10', predicate: '20', object: '30' } ])
                  @.query "object","300", (data)=>
                    data.assert_Is([ { subject: '100', predicate: '200', object: '300' } ])
                    @.query null,"300", (data)->
                      assert_Is_Null(data)
                      done()

    it 'get_Subjects', (done)->
      graphService.get_Subjects (data)->
        data.assert_Is [ '1', '10', '100' ]
        done()

    it 'get_Predicates', (done)->
      graphService.get_Predicates (data)->
        data.assert_Is [ '2', '20', '200' ]
        done()

    it 'get_Objects', (done)->
      graphService.get_Objects (data)->
        data.assert_Is [ '3', '30', '300' ]
        done()

#  describe 'open and close of dbs |', ->


    it 'confirm that only one db can be opened at the same time', (done)->
      @.timeout 5000
      graphService_1 = graphService
      graphService_2  = new Graph_Service()
      graphService_1.db_Lock_Tries = 2
      graphService_2.db_Lock_Tries = 2
      graphService_2.openDb (status)->
        status.assert_False()
        graphService_1.closeDb ->
          graphService_2.openDb (status)->
            status.assert_True()
            graphService_1.openDb (status)->
              status.assert_False()
              graphService_2.closeDb ->
                graphService_1.openDb (status)->
                  status.assert_True()
                  graphService_2.deleteDb done