Search_Text = require './../../../src/services/search/Search-Text'

describe '| services | text-search | Search-Text..', ->

  search_Text = null

  before (done)->
    search_Text = new Search_Text()
    done()

  it 'constructor', ->
    using new Search_Text(),->
      @.options.assert_Is {}
      @.cache_Search.constructor.name.assert_Is 'CacheService'
      @.search_Data .constructor.name.assert_Is 'Search_Data'

  it 'search_Mappings', (done)->
    search_Text.search_Mappings (data)->
      data.assert_Is_Not {}
      words = (word for word of data)
      words.assert_Size_Is_Bigger_Than 11000
      done()

  it 'tag_Mappings', (done)->
    search_Text.tag_Mappings (data)->
      data.assert_Is_Object()
      data.keys().assert_Size_Is 21
      done()

  it 'word_Data', (done)->
    search_Text.word_Data 'injection', (results)->
      results.keys().assert_Not_Empty()
      done()


  it 'word_Score', (done)->
    search_Text.word_Score 'injection', (results)->
    #search_Text.word_Score 'wcf 3.5', (results)->
      results.assert_Not_Empty()
      result = results.first()
      result.id.assert_Contains 'article-'
      result.score.assert_Is_Number()
      result.why.keys().assert_Not_Empty()
      done()

  it 'words_Score', (done)->
    search_Text.words_Score 'sQL   injECTion', (results_1)->
      search_Text.words_Score 'SQL Injection', (results_2)->
        search_Text.words_Score 'sql injection', (results_3)->
          results_1.assert_Not_Empty()
          results_1.assert_Is results_2
          results_1.assert_Is results_3
          done()

  it 'words_List ', (done)->
    search_Text.words_List (words)->
      words.assert_Bigger_Than 100
      "there are #{words.size()} unique words".log()
      done()

  it 'top 100 words', (done)->
    @.timeout 10000
    max = 100 #change to -1 to see data of all
    all_Data = []
    skip_Words = ['the','to','that','a', 'and', 'is', 'of', 'for', 'in','your','use','are','how','if','all'
                  'or','you','an','be','this','not','what','as','it','by','on','when','can','from','with','='
                  'each','add','may','will','have','more','sure']
    search_Text.search_Mappings (mappings)->
      search_Text.words_List (words)->
        #"Unique word count: #{words.size()}".log()
        for word in words.take(max)
          if skip_Words.not_Contains word
            search_Text.word_Score word, (result)->
              score = (item.score for item in result).reduce (previous, next)-> previous+next
              data = { word: word, articles: result.size(), score: score }
              all_Data.push data
        done()