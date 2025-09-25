#!/bin/bash

###
# GitHub Actions CI deployment script for SyntenyViz
# secure:
#   robqbot_TOKEN (can be passed as parameter or environment variable)
#   robqbot_EMAIL
#   robqbot_NAME
###

# Function to display usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --token TOKEN        GitHub token for authentication (overrides environment variable)"
  echo "  --email EMAIL        Bot email for git commits (overrides environment variable)"
  echo "  --name NAME          Bot name for git commits (overrides environment variable)"
  echo "  --jekyll-folder FOLDER  Jekyll folder to deploy (overrides environment variable)"
  echo "  --source-branch BRANCH  Source branch to deploy from (default: master)"
  echo "  --help               Show this help message"
  echo ""
  echo "Environment variables:"
  echo "  robqbot_TOKEN        GitHub token for authentication"
  echo "  robqbot_EMAIL        Bot email for git commits"
  echo "  robqbot_NAME         Bot name for git commits"
  echo "  jekyllFolder         Jekyll folder to deploy"
  echo "  SOURCE_BRANCH        Source branch to deploy from (default: master)"
  echo ""
  echo "Examples:"
  echo "  $0 --token \$GITHUB_TOKEN --email bot@example.com --name bot"
  echo "  robqbot_TOKEN=\$GITHUB_TOKEN $0"
  exit 1
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
      SOURCE_BRANCH="$2"
      shift 2
      ;;
    --help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Dual compatibility: Support both Travis CI and GitHub Actions
# Use GITHUB_WORKSPACE if available (GitHub Actions), fallback to TRAVIS_BUILD_DIR (Travis CI)
WORKSPACE_DIR="${GITHUB_WORKSPACE:-${TRAVIS_BUILD_DIR}}"

# Use GITHUB_RUN_NUMBER if available (GitHub Actions), fallback to TRAVIS_BUILD_NUMBER (Travis CI)
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"

# Detect CI system for appropriate commit message
if [ -n "$GITHUB_WORKSPACE" ]; then
  CI_SYSTEM="github actions"
  SKIP_CI="[skip ci]"
else
  CI_SYSTEM="travis"
  SKIP_CI="[skip travis]"
fi

# Debug information
echo "🔍 Jekyll Deploy Script - Dual CI Compatibility with Dynamic Token Support"
echo "  Workspace Directory: ${WORKSPACE_DIR}"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  CI System: ${CI_SYSTEM}"
echo "  Skip CI: ${SKIP_CI}"
echo "  Jekyll Folder: ${jekyllFolder:-'not set'}"
echo "  Source Branch: ${SOURCE_BRANCH:-'master (default)'}"
echo "  Token Source: ${robqbot_TOKEN:+'provided'}"
echo "  Email Source: ${robqbot_EMAIL:+'provided'}"
echo "  Name Source: ${robqbot_NAME:+'provided'}"

# Validate required variables
if [ -z "$WORKSPACE_DIR" ]; then
  echo "❌ ERROR: Neither GITHUB_WORKSPACE nor TRAVIS_BUILD_DIR is set"
  echo "   This script requires a workspace directory to be set"
  exit 1
fi

if [ -z "$BUILD_NUMBER" ]; then
  echo "❌ ERROR: Neither GITHUB_RUN_NUMBER nor TRAVIS_BUILD_NUMBER is set"
  echo "   This script requires a build number to be set"
  exit 1
fi

# Validate authentication credentials with helpful error messages
if [ -z "$robqbot_TOKEN" ]; then
  echo "❌ ERROR: robqbot_TOKEN is not set"
  echo "   You can provide the token in several ways:"
  echo "   1. Environment variable: robqbot_TOKEN=\$GITHUB_TOKEN"
  echo "   2. Command line: $0 --token \$GITHUB_TOKEN"
  echo "   3. GitHub Actions secrets: robqbot_TOKEN: \${{ secrets.ROBQBOT_TOKEN }}"
  exit 1
fi

if [ -z "$robqbot_EMAIL" ]; then
  echo "❌ ERROR: robqbot_EMAIL is not set"
  echo "   You can provide the email in several ways:"
  echo "   1. Environment variable: robqbot_EMAIL=bot@example.com"
  echo "   2. Command line: $0 --email bot@example.com"
  echo "   3. GitHub Actions secrets: robqbot_EMAIL: \${{ secrets.ROBQBOT_EMAIL }}"
  exit 1
fi

if [ -z "$robqbot_NAME" ]; then
  echo "❌ ERROR: robqbot_NAME is not set"
  echo "   You can provide the name in several ways:"
  echo "   1. Environment variable: robqbot_NAME=robqbot"
  echo "   2. Command line: $0 --name robqbot"
  echo "   3. GitHub Actions secrets: robqbot_NAME: robqbot"
  exit 1
fi

# Include git publish framework
# shellcheck source=/dev/null
source "${GITHUB_WORKSPACE}/.scripts/R_publish_framework.sh" --source-only

gh_setup () {
  echo "🔧 Setting up Git for deployment..."
  echo "  Using token: ${robqbot_TOKEN:0:8}... (truncated for security)"
  
  git remote add origin-SynViz "https://${robqbot_TOKEN}@github.com/DPP4ResearchGroup/SyntenyViz.git" > /dev/null 2>&1

  # setup push branch and clean orphan branch 
  git checkout -q --orphan jekyll
  git fetch --all
  git reset --hard origin-SynViz/gh-pages
  
  echo "✅ Git setup completed"
}

gh_doc_commit () {
  echo "📝 Committing documentation changes..."
  
  # Validate jekyllFolder
  if [ -z "$jekyllFolder" ]; then
    echo "❌ ERROR: jekyllFolder is not set"
    exit 1
  fi
  
  # Use configurable source branch, default to master if not set
  SOURCE_BRANCH="${SOURCE_BRANCH:-master}"
  echo "📋 Using source branch: ${SOURCE_BRANCH}"
  
  git fetch origin-SynViz "${SOURCE_BRANCH}:${SOURCE_BRANCH}" --quiet
  git checkout -f "${SOURCE_BRANCH}" -- "${jekyllFolder}" 
  git add "${jekyllFolder}"
  git commit -m "vignettes @robqbot GitHub Actions build: ${GITHUB_RUN_NUMBER}"  
}

gh_doc_publish () {
  echo "🚀 Publishing to gh-pages..."
  git push --set-upstream origin-SynViz jekyll:gh-pages
  echo "✅ Successfully published to gh-pages"
}

# Execute deployment steps
echo "🚀 Starting Jekyll deployment process..."
setup_git
gh_setup
gh_doc_commit
gh_doc_publish

echo "🎉 Jekyll deployment completed successfully!"
echo "  CI System: ${CI_SYSTEM}"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  Jekyll Folder: ${jekyllFolder}"
echo "  Source Branch: ${SOURCE_BRANCH:-master}"
echo "  Token Authentication: ✅ Dynamic token support enabled"
