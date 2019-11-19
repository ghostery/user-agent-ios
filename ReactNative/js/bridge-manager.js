import { NativeEventEmitter } from 'react-native';
import prefs from 'browser-core-user-agent-ios/build/modules/core/prefs';

export default class BridgeManager {
  constructor(bridge, inject, appReady) {
    this.actionListeners = new Set();
    this.onAction = this.onAction.bind(this);
    this.inject = inject;
    this.isAppReady = false;
    this.appReady = appReady;
    this.bridge = bridge;
    appReady.then(() => {
      this.isAppReady = true;
    });
    const eventEmitter = new NativeEventEmitter(bridge);
    eventEmitter.addListener('callAction', this.onAction);
    bridge.ready();
  }

  async onAction({ module, action, args, id }) {
    [...this.actionListeners].some(listener => {
      try {
        const handled = listener({ module, action, args, id });
        if (handled) {
          return false;
        }
      } catch (e) {
        //
      }
      return true;
    });

    if (module === 'core' && action === 'setPref') {
      prefs.set(...args);
      return;
    }

    if (!this.isAppReady) {
      await this.appReady;
    }

    try {
      const response = await this.inject.module(module).action(action, ...args);
      if (typeof id !== 'undefined') {
        this.bridge.replyToAction(id, { result: response });
      }
    } catch (e) {
      if (typeof id !== 'undefined') {
        this.bridge.replyToAction(id, { error: e });
      }
    }
  }

  addActionListener(listener) {
    this.actionListeners.add(listener);
  }

  removeActionListener(listener) {
    this.actionListeners.delete(listener);
  }
}
