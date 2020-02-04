###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

#!/bin/bash

# Include git publish framework
source .script/R_publish_framework.sh --source-onlly

commit_R_debug() {
  git checkout develop
  git add *.Rcheck           
  git commit --m "[skip travis] debug log @robqbot travis build: $TRAVIS_BUILD_NUMBER"
}

setup_git
commit_R_debug
upload_R_docs
