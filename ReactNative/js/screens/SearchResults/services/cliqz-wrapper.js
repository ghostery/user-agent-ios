const callAction = (inject, module, action, ...args) =>
  inject.module(module).action(action, ...args);
const createModuleWrapper = (inject, module, actions) =>
  actions.reduce(
    (all, action) => ({
      ...all,
      [action]: callAction.bind(null, inject, module, action),
    }),
    {},
  );

export default class Cliqz {
  constructor(inject) {
    this.mobileCards = createModuleWrapper(inject, 'mobile-cards', [
      'openLink',
      'callNumber',
      'openMap',
      'hideKeyboard',
      'sendUIReadySignal',
      'handleAutocompletion',
      'getConfig',
      'getTrackerDetails',
    ]);

    this.core = createModuleWrapper(inject, 'core', []);
    this.search = createModuleWrapper(inject, 'search', [
      'getSnippet',
      'reportHighlight',
      'reportSelection',
    ]);
    this.geolocation = createModuleWrapper(inject, 'geolocation', [
      'updateGeoLocation',
    ]);
  }
}
