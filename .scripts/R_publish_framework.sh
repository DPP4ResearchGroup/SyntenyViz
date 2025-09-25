#!/bin/sh

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Variables are expected to be set by the calling script
# These are just for shellcheck to understand the expected variables
# shellcheck disable=SC2034
robqbot_EMAIL="${robqbot_EMAIL:-}"
# shellcheck disable=SC2034
robqbot_NAME="${robqbot_NAME:-}"
# shellcheck disable=SC2034
robqbot_TOKEN="${robqbot_TOKEN:-}"

setup_git() {
  git config --global user.email "${robqbot_EMAIL}"
  git config --global user.name  "${robqbot_NAME}"
  # Ensure no credential helper overrides embedded PAT
  git config --global --unset-all credential.helper || true
}

upload_R_docs() {
  git remote add origin-SynViz "https://${robqbot_TOKEN}@github.com/DPP4ResearchGroup/SyntenyViz.git" > /dev/null 2>&1 || \
  git remote set-url origin-SynViz "https://${robqbot_TOKEN}@github.com/DPP4ResearchGroup/SyntenyViz.git"
  # Ensure we are on develop and up-to-date with remote before pushing
  git fetch --prune origin-SynViz develop || true
  git checkout develop 2>/dev/null || git checkout -b develop
  # Rebase to avoid merge commits in CI and handle remote updates non-interactively
  git pull --rebase origin-SynViz develop || true
  # Push changes upstream
  git push --quiet --set-upstream origin-SynViz develop:develop  
}

if [ "${1}" = '-source-only' ]; then
  main "${@}"
fi
