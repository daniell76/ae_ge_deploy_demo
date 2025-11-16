#!/bin/bash
#set -ex


check_variable_set() {
  for var in "$@"; do
    if ! printenv "$var" >/dev/null 2>&1; then
      echo "Error: $var not set up";
      exit 1; 
    fi
  done
}

deploy_agent() {
  check_variable_set PROJECT_ID REASONING_ENGINE_LOCATION BUCKET REASONING_ENGINE_AGENT_SA REASONING_ENGINE_AGENT_NAME
  echo "Building wheel..."
  source .venv/bin/activate
  uv build --wheel --out-dir=.

  whl_files=( *.whl )
  if [ "${whl_files[0]}" = "*.whl" ]; then
    echo "Error: No *.whl files found in the current directory." >&2
    exit 1
  fi

  FIRST_WHL_FILE="${whl_files[0]}"
  echo "deploying agent to Agent Engine with $FIRST_WHL_FILE ..."
  python -m deployment.deploy --create --project_id "$PROJECT_ID" \
    --bucket "$BUCKET" --location "$REASONING_ENGINE_LOCATION" \
    --agent_name "$REASONING_ENGINE_AGENT_NAME" --agent_sa "$REASONING_ENGINE_AGENT_SA" \
    --config_file "$(realpath "$CONFIG_FILE")" --wheel_file "$FIRST_WHL_FILE"
  echo "Done."
}

update_agent() {
  check_variable_set PROJECT_ID REASONING_ENGINE_LOCATION REASONING_ENGINE_ID BUCKET REASONING_ENGINE_AGENT_SA
  source .venv/bin/activate
  uv build --wheel --out-dir=.
  echo "Updating agent in Agent Engine..."
  python -m deployment.deploy --update --project_id $PROJECT_ID --bucket $BUCKET --location $REASONING_ENGINE_LOCATION --resource_id $REASONING_ENGINE --agent_sa $REASONING_ENGINE_AGENT_SA
  echo "Done."
}

delete_agent(){
  check_variable_set PROJECT_ID REASONING_ENGINE_LOCATION REASONING_ENGINE_ID
  source .venv/bin/activate
  echo "Deleting agent from Agent Engine"
  python -m deployment.deploy --delete --resource_id $REASONING_ENGINE
  echo "Done."
}

list_datastores(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP
  curl -X GET \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}"/v1/projects/${PROJECT_ID}/locations/${AS_LOCATION}/collections/default_collection/dataStores" 

}

create_datastore(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP DATASTORE_ID
  curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}"/v1/projects/${PROJECT_ID}/locations/${AS_LOCATION}/collections/default_collection/dataStores?dataStoreId=${DATASTORE_ID}" \
  -d '{
    "name": "projects/'${PROJECT_ID}'/locations/'${AS_LOCATION}'/collections/default_collection/dataStores/'${DATASTORE_ID}'",
    "displayName": "'${DATASTORE_ID}'",
    "industryVertical": "GENERIC",
    "solutionTypes": ["SOLUTION_TYPE_SEARCH"],
    "contentConfig": "CONTENT_REQUIRED"
  }'
}

create_as_app(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP DATASTORE_ID
  curl -X POST \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines?engineId=${AS_APP} \
        -d '{
              "name": "projects/'${PROJECT_NUMBER}'/locations/'${AS_LOCATION}'/collections/default_collection/engines/'${AS_APP}'",
              "displayName" : "'"${AS_APP}"'",
              "dataStoreIds": ["'${DATASTORE_ID}'"],
              "solutionType": "SOLUTION_TYPE_SEARCH",
              "searchEngineConfig": {
                "searchTier": "SEARCH_TIER_ENTERPRISE",
                "searchAddOns": [
                  "SEARCH_ADD_ON_LLM"
                ]
              },
              "industryVertical": "GENERIC",
              "appType": "APP_TYPE_INTRANET"
            }'  
}

update_as_app(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP DATASTORE_ID
  curl -X PATCH \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines/${AS_APP} \
        -d '{
              "name": "projects/'${PROJECT_NUMBER}'/locations/'${AS_LOCATION}'/collections/default_collection/engines/'${AS_APP}'",
              "displayName" : "'"${AS_APP}"'",
              "dataStoreIds": ["'${DATASTORE_ID}'"],
              "solutionType": "SOLUTION_TYPE_SEARCH",
              "searchEngineConfig": {
                "searchTier": "SEARCH_TIER_ENTERPRISE",
                "searchAddOns": [
                  "SEARCH_ADD_ON_LLM"
                ]
              },
              "industryVertical": "GENERIC",
              "appType": "APP_TYPE_INTRANET"
            }'  
}

delete_as_app(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP
  curl -X DELETE \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines/${AS_APP} 
}

list_as_apps(){
  check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION
  curl -X GET \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines
}

