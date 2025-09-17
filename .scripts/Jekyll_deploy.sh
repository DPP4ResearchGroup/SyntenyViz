#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

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
echo "🔍 Jekyll Deploy Script - Dual CI Compatibility"
echo "  Workspace Directory: ${WORKSPACE_DIR}"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  CI System: ${CI_SYSTEM}"
echo "  Skip CI: ${SKIP_CI}"
echo "  Jekyll Folder: ${jekyllFolder:-'not set'}"

# Validate required variables
if [ -z "$WORKSPACE_DIR" ]; then
  echo "❌ ERROR: Neither GITHUB_WORKSPACE nor TRAVIS_BUILD_DIR is set"
  exit 1
fi

if [ -z "$BUILD_NUMBER" ]; then
  echo "❌ ERROR: Neither GITHUB_RUN_NUMBER nor TRAVIS_BUILD_NUMBER is set"
  exit 1
fi

# Include git publish framework
# shellcheck source=/dev/null
source "${WORKSPACE_DIR}/.scripts/R_publish_framework.sh" --source-only

gh_setup () {
  echo "🔧 Setting up Git for deployment..."
  
  # Validate required credentials
  if [ -z "$robqbot_TOKEN" ]; then
    echo "❌ ERROR: robqbot_TOKEN is not set"
    exit 1
  fi
  
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
  git commit -m "${SKIP_CI} Jekyll @robqbot ${CI_SYSTEM} build: ${BUILD_NUMBER}"
  
  echo "✅ Documentation committed"
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
