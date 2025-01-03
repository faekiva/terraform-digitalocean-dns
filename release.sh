#!/bin/bash

CHANGE_TYPE=$(gum choose "major" "minor" "patch" "no-release")
gh pr create -l=$CHANGE_TYPE --title=$BRANCH_NAME -e
