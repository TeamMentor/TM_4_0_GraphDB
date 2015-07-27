Import_Service = require('./../../src/services/data/Import-Service')
Query_Tree = require('./../../src/services/data/Query-Tree')

describe '| regression-tests | tests-1',->
  importService  = null
  library_Data   = null

  #before (done)->
  #  @timeout 5000
  #  using new Import_Service(name: 'tm-uno'), ->
  #    importService  = @
  #    importService.graph.openDb =>
  #      @.graph_Find.find_Library (data)=>
  #        library_Data = data
  #        done()
#
  #after (done)->
  #  importService.graph.closeDb ->
  #    done()

  it 'Issue 902 - Dev branch of tm-sme/Lib_UNO crashes GraphDB', ->
    console.log 'aaa'


