# this class will build all the required search artifacts and put them in the search_cache

{Cache_Service} = require('teammentor')

class Search_Setup
  constructor: (options)->
    @.options       = options || {}
    @.cache         = @.options.cache || new Cache_Service("search_cache")

  create_Tag_Mappings: ->

module.exports = Search_Setup