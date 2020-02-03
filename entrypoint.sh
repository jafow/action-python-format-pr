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
REMOTE=origin
ARG=$1

printf "%s\n" "head is ${HEAD}"
printf "%s\n" "BASE is ${BASE}"
printf "%s\n" "ARG is ${ARG}"


################################################################################
# helpers
################################################################################
handle_delete_missing_branch() {
    printf "%s\n" "Tried to delete a branch $1 that doesn't exist; Noop"
}

clear_local_branch() {
    local br=$1
    git branch -D "${br}" 2>/dev/null
}

clear_remote_branch() {
    local br=$1
    git ls-remote --exit-code "${REMOTE}" "${br}"
    if [[ "$?" -eq 2 ]]; then
        # there are no branch on remote matching the created format branch. 
        printf "there is NO matching branch on remote\n"
    else
        # there is a match so remove
        printf "there is a matching branch on remote\n"
        git push "${REMOTE}" "${br}" --delete
    fi
}


################################################################################
# configure the git client
################################################################################
git config --global user.email "formatbot@boop.net"
git config --global user.name "FormatBot"

git remote rm "${REMOTE}"
git remote add "${REMOTE}" "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
printf "%s\n" "adding remote"
git fetch "${REMOTE}" "${BASE}"

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

# delete any local copy of the branch
clear_local_branch "${FORMAT_BRANCH}"|| handle_delete_missing_branch "${FORMAT_BRANCH}"
clear_remote_branch "${FORMAT_BRANCH}" || handle_delete_missing_branch "${FORMAT_BRANCH}"

git checkout -b "${FORMAT_BRANCH}"
printf "checkout ${FORMAT_BRANCH}\n"
# add the formatted files, commit them, and push the branch
git add .
printf "adding files\n"
git status
printf "commiting files\n"
git commit -m "python-format-action: run black over PR #$(jq -r .pull_request.number $GITHUB_EVENT_PATH)"
printf "pushing \n"
set -x
git push "${REMOTE}" "${FORMAT_BRANCH}"

printf "opening PR\n"
hub pull-request -b "${HEAD}" -h "${FORMAT_BRANCH}" -a "${GITHUB_ACTOR}" -m "python-format-action: fixing files that need formatting"

# output the list of formatted files
echo ::set-output name=fileslist::$formattable
