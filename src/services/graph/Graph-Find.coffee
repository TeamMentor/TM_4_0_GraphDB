async = require 'async'

class Graph_Find
  constructor: (graph)->
    @.graph = graph

  convert_To_Ids: (values,callback)->
    if @graph.db is null
      callback null
      return

    result = {}

    resolve_Id = (value,next)=>
      @find_Using_Title value, (data)=>
        next data.first()

    resolve_Title = (query_Id,next)=>
      @.graph.search query_Id, 'title', undefined, (data)=>
        next data?.first()?.object

    map_Data = (target, id, title, next)=>
      using target, ->
        if id
          @.id    = id
          @.title = title
        next()

    convert_Value = (value,next)=>

      value  = value.trim()
      target = result[value] = {}
      resolve_Title value , (title)=>
        if title
          map_Data target, value, title, next
        else
          resolve_Id value, (id)=>
            resolve_Title id, (title)=>
              map_Data target, id, title, next

    if values
      async.each values.split(','), convert_Value, ->
        callback result

  find_Using_Is: (value, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(value).archIn('is')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Title: (value, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(value).archIn('title')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Is_and_Title: (is_value, title_value, callback)=>
    if @graph.db is null
      return callback null

    @graph.db.nav(is_value).archIn('is').as('id')
                           .archOut('title').as('title')
                           .bind(title_value)
                           .solutions (err,data) ->
                              callback (item.id for item in data)


  find_Subject_Contains: (subject, callback)=>            #Legacy: TO Remove
    if @graph.db is null
      callback null
      return
    @graph.db.nav(subject).archOut('contains')
             .solutions (err,data) ->
                callback (item.x0 for item in data)

  find_Article: (ref, callback)=>
    find_Using = (method, next)->
      method ref, (article_Id)->
        if article_Id
          callback article_Id
        else
          next()

    find_Using @.find_Article_By_Id, =>
      find_Using @.find_Article_By_Partial_Id, =>
        find_Using @.find_Article_By_Guid, =>
          find_Using @.find_Article_By_Alias, =>
            callback null

  find_Article_By_Id: (id, callback)=>
    @graph.db.nav(id).archOut('is').as('is')
                      .solutions (err,data) ->
                        if data?.first()?.is is 'Article'
                          callback id
                        else
                          callback null

  find_Article_By_Partial_Id: (partial_Id, callback)=>
    id = "article-#{partial_Id}"
    @graph.db.nav(id).archOut('is').as('is')
                      .solutions (err,data) ->
                        if data?.first()?.is is 'Article'
                          callback id
                        else
                          callback null

  find_Article_By_Guid: (guid, callback)=>
    @graph.db.nav(guid).archIn('guid').as('id')
                       .archOut('is').as('is')
                       .solutions (err,data) ->
                         if data?.first()?.is is 'Article'
                           callback data.first().id
                         else
                           callback null

  find_Article_By_Alias: (guid, callback)=>
    @graph.db.nav(guid).archIn('alias').as('id')
                       .archOut('is').as('is')
                       .solutions (err,data) ->
                         if data?.first()?.is is 'Article'
                           callback data.first().id
                         else
                           callback null

  find_Articles: (callback)=>
    @graph.db.nav('Article').archIn('is').as('article')
                            .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Library: (callback)=>
    @graph.db.nav('Library').archIn('is').as('id')
                       .solutions (err,data) =>
                          query_Id = data?.first()?.id
                          if not query_Id
                            return callback {}
                          @get_Subject_Data query_Id, (data)=>
                            callback data


  find_Queries: (callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav('Query').archIn('is').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Query_Articles: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archOut('contains-article').as('article')
                           .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Query_Queries: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archOut('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Article_Parent_Queries: (article_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(article_Id).archIn('contains-article').as('query')
                             .solutions (err,data) ->
                                callback (item.query for item in data)

  find_Query_Parent_Queries: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archIn('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)


  get_Articles_Data: (callback)=>
    @.find_Using_Is 'Article', (articles_Ids)=>
      @.get_Subjects_Data articles_Ids, callback

  get_Subject_Data: (subject, callback)=>
    if @graph.db is null
      callback null
      return
    if not subject
      callback {}   #
    else
      @graph.db.get {subject: subject}, (error, data)=>
        result = {}
        throw error if error
        for item in data
          key = item.predicate
          value = item.object
          if (result[key])         # if there are more than one hit, return an array with them
            if typeof(result[key])=='string'
              result[key] = [result[key]]
            result[key].push(value)
          else
            result[key] = value
        if not result['id']
          result['id'] = subject.valueOf()
        callback(result)

  get_Subjects_Data:(subjects, callback)=>
    if @graph.db is null
      return callback null
    result = {}
    if not subjects
      callback result
      return
    if(typeof(subjects) == 'string')
      subjects = [subjects]

    map_Subject_data = (subject, next)=>
      @get_Subject_Data subject, (subjectData)=>
        result[subject] = subjectData
        next()

    async.each subjects, map_Subject_data, -> callback(result)

  find_Tags: (callback)=>
    if @.graph.db is null
      return callback {}
    @.graph.query 'predicate','tags', (data)=>
      tag_Data = {}
      if data
        for item in data
          tags       = item.object
          article_Id = item.subject
          for tag in tags.split(',')
            tag = tag.lower()
            if tag_Data[tag] is undefined or typeof tag_Data[tag] is 'function'
              tag_Data[tag] = []
            tag_Data[tag].push article_Id
      callback tag_Data

module.exports = Graph_Find