import { NativeEventEmitter, NativeModules } from 'react-native';
import networkStatus from './globals/browser/networkStatus';
import tabs from './globals/browser/tabs';
import search from './globals/browser/search';
import './globals/navigator/userAgent';
import './globals/window/FileReader';
import { DOMParser } from './globals/window/DOMParser';
import { crypto } from './globals/window/crypto';

window.DOMParser = DOMParser;
if (NativeModules.WindowCrypto.isAvailable) {
  // window.crypto cannot be reassigned in Chrome, so those APIs have to be tested in Safari
  try {
    window.crypto = crypto;
  } catch (e) {
    // breaks debugging in Chrome
  }
}

const browser = {
  networkStatus,
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
  tabs,
  search,
  cliqz: {
    async setPref(/* key, value */) {
      return Promise.resolve();
    },
    async getPref(key) {
      return NativeModules.BrowserCliqz.getPref(key);
    },
    async hasPref(/* key */) {
      return Promise.resolve(false);
    },
    async clearPref(/* key */) {
      return Promise.resolve();
    },
    onPrefChange: (function setupPrefs() {
      const prefs = NativeModules.BrowserCliqz;
      const listeners = new Map();
      const eventEmitter = new NativeEventEmitter(prefs);

      eventEmitter.addListener('prefChange', pref => {
        [...listeners].forEach(([listener, prefName]) => {
          if (pref === prefName) {
            try {
              listener();
            } catch (e) {
              // one failing listener should not prevent other from being called
            }
          }
        });
      });

      return {
        addListener(listener, prefix, key) {
          const pref = `${prefix || ''}${key || ''}`;
          listeners.set(listener, pref);
          prefs.addPrefListener(pref);
        },
        removeListener(listener) {
          const pref = listeners.get(listener);
          listeners.delete(listener);
          prefs.removePrefListener(pref);
        },
      };
    })(),
  },
};

global.browser = browser;
global.chrome = browser;
