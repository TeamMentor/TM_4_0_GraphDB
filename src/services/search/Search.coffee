Search_Text       = require './Search-Text'
Search_Query_Tree = require './Search-Query-Tree'

class Search
  constructor: (options)->
    @.options                          = options || {}
    @.search_Text                      = new Search_Text()
    @.search_Query_Tree                = new Search_Query_Tree()
    @.articles                         = []
    @.Technology_Independent_Increment = 10
    @.Exact_Title_Match_Score          = 80    #map_Using_Lower_Title
    @.Filtered_Title_Score             = 70    #map_Using_Filtered_Title
    @.Partial_Title_Score              = 50    #map_Using_Partial_Title
    @.Technology_Independent_Query     = 'query-99baeab17b26'

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  map_Articles_For_Text: (text, callback)=>
    filtered_Text        = text.lower().replace(/:/g, ' ').replace(/-/g, ' ')
    search_Text_articles = @.search_Text.search_Data.search_Text_Articles()
    query_Mappings       = @.search_Text.search_Data.query_Mappings()
    @.articles           = []


    map_Using_Lower_Title = (next)=>
      data = search_Text_articles[text.lower()]
      if data
        @.add_Search_Results data.article_Ids, @.Exact_Title_Match_Score
      next()

    map_Using_Filtered_Title = (next)=>
      data = search_Text_articles[filtered_Text]
      if data
        @.add_Search_Results data.article_Ids, @.Filtered_Title_Score
      next()

    map_Using_Words_Search = (next)=>
      @.search_Text.words_Score filtered_Text, (results)=>
        article_Ids = (result.id + "|" + result.score for result in results)
        if article_Ids.not_Empty()
          @.add_Search_Results(article_Ids)
        next()

    map_Using_Partial_Title =(next)=>
      articles_Ids = []
      keys = (key for key in search_Text_articles.keys() when key.contains(filtered_Text))
      for key in keys
        articles_Ids = articles_Ids.concat search_Text_articles[key].article_Ids
        @.add_Search_Results(articles_Ids,@.Partial_Title_Score)

      if @.articles?.length == 0
        return callback text, {}
      else
        # If article is a Technology Independent, then it increases the score in 10
        technologyIndependent = query_Mappings?[@.Technology_Independent_Query]?.articles;
        for article in @.articles
          if technologyIndependent?.indexOf(article.id) > -1
            article.score += @.Technology_Independent_Increment;
        data = (@.articles.sort (a,b) -> a.score - b.score).reverse()
        article_Ids = (result.id for result in data)
        return callback text, article_Ids

    map_Using_Lower_Title =>
      map_Using_Filtered_Title =>
        map_Using_Words_Search =>
          map_Using_Partial_Title()

  add_Search_Results:(data, score)=>
    for article in data
      if article?.contains "|"
        score   = article?.split("|")?.last()
        article = article?.split("|")?.first()

      searchResult = {id: article, score : parseInt(score)}

      result = @.articles?.filter((result) -> #finding existing records to increment score
        result.id == article
      )[0]
      if result?
        result.score = parseInt(result.score) + parseInt(score)
      else
        @.articles.push(searchResult)

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