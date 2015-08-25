Search_Service = require '../../../src/services/data/Search-Service'
Query_Tree     = require '../../../src/services/query-tree/Query-Tree'

describe '| services | data | Search-Service.test |', ->

  options       = null
  searchService = null
  importService = null
  graph         = null

#  before (done)->
#    searchService = new Search_Service(options)
#    importService = searchService.importService
#    graph         = importService.graph
#    graph.openDb ->
#      done()
#
#  after (done)->
#    searchService.graph.closeDb ->
#      done()

  it 'construtor',->
    using new Search_Service(), ->
      @.options      .assert_Is {}
      @.search     .constructor.name.assert_Is 'Search'
      @.search_Data.constructor.name.assert_Is 'Search_Data'
#      @.importService.assert_Is_Object()
#      @.graph        .assert_Is_Object()

  it 'article_Titles', (done)->
    using new Search_Service(), ->
      @.article_Titles (titles)=>
        titles.assert_Size_Is_Bigger_Than 2200
        article_Id    = titles.first().id
        article_Title = titles.first().title
        using @.search_Data.article(article_Id),->
          @.assert_Is_Object()
          @.title.assert_Is article_Title
          @.id   .assert_Is article_Id
          @.is   .assert_Is 'Article'
          done()

#  it 'article_Summaries', (done)->
#    searchService.article_Summaries (titles)->
#      titles.assert_Size_Is_Bigger_Than 10
#      article_Id    = titles.first().id
#      article_Summary = titles.first().summary
#      importService.graph_Find.get_Subjects_Data article_Id, (data)=>
#        data.keys().assert_Size_Is 1
#        using data[article_Id],->
#          @.assert_Is_Object()
#          @.summary.assert_Is article_Summary
#          @.id     .assert_Is article_Id
#          @.is     .assert_Is 'Article'
#        done()

  it 'query_Titles', (done)->
    using new Search_Service(), ->
      @.query_Titles (titles)=>
        titles.assert_Size_Is_Bigger_Than 10
        query_Id    = titles.first().id
        query_Title = titles.first().title
        using @.search_Data.query_Mappings()[query_Id],->
          @.assert_Is_Object()
          @.title.assert_Is query_Title
          @.id   .assert_Is query_Id
          @.is   .assert_Is 'Query'
          done()

  it 'query_Key_From_Text', ()->
    using new Search_Service().query_Id_From_Text,->
      @('xss'  ).assert_Is('search-xss'  )
      @('XSS'  ).assert_Is('search-xss'  )
      @(' XSS' ).assert_Is('search-xss'  )
      @(' XSS ').assert_Is('search-xss'  )
      @('X-s-s').assert_Is('search-x-s-s')
      @('X$s*s').assert_Is('search-x-s-s')

  it 'query_From_Text_Search (html5)', (done)->
    text = 'html5'
    using new Search_Service(options), ->
      @.query_From_Text_Search text, (query_Id)=>
        query_Id.assert_Is 'search-html5'
        new Query_Tree().get_Query_Tree query_Id, (data)->
          using data, ->
            @.id        .assert_Is query_Id
            @.title     .assert_Is 'html5'
            @.size      .assert_Is 81
            @.containers.assert_Size_Is 5
            @.results   .assert_Size_Is 81
            @.filters.assert_Size_Is 3  # this is a  bug
            done()

  it 'query_From_Text_Search (xss)', (done)->
    text = 'xss'
    using new Search_Service(options), ->
      @.query_From_Text_Search text, (query_Id)=>
        query_Id.assert_Is 'search-xss'
        new Query_Tree().get_Query_Tree query_Id, (data)->
          using data, ->
            @.id        .assert_Is query_Id
            @.title     .assert_Is 'xss'
            @.size      .assert_Is 77
            @.containers.assert_Size_Is 9
            @.results   .assert_Size_Is 77
            @.filters.assert_Size_Is 3
            done()