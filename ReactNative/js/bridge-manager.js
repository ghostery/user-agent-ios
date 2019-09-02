import { NativeEventEmitter } from 'react-native';

export default class BridgeManager {
  constructor(bridge, inject) {
    this.actionListeners = new Set();
    this.onAction = this.onAction.bind(this);
    this.inject = inject;
    const eventEmitter = new NativeEventEmitter(bridge);
    eventEmitter.addListener('callAction', this.onAction);
  }

  async onAction({ module, action, args, id }) {
    for(const listener of this.actionListeners) {
      try {
        listener({ module, action, args, id });
      } catch (e) {
        //
      }
    }

    if (module === 'core' && action === 'setPref') {
      prefs.set(...args);
      return;
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