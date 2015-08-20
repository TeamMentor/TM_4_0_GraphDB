#todo refactor and remove global.config dependency
require 'fluentnode'
root_Folder = process.cwd().path_Combine '../../'
if not global.config
  global.config =
    tm_graph:
      folder_Lib_UNO_Json     : root_Folder.path_Combine 'data/Lib_UNO-Json'



Search = require '../../../src/services/search/Search'

describe '| Search | ', ->
  it 'constructor', ->
    using new Search(),->
      @.assert_Is_Instance_Of Search
      @.search_Text      .constructor.name.assert_Is 'Search_Text'
      @.search_Query_Tree.constructor.name.assert_Is 'Search_Query_Tree'

  it 'query_Id_For_Text', (done)->
    @.timeout 5000
    using new Search(),->
      @.query_Id_For_Text 'jsp', (data)->
        console.log data
        done()
