#!/bin/bash

CHANGE_TYPE=$(gum choose "major" "minor" "patch")
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
gh pr create -f -l=$CHANGE_TYPE --title=$BRANCH_NAME -e
echo $CHANGE_TYPE $BRANCH_NAME
 