import { NativeModules } from 'react-native';

const { userAgent } = NativeModules.Constants;

// TODO: investigate who is using it
try {
  global.navigator.userAgent = userAgent;
} catch (e) {
  // breaks debugging in Chrome
}

// eslint-disable-next-line no-underscore-dangle
const _fetch = global.window.fetch;
global.window.fetch = (u, o) => {
  if (!o) {
    return _fetch(u);
  }

  return _fetch(u, {
    ...o,
    headers: {
      ...(o.headers || {}),
      'user-agent': userAgent,
    },
  });
};
