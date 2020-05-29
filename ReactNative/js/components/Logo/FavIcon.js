import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes } from 'react-native';

const componentInterface = {
  name: 'NativeFavicon',
  propTypes: {
    ...ViewPropTypes, // include the default view properties
    url: PropTypes.string,
  },
};

export default requireNativeComponent('NativeFavicon', componentInterface);
