Search_Build = require '../../../src/services/data/Search-Build'

xdescribe 'Search-Build.test',->

  it 'create_Search_TreeView', (done)->
    @.timeout 5000
    if false and not global.config
      root_Folder = process.cwd().path_Combine '../..'
      global.config =
        tm_graph:
          folder_Lib_UNO_Json     : root_Folder.path_Combine 'data/Lib_UNO-Json'

    using new Search_Build(), ->
      text = 'ios'
      @.create_Search_TreeView text, (data)->
        console.log data
        done()