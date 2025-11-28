#!/bin/bash

# Script to trigger GitHub Actions workflow manually

TOKEN="${GITHUB_TOKEN:-}"
REPO="superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8"
WORKFLOW_FILE="ios-build.yml"

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Usage: GITHUB_TOKEN=your_token ./trigger_workflow.sh"
  exit 1
fi

echo "Triggering workflow: $WORKFLOW_FILE"

curl -k -X POST \
  "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_FILE/dispatches" \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"ref":"main"}'

if [ $? -eq 0 ]; then
  echo "Workflow triggered successfully!"
else
  echo "Failed to trigger workflow"
  exit 1
fi
