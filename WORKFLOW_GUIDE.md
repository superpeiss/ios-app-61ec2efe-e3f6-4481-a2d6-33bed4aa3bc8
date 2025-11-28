# GitHub CI/CD Workflow Guide

This document explains how to use the GitHub Actions workflow and management scripts for the Speech Practice iOS app.

## Repository Information

- **Repository**: https://github.com/superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8
- **Owner**: superpeiss
- **Status**: ✅ Build Passing

## GitHub Actions Workflow

The project includes a GitHub Actions workflow that automatically builds the iOS app to verify compilation.

### Workflow Configuration

- **File**: `.github/workflows/ios-build.yml`
- **Trigger**: Manual only (`workflow_dispatch`)
- **Runner**: macOS Latest
- **Purpose**: Verify iOS app compiles successfully

### Workflow Steps

1. **Checkout code** - Downloads the repository
2. **Install XcodeGen** - Installs project generation tool
3. **Generate Xcode project** - Creates `.xcodeproj` from `project.yml`
4. **List Xcode schemes** - Verifies project structure
5. **Build iOS app** - Compiles the app (without code signing)
6. **Verify build success** - Checks build completed successfully
7. **Upload build log** - Saves build output as artifact

### Key Features

- **No code signing required** - Builds for generic iOS platform
- **Build verification** - Checks exit codes and build logs
- **Artifact upload** - Build logs always uploaded for debugging
- **Manual trigger only** - Prevents unnecessary builds on every commit

## Management Scripts

The `scripts/` directory contains helper scripts for managing the workflow.

### Prerequisites

All scripts require the `GITHUB_TOKEN` environment variable:

```bash
export GITHUB_TOKEN="your_github_token_here"
```

### Available Scripts

#### 1. trigger_workflow.sh

Manually triggers the iOS build workflow.

```bash
GITHUB_TOKEN=your_token ./scripts/trigger_workflow.sh
```

#### 2. monitor_workflow.sh

Monitors a running workflow until completion.

```bash
GITHUB_TOKEN=your_token ./scripts/monitor_workflow.sh
```

#### 3. query_results.sh

Queries the latest workflow run results.

```bash
GITHUB_TOKEN=your_token ./scripts/query_results.sh
```

#### 4. run_complete_workflow.sh

Comprehensive script that triggers a workflow and monitors it until completion.

```bash
GITHUB_TOKEN=your_token ./scripts/run_complete_workflow.sh
```

## GitHub API Endpoints Used

### Repository Creation

```bash
POST https://api.github.com/user/repos
```

Creates a new public repository.

### SSH Key Management

```bash
POST https://api.github.com/user/keys
```

Adds SSH deploy keys to the account.

### Workflow Dispatch

```bash
POST https://api.github.com/repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches
```

Triggers a workflow manually.

### Workflow Runs Query

```bash
GET https://api.github.com/repos/{owner}/{repo}/actions/runs
```

Retrieves workflow run status and results.

## Workflow Results

The latest build has completed successfully:

- **Status**: ✅ Completed
- **Conclusion**: Success
- **Run URL**: https://github.com/superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8/actions/runs/19759369238

## Iterative Build Fixes

During development, the following issue was identified and fixed:

### Issue 1: Code Signing Requirements

**Problem**: Initial build failed because xcodebuild expected code signing for iOS builds.

**Solution**: Added the following flags to disable code signing for CI:
```bash
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

**Result**: Build now succeeds on macOS runners without requiring provisioning profiles.

## Build Verification

The workflow verifies successful builds by:

1. Checking the `xcodebuild` exit code (must be 0)
2. Looking for "BUILD SUCCEEDED" in the output
3. Uploading build logs as artifacts for review

## Security Notes

- Tokens are stored in environment variables, not hardcoded in scripts
- GitHub's push protection prevents accidental token commits
- SSH keys are generated specifically for deployment
- Repository is public for demonstration purposes

## Next Steps

To continue development:

1. Clone the repository locally
2. Run `./setup.sh` to generate the Xcode project
3. Open `SpeechPractice.xcodeproj` in Xcode
4. Make changes and commit
5. Optionally trigger the workflow to verify compilation

## Troubleshooting

### Build Failures

If the build fails:

1. Check the workflow run logs: https://github.com/superpeiss/ios-app-61ec2efe-e3f6-4481-a2d6-33bed4aa3bc8/actions
2. Download the build log artifact
3. Look for compilation errors in the log
4. Fix the errors locally and push changes
5. Re-trigger the workflow

### Permission Issues

If scripts fail with permission errors:

```bash
chmod +x scripts/*.sh
```

### Token Expiration

If API calls fail with 401 errors, your GitHub token may have expired. Generate a new token with the following scopes:

- `repo` (full control of repositories)
- `workflow` (update GitHub Action workflows)

## Complete Implementation Code

All source code is available in the repository:

- **Models**: `SpeechPractice/Models/`
- **Views**: `SpeechPractice/Views/`
- **ViewModels**: `SpeechPractice/ViewModels/`
- **Services**: `SpeechPractice/Services/`
- **Project Config**: `project.yml`
- **Workflow**: `.github/workflows/ios-build.yml`
- **Scripts**: `scripts/`
