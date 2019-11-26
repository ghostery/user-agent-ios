import React from 'react';
import { AppRegistry, YellowBox, NativeModules } from 'react-native';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
import inject from 'browser-core-user-agent-ios/build/modules/core/kord/inject';
import events from 'browser-core-user-agent-ios/build/modules/core/events';
import Home from './ReactNative/js/screens/Home';
import SearchResults from './ReactNative/js/screens/SearchResults';
import BridgeManager from './ReactNative/js/bridge-manager';
import Logo from './ReactNative/js/components/Logo';
import { ThemeWrapperComponentProvider } from './ReactNative/js/contexts/theme';

YellowBox.ignoreWarnings([
  'Warning: componentWillMount',
  'Warning: componentWillReceiveProps',
]);

const app = new App({
  browser: global.browser,
  debug: NativeModules.Constants.isDebug || NativeModules.Constants.isCI
});
const appReady = app.start();

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