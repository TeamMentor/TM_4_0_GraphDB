winston    = null

class Logging_Service

  dependencies: ()->
    winston         = require 'winston'
    DailyRotateFile = require 'winston-daily-rotate-file'
  constructor: (options)->
    @.dependencies()
    @.options          = options || {}
    @.log_Folder       = @options.log_Folder || './.logs'
    @.log_File         = null
    @.logger           = null
    @.original_Console = null

  setup: =>
    @.log_File = @.log_Folder.folder_Create().path_Combine('tm-graphDb')

    @.logger = new (winston.Logger)(transports: [
      new  winston.transports.DailyRotateFile({ filename: @.log_File, datePattern: '.yyyy-MM-dd'})
      new  winston.transports.Console({ timestamp: true, level: 'verbose', colorize: true })
    ])

    @.hook_Console()
    @

  hook_Console: =>
    if(console.log?.source_Code() is "function () { [native code] }")
      console.log 'Hooking Console to Winston logger'
      @.original_Console = console.log
      console.log        = (args...)=> @.info args...
      global.logger      = @
      @.log '[Logging-Service] console hooked'

  restore_Console: =>
    if @.original_Console
      console.log = @.original_Console
      @.log 'Console restored'

  info: (data)=>
    @.logger.info data

  log: (data)=>
    @.logger.info data

  error: (data)=>
    @.logger.error data


module.exports = Logging_Service