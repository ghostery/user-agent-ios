/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import React from 'react';
import { AppRegistry, YellowBox, NativeModules, Platform } from 'react-native';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
import config from 'browser-core-user-agent-ios/build/modules/core/config';
import inject from 'browser-core-user-agent-ios/build/modules/core/kord/inject';
import prefs from 'browser-core-user-agent-ios/build/modules/core/prefs';
import events from 'browser-core-user-agent-ios/build/modules/core/events';
import Home from './ReactNative/js/screens/Home';
import PrivacyStats from './ReactNative/js/screens/PrivacyStats/index';
import SearchResults from './ReactNative/js/screens/SearchResults';
import BridgeManager from './ReactNative/js/bridge-manager';
import Logo from './ReactNative/js/components/Logo';
import { ThemeWrapperComponentProvider } from './ReactNative/js/contexts/theme';
import moment from './ReactNative/js/services/moment';
import { seedRandom } from './ReactNative/js/globals/window/crypto';

YellowBox.ignoreWarnings([
  'Warning: componentWillMount',
  'Warning: componentWillReceiveProps',
]);

moment.locale(NativeModules.LocaleConstants.lang);

prefs.set('tabSearchEnabled', true);
prefs.set('modules.autoconsent.enabled', false);

const isDebug = NativeModules.Constants.isDebug || NativeModules.Constants.isCI;

const app = new App({
  browser: global.browser,
  debug: isDebug,
  config: {
    ...config,
    settings: {
      ...config.settings,
      telemetry: {
        demographics: {
          brand: 'cliqz',
          name: `browser:${NativeModules.Constants.bundleIdentifier}`,
          platform: 'ios',
        },
      },
      HW_CHANNEL: isDebug ? 'ios-debug' : 'ios',
    },
  },
});

const appReady = new Promise(resolve => {
  (async () => {
    try {
      if (NativeModules.WindowCrypto.isAvailable) {
        await seedRandom();
      }
    } catch (e) {
      // no random, no problem
    }
    await app.start();
    resolve();
  })();
});

app.modules['insights'].background.actions['reportStats'] = async function (tabId, stats) {
  await this.db.insertPageStats(tabId, stats);
}.bind(app.modules['insights'].background);

app.modules['insights'].background.actions['getSearchStats'] = async function () {
  const searchStats = await this.db.getSearchStats();
  return searchStats;
}.bind(app.modules['insights'].background);

global.CLIQZ = {
  app,
};

const bridgeManager = new BridgeManager(NativeModules.JSBridge, inject, appReady);

bridgeManager.addActionListener(({ module, action, args /* , id */ }) => {
  // TODO: replace with browser.webNavigation listener
  if (module === 'BrowserCore' && action === 'notifyLocationChange') {
    const url = args[0];
    events.pub('content:location-change', { url });
    return true;
  }
  return false;
});

AppRegistry.setWrapperComponentProvider(ThemeWrapperComponentProvider(bridgeManager));
AppRegistry.registerComponent('BrowserCore', () => class extends React.Component { render() { return null; }});
AppRegistry.registerComponent('Home', () => (props) => <Home newsModule={inject.module('news')} {...props} />);
AppRegistry.registerComponent('SearchResults', () => (props) => <SearchResults searchModule={inject.module('search')} insightsModule={inject.module('insights')} bridgeManager={bridgeManager} events={events} {...props} />);
AppRegistry.registerComponent('Logo', () => Logo);
AppRegistry.registerComponent('PrivacyStats', () => (props) => <PrivacyStats insightsModule={inject.module('insights')} {...props} />);
