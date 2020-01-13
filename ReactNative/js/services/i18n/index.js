import { NativeModules } from 'react-native';

let translations;

export default function t(key) {
  if (key in NativeModules.LocaleConstants) {
    return NativeModules.LocaleConstants[key];
  }
  if (!translations) {
    const locale = NativeModules.LocaleConstants.lang;
    switch (locale) {
      case 'de':
        // eslint-disable-next-line global-require
        translations = require('./localizations/de.json');
        break;
      default:
        // eslint-disable-next-line global-require
        translations = require('./localizations/en.json');
    }
  }
  const translation = translations[key];

  if (!translation) {
    // eslint-disable-next-line no-console
    console.warn(`Cannot find translation for key "${key}"`);
    return key;
  }

  return translation.message;
}
