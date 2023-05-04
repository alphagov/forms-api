#!/bin/bash

# This script updates the Ruby and Docker Alpine Versions in the
# necessary places to make updating simpler.
#
# Start from main branch with an up-to-date checkout.  Change the
# NEW_RUBY_VERSION and or the DOCKER_ALPINE_VERSION to the desired new version
# and then run the script. It will create a branch, make the necessary updates,
# commit the changes and push to Github for you to raise a
# PR.

# Update these values as necessary and then run the script
NEW_RUBY_VERSION="3.2.2"
DOCKER_ALPINE_VERSION="3.17"

set -e

if ! docker info > /dev/null 2>&1 ; then
    echo "Docker is not running. Docker is required to find the correct docker
    base image for the new version of Ruby. Start Docker and try again. more
    info here: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo "Updating to $NEW_RUBY_VERSION"

echo "Creating new branch"
GIT_BRANCH_NAME="bump_ruby_to_${NEW_RUBY_VERSION}"
git checkout -b "${GIT_BRANCH_NAME}"

echo "Updating .ruby-version file"
echo "$NEW_RUBY_VERSION" > .ruby-version

echo "Update github workflow"
sed -i '' 's/ruby-version: \[.*$/ruby-version: ['\'''"${NEW_RUBY_VERSION}"''\'']/' .github/workflows/ruby-on-rails.yml

echo "Update Gemfile"
sed -i '' 's/^ruby.*$/ruby "'"${NEW_RUBY_VERSION}"'"/' Gemfile

echo "Running 'bundle install' to update Gemfile.lock"
bundle install

echo "Getting Docker manifest list"
MANIFEST_LIST_SHA="$(docker buildx imagetools inspect ruby:${NEW_RUBY_VERSION}-alpine${DOCKER_ALPINE_VERSION} | grep Digest | cut -d : -f 2-3 | tr -d ' ')"

echo "Updating version in Dockerfile"
sed -i '' 's/^FROM ruby:.* AS/FROM ruby:'"${NEW_RUBY_VERSION}"'-alpine'"${DOCKER_ALPINE_VERSION}"'@'"${MANIFEST_LIST_SHA}"' AS/' Dockerfile

echo "Committing changes"
git add update_versions.sh
git add .github/workflows/ruby-on-rails.yml
git add .ruby-version
git add Dockerfile
git add Gemfile
git add Gemfile.lock
git commit -S -m "Bump Ruby to ${NEW_RUBY_VERSION}"
git push -u origin "${GIT_BRANCH_NAME}"

echo "Now raise a PR"
