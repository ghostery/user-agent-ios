import { NativeModules, NativeEventEmitter } from 'react-native';
import globToRegExp from 'glob-to-regexp';

const TabsAPIFactory = () => {
  const listeners = {
    onCreated: new Set(),
    onRemoved: new Set(),
    onUpdated: new Set(),
    onActivated: new Set(),
  };
  let isListening = false;

  const listenerHandlerFactroy = eventType => {
    return {
      addListener(listener) {
        listeners[eventType].add(listener);
        if (!isListening) {
          isListening = true;
          NativeModules.BrowserTabs.startListeningForTabEvents();
        }
      },
      removeListener(listener) {
        listeners[eventType].remove(listener);
      },
    };
  };

  const eventEmiter = new NativeEventEmitter(NativeModules.BrowserTabs);

  eventEmiter.addListener('BrowserTabsEvent', ({ eventName, eventData }) => {
    const eventListeners = listeners[eventName] || [];
    [...eventListeners].forEach(listener => {
      try {
        listener(...eventData);
      } catch (e) {
        // one failing listener should not prevent other from being called
      }
    });
  });

  return {
    onCreated: listenerHandlerFactroy('onCreated'),

    onRemoved: listenerHandlerFactroy('onRemoved'),

    onUpdated: listenerHandlerFactroy('onUpdated'),

    onActivated: listenerHandlerFactroy('onActivated'),

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
          if (queryInfo.url !== '<all_urls>') {
            const urlRegex = globToRegExp(queryInfo.url);
            if (!urlRegex.test(tab.url)) {
              return false;
            }
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
};

const tabsApi = TabsAPIFactory();

export default tabsApi;
