import { NativeEventEmitter } from 'react-native';

export default class BridgeManager {
  constructor(bridge, inject, appReady) {
    this.actionListeners = new Set();
    this.onAction = this.onAction.bind(this);
    this.inject = inject;
    this.isAppReady = false;
    this.appReady = appReady;
    appReady.then(() => {
      this.isAppReady = true;
    });
    const eventEmitter = new NativeEventEmitter(bridge);
    eventEmitter.addListener('callAction', this.onAction);
    bridge.ready();
  }

  async onAction({ module, action, args, id }) {
    for(const listener of this.actionListeners) {
      try {
        const handled = listener({ module, action, args, id });
        if (handled) {
          return;
        }
      } catch (e) {
        //
      }
    }

    if (module === 'core' && action === 'setPref') {
      prefs.set(...args);
      return;
    }

    if (!this.isAppReady) {
      await this.appReady
    }

    const response = await this.inject.module(module).action(action, ...args);
    if (typeof id !== 'undefined') {
      // nativeBridge.replyToAction(id, { result: response });
    }
  }

  addActionListener(listener) {
    this.actionListeners.add(listener)
  }

  removeActionListener(listener) {
    this.actionListeners.delete(listener);
  }
}