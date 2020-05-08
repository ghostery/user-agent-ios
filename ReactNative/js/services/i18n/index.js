import { NativeModules } from 'react-native';

export default function t(key) {
  if (key in NativeModules.LocaleConstants) {
    return NativeModules.LocaleConstants[key];
  }

  throw new Error(`Cannot find translation for key "${key}"`);
}
