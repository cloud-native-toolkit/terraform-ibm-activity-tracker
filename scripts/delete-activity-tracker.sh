#!/bin/bash

set -e

PATH=$BIN_DIR:$PATH
JQ="$BIN_DIR/jq"

IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | ${JQ} -r '.access_token')

ACCOUNT_ID=$(curl -s -X GET 'https://iam.cloud.ibm.com/v1/apikeys/details' \
  -H "Authorization: Bearer $IAM_TOKEN" -H "IAM-Apikey: ${IBMCLOUD_API_KEY}" \
  -H 'Content-Type: application/json' | ${JQ} -r '.account_id')


# check if instance exists

RESULT=$(curl -s --url "https://resource-controller.cloud.ibm.com/v2/resource_instances?name=$INSTANCE_NAME"  \
  --header "Authorization: Bearer $IAM_TOKEN" \
  --header 'Content-Type: application/json')


COUNT=$(echo $RESULT | jq '.resources | length' -r)

if [ "$COUNT" -gt "0" ]; then
  echo "Found instance $INSTANCE_NAME..."
  ID=$(echo $RESULT | jq '.resources[].id' -r)
  GUID=$(echo $RESULT | jq '.resources[].guid' -r)
  echo "ID: $ID"
  echo "GUID: $GUID"

  #check to make sure the instance has the automation tag before deleting
  TAGS=$(curl -s -X GET \
    --header "Authorization: Bearer $IAM_TOKEN" \
    --header 'Content-Type: application/json' \
    "https://tags.global-search-tagging.cloud.ibm.com/v3/tags?tag_type=user&providers=ghost&offset=0&limit=10&order_by_name=asc&attached_to=$ID")


  if [[ "$TAGS" == *"$AUTOMATION_TAG"* ]]; then
    echo "Found automation tag: $AUTOMATION_TAG. Deleting instance $ID..."

    curl -s -X DELETE "https://resource-controller.cloud.ibm.com/v2/resource_instances/$GUID" \
      --header "Authorization: Bearer $IAM_TOKEN" \
      --header 'Content-Type: application/json'
    echo "Deleted"
  fi
else
  echo "Activity Tracker instance not found"
  exit 1;
fi

