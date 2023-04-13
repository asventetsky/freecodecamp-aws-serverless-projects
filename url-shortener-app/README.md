# URL shortener project
-  TBD

## Prepare local build & deploy by Terragrunt
The idea behind it is to create archives for lambdas and prepare
local environment to run Terragrunt stuff (like `terragrunt init`, `terragrunt plan` etc.)
In the project's `source` directory run:
````bash
../../scripts/setup_local_terragrunt_deployment.sh
````
Scrip is used to install required dependencies (in `venv` folder),
create lambda archives based on `lambda_modules.txt` and update
`common_vars.yaml` required for Terragrunt.

## Set up Cognito user

### Fetch user_pool_id
```bash
aws cognito-idp list-user-pools \
  --max-results 1 \
  --query "UserPools[?starts_with(Name, 'url-shortener-app')].Id | [0]"
```

### Fetch user_pool_client_id
```bash
aws cognito-idp list-user-pool-clients \
  --user-pool-id [user_pool_id] \
  --query "UserPoolClients[?starts_with(ClientName, 'url-shortener-app')].ClientId | [0]"
```

### Create Cognito user
```bash
aws cognito-idp sign-up \
  --client-id [user_pool_client_id] \
  --username [username] \
  --password [password] \
  --user-attributes Name=email,Value=[email]
```

### Confirm Cognito user
```bash
aws cognito-idp confirm-sign-up \
  --client-id [user_pool_client_id] \
  --username=[username] \
  --confirmation-code [verification_code_from_email]
```

### Get token
```bash
aws cognito-idp initiate-auth \
  --client-id [user_pool_client_id] \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=[username],PASSWORD=[password] \
  --query 'AuthenticationResult.IdToken' \
  --output text
```
