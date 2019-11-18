#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#

set -x
set -e

brew bundle

brew bootstrap-nodenv-node

brew bundle exec npm ci
brew bundle exec npm run build-user-scripts

bundle install
bundle exec pod install --repo-update
