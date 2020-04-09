import React from 'react';
import {
  View,
  Text,
  NativeModules,
  TouchableWithoutFeedback,
} from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';
import { useStyles } from '../../../contexts/theme';
import t from '../../../services/i18n';

const startSearch = () => NativeModules.BrowserActions.startSearch('');

const getStyles = theme => ({
  container: {
    height: 47,
    width: '100%',
    paddingHorizontal: 20,
    borderRadius: 40,
    backgroundColor: 'white',
    flexDirection: 'row',
  },
  text: {
    alignSelf: 'center',
    flexGrow: 1,
    color: '#444444',
  },
  iconWrapper: {
    width: 20,
    height: '100%',
  },
  icon: {
    color: theme.brandColor,
    height: '100%',
  },
});

export default () => {
  const styles = useStyles(getStyles);

  return (
    <TouchableWithoutFeedback onPress={startSearch} accessible={false}>
      <View style={styles.container} testID="urlbar">
        <Text style={styles.text}>{t('UrlBar.Placeholder')}</Text>
        <View style={styles.iconWrapper}>
          <NativeDrawable
            style={styles.icon}
            color={styles.icon.color}
            source="search"
          />
        </View>
      </View>
    </TouchableWithoutFeedback>
  );
};
