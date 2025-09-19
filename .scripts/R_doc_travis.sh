#!/bin/bash
set -euxo pipefail

###
# secure:
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
    echo "  --jekyll-folder FOLDER  Jekyll folder destination (default: docs)"
    echo "  --source-branch BRANCH  Source branch for deployment (default: develop)"
    echo "  --help              Show this help message"
    echo ""
    echo "Environment variables (fallback if not provided as arguments):"
    echo "  robqbot_TOKEN       GitHub token"
    echo "  robqbot_EMAIL       Git user email"
    echo "  robqbot_NAME        Git user name"
    echo "  jekyllFolder        Jekyll folder destination"
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
jekyllFolder="${jekyllFolder:-docs}"
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
echo "🔧 R Documentation Travis Configuration:"
echo "  Token source: $([ -n "${1:-}" ] && echo "command line" || echo "environment variable")"
echo "  Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "  Email: $robqbot_EMAIL"
echo "  Name: $robqbot_NAME"
echo "  Jekyll folder: $jekyllFolder"
echo "  Source branch: $source_branch"
echo "  Travis build number: ${TRAVIS_BUILD_NUMBER:-N/A}"

# Include git publish framework
# shellcheck source=/dev/null
source "${TRAVIS_BUILD_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_docs() {
  echo "📚 Committing R documentation..."
  git checkout "$source_branch"
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git add doc -f	# commit doc
  git add vignettes	# commit vignettes output assets
  git commit -m "[skip travis] documentation @robqbot travis build: ${TRAVIS_BUILD_NUMBER}"
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
  git commit -m "[skip travis] vignettes @robqbot travis build: ${TRAVIS_BUILD_NUMBER}"  
  echo "✅ Vignettes committed successfully"
}

# Main execution
echo "🚀 Starting R documentation Travis deployment..."
echo "=========================================="

setup_git
commit_R_docs
prep_vignettes
commit_R_vignettes
upload_R_docs

echo "=========================================="
echo "✅ R Documentation Travis deployment completed successfully!"
echo "📋 Deployment Summary:"
echo "  - Source branch: $source_branch"
echo "  - Jekyll folder: $jekyllFolder"
echo "  - Travis build: ${TRAVIS_BUILD_NUMBER:-N/A}"
echo "  - Git user: $robqbot_NAME <$robqbot_EMAIL>"
echo "  - Token: ${robqbot_TOKEN:0:8}... (truncated for security)"
echo "=========================================="
