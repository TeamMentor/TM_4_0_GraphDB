/*jslint node: true */
"use strict";

require('coffee-script/register');              // adding coffee-script support


process.env.TM_SITE_DATA = "SiteData_TM";

var Side_Data = require('../TM_Shared/src/Site-Data');
var site_Data = new Side_Data()

console.log('[SiteData] loading data from ' + site_Data.siteData_Folder())

global.config = site_Data//.load_Custom_Code()
                         .load_Options()


var Server = require('./src/TM-Server');           // gets the express server

var server = new Server().configure()              // configure the server

function add_Swagger(app)
{
  var Swagger_Service = require('./src/services/rest/Swagger-Service')
  var options = { app: app }
  var swaggerService = new Swagger_Service(options)
  swaggerService.set_Defaults()


  new (require('./src/api/Data-API'   ))({swaggerService: swaggerService}).add_Methods()
  new (require('./src/api/Search-API' ))({swaggerService: swaggerService}).add_Methods()
  new (require('./src/api/Convert-API'))({swaggerService: swaggerService}).add_Methods()
  new (require('./src/api/GraphDB-API'))({swaggerService: swaggerService}).add_Methods()
  new (require('./src/api/User-API' ))({swaggerService: swaggerService}).add_Methods()

  swaggerService.swagger_Setup()
}

server.start(function (data){
  console.log('Adding swagger support')
  add_Swagger(server.app);
  console.log('Server started at: ' + server.url());
  console.log("--- server up and running ---")
})

