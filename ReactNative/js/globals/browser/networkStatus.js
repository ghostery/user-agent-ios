import NetInfo from '@react-native-community/netinfo';

let connectionType = 'wifi';

NetInfo.fetch().then(state => {
  connectionType = state.type;
});

NetInfo.addEventListener(state => {
  connectionType = state.type;
});

export default {
  async getLinkInfo() {
    return connectionType;
  }
};