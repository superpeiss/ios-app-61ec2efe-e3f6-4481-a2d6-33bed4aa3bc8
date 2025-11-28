#!/bin/bash

# Comprehensive script to manage GitHub repository and workflow

set -e

TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8"
REPO_FULL="superpeiss/$REPO_NAME"
USER_NAME="superpeiss"
USER_EMAIL="dmfmjfn6111@outlook.com"

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Usage: GITHUB_TOKEN=your_token ./run_complete_workflow.sh"
  exit 1
fi

echo "================================"
echo "GitHub Workflow Management"
echo "================================"
echo ""

# Function to trigger workflow
trigger_workflow() {
  echo "Triggering workflow..."
  curl -k -s -X POST \
    "https://api.github.com/repos/$REPO_FULL/actions/workflows/ios-build.yml/dispatches" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -d '{"ref":"main"}' > /dev/null

  if [ $? -eq 0 ]; then
    echo "✅ Workflow triggered successfully!"
  else
    echo "❌ Failed to trigger workflow"
    exit 1
  fi
}

# Function to check workflow status
check_workflow() {
  RESPONSE=$(curl -k -s -X GET \
    "https://api.github.com/repos/$REPO_FULL/actions/runs?per_page=1" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28")

  STATUS=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['workflow_runs'][0]['status'] if data['workflow_runs'] else 'unknown')" 2>/dev/null || echo "unknown")
  CONCLUSION=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['workflow_runs'][0]['conclusion'] if data['workflow_runs'] and data['workflow_runs'][0]['conclusion'] else 'null')" 2>/dev/null || echo "null")

  echo "$STATUS|$CONCLUSION"
}

# Function to download build log
download_build_log() {
  echo "Fetching build log..."

  RUN_ID=$(curl -k -s -X GET \
    "https://api.github.com/repos/$REPO_FULL/actions/runs?per_page=1" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" | \
    python3 -c "import sys, json; data=json.load(sys.stdin); print(data['workflow_runs'][0]['id'] if data['workflow_runs'] else '')" 2>/dev/null || echo "")

  if [ -n "$RUN_ID" ]; then
    echo "Run ID: $RUN_ID"
    echo "View logs at: https://github.com/$REPO_FULL/actions/runs/$RUN_ID"
  fi
}

# Monitor workflow until completion
monitor_workflow() {
  echo ""
  echo "Monitoring workflow..."
  MAX_WAIT=600  # 10 minutes
  ELAPSED=0

  while [ $ELAPSED -lt $MAX_WAIT ]; do
    RESULT=$(check_workflow)
    STATUS=$(echo "$RESULT" | cut -d'|' -f1)
    CONCLUSION=$(echo "$RESULT" | cut -d'|' -f2)

    echo "[$(date '+%H:%M:%S')] Status: $STATUS | Conclusion: $CONCLUSION"

    if [ "$STATUS" = "completed" ]; then
      echo ""
      if [ "$CONCLUSION" = "success" ]; then
        echo "✅ BUILD SUCCEEDED!"
        download_build_log
        return 0
      else
        echo "❌ BUILD FAILED!"
        download_build_log
        return 1
      fi
    fi

    sleep 10
    ELAPSED=$((ELAPSED + 10))
  done

  echo "⏱️  Timeout waiting for workflow to complete"
  return 1
}

# Main execution
echo "Repository: https://github.com/$REPO_FULL"
echo ""

# Trigger the workflow
trigger_workflow

# Wait a moment for workflow to initialize
sleep 5

# Monitor until completion
if monitor_workflow; then
  echo ""
  echo "✅ All done! Build succeeded."
  exit 0
else
  echo ""
  echo "❌ Build failed. Check the logs for errors."
  echo "   Visit: https://github.com/$REPO_FULL/actions"
  exit 1
fi
