#!/usr/bin/env bash
set -e;
set -o pipefail;

################################################################################
# Variables
#
# all variables prefixed with "GITHUB_" are passed in via the action context
################################################################################
API_VERSION=v3
BASE_URL=https://api.github.com
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
HEADERS="Accept: application/vnd.github.${API_VERSION}+json"

## url
REPO="${BASE_URL}/repos/${GITHUB_REPOSITORY}"
PULL_REQUESTS="${REPO}/pulls"

## repo
HEAD="${GITHUB_REF}" # ref to the branch that triggered the pull request
BASE=$(jq --raw-output .pull_request.base.sha "${GITHUB_EVENT_PATH}")
ARG=$1

printf "%s\n" "head is ${HEAD}"
printf "%s\n" "BASE is ${BASE}"
printf "%s\n" "ARG is ${ARG}"

git fetch origin "${BASE}"

fileslist=$(git diff origin "${BASE}" --name-only | tr ' ' '\n' | grep -E '.py$')

##
# get all the files in the PR
# filter the python files (if any)
# format the files
# if a diff exists
#   cut a branch "format/$ORIG_BRANCH"
#   add / commit
#   push
#   check no PRS open for current fix branch
#   create a pr to ORIG_BRANCH
# prosper

# input_path=$1

# if [[ -z "${input_path}" ]]; then
#     input_path=`pwd`
# fi

# echo "args: looking at $input_path"

# fileslist=$(find $input_path -name "*.py" -type "f")

# # run black over the files list
# black $fileslist

echo ::set-output name=fileslist::$fileslist
