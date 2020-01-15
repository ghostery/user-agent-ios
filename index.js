/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import React from 'react';
import { AppRegistry, YellowBox, NativeModules } from 'react-native';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
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

YellowBox.ignoreWarnings([
  'Warning: componentWillMount',
  'Warning: componentWillReceiveProps',
]);

moment.locale(NativeModules.LocaleConstants.lang);

prefs.set('tabSearchEnabled', true);

const app = new App({
  browser: global.browser,
  debug: NativeModules.Constants.isDebug || NativeModules.Constants.isCI
});
const appReady = app.start();

app.modules['insights'].background.actions['reportStats'] = async function (tabId, stats) {
  await this.db.insertPageStats(tabId, stats);
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
AppRegistry.registerComponent('SearchResults', () => (props) => <SearchResults bridgeManager={bridgeManager} events={events} {...props} />);
AppRegistry.registerComponent('Logo', () => Logo);
AppRegistry.registerComponent('PrivacyStats', () => (props) => <PrivacyStats insightsModule={inject.module('insights')} {...props} />);
