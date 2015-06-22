Swagger_Common   = require './base-classes/Swagger-Common'
Config_Service   = require '../services/utils/Config-Service'
Import_Service   = require '../services/data/Import-Service'
{Cache_Service}  = require 'teammentor'


class Config_API extends Swagger_Common

    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.configService  = new Config_Service()
      @.cache          = new Cache_Service("data_cache")
      #@.tmGuidance     = new TM_Guidance { importService : new Import_Service(name:'tm-uno') }
      @.options.area   = 'config'
      super(options)

    file: (req,res)=>
      res.send @configService.config_File_Path().json_pretty()

    contents: (req,res)=>
      @configService.get_Config (config)=>
        res.send config.json_pretty()

    delete_data_cache: (req,res)=>
      @.cache.cacheFolder().folder_Delete_Recursive()
      result = "deleted all files from folder #{@.cache.cacheFolder()}"
      @.cache.cacheFolder().folder_Create()                             # create it again (so that it exists for new puts)
      res.send result.json_pretty()

    add_Methods: ()=>
      @.add_Get_Method 'file'
      @.add_Get_Method 'contents'
      @.add_Get_Method 'reload'
      @.add_Get_Method 'delete_data_cache'
      @

module.exports = Config_API
