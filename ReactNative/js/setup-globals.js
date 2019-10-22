import { NativeEventEmitter, NativeModules } from 'react-native';

global.browser = global.chrome = {
  webRequest: {
    onHeadersReceived: {
      addListener() {},
    },
  },
  history: {
    onVisited: {
      addListener() {},
    },
    getVisits() {
      return Promise.resolve([]);
    },
    search() {
      return Promise.resolve([]);
    },
  },
  tabs: {
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
    query: () => Promise.resolve([]),
  },
  cliqz: {
    async setPref(key, value) {
    },
    async getPref(key) {
      return NativeModules.BrowserCliqz.getPref(key);
    },
    async hasPref(key) {
    },
    async clearPref(key) {
    },
    onPrefChange: (function () {
      const prefs = NativeModules.BrowserCliqz;
      const listeners = new Map();
      const eventEmitter = new NativeEventEmitter(prefs);

      eventEmitter.addListener('prefChange', (pref) => {
        for (const [listener, prefName] of listeners.entries()) {
          if (pref === prefName) {
            try {
              listener();
            } catch (e) {
              // one failing listener should not prevent other from being called
            }
          }
        }
      });

      return {
        addListener(listener, prefix, key) {
          const pref = `${prefix || ''}${key || ''}`
          listeners.set(listener, pref);
          prefs.addPrefListener(pref);
        },
        removeListener(listener) {
          listeners.delete(listener);
          prefs.removePrefListener(pref);
        },
      };
    })(),
  },
};

// TODO: investigate who is using it
global.navigator.userAgent = 'Cliqz';