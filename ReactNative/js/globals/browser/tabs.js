import { NativeModules } from 'react-native';

const tabs = {
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
  async query() {
    console.warn("XXXX")
    return NativeModules.BrowserTabs.query();
  },
};

tabs.query().then((x) => {
  console.warn("XXXX1111");
  console.warn(x)
})

export default tabs;
