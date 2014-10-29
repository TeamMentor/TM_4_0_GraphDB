addData = (dataUtil)->
  # Articles
  dataUtil.addMappings "article-e7ed2762fc3e",  { is: 'Article', title : 'All Input Is Validated - in .Net'          ,  guid: 'a330bfdd-9576-40ea-997e-e7ed2762fc3e' , summary: 'On Html 5, Verify that whitelist (positive) input validation is used to filter all input.'}
  dataUtil.addMappings "article-d5bc580df781",  { is: 'Article', title : 'All Input Is Validated - in HTML 5'        ,  guid: 'cde61562-aff2-40a0-beb9-d5bc580df781' , summary: 'On Android, Properly implemented input validation is effective at preventing many types of injection vulnerabilities, such as Cross-Site Scripting and SQL injection.'}
  dataUtil.addMappings "article-9771b8ed3eda",  { is: 'Article', title : 'Should validated all Input'                ,  guid: 'ed7404ea-00fa-4f4c-a692-9771b8ed3eda' , summary: 'On iOS, Verify that all input is validated. Properly implemented input validation mitigates many types of injection vulnerabilities, such as Cross-Site Scripting and SQL injection.'}
  dataUtil.addMappings "article-1106d793193b",  { is: 'Article', title : 'The Input should be Validated'             ,  guid: '0f3bb6f1-9058-463f-a835-1106d793193b' , summary: 'On C++, Ensure that all input is validated. Validation routines should check for length, range, format, and type. Validation should check first for known valid and safe data and then for malicious, dangerous data.'}
  dataUtil.addMappings "article-3e15eef3a23c",  { is: 'Article', title : 'Centralize Input Validation'               ,  guid: '172019bd-2e47-49a0-8852-3e15eef3a23c' , summary: 'All web applications need to validate their input, and this should be performed in a single centralized place, to ensure consistency.'}
  dataUtil.addMappings "article-9f8b44a5b27d",  { is: 'Article', title : 'Client-side Validation Is Not Relied On'   ,  guid: '9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d' , summary: 'Verify that the same or more rigorous checks are performed on the server as on the client. Verify that client-side validation is used only for usability and to reduce the number of posts to the server.'}
  dataUtil.addMappings "article-46d6939abe45",  { is: 'Article', title : 'Don\'t rely on Client-side Validation'     ,  guid: '585828bc-06d7-4f7d-94fc-46d6939abe45' , summary: 'Verify that the same or more rigorous checks are performed on the server as on the client. Verify that client-side validation is used only for usability and to reduce the number of posts to the server.'}

module.exports = addData