Import_Service = require('./../../src/services/data/Import-Service')

describe '| _issues | to-fix',->
  importService  = null
  library_Data   = null

  before (done)->
    using new Import_Service('tm-uno'), ->
      importService  = @
      #graph_Find     = @.graph_Find
      #query_Mappings = @.query_Mappings
      #query_Tree     = @.query_Tree
      @.content.load_Data =>
        importService.graph.openDb =>
          @.graph_Find.find_Library (data)=>
            library_Data = data
            done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'Issue xxx - weird bug in query-tree', (done)->
    log library_Data
    #log root_Queries
    #query_Id = root_Queries.first().id
    #log query_Id
      #query_Id = root_Queries.queries.first().id
    done()