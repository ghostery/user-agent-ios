import React, { useCallback } from 'react';
import { View, TouchableWithoutFeedback, Text } from 'react-native';
import { parse } from 'tldts';
import { merge } from '@cliqz/component-styles';
import Logo from './Logo';
import NativeDrawable from './NativeDrawable';
import { withTheme } from '../contexts/theme';

export const getStyles = theme => ({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  circle: {
    padding: 20,
    borderRadius: 60,
    backgroundColor: '#ffffff33',
  },
  label: {
    marginTop: 5,
    color: 'white',
    fontSize: 12,
    fontWeight: '500',
  },
  pin: {
    position: 'absolute',
    top: 1,
    zIndex: 10,
    alignSelf: 'center',
    width: 20,
    height: 20,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  pinIcon: {
    width: 12,
    height: 12,
    color: '#ffffff',
  },
});

const SpeedDial = ({
  speedDial,
  onPress,
  onLongPress,
  theme,
  styles: customStyles = {},
}) => {
  const styles = merge(getStyles(theme), customStyles);
  const { url } = speedDial;
  const name = parse(url).domain;
  const pressAction = useCallback(() => onPress(speedDial), [
    onPress,
    speedDial,
  ]);
  const longPressAction = useCallback(
    () => (onLongPress ? onLongPress(speedDial) : null),
    [onLongPress, speedDial],
  );

  return (
    <TouchableWithoutFeedback
      onPress={pressAction}
      onLongPress={longPressAction}
    >
      <View style={styles.container}>
        <View style={styles.circle}>
          {speedDial.pinned && (
            <View style={styles.pin}>
              <NativeDrawable
                style={styles.pinIcon}
                color={styles.pinIcon.color}
                source="ic_ez_pin"
              />
            </View>
          )}
          <Logo key={speedDial.url} url={speedDial.url} size={30} />
        </View>
        <Text numberOfLines={1} style={styles.label} allowFontScaling={false}>
          {name}
        </Text>
      </View>
    </TouchableWithoutFeedback>
  );
};

export default withTheme(SpeedDial);
