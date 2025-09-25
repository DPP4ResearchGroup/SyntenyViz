#!/bin/bash
set -euxo pipefail

# Travis CI R Debug Script for SyntenyViz
# This script is specifically designed for Travis CI environment

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --token TOKEN       GitHub token for authentication (required)"
    echo "  --email EMAIL       Git user email (required)"
    echo "  --name NAME         Git user name (required)"
    echo "  --source-branch BRANCH  Source branch for deployment (default: develop)"
    echo "  --help              Show this help message"
    echo ""
    echo "Environment variables (fallback if not provided as arguments):"
    echo "  robqbot_TOKEN       GitHub token"
    echo "  robqbot_EMAIL       Git user email"
    echo "  robqbot_NAME        Git user name"
    echo "  TRAVIS_BUILD_NUMBER Travis build number"
    echo ""
    echo "Examples:"
    echo "  $0 --token \$GITHUB_TOKEN --email user@example.com --name 'User Name'"
    echo "  $0 --token \$GITHUB_TOKEN --email user@example.com --name 'User Name' --source-branch develop"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            robqbot_TOKEN="$2"
            shift 2
            ;;
        --email)
            robqbot_EMAIL="$2"
            shift 2
            ;;
        --name)
            robqbot_NAME="$2"
            shift 2
            ;;
        --source-branch)
            source_branch="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Set defaults
source_branch="${source_branch:-develop}"

# Validate required parameters
if [ -z "$robqbot_TOKEN" ]; then
    echo "❌ ERROR: robqbot_TOKEN is required"
    echo "   Provide it as --token parameter or set robqbot_TOKEN environment variable"
    usage
    exit 1
fi

if [ -z "$robqbot_EMAIL" ]; then
    echo "❌ ERROR: robqbot_EMAIL is required"
    echo "   Provide it as --email parameter or set robqbot_EMAIL environment variable"
    usage
    exit 1
fi

if [ -z "$robqbot_NAME" ]; then
    echo "❌ ERROR: robqbot_NAME is required"
    echo "   Provide it as --name parameter or set robqbot_NAME environment variable"
    usage
    exit 1
fi

echo "=== Travis CI R Debug Script ==="
echo "Build directory: ${TRAVIS_BUILD_DIR}"
echo "Build number: ${TRAVIS_BUILD_NUMBER}"
echo "🔧 Debug Configuration:"
echo "  Token source: $([ -n "${1:-}" ] && echo "command line" || echo "environment variable")"
echo "  Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "  Email: $robqbot_EMAIL"
echo "  Name: $robqbot_NAME"
echo "  Source branch: $source_branch"

# Include git publish framework
# shellcheck source=/dev/null
source "${TRAVIS_BUILD_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_debug() {
  echo "🐛 Committing debug logs..."
  git checkout "$source_branch"
  git add ./*.Rcheck           
  git commit -m "[skip travis] debug log @robqbot Travis CI build: ${TRAVIS_BUILD_NUMBER}"
  echo "✅ Debug logs committed successfully"
}

# Main execution
echo "🚀 Starting Travis CI R debug deployment..."
echo "=========================================="

setup_git
commit_R_debug
upload_R_docs

echo "=========================================="
echo "✅ Travis CI R Debug deployment completed successfully!"
echo "📋 Debug Summary:"
echo "  - Source branch: $source_branch"
echo "  - Travis build number: ${TRAVIS_BUILD_NUMBER:-N/A}"
echo "  - Git user: $robqbot_NAME <$robqbot_EMAIL>"
echo "  - Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "=========================================="
