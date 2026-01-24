#!/bin/bash
set -e

# Detect repository from git
if [ -d ".git" ]; then
    REMOTE_URL=$(git config --get remote.origin.url)
    if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)? ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
    else
        echo "Could not parse repository info from git remote."
        exit 1
    fi
else
    echo "Not a git repository."
    exit 1
fi

WORKFLOW="android-build.yml"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Triggering $WORKFLOW on $REPO_OWNER/$REPO_NAME (branch: $BRANCH)..."

if command -v gh &> /dev/null; then
    # Login check
    if ! gh auth status &> /dev/null; then
        echo "You are not logged into GitHub CLI. Run 'gh auth login' first."
        exit 1
    fi

    gh workflow run "$WORKFLOW" --ref "$BRANCH" -f profile=preview
    
    echo "🚀 Workflow triggered successfully!"
    echo "Run this to check status:"
    echo "  gh run list --workflow=$WORKFLOW"
    echo "  gh run watch"
else
    echo "❌ GitHub CLI ('gh') is not installed found in PATH."
    echo "To execute this skill, please install gh: https://cli.github.com/"
    exit 1
fi
