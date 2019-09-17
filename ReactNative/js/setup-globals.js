
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
  }
};

// TODO: investigate who is using it
global.navigator.userAgent = 'Cliqz';