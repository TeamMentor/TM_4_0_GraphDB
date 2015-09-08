{Cache_Service} = require('teammentor')

class Search_Text_Mappings
  constructor: (options)->
    @.options              = options || {}
    @.search_Cache         = @.options.cache || new Cache_Service("search_cache")
    @.folder_Lib_UNO_Json  = null
    @.key_Search_Words_All = 'search_words_all.json'
    @.key_Search_Words     = 'search_words.json'
    @.key_Search_Text_Data = 'search_text_data.json'
    @.key_Query_Mappings   = 'query_mappings.json'
    @.key_Articles         = 'articles.json'

  folder_Raw_Search_Data: ()=>
    if global.config
      @.folder_Lib_UNO_Json =  global.config?.tm_graph?.folder_Lib_UNO_Json
    else
      @.folder_Lib_UNO_Json  = process.cwd().path_Combine '../../data/Lib_UNO-Json'
    @.folder_Lib_UNO_Json?.path_Combine 'Search_Data'


  search_Mappings_Raw: (callback)=>
    search_Mappings_File = @.folder_Raw_Search_Data()?.path_Combine 'search_mappings.json'
    if search_Mappings_File?.file_Exists()
      callback search_Mappings_File.load_Json()
    else
      callback {}

  # 'text and titles to articles' mappings used by the search algorithm
  get_Search_Text_Articles: (callback)=>
    search_Data = {}
    for article_Id, article of @.search_Cache.get(@.key_Articles)?.json_Parse()
      key = article.title.lower().replace(/:/g, ' ').replace(/-/g, ' ')
      search_Data[key] = { text: article.title, source: 'article-title', article_Ids:  [ article_Id]}

    for query_Id, query_Data of @.search_Cache.get(@.key_Query_Mappings)?.json_Parse()
      if query_Data.articles.size() > 0
        search_Data[query_Data.title.lower()]  =  { text: query_Data.title, source: 'query-mapping',query_Id: query_Id,  article_Ids: query_Data.articles }

    callback search_Data

  # 'words to articles' mappings used by the search algorithm
  get_Search_Text_Data: (callback)=>                       # takes 10,421 ms to create and 789 ms from cache
    if @.search_Cache.has_Key @.key_Search_Text_Data
      callback @.search_Cache.get(@.key_Search_Text_Data)?.json_Parse()
    else
      @search_Mappings_Raw (search_Mappings)=>
        @.search_Words (search_Words)=>
          console.log search_Words.size()
          search_Data = {}

          for word in search_Words
            word_Data      = {}
            search_Mapping = search_Mappings[word]
            for guid, mapping_Data of search_Mapping
              article_Id = 'article-' + guid.split('-').last()
              where_Mapping = {}
              for tag in mapping_Data.where
                where_Mapping[tag]?= 0
                where_Mapping[tag]++

              word_Data[article_Id] = where_Mapping
            search_Data[word] = word_Data

          @.search_Cache.put @.key_Search_Text_Data, search_Data
          callback search_Data

  # list of all words that we currently have a mapping (includes tons of large and non intuitive words)
  search_Words_All: (callback)=>
    if @.search_Cache.has_Key @.key_Search_Words_All
      callback @.search_Cache.get(@.key_Search_Words_All)?.json_Parse()
    else
      @.search_Mappings_Raw (mappings)=>
        words_List = (word for word of mappings).sort()
        @.search_Cache.put @.key_Search_Words_All,words_List
        callback words_List

  # this creates a subset of search_Words_All containing the workds most likely for the user to type
  # formula:
  # add word if matches the word
  #   - after all weird chars are converted into _
  #   - don't have - . or _
  search_Words: (callback)=>
    if @.search_Cache.has_Key @.key_Search_Words
      return callback @.search_Cache.get(@.key_Search_Words)?.json_Parse()
    @.search_Words_All (all_Words)=>
      words = []
      for word in all_Words
        if word is word.to_Safe_String().replace(/-/g,'').replace(/\./g,'').replace(/_/g,'')
          if word.length < 15
            words.push word
      @.search_Cache.put @.key_Search_Words,words
      callback words


module.exports = Search_Text_Mappings