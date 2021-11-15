#!/usr/bin/env bash

# Synchs the release-next branch to master and then triggers CI
# Usage: update-to-head.sh

set -ex
REPO_NAME=${REPO_NAME:-tektoncd-catlog}
BRANCH=${BRANCH:-main}
OPENSHIFT_REMOTE=${OPENSHIFT_REMOTE:-openshift}
LABEL=nightly-ci

# Reset release-next to upstream/main.
git fetch upstream ${BRANCH}
git checkout upstream/${BRANCH} --no-track -B release-next

# Update openshift's master and take all needed files from there.
git fetch ${OPENSHIFT_REMOTE} tempmaster
git checkout ${OPENSHIFT_REMOTE}/tempmaster openshift OWNERS_ALIASES OWNERS
git add openshift OWNERS_ALIASES OWNERS
git commit -m ":open_file_folder: Update openshift specific files."

git push -f ${OPENSHIFT_REMOTE} HEAD:release-next

# Trigger CI
git checkout release-next --no-track -B release-next-ci
date > ci
git add ci
git commit -m ":robot: Triggering CI on branch 'release-next' after synching to upstream/main"
git push -f ${OPENSHIFT_REMOTE} HEAD:release-next-ci

# removing upstream remote so that hub points origin for hub pr list command due to this issue https://github.com/github/hub/issues/1973
git remote remove upstream

already_open_github_issue_id=$(hub pr list -s open -f "%I %l%n"|grep ${LABEL}| awk '{print $1}'|head -1)
[[ -n ${already_open_github_issue_id} ]]  && {
    echo "PR for nightly is already open on #${already_open_github_issue_id}"
    #hub api repos/${OPENSHIFT_ORG}/${REPO_NAME}/issues/${already_open_github_issue_id}/comments -f body='/retest'
    exit 0
}

hub pull-request -m "🛑🔥 Triggering Nightly CI for ${REPO_NAME} 🔥🛑" -m "/hold" -m "Nightly CI do not merge :stop_sign:" \
    --no-edit -l "${LABEL}" -b ${OPENSHIFT_REMOTE}/${REPO_NAME}:release-next -h ${OPENSHIFT_REMOTE}/${REPO_NAME}:release-next-ci
