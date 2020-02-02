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
OWNER=$(echo "${GITHUB_REPOSITORY}" | cut -d / -f 1)
HEAD=$(jq --raw-output .pull_request.head.ref "${GITHUB_EVENT_PATH}") # ref to the branch that triggered the pull request
BASE=$(jq --raw-output .pull_request.base.sha "${GITHUB_EVENT_PATH}")
ARG=$1

printf "%s\n" "head is ${HEAD}"
printf "%s\n" "BASE is ${BASE}"
printf "%s\n" "ARG is ${ARG}"

##
# configure the git client
##
git config --global user.email "formatbot@boop.net"
git config --global user.name "For Mat Bot"

# add action origin to set the access token
git remote rm origin
git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
printf "%s\n" "adding remote"
git fetch origin "${BASE}"

printf "%s\n" "fetched ${BASE}"

printf "%s\n" "getting files list"
formattable=$(git diff "${BASE}" --name-only | tr ' ' '\n' | grep -E '.py$')

# check if any of the formattable files need formatting!
printf "running black \n"
black -q -l 120 $formattable

# if no files in diff then everything is already formatted
is_already_formatted=$(git diff --name-only)

if [[ -z "${is_already_formatted}" ]]; then
    printf "nothing to format. Exiting.\n"
    exit 0
fi

# otherwise we cut a branch and add + commit the changes
FORMAT_BRANCH="format/${HEAD}"
set -x
existing_format_branch=$(git branch -d "${FORMAT_BRANCH}" 2>/dev/null)


if [[ -z "${existing_format_branch}" ]]; then
    # branch exists making a new one!
    printf "%s\n" "An existing format branch found for ${BASE}"
    printf "%s\n" "Cutting new format branch for this PR"
fi

git checkout -b "${FORMAT_BRANCH}"

# add specifically the formatted files, commit them, and push the branch
git add $formattable
git commit -m "formatbot: run black over $(jq -r .pull_request.number $GITHUB_EVENT_PATH)"
git push origin "${FORMAT_BRANCH}"
 # todo @jafow these will break on forked repos?
hub pull-request -b $HEAD -h $FORMAT_BRANCH -a $GITHUB_ACTOR --no-edit

# output the list of formatted files
echo ::set-output name=fileslist::$formattable
