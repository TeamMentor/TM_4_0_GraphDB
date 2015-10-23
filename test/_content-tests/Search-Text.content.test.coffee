require 'fluentnode'

Search_Text = require './../../src/services/search/Search-Text'

describe '| _content-tests | Search-Text.content', ->

  it 'words_Score (SQL Injection)', (done)->
    using new Search_Text(), ->
      @.words_Score 'SQL Injection', (results)->
        results.assert_Size_Is 222
        results[0].assert_Is id: 'article-8ca2b924d617',score: 177,why:{ sql:{ p: 1,ul: 1,li: 1,div: 1,h2: 4,blockquote: 1,b: 3,h1: 5,h3: 1,ol: 1,title: 30 }, injection: { p: 1, ul: 1, li: 1, h2: 4, blockquote: 1, ol: 1, title: 30 } }
        results[221].assert_Is 	id: 'article-5361f7ef3aab', score: -7, why: { sql: { ul: 1, li: 1, table: 1, tr: 1, td: 1, a: -4 }, injection: { ul: 1, li: 1, a: -4 } }
        done()

  it 'words_Score (Java)', (done)->
    using new Search_Text(), ->
      @.words_Score 'Java', (results_1)=>
        @.words_Score 'JAVA', (results_2)->
          results_1.assert_Size_Is 473
          results_1.size().assert_Is results_2.size()
          results_1[0].assert_Is_Not results_2[0]
          done()

  it 'words_Score (.NET)', (done)->
    using new Search_Text(), ->
      @.words_Score '.net', (results_1)=>
        @.words_Score '.NET', (results_2)->
          results_1.assert_Size_Is 12
          results_1.size().assert_Is results_2.size()
          results_1.assert_Is results_2
          done()


  it 'words_Score (cwe-22)', (done)->
    using new Search_Text(), ->
      @.words_Score 'cwe-22', (results)->
        console.log results
        done()
