# Combination API app
The project deploys an API with Lambda. It invokes a ***icanhazdadjoke.com*** in order to get 2 jokes and return to the caller.

## Testing
`python3 -m unittest tests.test_api_composer`

## Set up Cognito user

### Fetch user_pool_id
```bash
aws cognito-idp list-user-pools \
  --max-results 1 \
  --query "UserPools[?starts_with(Name, 'combination-api-app')].Id | [0]"
```

### Fetch user_pool_client_id
```bash
aws cognito-idp list-user-pool-clients \
  --user-pool-id [user_pool_id] \
  --query "UserPoolClients[?starts_with(ClientName, 'combination-api-app')].ClientId | [0]"
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
If `"confirm_email_option": "CONFIRM_WITH_LINK"` a user can be confirmed by a link in the email that has been provided
during the registration.
Otherwise, if `"confirm_email_option": "CONFIRM_WITH_LINK"`, the user receives email with verification code. Next, the user
should be confirmed by executing the following command:
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
