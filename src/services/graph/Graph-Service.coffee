levelup         = null
levelgraph      = null
GitHub_Service  = null
async           = require 'async'
path            = require 'path'
domain          = require 'domain'

class Graph_Service

  locked = false

  dependencies: ->
    levelup           = require 'level'
    levelgraph        = require 'levelgraph'
    {GitHub_Service}  = require 'teammentor'

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.dbName          = @.options.name || '_tmp_db'.add_Random_String(5)
    @.tmCache         = './.tmCache'
    @.dbPath          = @.tmCache.path_Combine @dbName
    @.lib_Loaded_Flag = "#{@.tmCache}/tm-uno-loaded.flag"
    @.lib_UNO_Json    = global.config?.tm_graph?.folder_Lib_UNO_Json
    @.db              = null
    @.db_Lock_Tries   = @.options.db_Lock_Tries || 20
    @.db_Lock_Delay   = @.options.db_Lock_Delay || 250

  openDb : (callback)=>
    if locked
      @.wait_For_Unlocked_DB (()=> @.openDb(callback)), ()->
        console.log("Error: [GraphDB] is in use")
        callback false
    else
      locked = true
      process.nextTick =>
        console.log '***[Graph-Service]*** open db'
        @.ensure_TM_Uno_Is_Loaded =>
          @.db = levelgraph(levelup(@dbPath))
          process.nextTick =>
            callback true

  closeDb: (callback)=>
    console.log '***[Graph-Service]*** close db'
    if (@db)
      @db.close =>
        @db    = null
        @level = null
        locked = false
        callback()
    else
      callback()

  deleteDb: (callback)=>
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  wait_For_Unlocked_DB: (callback_Ok, callback_Fail) =>
    tries = @.db_Lock_Tries
    delay = @.db_Lock_Delay
    check_Lock = =>
      if locked is true
        if tries
          console.log "checking lock: #{tries}"
          tries--
          delay.wait =>
            process.nextTick =>
              check_Lock()
        else
          console.log "[wait_For_Unlocked_DB] failed to get a lock after : #{@.db_Lock_Tries}"
          callback_Fail()
      else
        callback_Ok()
    check_Lock()

  exec_In_DB: (action, callback)=>
    exec_Domain = domain.create()                  # create a domain to execute 'action' function
    exec_Domain.on 'error', (er)=>                 # catch errors thrown inside 'action'
      console.log('[exec_In_DB][async error]' + er) # log the error
      @.closeDb =>                                 # ensure the db is closed
        callback null                              # send back an null value

    exec_Domain.run () =>                          # start the domain (which will catch any async exceptions)
      @.openDb (status)=>                          # open the DB
        if not status                              # if DB can't be opened
          return callback null                     # send back an null value

        action (data)=>                            # call 'action' function
          @.closeDb =>                             # close db
            callback(data)                         # send back data received




  # Refactor move to different file

  add: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  del: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.del { subject:subject , predicate:predicate  , object:object }, (err)->
      throw err if err
      callback()

  ensure_TM_Uno_Is_Loaded: (callback)=>
    @.dbPath.create_Dir()                   # ensure folder exists
    if @.dbName isnt 'tm-uno'               # to-do: this tm-uno code needs to be refactored into another class
      return callback()
    path_Lib_Uno_Flag = @.lib_Loaded_Flag
    path_Lib_Uno_Json = @.lib_UNO_Json
    path_Graph_data   = @.lib_UNO_Json?.path_Combine('Graph_Data')

    if (not path_Lib_Uno_Json) or path_Lib_Uno_Json.folder_Not_Exists()
      console.log("[ensure_TM_Uno_Is_Loaded] ERROR: Lib_Uno-json folder not found : #{path_Lib_Uno_Json}")
      return callback()

    if path_Lib_Uno_Flag.file_Exists()
      return callback()

    console.log("[ensure_TM_Uno_Is_Loaded] Using path_To_Lib_Uno_Json: #{path_Lib_Uno_Json}")
    console.log("[ensure_TM_Uno_Is_Loaded] #{path_Lib_Uno_Flag.file_Name()} file doesn't exist, so deleting GraphDB and re-importing Lib_Uno-Json data")

    @.deleteDb =>
      console.log('[ensure_TM_Uno_Is_Loaded] deleting data_cache and search_cache folders')
      "#{@.tmCache}/data_cache".folder_Delete_Recursive()
      "#{@.tmCache}/search_cache".folder_Delete_Recursive()

      @.db = levelgraph(levelup(@.dbPath))                # needs to be done direcly since ensure_TM_Uno_Is_Loaded is part of the openDb code

      console.time('graph import')
      import_Data = (file, callback)=>
        console.log("[ensure_TM_Uno_Is_Loaded] Loading graph data from: #{file.file_Name()}")
        graph_Data = file.load_Json()
        if graph_Data and graph_Data.size
          console.log("[ensure_TM_Uno_Is_Loaded] There are #{graph_Data.size()} triplets to import")
          async.each graph_Data, @.db.put, callback
        else
          callback()


      async.each path_Graph_data.files(), import_Data , =>
        "[ensure_TM_Uno_Is_Loaded] Data loaded at #{new Date()}".log().save_As path_Lib_Uno_Flag
        console.timeEnd('graph import')

        @.closeDb =>                              # seems need to make sure all data is synced
          callback()


  get_Subjects: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ subject  : @db.v("subject")}], (err, data)->
      resuls = (item.subject for item in data) .unique()
      callback(resuls)

  get_Predicates: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ predicate  : @db.v("predicate")}], (err, data)->
      resuls = (item.predicate for item in data) .unique()
      callback(resuls)

  get_Objects: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ object  : @db.v("object")}], (err, data)->
      resuls = (item.object for item in data) .unique()
      callback(resuls)

  get_Subject: (subject, callback)->
    if @.db is null
      callback null
      return
    @db.get {subject:subject}, (err,data)->
      throw err if err
      callback(data)

  get_Predicate: (predicate, callback)->
    if @.db is null
      callback null
      return
    @db.get {predicate:predicate}, (err,data)->callback(data)

  get_Object: (object, callback)->
    if @.db is null
      callback null
      return
    @db.get {object:object}, (err,data)->callback(data)

  allData: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{
      subject  : @db.v("subject"),
      predicate: @db.v("predicate"),
      object   : @db.v("object"),
    }], (err, data)->callback(data)

  search: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.search [{
      subject  : subject    || @db.v("subject")
      predicate: predicate  || @db.v("predicate")
      object   : object     || @db.v("object")
    }], (err, data)->callback(data)

  query: (key, value, callback)=>
    if @.db is null
      callback null
      return
    switch key
      when "subject"      then @db.get { subject: value}  , (err, data) -> callback(data)
      when "predicate"    then @db.get { predicate: value}, (err, data) -> callback(data)
      when "object"       then @db.get { object: value}   , (err, data) -> callback(data)
      when "all"          then @allData callback
      else callback(null)

module.exports = Graph_Service