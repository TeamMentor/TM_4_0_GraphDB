Search_Service = require '../../../src/services/data/Search-Service'

describe '| services | data | Search-Service.test |', ->

  options       = null
  searchService = null
  importService = null
  graph         = null

  before (done)->
    searchService = new Search_Service(options)
    importService = searchService.importService
    graph         = importService.graph
    graph.openDb ->
      done()

  after (done)->
    searchService.graph.closeDb ->
      done()

  it 'construtor',->
    using new Search_Service(), ->
      @.options      .assert_Is {}
      @.importService.assert_Is_Object()
      @.graph        .assert_Is_Object()

  it 'article_Titles', (done)->
    @.timeout 4000
    searchService.article_Titles (titles)->
      titles.assert_Size_Is_Bigger_Than 10
      article_Id    = titles.first().id
      article_Title = titles.first().title
      importService.graph_Find.get_Subjects_Data article_Id, (data)=>
        data.keys().assert_Size_Is 1
        using data[article_Id],->
          @.assert_Is_Object()
          @.title.assert_Is article_Title
          @.id   .assert_Is article_Id
          @.is   .assert_Is 'Article'
        done()

  it 'article_Summaries', (done)->
    searchService.article_Summaries (titles)->
      titles.assert_Size_Is_Bigger_Than 10
      article_Id    = titles.first().id
      article_Summary = titles.first().summary
      importService.graph_Find.get_Subjects_Data article_Id, (data)=>
        data.keys().assert_Size_Is 1
        using data[article_Id],->
          @.assert_Is_Object()
          @.summary.assert_Is article_Summary
          @.id     .assert_Is article_Id
          @.is     .assert_Is 'Article'
        done()

  it 'query_Titles', (done)->
    searchService.query_Titles (titles)->
      titles.assert_Size_Is_Bigger_Than 10
      query_Id    = titles.first().id
      query_Title = titles.first().title
      importService.graph_Find.get_Subjects_Data query_Id, (data)=>
        data.keys().assert_Size_Is 1
        using data[query_Id],->
          @.assert_Is_Object()
          @.title.assert_Is query_Title
          @.id   .assert_Is query_Id
          @.is   .assert_Is 'Query'
        done()

  # see https://github.com/TeamMentor/TM_4_0_Design/issues/521
  # doesn't work until the search data is parsed and loaded. This should be fixed in an improved version of the search cache

  it 'search_Using_Text', (done)->
    @.timeout 5000
    text = 'security'
    searchService.search_Using_Text text, (results)->
      results.assert_Not_Empty()
      done()

  it 'query_Key_From_Text', ()->
    using searchService.query_Id_From_Text,->
      @('xss'  ).assert_Is('search-xss'  )
      @('XSS'  ).assert_Is('search-xss'  )
      @(' XSS' ).assert_Is('search-xss'  )
      @(' XSS ').assert_Is('search-xss'  )
      @('X-s-s').assert_Is('search-x-s-s')
      @('X$s*s').assert_Is('search-x-s-s')

  # see https://github.com/TeamMentor/TM_4_0_Design/issues/521
  # doesn't work until the search data is parsed and loaded. This should be fixed in an improved version of the search cache
  it 'query_From_Text_Search', (done)->
    text = 'Security'
    searchService.query_From_Text_Search text, (query_Id)->
      query_Id.assert_Is 'search-security'
      importService.graph_Find.get_Subject_Data query_Id, (data)->
        data.title.lower().assert_Is text.lower()
        done();

  xit 'Check that parent queries are mapped', (done)->
    @.timeout 10000
    #query = 'search-jsp-debug'
    text = 'jsp debug'
    searchService.query_From_Text_Search text, (query_Id)->
      #searchService.map_Search_Parent_Queries query_Id, (data)->
      #  searchService.create_Search_Parent_Queries_Nodes query_Id, data, (result)->
      #    console.log result
          done()
  xit 'Check that query tree for 53bb1a85ee3a', (done)->
    searchService.get_Query_Tree 'query-53bb1a85ee3a', (data)->
      console.log data
      done()
