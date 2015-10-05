Search_Text       = require './Search-Text'
Search_Query_Tree = require './Search-Query-Tree'

class Search
  constructor: (options)->
    @.options           = options || {}
    @.search_Text       = new Search_Text()
    @.search_Query_Tree = new Search_Query_Tree()

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  map_Articles_For_Text: (text, callback)=>
    text = text.lower()
    data = @.search_Text.search_Data.search_Text_Articles()[text]
    if data
      callback text, data.article_Ids
      return


    @.search_Text.words_Score text, (results)=>
      article_Ids = (result.id for result in results)
      callback text, article_Ids

  map_Search_Results_For_Text: (text, callback)=>
    @.map_Articles_For_Text text, (text_Searched, article_Ids)=>
      query_Id    = @.query_Id_From_Text(text_Searched)
      title       = text_Searched
      cache_Key   = @.search_Query_Tree.cache_Key(query_Id, null)

      @.search_Query_Tree.create_Query_Tree_For_Articles query_Id, title, cache_Key, article_Ids, (query_Tree)=>
        callback query_Id, query_Tree


  for: (text, callback)=>
    @.map_Search_Results_For_Text text, callback

module.exports = Search