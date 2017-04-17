Search_Text       = require './Search-Text'
Search_Query_Tree = require './Search-Query-Tree'

class Search
  constructor: (options)->
    @.options                          = options || {}
    @.search_Text                      = new Search_Text()
    @.search_Query_Tree                = new Search_Query_Tree()
    @.articles                         = []
    @.Technology_Independent_Increment = 150
    @.Exact_Title_Match_Score          = 80    #map_Using_Lower_Title
    @.Filtered_Title_Score             = 70    #map_Using_Filtered_Title
    @.Partial_Title_Score              = 50    #map_Using_Partial_Title
    @.CheckList_Decrement_Score        = 150    #Score will be decremented on 150 if it is a checklist
    @.Technology_Independent_Query     = 'query-99baeab17b26'
    @.Checklist_Query                  = 'query-cab5946af82b'

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  map_Articles_For_Text: (text, callback)=>
    filtered_Text        = text.lower().replace(/:/g, ' ').replace(/-/g, ' ')
    search_Text_articles = @.search_Text.search_Data.search_Text_Articles()
    query_Mappings       = @.search_Text.search_Data.query_Mappings()

    @.articles           = []

    #Search string must be greater than 1 char an it must not be an empty string
    return callback text, {} if !filtered_Text.trim() || text.trim().length == 1

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

    # todo: This method as to be refactored, it is very complex and the parsing logic should be done in other functions.
    map_Using_Partial_Title =(next)=>
      articles_Ids = []
      keys = (key for key in search_Text_articles.keys_Own() when key.contains(filtered_Text))
      for key in keys
        articles_Ids = articles_Ids.concat search_Text_articles[key].article_Ids

      @.add_Search_Results(articles_Ids,@.Partial_Title_Score)

      return callback text, {} if @.articles?.length == 0

      # If article is a Technology Independent, then it increases the score in 10
      technologyIndependent = query_Mappings?[@.Technology_Independent_Query]?.articles
      checklistMappings     = query_Mappings?[@.Checklist_Query]?.articles

      for article in @.articles
        if technologyIndependent?.indexOf(article.id) > -1    #If article is Technology Independent, score is incremented
          article.score += @.Technology_Independent_Increment;

        if checklistMappings?.indexOf(article.id) > -1       #If the article is Checklist, score is decremented
          article.score -= @.CheckList_Decrement_Score

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

      result = @.articles?.filter((result) -> result.id == article)[0] #finding duplicated articles
      if result?
        result.score = result.score + parseInt(score)
      else
        searchResult = {id: article, score : parseInt(score)}
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