function hubble() {
  local AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
  local AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
  local AWS_SESSION_TOKEN=$(aws configure get aws_session_token)
  local USER_EMAIL=$(aws sts get-caller-identity | jq -r '.UserId' | cut -d':' -f 2)
  local IMAGE=hubble-cli

  # NOTE: mount current dir to allow copy (this bad mang)
  docker run --rm -it \
    --entrypoint "/scripts/entrypoint.sh" \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -e "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" \
    -e "PROFILE=$PROFILE" \
    -e USER_EMAIL=$USER_EMAIL \
    --mount type=bind,source="$(pwd)",target=/app,readonly \
    $IMAGE "$@"
}
