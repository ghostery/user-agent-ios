#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#

set -x
set -e

brew update
brew bundle

nodenv install -s
nodenv exec npm ci
nodenv exec npm run build-user-scripts

rbenv install -s
rbenv exec bundle install
rbenv exec bundle exec pod install --repo-update
