levelgraph      = require('levelgraph'   )
GitHub_Service  = require('./GitHub-Service')

class GraphService
  constructor: (dbName)->
    @dbName     = if  dbName then dbName else '_tmp_db'.add_Random_String(5)
    @dbPath     = "./.tmCache/#{@dbName}"#.create_Dir()
    @db         = null

  #Setup methods

  openDb : (callback)=>
    @db         = levelgraph(@dbPath)
    callback() if callback
    return @db

  closeDb: (callback)=>
    @db.close =>
      @db    = null
      @level = null
      callback()

  deleteDb: (callback)=>
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  add: (subject, predicate, object, callback)=>
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  get_Subject: (subject, callback)->
    @db.get {subject:subject}, (err,data)->
      throw err if err
      callback(data)

  get_Predicate: (predicate, callback)->
    @db.get {predicate:predicate}, (err,data)->callback(data)

  get_Object: (object, callback)->
    @db.get {object:object}, (err,data)->callback(data)

  allData: (callback)=>
    @db.search [{
      subject  : @db.v("subject"),
      predicate: @db.v("predicate"),
      object   : @db.v("object"),
    }], (err, data)->callback(data)

  query: (key, value, callback)->
    switch key
      when "subject"      then @db.get { subject: value}  , (err, data) -> callback(data)
      when "predicate"    then @db.get { predicate: value}, (err, data) -> callback(data)
      when "object"       then @db.get { object: value}   , (err, data) -> callback(data)
      when "all"          then @allData callback
      else callback(null,[])

  graph_From_Data: (data, callback)->
    nodes = []
    edges = []

    addNode =  (node)->
      nodes.push(node) if node not in nodes

    addEdge =  (from, to, label)->
      edges.push({from: from , to: to , label: label})

    for triplet in data
      if (triplet.subject.length > 40)
        triplet.subject =  triplet.subject.substring(0,40) + "..."
      addNode(triplet.subject)
      addNode(triplet.object)
      addEdge(triplet.subject, triplet.object, triplet.predicate)

    nodes = ({id: node} for node in nodes)

    graph = { nodes: nodes, edges: edges }

    callback(graph)

module.exports = GraphService