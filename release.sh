#!/bin/bash

CHANGE_TYPE=$(gum choose "major" "minor" "patch")
gh pr create -l=$CHANGE_TYPE --title=$BRANCH_NAME -e
