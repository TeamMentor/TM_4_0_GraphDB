Swagger_GraphDB      = require './base-classes/Swagger-GraphDB'

class GraphDB_API extends Swagger_GraphDB

    constructor: (options)->
      @.options      = options || {}
      @.options.area = 'graph-db'
      super(@.options)


    contents: (req, res)=>
      @.using_Graph res, null, (send)->
        @.allData send

    subjects: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Subjects send

    predicates: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Predicates send

    objects: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Objects send

    subject: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Subject value, send

    predicate: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Predicate value, send

    object: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Object value, send

    pre_obj: (req,res)=>
      predicate = req.params.predicate
      object    = req.params.object

      @.using_Graph res, null, (send)->
        @.search undefined, predicate, object, send

    sub_pre: (req,res)=>
      subject   = req.params.subject
      predicate = req.params.predicate
      @.using_Graph res, null, (send)->
        @.search subject, predicate, undefined, send

    status: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        send { status: 'ok' }

    cache_path: (req, res)=>
      res.json { path: @.cache._cacheFolder.real_Path() }

    add_Methods: ()=>

      @.add_Get_Method 'contents'   , []
      @.add_Get_Method 'subjects'   , []
      @.add_Get_Method 'predicates' , []
      @.add_Get_Method 'objects'    , []
      @.add_Get_Method 'subject'    , ['value']
      @.add_Get_Method 'predicate'  , ['value']
      @.add_Get_Method 'object'     , ['value']
      @.add_Get_Method 'sub_pre'    , ['subject', 'predicate']
      @.add_Get_Method 'pre_obj'    , ['predicate','object']
      @.add_Get_Method 'status'     , []
      @.add_Get_Method 'cache_path' , []



module.exports = GraphDB_API