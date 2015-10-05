Swagger_Common  = require '../../../src/api/base-classes/Swagger-Common'

describe '| api | base-classes | Swagger-Common.test', ->

  it 'constructor', ->
    using new Swagger_Common(), ->
      @.options.assert_Is {}
      assert_Is_Undefined @.area
      assert_Is_Undefined @.swaggerService

  it 'constructor (with options)', ->
    options =  { area:'aaaa', swaggerService: 'bbbb'}
    using new Swagger_Common(options), ->
      @.options       .assert_Is options
      @.area          .assert_Is options.area
      @.swaggerService.assert_Is options.swaggerService

  it 'add_Get_Method (no params)', (done)->
    area           = 'area_'.add_5_Letters()
    name           = 'name_'.add_5_Letters()
    swaggerService =
      addGet: (get_Command)->
        get_Command.spec.assert_Is { path: "/#{area}/#{name}", nickname: name, parameters: [] },
        done()
    options =  { area:area, swaggerService}
    using new Swagger_Common(options), ->
      @.add_Get_Method name

  it 'add_Get_Method (with params)', (done)->
    area           = 'area'.add_5_Letters()
    name           = 'name_'.add_5_Letters()
    params         = [ 'param_1'.add_5_Letters(), 'param_2'.add_5_Letters()]
    swaggerService =
      addGet: (get_Command)->

        get_Command.spec.assert_Is
          path: "/#{area}/#{name}/{#{params.first()}}/{#{params.second()}}"
          nickname: name
          parameters: [ {
                              "defaultValue": undefined
                              "description": "method parameter"
                              "enum": undefined
                              "name": params.first()
                              "paramType": "path"
                              "required": true
                              "type": "string"
                            }
                            {
                              "defaultValue": undefined
                              "description": "method parameter"
                              "enum": undefined
                              "name": params.second()
                              "paramType": "path"
                              "required": true
                              "type": "string"
                            } ]
        done()

    options =  { area:area, swaggerService}
    using new Swagger_Common(options), ->
      @.add_Get_Method name, params