Cache_Service  = null
Import_Service = null
Article        = null
crypto         = null
cheerio        = null
async          = null

checksum = (str, algorithm, encoding)->
    crypto.createHash(algorithm || 'md5')
           .update(str, 'utf8')
           .digest(encoding || 'hex')

class Search_Artifacts_Service

  dependencies: ->
    Import_Service  = require('./../../../src/services/data/Import-Service')
    Article         = require './../../../src/graph/Article'
    Cache_Service   = require('teammentor').Cache_Service
    crypto          = require('crypto')
    cheerio         = require 'cheerio'
    async           = require 'async'

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.import_Service  = @.options.import_Service || new Import_Service('tm-uno')
    @.article         = new Article(@.import_Service)
    @.cache           = new Cache_Service("article_cache")
    @.cache_Search    = new Cache_Service("search_cache")

  parse_Article: (article_Id, callback)=>
    key = "#{article_Id}.json"
    if @.cache.has_Key key
      data = @.cache.get key
      callback data.json_Parse(), false
    else
      @.parse_Article_Html article_Id, (data)=>
        #log "Parsed html for #{article_Id}"
        @.cache.put key, data
        callback data, true

  parse_Articles: (article_Ids, callback)=>
    results = []
    total = article_Ids.size()
    count = 0
    map_Article = (article_Id, next)=>
      @.parse_Article article_Id, (data, showLog)->
        count++
        if showLog
          log "[#{count}/#{total}] Parsed html for #{article_Id}"
        results.push data
        next()

    async.each article_Ids , map_Article, ()=>
      callback results

  parse_Article_Html: (article_Id, callback)=>
    data =
          id       : article_Id
          checksum : null
          words    : {}
          tags     : {}
          links    : []
    @.article.html article_Id, (html)->
      data.html     = html
      data.checksum = checksum(html,'sha1')

      $ = cheerio.load html

      $('*').each (index,item)->
        tagName = item.name
        $tag = $(item)
        text    = $tag.text()
        if tagName is 'a'
          attrs = $tag.attr()
          attrs.text = $tag.text()
          data.links.push attrs

        data.tags[tagName] ?= []
        data.tags[tagName].push(text.trim())
        for word in text.split(' ')
          word = word.trim().lower().replace(/[,\.;\:\n\(\)\[\]<>]/,'')     # this has some performance implications (from 9ms to 18ms) and it might be better to do it on data consolidation
          if word and word isnt ''
            if data.words[word] is undefined or typeof data.words[word] is 'function' # need to do this in order to avoid confict with js build in methods (like constructor)
              data.words[word] = []
            data.words[word].push(tagName)
      callback data

  raw_Articles_Html: (callback)=>
    key = 'raw_articles_html.json'
    if @.cache_Search.has_Key key
      data =@.cache_Search.get key
      callback data.json_Parse()
    else
      raw_Articles_Html = []
      for file in @.cache.cacheFolder().files() #.take(10)
        raw_Articles_Html.push file.load_Json()
      @.cache_Search.put key, raw_Articles_Html
      callback raw_Articles_Html

  create_Search_Mappings: (callback)=>
    @.raw_Articles_Html (articles_Data)=>
      search_Mappings =
        words: {}
      for article_Data in articles_Data #.take(10)
        for word,where of article_Data.words
          if search_Mappings.words[word] is undefined or typeof search_Mappings.words[word] is 'function'
            search_Mappings.words[word] = []
            #search_Mappings.words[word].where = search_Mappings.words[word].where.concat where
          search_Mappings.words[word].push articles: [ { id: article_Data.id, where: where.unique()}]

      @.cache_Search.put 'search_mappings.json', search_Mappings
      log search_Mappings.words
      callback()

module.exports = Search_Artifacts_Service