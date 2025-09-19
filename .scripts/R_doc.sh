#!/bin/bash
set -euxo pipefail

###
# compatible with both Travis CI and GitHub Actions
# uses GITHUB_WORKSPACE if available, fallback to TRAVIS_BUILD_DIR for compatibility
# uses GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
#
###
# travis secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --token TOKEN       GitHub token for authentication (required)"
    echo "  --email EMAIL       Git user email (required)"
    echo "  --name NAME         Git user name (required)"
    echo "  --jekyll-folder FOLDER  Jekyll folder destination (default: jekyll_collection)"
    echo "  --source-branch BRANCH  Source branch for deployment (default: develop)"
    echo "  --help              Show this help message"
    echo ""
    echo "Environment variables (fallback if not provided as arguments):"
    echo "  robqbot_TOKEN       GitHub token"
    echo "  robqbot_EMAIL       Git user email"
    echo "  robqbot_NAME        Git user name"
    echo "  jekyllFolder        Jekyll folder destination"
    echo "  GITHUB_RUN_NUMBER   GitHub Actions run number"
    echo "  TRAVIS_BUILD_NUMBER Travis build number"
    echo ""
    echo "Examples:"
    echo "  $0 --token \$GITHUB_TOKEN --email user@example.com --name 'User Name'"
    echo "  $0 --token \$GITHUB_TOKEN --email user@example.com --name 'User Name' --jekyll-folder docs --source-branch develop"
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
        --jekyll-folder)
            jekyllFolder="$2"
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
jekyllFolder="${jekyllFolder:-jekyll_collection}"
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

# Debug output
echo "🔧 R Documentation Configuration:"
echo "  Token source: $([ -n "${1:-}" ] && echo "command line" || echo "environment variable")"
echo "  Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "  Email: $robqbot_EMAIL"
echo "  Name: $robqbot_NAME"
echo "  Jekyll folder: $jekyllFolder"
echo "  Source branch: $source_branch"
echo "  GitHub run number: ${GITHUB_RUN_NUMBER:-N/A}"
echo "  Travis build number: ${TRAVIS_BUILD_NUMBER:-N/A}"

# Include git publish framework
# shellcheck source=/dev/null
# Use GITHUB_WORKSPACE if available, fallback to TRAVIS_BUILD_DIR for compatibility
WORKSPACE_DIR="${GITHUB_WORKSPACE:-${TRAVIS_BUILD_DIR}}"
source "${WORKSPACE_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_docs() {
  echo "📚 Committing R documentation..."
  git checkout "$source_branch"
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git add doc -f	# commit doc
  git add vignettes	# commit vignettes output assets
  # Use GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
  BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"
  git commit -m "[skip ci] documentation @robqbot build: ${BUILD_NUMBER}"
  echo "✅ R documentation committed successfully"
}

prep_vignettes () {
  echo "📖 Preparing vignettes for Jekyll deployment..."
  if [[ ! -d "$jekyllFolder" ]]; then mkdir -p "$jekyllFolder"; fi 
  cp -a doc/* "$jekyllFolder"
  echo "✅ Vignettes prepared for deployment to: $jekyllFolder"
}

commit_R_vignettes() {
  echo "📝 Committing vignettes to repository..."
  git add "$jekyllFolder"
  # Use GITHUB_RUN_NUMBER if available, fallback to TRAVIS_BUILD_NUMBER for compatibility
  BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"
  git commit -m "[skip ci] vignettes @robqbot build: ${BUILD_NUMBER}"  
  echo "✅ Vignettes committed successfully"
}

# Main execution
echo "🚀 Starting R documentation deployment..."
echo "=========================================="

setup_git
commit_R_docs
prep_vignettes
commit_R_vignettes
upload_R_docs

echo "=========================================="
echo "✅ R Documentation deployment completed successfully!"
echo "📋 Deployment Summary:"
echo "  - Source branch: $source_branch"
echo "  - Jekyll folder: $jekyllFolder"
echo "  - GitHub run number: ${GITHUB_RUN_NUMBER:-N/A}"
echo "  - Travis build number: ${TRAVIS_BUILD_NUMBER:-N/A}"
echo "  - Git user: $robqbot_NAME <$robqbot_EMAIL>"
echo "  - Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "=========================================="
