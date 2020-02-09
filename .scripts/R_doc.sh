###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

#!/bin/bash

# Include git publish framework
source .scripts/R_publish_framework.sh --source-only

commit_R_docs() {
  git checkout develop
  git add NAMESPACE     # commit new NAMESPACE
  git add man 		# commit manual 
  git commit -m "[skip travis] documentation @robqbot travis build: $TRAVIS_BUILD_NUMBER"
}

commit_R_vignettes() {
  ls -aRl
  git add doc
  git commit -m "[skip travis] vignettes  @robqbot travis build: $TRAVIS_BUILD_NUMBER"  
}

setup_git
commit_R_docs
commit_R_vignettes
upload_R_docs