link_as_agent() {
    check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP AS_AGENT_DESCRIPTION REASONING_ENGINE_ID
    API_RESPONSE=$(curl -X POST \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines/${AS_APP}/assistants/default_assistant/agents \
        -d '{
      "name": "projects/'${PROJECT_NUMBER}'/locations/'${AS_LOCATION}'/collections/default_collection/engines/'${AS_APP}'/assistants/default_assistant",
      "displayName": "'"${AS_AGENT_DISPLAY_NAME}"'",
      "description": "'"${AS_AGENT_DESCRIPTION}"'",
      "icon": {
        "uri": "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/corporate_fare/default/24px.svg"
      },
      "adk_agent_definition": {
        "tool_settings": {
          "toolDescription": "'"${AS_AGENT_DESCRIPTION}"'",
        },
        "provisioned_reasoning_engine": {
          "reasoningEngine": "'"${REASONING_ENGINE}"'"
        },
      }
    }')
    AS_AGENT_ID=$(echo "$API_RESPONSE"| jq -r '.name | split("/")[-1]')
    echo "$API_RESPONSE"
    echo "Created Agent Space App with ID: ${AS_AGENT_ID}"

    # Update the CONFIG file in place
    jq --arg id "$AS_AGENT_ID" --indent 4 '.agent_space_agent_id = $id' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"
}

list_as_agents() {
    check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP
    curl  \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines/${AS_APP}/assistants/default_assistant/agents \
    
}


unlink_as_agent() {
   check_variable_set PROJECT_ID PROJECT_NUMBER AS_LOCATION AS_APP AS_AGENT_ID
   curl  -X DELETE \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: ${PROJECT_ID}" \
        ${DISCOVERY_ENGINE_PROD_API_ENDPOINT}/v1alpha/projects/${PROJECT_NUMBER}/locations/${AS_LOCATION}/collections/default_collection/engines/${AS_APP}/assistants/default_assistant/agents/${AS_AGENT_ID} 
}


# --- Parse arguments ---
ACTION=""
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deploy-agent|--update-agent|--delete-agent|--create-datastore|--list-datastores|--create-as-app|--update-as-app|--delete-as-app|--list-as-apps|--link-as-agent|--list-as-agents|--unlink-as-agent)
      ACTION="${1#--}"  # strip the leading '--'
      shift
      ;;
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --deploy-agent|--update-agent|--delete-agent|--create-datastore|--list-datastores|--create-as-app|--update-as-app|--delete-as-app|--list-as-apps|--link-as-agent|--list-as-agents|--unlink-as-agent --config <config.json>"
      exit 1
      ;;
  esac
done

# --- Validate inputs ---
if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 --deploy-agent|--update-agent|--delete-agent|--create-datastore|--list-datastores|--create-as-app|--update-as-app|--delete-as-app|--list-as-apps|--link-as-agent|--list-as-agents|--unlink-as-agent --config <config.json>"
  exit 1
fi

if [[ -z "$CONFIG_FILE" ]]; then
  echo "No config file specified, using default 'config.json'"
  CONFIG_FILE="config.json"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file '$CONFIG_FILE' not found"
  exit 1
fi

# --- Load config values if needed ---
# Example: EPOCHS=$(jq -r '.epochs' "$CONFIG_FILE")

export PROJECT_ID=$(jq -r '.project_id' $CONFIG_FILE) # String 
export PROJECT_NUMBER=$(jq -r '.project_number' $CONFIG_FILE) # String 
export BUCKET=$(jq -r '.bucket' $CONFIG_FILE)
export REASONING_ENGINE_AGENT_NAME=$(jq -r '.reasoning_engine_agent_name' $CONFIG_FILE)
export REASONING_ENGINE_AGENT_SA=$(jq -r '.reasoning_engine_agent_sa' $CONFIG_FILE)
export REASONING_ENGINE_LOCATION=$(jq -r '.reasoning_engine_location' $CONFIG_FILE) # String - e.g. us-central1
export REASONING_ENGINE_ID=$(jq -r '.reasoning_enigne_id' $CONFIG_FILE)
export REASONING_ENGINE="projects/${PROJECT_ID}/locations/${REASONING_ENGINE_LOCATION}/reasoningEngines/${REASONING_ENGINE_ID}"
export DATASTORE_ID=$(jq -r '.datastore_id' $CONFIG_FILE)
export AS_APP=$(jq -r '.agent_space_app' $CONFIG_FILE) # String - Find it in Google Cloud AI Applications
export AS_LOCATION=$(jq -r '.agent_space_location' $CONFIG_FILE) # String - e.g. global, eu, us
export AS_AGENT_DISPLAY_NAME=$(jq -r '.agent_space_agent_display_name' $CONFIG_FILE)
export AS_AGENT_DESCRIPTION=$(jq -r '.agent_space_agent_decription' $CONFIG_FILE)
export AS_AGENT_ID=$(jq -r '.agent_space_agent_id' $CONFIG_FILE)
export GOOGLE_CLOUD_QUOTA_PROJECT=$(jq -r '.project_id' $CONFIG_FILE)
export DISCOVERY_ENGINE_PROD_API_ENDPOINT="https://${AS_LOCATION}-discoveryengine.googleapis.com"

if [[ -z "$AS_AGENT_DISPLAY_NAME" ]]; then
  AS_AGENT_DISPLAY_NAME="$AS_APP"
fi

# --- Run the selected function ---
case "$ACTION" in
  deploy-agent)         deploy_agent ;;
  update-agent)         update_agent ;;
  delete-agent)         delete_agent;;
  create-datastore)     create_datastore;;
  list-datastores)      list_datastores;;
  create-as-app)        create_as_app;;
  update-as-app)        update_as_app;;
  delete-as-app)        delete_as_app;;
  list-as-apps)         list_as_apps;;
  link-as-agent)        link_as_agent ;;
  list-as-agents)       list_as_agents ;;
  unlink-as-agent)      unlink_as_agent ;;
  *)
    echo "Unknown action '$ACTION'"
    exit 1
    ;;
esac
