{Cache_Service} = require('teammentor')

class Search_Data
  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("search_cache")
    @.key_Articles             = 'articles.json'
    @.key_Article_Ids          = 'article_Ids.json'
    @.key_Article_Root_Queries = 'article_Root_Queries.json'
    @.key_Query_Mappings       = 'query_mappings.json'
    @.key_Query_Titles         = 'query_titles.json'
    @.key_Search_Text_Data     = 'search_text_data.json'
    @.key_Tags_Mappings        = 'tags_mappings.json'

  get_Data: (key_Name)->
    if @.cache.has_Key(key_Name)
      @.cache.get(key_Name)?.json_Parse()
    else
      {}

  article             : (article_Id) => @.get_Data(@.key_Articles)[article_Id]

  articles            : => @.get_Data @.key_Articles
  article_Ids         : => @.get_Data @.key_Article_Ids
  article_Root_Queries: => @.get_Data @.key_Article_Root_Queries
  query_Mappings      : => @.get_Data @.key_Query_Mappings
  query_Titles        : => @.get_Data @.key_Query_Titles
  search_Text_Data    : => @.get_Data @.key_Search_Text_Data
  tag_Mappings        : => @.get_Data @.key_Tags_Mappings


module.exports = Search_Data