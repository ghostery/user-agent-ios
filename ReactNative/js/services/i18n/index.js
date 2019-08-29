import { NativeModules } from 'react-native';

let translations;

export default function t(key) {
  if (!translations) {
    const locale = NativeModules.LocaleConstants.lang;
    switch (locale) {
      case 'de':
        translations = require('./localizations/de.json');
        break;
      default:
        translations = require('./localizations/en.json');
    }
  }
  const translation = translations[key];

  if (!translation) {
    console.warn(`Cannot find translation for key "${key}"`);
    return key;
  }

  return translation.message;
}