/* eslint-disable import/prefer-default-export */
export const isSwitchToTab = result => {
  const type = result.type || '';
  return result.provider === 'tabs' || type.indexOf('switchtab') >= 0;
};
