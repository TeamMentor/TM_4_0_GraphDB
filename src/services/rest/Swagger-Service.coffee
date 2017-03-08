require 'fluentnode'
express                 = require("express")
bodyParser              = require('body-parser')
swagger_node_express    = require("swagger-node-express")
paramTypes              = swagger_node_express.paramTypes
errors                  = swagger_node_express.errors;
Swagger_Client          = require("swagger-client")

apiInfo =
          title             : "TeamMentor GraphDB 4.0"
          description       : "This is the TeamMentor Engine that powers the 4.0 UI"
          #termsOfServiceUrl : "http://localhost/terms/"
          #contact           : "abc@name.com"
          #license           : "Apache 2.0"
          #licenseUrl        : "http://www.apache.org/licenses/LICENSE-2.0.html"

class Swagger_Service
  constructor: (options)->
    @.options      = options || {}
    @.app          = @.options.app || express()
    @.apiInfo      = @.options.apiInfo || apiInfo
    @.swagger      = null
    @.port         = @.options.port || global.config?.tm_graph?.port || process.env.PORT || 1332
    @.server       = "http://localhost:#{@.port}"
    @.url_Api_Docs = @.server.append('/v1.0/api-docs')

  path_Swagger_UI: ()=>
    for path in require.cache.keys_Own()
       if path.contains('swagger-node-express')
        return path.parent_Folder()
                   .path_Combine('swagger-ui')

  map_Docs: ()=>
    docs_handler = express.static(@path_Swagger_UI());

    @.app.get /^\/docs(\/.*)?$/, (req, res, next)=>
      if (req.url == '/docs')                                                                             # express static barfs on root url w/o trailing slash
        res.writeHead(302, { 'Location' : req.url + "/?url=http://localhost:#{@.port}/v1.0/api-docs" });
        res.end();
        return;
      req.url = req.url.substr('/docs'.length);                                                           # take off leading /docs so that connect locates file correctly
      return docs_handler(req, res, next);
    @

  setup: =>
    @.map_Docs()
    @.app.use(bodyParser.urlencoded({ extended: false }))
    @.app.use(bodyParser.json())
    @.swagger = swagger_node_express.createNew(@app)
    @

  addGet: (getSpec)=>
    @.swagger.addGet(getSpec)
    @

  #addPost: (getSpec)=>
  #  @swagger.addPost(getSpec)
  #  @

  swagger_Setup: =>
    @swagger.setApiInfo(@.apiInfo)
    @swagger.configureSwaggerPaths("", "v1.0/api-docs", "")
    @swagger.configure(@server, "1.0.0");
    @

  set_Defaults: =>
    @.setup()
     .swagger_Setup()
    @

  get_Client_Api: (apiName, callback)=>
    api_Url = @.url_Api_Docs.append("/#{apiName}")

    onSuccess  = ()    -> callback(swaggerApi[apiName])
    onFailure  = (data)-> "API Call Failed".log(); log data
    onProgress = (data)-> #log data
    options    = { url: api_Url, success:onSuccess, failure: onFailure, progress: onProgress }

    swaggerApi = new Swagger_Client.SwaggerClient(api_Url, options)

module.exports = Swagger_Service
