Cache_Service            = null
async                    = null
loaded_Search_Mappings   = null
loaded_Tag_Mappings      = null
Search_Data              = null

class Search_Text

  dependencies: ->
    {Cache_Service}       = require 'teammentor'
    async                 = require 'async'
    Search_Data           = require '../search/Search-Data'


  constructor: (options)->
    @.dependencies()
    @.options             = options || {}
    @.cache_Search        = new Cache_Service("search_cache")
    @.search_Data         = new Search_Data()
    @.tag_Score           = 45 #Score assigned to tag articles

  search_Mappings: (callback)=>
    if loaded_Search_Mappings is null
      loaded_Search_Mappings = @.search_Data.search_Text_Data()
    callback loaded_Search_Mappings


  tag_Mappings: (callback)=>
    if loaded_Tag_Mappings is null
      loaded_Tag_Mappings = @.search_Data.tag_Mappings()
    callback loaded_Tag_Mappings

  word_Data: (word, callback)=>
    @.search_Mappings (mappings)->
      callback mappings[word] || null

#  normalize_Article_Id: (article_Id)=>
#    if article_Id.starts_With('article-')
#      return article_Id
#    splited = article_Id.split('-')
#    if splited.size() is 5
#      return "article-#{splited.last()}"
#    return article_Id

  word_Score: (word, callback)=>
    word = word.lower()
    results = []

    @.tag_Mappings (tag_Mappings)=>
      @.search_Mappings (mappings)=>
        add_Results_Mappings =  (key)=>
          for article_Id, data of mappings[key]
            result = {id : article_Id, score: 0, why: {}}

            for tag,occurences of data
              score = 1
              switch tag
                when 'title'
                  score = 45
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
              result.score += score * occurences
              result.why[tag]?=0
              result.why[tag]+=score

            results.push result


        add_Tag_Mappings = (key)=>
          if tag_Mappings[key]
            tag_Articles = tag_Mappings[key]
            for result in results
              if tag_Articles.contains?(result.id)
                result.score +=  @.tag_Score
                result.why.tag = @.tag_Score
                tag_Articles.splice tag_Articles.indexOf(result.id),1

            for article_Id in tag_Articles
              result = {id : article_Id, score: @.tag_Score, why: {tag:@.tag_Score}}
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
        article_Ids = (r for r in result)
        return callback result
      get_Score = (word,next)=>
        if word is ''
          return next()

        @word_Score word , (word_Results)->
          article_Ids = (result.id for result in word_Results)
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


module.exports = Search_Text