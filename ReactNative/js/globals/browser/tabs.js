import { NativeModules } from 'react-native';
import globToRegExp from 'glob-to-regexp';

const TabsAPI = {
  onCreated: {
    addListener() {},
    removeListener() {},
  },
  onUpdated: {
    addListener() {},
    removeListener() {},
  },
  onRemoved: {
    addListener() {},
    removeListener() {},
  },
  onActivated: {
    addListener() {},
    removeListener() {},
  },
  async query(queryInfo) {
    if (!queryInfo) {
      throw new Error('missing queryInfo');
    }

    const allTabs = await NativeModules.BrowserTabs.query();

    return allTabs.filter(tab => {
      if (typeof queryInfo.active === 'boolean') {
        if (tab.active !== queryInfo.active) {
          return false;
        }
      }

      if (typeof queryInfo.title === 'string') {
        const titleRegex = globToRegExp(queryInfo.title);
        if (!titleRegex.test(tab.title)) {
          return false;
        }
      }

      if (typeof queryInfo.url === 'string') {
        const urlRegex = globToRegExp(queryInfo.url);
        if (!urlRegex.test(tab.url)) {
          return false;
        }
      } else if (Array.isArray(queryInfo.url)) {
        if (
          !queryInfo.url.some(url => {
            const urlRegex = globToRegExp(url);
            if (urlRegex.test(tab.url)) {
              return true;
            }
            return false;
          })
        ) {
          return false;
        }
      }

      return true;
    });
  },
};

export default TabsAPI;
