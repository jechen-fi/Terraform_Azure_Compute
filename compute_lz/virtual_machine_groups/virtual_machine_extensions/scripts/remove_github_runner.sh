#!/bin/bash
echo "Starting GitHubRunner Removal from Organization for Runner = ${GH_ACTIONS_RUNNER_NAME}"

RUNNER_ID="$(curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/${GH_ORG}/actions/runners | jq -r ".runners[] | select(.name == \"${GH_ACTIONS_RUNNER_NAME}\") | .id")"

echo "Removing Self-Hosted Runner ID = ${RUNNER_ID} from ${GH_ORG}"

DELETE_RUNNER="$(curl -L -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/${GH_ORG}/actions/runners/${RUNNER_ID})"

echo "Completed GitHubRunner Removal from Organization"
