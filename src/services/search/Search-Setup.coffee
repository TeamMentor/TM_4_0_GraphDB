# this class will build all the required search artifacts and put them in the search_cache

{Cache_Service} = require('teammentor')
Graph_Service   = require '../graph/Graph-Service'
Graph_Find      = require '../graph/Graph-Find'

class Search_Setup
  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("search_cache")
    @.graph         = new Graph_Service name: 'tm-uno'
    @.graph_Find    = new Graph_Find(@.graph)


  create_Tag_Mappings: (callback)=>

    action = (next)=>
      @.graph_Find.find_Tags (data)=>
        if data
          @.cache.put 'tags_mappings.json', data
        next data

    @.graph.exec_In_DB action, callback


module.exports = Search_Setup