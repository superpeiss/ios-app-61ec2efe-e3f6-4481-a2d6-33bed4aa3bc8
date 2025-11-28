#!/bin/bash

# Script to query GitHub Actions workflow results

TOKEN="${GITHUB_TOKEN:-}"
REPO="superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8"

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Usage: GITHUB_TOKEN=your_token ./query_results.sh"
  exit 1
fi

echo "Fetching workflow runs..."

RESPONSE=$(curl -k -s -X GET \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=5" \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28")

echo "$RESPONSE" | python3 -m json.tool | grep -A 15 '"workflow_runs"'

echo ""
echo "Summary:"
echo "--------"

# Extract and display summary
STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
CONCLUSION=$(echo "$RESPONSE" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
CREATED_AT=$(echo "$RESPONSE" | grep -o '"created_at":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "Latest Run Status: $STATUS"
echo "Conclusion: $CONCLUSION"
echo "Created At: $CREATED_AT"

if [ "$CONCLUSION" = "success" ]; then
  echo ""
  echo "✅ Build SUCCEEDED!"
  exit 0
elif [ "$CONCLUSION" = "failure" ]; then
  echo ""
  echo "❌ Build FAILED!"
  exit 1
else
  echo ""
  echo "⏳ Build is still $STATUS"
fi
