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


# check if existing instance of activity tracer exists within in the target region

REGIONS=""

url="/v2/resource_instances?type=service_instance&resource_id=$ACTIVITY_TRACKER_CATALOG_ID"
while [ "$url" != "null" ]
do
  #echo $url
  RESULT=$(curl -s -X GET "https://resource-controller.cloud.ibm.com$url" \
    --header "Authorization: Bearer $IAM_TOKEN" \
    --header 'Content-Type: application/json')

  if [ ! -z "$var" ]; then
    REGIONS=",$REGIONS"
  fi
  REGIONS="$(echo $RESULT | jq ".resources[].region_id" -r)$REGIONS"
  url=$(echo "$RESULT" | jq '.next_url' -r )
done

if [[ ! "$REGIONS" == *"$REGION"* ]]; then
  PLANS=$(curl -s -X GET \
    --url "https://globalcatalog.cloud.ibm.com/api/v1/$ACTIVITY_TRACKER_CATALOG_ID/*?include=metadata.plan" \
    --header "Authorization: Bearer $IAM_TOKEN" \
    --header 'Content-Type: application/json')

  PLAN_ID=$(echo "$PLANS" | jq '.resources[] | select(.name=="'$PLAN'").id' -r)

  RESULT=$(curl -s -w "%{http_code}" -X POST https://resource-controller.cloud.ibm.com/v2/resource_instances \
    -d '{
      "name": "'$INSTANCE_NAME'",
      "target": "'$REGION'",
      "resource_group": "'$RESOURCE_GROUP_ID'",
      "resource_plan_id": "'$PLAN_ID'",
      "tags": ["'$AUTOMATION_TAG'"]
    }' \
    --header "Authorization: Bearer $IAM_TOKEN" \
    --header 'Content-Type: application/json')

  if [[ ! "$http_code" == "20"* ]]; then
    # this handles success (200, 201, 202) response code
    echo "$RESULT"
    echo "$RESULT" > creation-output.json
    exit 0
  elif [[ ! "$RESULT" == *"This region already has an instance"* ]; then
    #do nothing, we will handle below
  else
    echo "$RESULT"
    exit 1
  fi
fi

# this case should only be entered if creation fails or if an instance already exists
echo "An activity tracker instance already exists in the $REGION region".

RESULT=$(curl -s -X GET "https://resource-controller.cloud.ibm.com/v2/resource_instances?type=service_instance&resource_id=$ACTIVITY_TRACKER_CATALOG_ID" \
    --header "Authorization: Bearer $IAM_TOKEN" \
    --header 'Content-Type: application/json')

INSTANCE="$(echo "$RESULT" | jq ".resources[] | select( .region_id | contains(\"$REGION\") )" -r)"

echo $INSTANCE > creation-output.json

echo $INSTANCE
