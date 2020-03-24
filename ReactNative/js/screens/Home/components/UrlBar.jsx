import React from 'react';
import { View, Text } from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';
import { useStyles } from '../../../contexts/theme';

const getStyles = theme => ({
  container: {
    height: 40,
    width: '100%',
    paddingHorizontal: 20,
    borderRadius: 40,
    backgroundColor: 'white',
    flexDirection: 'row',
  },
  text: {
    alignSelf: 'center',
    flexGrow: 1,
    color: theme.descriptionColor,
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
    <View style={styles.container}>
      <Text style={styles.text}>Search Privately</Text>
      <View style={styles.iconWrapper}>
        <NativeDrawable
          style={styles.icon}
          color={styles.icon.color}
          source="search"
        />
      </View>
    </View>
  );
};
