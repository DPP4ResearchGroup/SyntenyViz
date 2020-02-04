###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

#!/bin/bash 

# Include git publish framework
./R_publish_framework.sh

commit_R_docs() {
  git checkout develop
# git add DESCRIPTION	# commit new DESCRIPTION
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git commit --m "[skip travis] documentation @robqbot travis build: $TRAVIS_BUILD_NUMBER"
}

setup_git
commit_R_docs
upload_R_docs

