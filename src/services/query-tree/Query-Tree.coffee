Search_Query_Tree = require '../search/Search-Query-Tree'

class Query_Tree
  constructor: (options)->
    @.options           = options || {}
    @.Search_Query_Tree = new Search_Query_Tree()

  cache_Key: (query_Id, filters)=>
    @.Search_Query_Tree.cache_Key query_Id, filters

  delete_Query: (query_Id)=>
    cache_Key = @.cache_Key(query_Id)                  # delete index_Id file
    @.Search_Query_Tree.data_Cache.delete(cache_Key)

  get_Query_Tree: (query_Id, callback)=>
    @.get_Query_Tree_Filtered query_Id , null, callback

  get_Query_Tree_Filtered: (query_Id, filters, callback)=>
    using @.Search_Query_Tree, ->
      cache_Key = @.cache_Key query_Id, filters
      if @.data_Cache.has_Key cache_Key
        callback @.data_Cache.get(cache_Key)?.json_Parse()
      else
        @.create_Query_Tree_For_Query_Id query_Id, (query_Tree)=>
          if filters
            @.apply_Query_Tree_Query_Id_Filter query_Tree, filters, (filtered_Query_Tree)->
              callback filtered_Query_Tree
          else
            callback query_Tree





module.exports = Query_Tree