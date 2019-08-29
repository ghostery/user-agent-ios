import React from 'react';
import { AppRegistry, YellowBox, NativeModules, NativeEventEmitter } from 'react-native';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
import inject from 'browser-core-user-agent-ios/build/modules/core/kord/inject';
import prefs from 'browser-core-user-agent-ios/build/modules/core/prefs';
import { addConnectionChangeListener } from 'browser-core-user-agent-ios/build/modules/platform/network';
import { setDefaultSearchEngine } from 'browser-core-user-agent-ios/build/modules/core/search-engines';
import events from 'browser-core-user-agent-ios/build/modules/core/events';
import Home from './ReactNative/js/screens/Home';
import SearchResults from './ReactNative/js/screens/SearchResults';

YellowBox.ignoreWarnings([
  'Warning: NetInfo', // TODO: use netinfo from community package
]);

const app = new App();
app.start();

global.CLIQZ = {
  app,
};

addConnectionChangeListener();

const eventEmitter = new NativeEventEmitter(NativeModules.JSBridge);

let updateQuery;
let lastQuery;
eventEmitter.addListener('callAction', async ({ module, action, args, id }) => {
  if (module === 'search' && action === 'startSearch') {
    const query = args[0];
    if (updateQuery) {
      updateQuery(query);
    } else {
      lastQuery = query;
    }
  }

  if (module === 'core' && action === 'setPref') {
    prefs.set(...args);
    return;
  }

  const response = await inject.module(module).action(action, ...args);
  if (typeof id !== 'undefined') {
    // nativeBridge.replyToAction(id, { result: response });
  }
});

eventEmitter.addListener('publishEvent', () => {});

events.sub('mobile-browser:notify-preferences', (_prefs) => {
  // clear cache with every visit to tab overiew and settings
  Object.keys(_prefs).forEach((key) => {
    prefs.set(key, _prefs[key]);
  });
});

events.sub('mobile-browser:set-search-engine', (engine) => {
  setDefaultSearchEngine(engine);
});

let updateResults;
let lastResults;
events.sub('search:results', (results) => {
  if (updateResults) {
    updateResults(results);
  } else {
    lastResults = results;
  }
});

class SearchWrapper extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      results: lastResults,
      query: lastQuery,
    };
  }

  componentWillMount() {
    updateResults = (results) => this.setState({ results });
    updateQuery = (query) => this.setState({ query });
  }

  componentWillUnmount() {
    updateResults = null;
    lastResults = null;
    updateQuery = null;
    lastQuery = null;
  }

  render() {
    return (
      <SearchResults results={this.state.results} query={this.state.query} />
    );
  }
};

AppRegistry.registerComponent('BrowserCore', () => class extends React.Component {});
AppRegistry.registerComponent('Home', () => Home);
AppRegistry.registerComponent('SearchResults', () => SearchWrapper);