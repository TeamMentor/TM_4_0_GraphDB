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

    filtered_Text        = text.lower().replace(/:/g, ' ').replace(/-/g, ' ')
    search_Text_articles = @.search_Text.search_Data.search_Text_Articles()

    map_Using_Fill_Title = (next)=>
      data = search_Text_articles[filtered_Text]
      if data
        callback text, data.article_Ids
      else
        next()

    map_Using_Words_Search = (next)=>
      @.search_Text.words_Score filtered_Text, (results)=>
        article_Ids = (result.id for result in results)
        if article_Ids.not_Empty()
          callback text, article_Ids
        else
          next()

    map_Using_Partial_Title = (next)=>
      articles_Ids = []
      keys = (key for key in search_Text_articles.keys() when key.contains(filtered_Text))
      for key in keys
        articles_Ids = articles_Ids.concat search_Text_articles[key].article_Ids
      callback text, articles_Ids

    map_Using_Fill_Title =>
      map_Using_Words_Search =>
        map_Using_Partial_Title()


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