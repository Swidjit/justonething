#!/bin/bash
REMOTE=`git remote -v | grep -e ':swidjit.git' | head -n 1 | awk '{print $1}'`
if [ "$REMOTE" == "" ]; then
  echo "Could not identify the name of the git remote repo for the production environment"
  exit 1
fi

git push $REMOTE master:master &&
heroku maintenance:on --app swidjit &&
heroku run rake db:migrate --app swidjit &&
heroku restart --app swidjit &&
heroku maintenance:off --app swidjit