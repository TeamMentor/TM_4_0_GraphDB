Cache_Service            = null
Search_Artifacts_Service = null
async                    = null
loaded_Search_Mappings   = null
loaded_Tag_Mappings      = null

class Search_Text_Service

  dependencies: ->
    Cache_Service            = require('teammentor').Cache_Service
    Search_Artifacts_Service = require './Search-Artifacts-Service'
    async                    = require 'async'

  constructor: (options)->
    @.dependencies()
    @.options             = options || {}
    @.importService       = @.options.importService
    @.cache_Search        = new Cache_Service("search_cache")
    @.folder_Lib_UNO_Json = global.config?.tm_graph?.folder_Lib_UNO_Json

  folder_Search_Data: ()=>
    @.folder_Lib_UNO_Json.path_Combine 'Search_Data'


  search_Mappings: (callback)=>
    if loaded_Search_Mappings
      return callback loaded_Search_Mappings

    key = @.folder_Search_Data().path_Combine 'search_mappings.json'

    if key.file_Exists()
      loaded_Search_Mappings = key.load_Json()
      return callback loaded_Search_Mappings
    callback {}

  tag_Mappings: (callback)=>
    if loaded_Tag_Mappings
      return callback loaded_Tag_Mappings
    key = 'tags_mappings.json'
    if @.cache_Search.has_Key key
      data = @.cache_Search.get key
      if  data isnt '{}'
        loaded_Tag_Mappings = data.json_Parse()
        return callback loaded_Tag_Mappings
    new Search_Artifacts_Service(import_Service:@.importService).create_Tag_Mappings (tag_Mappings)->
      callback tag_Mappings

  word_Data: (word, callback)=>
    @.search_Mappings (mappings)->
      callback mappings[word] || null

  normalize_Article_Id: (article_Id)=>
    if article_Id.starts_With('article-')
      return article_Id
    splited = article_Id.split('-')
    if splited.size() is 5
      return "article-#{splited.last()}"
    return article_Id

  word_Score: (word, callback)=>
    word = word.lower()
    results = []

    @.tag_Mappings (tag_Mappings)=>
      @.search_Mappings (mappings)=>
        add_Results_Mappings =  (key)=>
          for article_Id, data of mappings[key]
              result = {id : @.normalize_Article_Id(article_Id), score: 0, why: {}}
              for tag in data.where
                score = 1
                switch tag
                  when 'title'
                    score = 30
                  when 'h1'
                    score = 5
                  when 'h2'
                    score = 4
                  when 'em'
                    score = 3
                  when 'b'
                    score = 3
                  when 'a'
                    score = -4
                  when 'span'
                    score = 0

                result.score += score
                result.why[tag]?=0
                result.why[tag]+=score
              results.push result

        add_Tag_Mappings = (key)=>
          if tag_Mappings[key]
            tag_Articles = tag_Mappings[key]
            for result in results
              if tag_Articles.contains?(result.id)
                result.score += 30
                result.why.tag = 30
                tag_Articles.splice tag_Articles.indexOf(result.id),1

            for article_Id in tag_Articles
              result = {id : article_Id, score: 30, why: {tag:30}}
              results.push result

        add_Results_Mappings word
        add_Tag_Mappings word

        results = (results.sort (a,b)-> a.score - b.score).reverse()

        callback results

  words_Score: (words, callback)=>
    words = words.lower()
    results = {}

    @word_Score words, (result)=>
      if result.not_Empty()
        return callback result

      get_Score = (word,next)=>
        if word is ''
          return next()
        @word_Score word , (word_Results)->
          results[word] = word_Results
          next()

      async.eachSeries words.split(' '), get_Score , =>
        @.consolidate_Scores(results, callback)

  consolidate_Scores: (scores, callback)=>
    mapped_Scores = {}
    for word,results of scores
      for result in results
        mapped_Scores[result.id]?={}
        mapped_Scores[result.id][word]=result

    #log mapped_Scores

    results = []
    words_Size =  scores.keys?().size()

    for id, id_Data of mapped_Scores
      if id_Data.keys?().size() is words_Size
        result = {id: id, score:0 , why: {}}
        for word,word_Data of id_Data
          result.score +=  word_Data.score
          result.why[word] = word_Data.why
        results.push result

    #log results

    results = (results.sort (a,b)-> a.score - b.score).reverse()

    callback results

  words_List: (callback)=>
    @.search_Mappings (mappings)->
      words_List = (word for word of mappings)
      callback words_List

  #tags_List: (callback)=>
  #  @.search_Mappings (mappings)->
  #    tags_List = for word,mapping of mappings
  #                  for article,data of mapping
  #                    for where in data.where
  #                      log where
  #                      #where
  #    callback tags_List


module.exports = Search_Text_Service