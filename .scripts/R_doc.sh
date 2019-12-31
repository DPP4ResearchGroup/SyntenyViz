#!/bin/bash 

setup_git() {
  git config --global user.email "qiao0015@flinders.edu.au"
  git config --global user.name  "robqbot"
}

commit_R_docs() {
  git checkout develop
  git add DESCRIPTION	# commit new DESCRIPTION
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git commit --message "robqbot travis build: $TRAVIS_BUILD_NUMBER"
}

upload_R_docs() {
  git remote add origin-SynViz https://${robqbot_TOKEN}@github.com/DPP4ResearchGroup/SyntenyViz.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-SynViz develop:develop  
}

setup_git
commit_R_docs
upload_R_docs

