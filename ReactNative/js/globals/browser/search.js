import { NativeModules } from 'react-native';

export default {
  async get() {
    return [
      {
        name: 'google',
        isDefault: false,
        favIconUrl: 'https://google.com/',
      },
    ];
  },
  async search(searchProperties) {
    // ignore tabId for now
    const { query, engine, tabId } = searchProperties;

    if (!query) {
      throw new Error('query is required');
    }

    NativeModules.BrowserActions.openLink(
      `https://beta.cliqz.com/search?q=${query}`,
      '',
      false,
    );
  },
};
