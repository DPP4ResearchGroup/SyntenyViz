#!/bin/sh

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

setup_git() {
  git config --global user.email "${robqbot_EMAIL}"
  git config --global user.name  "${robqbot_NAME}"
}

upload_R_docs() {
  git remote add origin-SynViz https://"${robqbot_TOKEN}"@github.com/DPP4ResearchGroup/SyntenyViz.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-SynViz develop:develop  
}

if [ "${1}" = '-source-only' ]; then
  main "${@}"
fi
