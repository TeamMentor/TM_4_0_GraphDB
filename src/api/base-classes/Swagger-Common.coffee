Cache_Service         = require('teammentor').Cache_Service
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes

class Swagger_Common
  constructor: (options)->
    @.options        = options || {}
    @.area           = @.options.area
    @.swaggerService = @.options.swaggerService

  add_Get_Method: (name, params = [])=>
    get_Command =
          spec       : { path : "/#{@.area}/#{name}", nickname : name, parameters : []}
          action     : (req,res)=> @[name](req, res)

    for param in params
      get_Command.spec.path += "/{#{param}}"
      get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))

    @.swaggerService.addGet(get_Command)

module.exports = Swagger_Common