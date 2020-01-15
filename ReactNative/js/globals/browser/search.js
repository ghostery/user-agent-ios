import { NativeModules } from 'react-native';

export default {
  async get() {
    return NativeModules.BrowserSearch.get();
  },
  async search(searchProperties) {
    // ignore tabId for now
    const { query, engine } = searchProperties;

    if (!query) {
      throw new Error('query is required');
    }

    if (!engine) {
      throw new Error('engine is required');
    }

    NativeModules.BrowserSearch.search(query, engine);
  },
};
