#!/bin/bash

# Script to monitor GitHub Actions workflow status

TOKEN="${GITHUB_TOKEN:-}"
REPO="superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8"

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Usage: GITHUB_TOKEN=your_token ./monitor_workflow.sh"
  exit 1
fi

echo "Monitoring workflow status..."

while true; do
  RESPONSE=$(curl -k -s -X GET \
    "https://api.github.com/repos/$REPO/actions/runs?per_page=1" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28")

  STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
  CONCLUSION=$(echo "$RESPONSE" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)

  echo "Status: $STATUS"

  if [ "$STATUS" = "completed" ]; then
    echo "Workflow completed with conclusion: $CONCLUSION"

    if [ "$CONCLUSION" = "success" ]; then
      echo "Build succeeded!"
      exit 0
    else
      echo "Build failed!"
      exit 1
    fi
  fi

  sleep 10
done
