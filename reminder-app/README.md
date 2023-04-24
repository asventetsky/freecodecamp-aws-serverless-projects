# Reminder app
-  TBD

## Create ECR Repository before running deployment
ECR Repository should follow the format `reminder-app-[region]-[environment]`

## Prepare local build & deploy by Terragrunt
The idea behind it is to create and push Docker Images for lambdas and prepare
local environment to run Terragrunt stuff (like `terragrunt init`, `terragrunt plan` etc.)
In the project's `source` directory run:
````bash
../../scripts/setup_lambda_docker_local_deployment.sh [region] [ecr_uri] [terragrunt_env_vars_path]
````
Scrip is used to install required dependencies (in `venv` folder),
create and push Docker Images for lambda based on `lambdas_spec.txt` and update
`env_vars.yaml` required for Terragrunt.