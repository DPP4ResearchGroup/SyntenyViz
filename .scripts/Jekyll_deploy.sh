#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
source "${TRAVIS_BUILD_DIR}/.scripts/R_publish_framework.sh" --source-only

gh_setup () {
  git remote add origin-SynViz "https://${robqbot_TOKEN}@github.com/DPP4ResearchGroup/SyntenyViz.git" > /dev/null 2>&1

  # setup push branch and clean orphan branch 
  git checkout -q --orphan jekyll
  git reset --hard origin-SynViz/gh-pages
}

gh_doc_commit () {
  git pull origin-SynViz master:master --quiet
  git checkout master -- "${jekyllFolder}" -f
  git add "${jekyllFolder}"
  git commit -m "[skip travis] Jekyll @robqbot travis build: ${TRAVIS_BUILD_NUMBER}"  
}

gh_doc_publish () {
  git push origin-SynViz jekyll:gh-pages
}

setup_git
gh_setup
gh_doc_commit
gh_doc_publish
