# Combination API project
The project deploys an API with Lambda. It invokes a ***icanhazdadjoke.com*** in order to get 2 jokes and return to the caller.

## Testing locally
Make sure you have installed ***python-lambda-local***. You can find installation guide here: https://pypi.org/project/python-lambda-local/ <br>
Next just run in a terminal: <br>
`python-lambda-local -f lambda_handler api_composer.py event.json`