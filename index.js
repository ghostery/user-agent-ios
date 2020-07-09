/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import React from 'react';
import {
  AppRegistry,
  YellowBox,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';
import './ReactNative/js/fixes';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
import config from 'browser-core-user-agent-ios/build/modules/core/config';
import inject from 'browser-core-user-agent-ios/build/modules/core/kord/inject';
import prefs from 'browser-core-user-agent-ios/build/modules/core/prefs';
import { overrideSuggestionsHandler } from 'browser-core-user-agent-ios/build/modules/core/search-engines';
import events from 'browser-core-user-agent-ios/build/modules/core/events';
import { loadSearchEngines } from 'browser-core-user-agent-ios/build/modules/platform/search-engines';
import Home from './ReactNative/js/screens/Home';
import PrivacyStats from './ReactNative/js/screens/PrivacyStats/index';
import History from './ReactNative/js/screens/History/index';
import DomainDetails from './ReactNative/js/screens/DomainDetails/index';
import SearchResults from './ReactNative/js/screens/SearchResults';
import BridgeManager from './ReactNative/js/bridge-manager';
import Logo from './ReactNative/js/components/Logo';
import moment from './ReactNative/js/services/moment';
import { seedRandom } from './ReactNative/js/globals/window/crypto';

YellowBox.ignoreWarnings([
  'Warning: componentWillMount',
  'Warning: componentWillReceiveProps',
]);

moment.locale(NativeModules.LocaleConstants.lang);

const searchEnginesEventEmitter = new NativeEventEmitter(
  NativeModules.SearchEnginesModule);
searchEnginesEventEmitter.addListener('SearchEngines:SetDefault', () => {
  loadSearchEngines();
});

prefs.set('tabSearchEnabled', true);
prefs.set('modules.autoconsent.enabled', false);

prefs.set(
  'modules.search.providers.cliqz.enabled',
  NativeModules.Constants.Features.Search.QuickSearch.isEnabled,
);

const isDebug = NativeModules.Constants.isDebug || NativeModules.Constants.isCI;

const { settings, default_prefs } = config;

if (!NativeModules.Constants.Features.Search.QuickSearch.isEnabled) {
  default_prefs.suggestionChoice = 2;
}

overrideSuggestionsHandler(async query => {
  if (NativeModules.Constants.Features.Search.QuickSearch.isEnabled) {
    return [query, []];
  }
  const suggestions = await NativeModules.BrowserActions.getQuerySuggestions(
    query,
  );
  return [query, suggestions];
});

settings.telemetry = {
  demographics: {
    brand: NativeModules.Constants.Features.Telemetry.brand,
    name: `browser:${NativeModules.Constants.bundleIdentifier}`,
    platform: 'ios',
  },
};

settings.HW_CHANNEL = isDebug ? 'ios-debug' : 'ios';
settings.RESULTS_PROVIDER_ORDER = [
  'instant',
  'calculator',
  'history',
  'cliqz',
  'querySuggestions',
];
if (NativeModules.Constants.Features.BrowserCore.configUrl) {
  settings.CONFIG_PROVIDER =
    NativeModules.Constants.Features.BrowserCore.configUrl;
}
if (NativeModules.Constants.Features.HumanWeb.collectorDirectUrl) {
  settings.HUMAN_WEB_LITE_COLLECTOR_VIA_PROXY =
    NativeModules.Constants.Features.HumanWeb.collectorDirectUrl;
}
if (NativeModules.Constants.Features.HumanWeb.collectorProxyUrl) {
  settings.HUMAN_WEB_LITE_COLLECTOR_DIRECT =
    NativeModules.Constants.Features.HumanWeb.collectorDirectUrl;
}
if (NativeModules.Constants.Features.Telemetry.anolysisUrl) {
  settings.ANOLYSIS_BACKEND_URL =
    NativeModules.Constants.Features.Telemetry.anolysisUrl;
}
if (NativeModules.Constants.Features.Telemetry.anolysisStagingUrl) {
  settings.ANOLYSIS_STAGING_BACKEND_URL =
    NativeModules.Constants.Features.Telemetry.anolysisStagingUrl;
}

const app = new App({
  browser: global.browser,
  debug: isDebug,
  config: {
    ...config,
    settings,
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

app.modules['search'].background.actions['getWeatherLocation'] = async function (city) {
  const query = encodeURIComponent(`weather ${city}`);
  const searchResultsResponse = await fetch(
    `${config.settings.RESULTS_PROVIDER}${query}`,
  );
  const searchResults = await searchResultsResponse.json();
  if (
    searchResults.results[0] &&
    searchResults.results[0].template === 'weatherEZ'
  ) {
    return searchResults.results[0].snippet.extra.api_returned_location
      .split(',')[0]
      .trim();
  }
}.bind(app.modules['search'].background);

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

const telemetry = inject.service('telemetry', ['push']);
// This is a quick fix for https://github.com/cliqz/user-agent-ios/issues/939
const safeTelemetry = {
  async push(...args) {
    if (!bridgeManager.isAppReady) {
      await bridgeManager.appReady;
    }
    try {
      await telemetry.push(...args);
    } catch (e) {
      // in some cases telemetry may not be initialized propererly
      // or not initliazed yet
    }
  },
};

AppRegistry.registerComponent('BrowserCore', () => class extends React.Component { render() { return null; }});
AppRegistry.registerComponent('Home', () => (props) => <Home newsModule={inject.module('news')} telemetry={safeTelemetry} {...props} />);
AppRegistry.registerComponent('SearchResults', () => (props) => <SearchResults searchModule={inject.module('search')} insightsModule={inject.module('insights')} bridgeManager={bridgeManager} events={events} {...props} />);
AppRegistry.registerComponent('Logo', () => Logo);
AppRegistry.registerComponent('PrivacyStats', () => (props) => <PrivacyStats insightsModule={inject.module('insights')} {...props} />);
AppRegistry.registerComponent('History', () => (props) => <History {...props} />);
AppRegistry.registerComponent('DomainDetails', () => (props) => <DomainDetails {...props} />);
