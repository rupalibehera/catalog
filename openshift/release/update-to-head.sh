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
git fetch ${OPENSHIFT_REMOTE} master
git checkout ${OPENSHIFT_REMOTE}/master openshift OWNERS_ALIASES OWNERS
git add openshift OWNERS_ALIASES OWNERS
git commit -m ":open_file_folder: Update openshift specific files."

git push -f ${OPENSHIFT_REMOTE} HEAD:release-next
