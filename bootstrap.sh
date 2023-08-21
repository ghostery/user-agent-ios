#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#

if [ -z "$1" ]; then
   echo "No argument specified. Fallback to Ghostery"
   sh Branding/setup.sh Ghostery ./
else
   sh Branding/setup.sh $1 ./
fi

# nodejs
npm ci
npm run build-user-scripts

# ruby
gem install bundler
bundle install
bundle exec pod install --repo-update
