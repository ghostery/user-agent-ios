import { AppRegistry } from 'react-native';
import './ReactNative/js/setup-globals';
import App from 'browser-core-user-agent-ios/build/modules/core/app';
import Home from './ReactNative/js/screens/Home';
import SearchResults from './ReactNative/js/screens/SearchResults';

const app = new App();
app.start();

global.CLIQZ = {
  app,
};

AppRegistry.registerComponent('Home', () => Home);
AppRegistry.registerComponent('SearchResults', () => SearchResults);