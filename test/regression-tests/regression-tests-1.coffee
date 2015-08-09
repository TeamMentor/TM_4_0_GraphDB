# this is temp until the global.config is replaced with a config class (like in TM_Design)
require 'fluentnode'
root_Folder = process.cwd().path_Combine '../../'
tm_Cache      = root_Folder.path_Combine '.tmCache'
global.config =
  tm_graph:
    folder_Lib_UNO_Json     : root_Folder.path_Combine 'data/Lib_UNO-Json'


supertest = require 'supertest'
express   = require 'express'

describe '| _issues | regresion-tests-1 |',->

  it 'Issue 753 - Seaching for HTML tags causes large number of results, its slow and causes DoS ', (done)->
    @.timeout 5000                                                                        # only needed when running only this test (because the @.search_Mappings needs to load)
    Search_Text_Service = require('./../../src/services/text-search/Search-Text-Service')
    search_Text = new Search_Text_Service()

    test_1 =  (next)->
      search_Text.word_Score 'p', (results)->                                             # proof that something is wrong with the search results
        results.assert_Size_Is (result.id for result in results).unique().size()          # 'p' search returns unique articles ids
        search_Text.word_Score 'a', (results)->
          results.assert_Size_Is (result.id for result in results).unique().size()        # so does 'a'
          search_Text.word_Score 'ul', (results)->
            results.assert_Size_Is (result.id for result in results).unique().size()  # but NOT 'ul'
            next()

    test_2 = (next)->
      search_Text.word_Score 'li', (results)->        # here is the prob, we're getting:
        results.assert_Size_Is 0                      #   24067 hits for li
        search_Text.word_Score 'ul', (results)->
          results.assert_Size_Is 0                    #   9366 hits for ul
          search_Text.word_Score 'a', (results)->
            results.assert_Is_Greater_Than 200               #   2233 hits for a
            search_Text.word_Score 'td', (results)->
              results.assert_Size_Is 0                #   9366 hits for td
              search_Text.word_Score 'p', (results)->
                results.assert_Is_Greater_Than 20             #   23 hits for p
                done()

    test_3 = (next)->
      search_Text.word_Data 'xss', (results)->        #all good with word_Data results for XSS and LI
        results.keys().assert_Size_Is_Bigger_Than(50)
        search_Text.word_Data 'li', (results)->
          assert_Is_Null results
          next()

    test_1 ->
      test_2 ->
        test_3 ->
          done()

  describe 'Issue 421 - Specific search causes Express error', (done)->

    mock_app = null

    before ->
      app      = new express()
      app.get '/', (req,res)-> res.send '42 is the answer'
      app.get '/:id', (req,res)-> res.send 'throws with $%'
      app.use (err, req, res, next)->
          #console.error(err.stack)
          res.status(500)
             .send(err.message)

      mock_app = supertest(app)

    it '/', (done)->
      mock_app.get('/')
              .expect(200)
              .end (err,res)->
                res.text.assert_Is '42 is the answer'
                done()

    it '/$%', (done)->
      mock_app.get('/$%')
              .expect(500)
              .end (err,res)->
                res.text.assert_Is "Failed to decode param '$%'"
                done()