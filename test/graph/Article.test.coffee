require 'fluentnode'

Article    = require '../../src/graph/Article'

describe '| graph | Article', ->
  @.timeout 5000

  importService = null
  article       = null
  article_Id    = null

  before (done)->
    article      = new Article()
    articles_Html = article.folder_Articles_Html().files_Recursive()
    article_File  = articles_Html.first()
    article_Id    = "article-" + article_File.split('-').last().remove(".html")
    articles_Html.assert_Not_Empty()
    article_File.assert_Is_String()
    article_Id.assert_Is_String()

    importService = article.importService
    importService.graph.openDb ->
      done()

  after (done)->
    importService.graph.closeDb ->
      done();

  it 'constructor',->
    article.assert_Instance_Of Article

  it 'folder_Articles_Html', ()->
    article.folder_Articles_Html().assert_Folder_Exists()
    article.folder_Articles_Html().files_Recursive().size().assert_Bigger_Than 2000

  it 'article_Id_To_Guid', (done)->

    article.article_Id_To_Guid article_Id, (guid)->
      article_Id.assert_Contains guid.split('-').last()
      done()

  it 'html', (done)->
    article.html article_Id, (html)->
      html.assert_Contains '<h2>'
      done()

  it 'html (bad guid)', (done)->
    article.html '1231231-13123-1231', (html)->
      assert_Is_Null html
      done()

  #it 'raw_Articles_Html', (done)->
  #  article.raw_Articles_Html (raw_Articles_Html)->
  #    raw_Articles_Html.keys().assert_Not_Empty()
  #    done()