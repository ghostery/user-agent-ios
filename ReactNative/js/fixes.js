import RNFS from 'react-native-fs';
import ResourceLoaderStorage from 'browser-core-user-agent-ios/build/modules/platform/resource-loader-storage';

const ASSETS = ['tracker_db_v2.json'];
const { load } = ResourceLoaderStorage.prototype;

ResourceLoaderStorage.prototype.load = function () {
  const assetIndex = ASSETS.indexOf(this.filePath[this.filePath.length - 1]);
  if (assetIndex >= 0) {
    return RNFS.readFile(`${RNFS.MainBundlePath}/${ASSETS[assetIndex]}`);
  }
  return load.call(this);
};
