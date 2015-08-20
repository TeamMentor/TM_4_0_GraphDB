{Cache_Service} = require('teammentor')

class Search_Data
  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("search_cache")
    @.key_Articles       = 'articles.json'
    @.key_Query_Mappings = 'query_mappings.json'
    @.key_Tags_Mappings  = 'tags_mappings.json'

  get_Data: (key_Name)->
    if @.cache.has_Key(key_Name)
      @.cache.get(key_Name)?.json_Parse()
    else
      {}

  articles      : => @.get_Data @.key_Articles
  query_Mappings: => @.get_Data @.key_Query_Mappings
  tag_Mappings  : => @.get_Data @.key_Tags_Mappings


module.exports = Search_Data