express              = require 'express'
compress             = require 'compression'
{Jade_Service}       = require 'teammentor'
Logging_Service      = require './services/utils/Logging-Service'

class TM_Server
    constructor: (options)->
        @.options         = options || {}
        @_server          = null;
        @.app             = express()
        @.port            = @.options.port || global.config?.tm_graph?.port || process.env.PORT || 1332
        @.logging_Service = null

    configure: =>
        @.app.set('view engine', 'jade')
        @.app.use(compress())
        @.app.get '/'    , (req,res) -> res.redirect 'docs'
        @.enable_Logging()
        @

    start: (callback)=>
        @._server = @app.listen @port, ->
          callback() if callback
        @

    stop: (callback)=>
      @.logging_Service.restore_Console()
      @_server._connections = 0   # trick the server to believe there are no more connections (I didn't find a nice way to get and open existing connections)

      @_server.close ->
        callback() if callback

    url: =>
        "http://localhost:#{@port}"

    routes: =>
        routes = @app._router.stack
        paths = []
        routes.forEach (item)->
            if (item.route)
                paths.push(item.route.path)               
        return paths

    enable_Logging: =>
      @.logging_Service = new Logging_Service().setup()

      @.app.use (req, res, next)->
        console.log({method: req.method, url: req.url})
        next();
        
module.exports = TM_Server


