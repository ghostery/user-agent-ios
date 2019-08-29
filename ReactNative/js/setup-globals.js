
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
};

// TODO: investigate who is using it
global.navigator.userAgent = 'Cliqz';