#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#

if [ -z "$1" ]; then
   echo "No argument specified. Fallback to Cliqz"
   sh Branding/setup.sh Cliqz ./
else
   sh Branding/setup.sh $1 ./
fi

set -e

brew update
brew bundle

nodenv install -s
eval "$(nodenv init -)"
nodenv exec npm i -g npm@6.5
nodenv exec npm ci
nodenv exec npm run build-user-scripts

rbenv install -s
eval "$(rbenv init -)"
rbenv exec gem install bundler
rbenv exec bundle install
rbenv exec bundle exec pod install --repo-update
