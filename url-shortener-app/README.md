# URL shortener project
-  TBD

## Testing locally
Make sure you have installed ***python-lambda-local***. You can find installation guide here: https://pypi.org/project/python-lambda-local/ <br>
Next just run in a terminal: <br>
`python-lambda-local -f lambda_handler api_composer.py event.json`


curl -H "Content-Type: application/json" -X POST -d '{"originalUrl": "https://google.com"}' https://jlivrtqj7g.execute-api.eu-central-1.amazonaws.com/dev/short-url