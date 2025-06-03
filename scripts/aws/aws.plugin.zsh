rebuild_aws_config() {
  local SSO_SESSION_NAME=$1
  local SSO_START_URL=$2
  local SSO_REGION=$3
  local CONFIG_FILE="$HOME/.aws/config"
  local TMP_CONFIG="$CONFIG_FILE.generated"
  local PROFILE_PREFIX="aws-sso"

  rm "$TMP_CONFIG"

  # Ensure jq is installed
  if ! command -v jq &>/dev/null; then
    echo "❌ jq is not installed. Please install jq to proceed."
    return 1
  fi

  echo "🔐 Logging in to AWS Identity Center (SSO session: $SSO_SESSION_NAME)..."
  aws sso login --sso-session "$SSO_SESSION_NAME"
  if [ $? -ne 0 ]; then
    echo "❌ SSO login failed"
    return 1
  fi

  echo "🔍 Extracting access token from AWS CLI SSO cache..."
  local TOKEN=$(jq -r '.accessToken' ~/.aws/sso/cache/*.json | tail -n 1)

  if [ -z "$TOKEN" ]; then
    echo "❌ Failed to extract access token. Make sure 'jq' is installed and you've logged in."
    return 1
  fi

  echo "📦 Fetching AWS session details..."
  echo "[sso-session $SSO_SESSION_NAME]" >>"$TMP_CONFIG"
  echo "sso_start_url = $SSO_START_URL" >>"$TMP_CONFIG"
  echo "sso_region = $SSO_REGION" >>"$TMP_CONFIG"
  echo "sso_registration_scopes = sso:account:access" >>"$TMP_CONFIG"
  echo "" >>"$TMP_CONFIG"

  echo "✅ Imported sso-session: $SSO_SESSION_NAME"

  echo "📦 Fetching AWS accounts you have access to..."
  local accounts=$(aws sso list-accounts --access-token "$TOKEN" --region "$SSO_REGION")
  local account_ids=$(echo "$accounts" | jq -r '.accountList[].accountId')

  for account_id in $account_ids; do
    local account_name=$(echo "$accounts" | jq -r ".accountList[] | select(.accountId==\"$account_id\") | .accountName")
    local roles=$(aws sso list-account-roles --access-token "$TOKEN" --account-id "$account_id" --region "$SSO_REGION")

    for role_name in $(echo "$roles" | jq -r '.roleList[].roleName'); do
      local profile_name=$(echo "$PROFILE_PREFIX-$account_name-$role_name" | sed 's/[[:space:]]//g' | tr -d '[:blank:]')

      echo "[profile $profile_name]" >>"$TMP_CONFIG"
      echo "sso_session = $SSO_SESSION_NAME" >>"$TMP_CONFIG"
      echo "sso_account_id = $account_id" >>"$TMP_CONFIG"
      echo "sso_role_name = $role_name" >>"$TMP_CONFIG"
      echo "region = eu-west-1" >>"$TMP_CONFIG"
      echo "output = json" >>"$TMP_CONFIG"
      echo "" >>"$TMP_CONFIG"

      echo "✅ Imported profile: $profile_name"
    done
  done

  # TODO: handle in a more dynamic way
  echo "[profile lw-data-prod-dbt]" >>"$TMP_CONFIG"
  echo "role_arn = arn:aws:iam::478824949770:role/hubble-rbac/DbtDeveloper" >>"$TMP_CONFIG"
  echo "source_profile = aws-sso-LunarWay-Production-Data-OktaDataLogin" >>"$TMP_CONFIG"
  echo "region = eu-west-1" >>"$TMP_CONFIG"
  echo "output = json" >>"$TMP_CONFIG"

  echo "[profile lw-data-dev-dbt]" >>"$TMP_CONFIG"
  echo "role_arn = arn:aws:iam::899945594626:role/hubble-rbac/DbtDeveloper" >>"$TMP_CONFIG"
  echo "source_profile = aws-sso-LunarWay-Development-Data-OktaDataLogin" >>"$TMP_CONFIG"
  echo "region = eu-west-1" >>"$TMP_CONFIG"
  echo "output = json" >>"$TMP_CONFIG"

  cat "$TMP_CONFIG"
  echo "🔧 Updating AWS config at $CONFIG_FILE..."
  cat "$TMP_CONFIG" >"$CONFIG_FILE"
  echo "✅ All profiles generated and appended to $CONFIG_FILE"
}

aws_login() {
  aws sso login --sso-session "$SSO_SESSION_NAME"
  export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' ~/.aws/sso/cache/*.json | tail -n 1)
}

assume_aws_role() {
  aws sts get-caller-identity &>/dev/null
  EXIT_CODE=$? # captures exit code

  if [[ $EXIT_CODE == 0 ]]; then
    echo "Current credentials are still valid. Let's just reuse them 🚀"
    return 0
  else
    aws_login
  fi

  export AWS_PROFILE=$(cat ~/.aws/config | grep profile | awk -F'[][]' '{print $2}' | sed 's/^profile //' | fzf --prompt "Choose AWS role:")
  export AWS_ACCESS_KEY_ID=$(cat ~/.aws/cli/cache/$cache_file | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/cli/cache/$cache_file | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(cat ~/.aws/cli/cache/$cache_file | jq -r '.Credentials.SessionToken')

  # set expiration time variable
  aws_sessions_expiration=$(cat ~/.aws/cli/cache/$cache_file | jq -r '.Credentials.Expiration')
  aws sts get-caller-identity &>/dev/null
}

