# aws-lambda-multiple-creation

    bash zip.sh
It will zip all the python folders search based on lambda-function.py file
  
    bash publish.sh alias-name
It will search the lambda based on the zip file names. If, not available create function with alias. If, exist check for alias if exist update the version if not create the alias

    bash delete-function.sh
It will delete all the lambda functions which was created before. works based on zip-file name.
