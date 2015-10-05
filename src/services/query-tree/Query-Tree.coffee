Search            = require '../search/Search'
Search_Query_Tree = require '../search/Search-Query-Tree'
{Cache_Service}   = require('teammentor')

class Query_Tree
  constructor: (options)->
    @.options           = options || {}
    @.data_Cache        = @.options.data_Cache   || new Cache_Service("data_cache")
    @.search            = new Search()
    @.search_Query_Tree = new Search_Query_Tree()

  cache_Key: (query_Id, filters)=>
    "query_tree_#{query_Id}#{if filters then '_'  else ''}#{filters || ''}.json"

  delete_Query: (query_Id)=>
    cache_Key = @.cache_Key(query_Id)                  # delete index_Id file
    @.search_Query_Tree.data_Cache.delete(cache_Key)

  apply_Filters_To_Query_Tree: (query_Tree, filters, callback)=>
    if filters
      @.search_Query_Tree.apply_Query_Tree_Query_Id_Filter query_Tree, filters, (filtered_Query_Tree)->
        callback filtered_Query_Tree
    else
      callback query_Tree

  create_Query_Tree: (query_Id, filters, callback)=>
    if query_Id?.starts_With('query-')
      @.search_Query_Tree.create_Query_Tree_For_Query_Id query_Id, (query_Tree)=>
        if not query_Tree?.id
          return callback {}
        @.apply_Filters_To_Query_Tree query_Tree, filters, callback

    else if query_Id?.starts_With('search-')
      text = query_Id.remove('search-').replace(/-/g, ' ')
      @.search.for text, (query_Id, query_Tree)=>
        @.apply_Filters_To_Query_Tree query_Tree, filters, callback

    else
      callback {}

  get_Query_Tree: (query_Id, callback)=>
    @.get_Query_Tree_Filtered query_Id , null, callback

  get_Query_Tree_Filtered: (query_Id, filters, callback)=>
    cache_Key            = @.cache_Key query_Id, filters
    cache_Key_No_Filters = @.cache_Key query_Id, null

    if @.data_Cache.has_Key cache_Key
      callback @.data_Cache.get(cache_Key)?.json_Parse()
    else
      if @.data_Cache.has_Key cache_Key_No_Filters
        query_Tree =  @.data_Cache.get(cache_Key_No_Filters)?.json_Parse()
        @.apply_Filters_To_Query_Tree query_Tree, filters, (filtered_Query_Tree)=>
          @.data_Cache.put cache_Key, filtered_Query_Tree
          callback filtered_Query_Tree
      else
        @.create_Query_Tree query_Id, filters, callback





module.exports = Query_Tree