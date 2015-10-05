require('fluentnode')
coffeeScript           = require 'coffee-script'
Cache_Service          = require('teammentor').Cache_Service
Graph_Add_Data         = require '../graph/Graph-Add-Data'
Graph_Find             = require '../graph/Graph-Find'
Graph_Service          = require '../graph/Graph-Service'
#Content_Service        = require '../import/Content-Service'
#Library_Import_Service = require '../import/Library-Import-Service'
Query_Mappings         = require './Query-Mappings'
#Query_Tree             = require './Query-Tree'
Query_Tree             = require '../query-tree/Query-Tree'
@
Queries                = require './Queries'


class ImportService

  constructor: (options)->
    @.options         = options || {}
    @.name            = options.name || '_tmp_import'
    #@.cache           = new Cache_Service("#{@name}_cache")  # I don't think we need this anymore
    #@.content         = new Content_Service()
    @.graph           = new Graph_Service(options)
    @.graph_Add_Data  = new Graph_Add_Data @.graph
    @.graph_Find      = new Graph_Find @.graph
    #@.library_Import  = new Library_Import_Service @.content
    @.query_Mappings  = new Query_Mappings @
    #@.query_Tree      = new Query_Tree @
    @.query_Tree      = new Query_Tree
    @.queries         = new Queries @
    @.path_Root       = ".tmCache"
    @.path_Name       = ".tmCache/#{@.name}"

  setup: (callback)->
    @path_Root   .folder_Create()
    @path_Name   .folder_Create()

    @graph.openDb ->
      callback()

module.exports = ImportService
