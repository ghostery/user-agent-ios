/* eslint-disable react/prop-types */
import React, { useCallback } from 'react';
import { View, TouchableWithoutFeedback, Text } from 'react-native';
import { parse } from 'tldts';
import Logo from './Logo';
import NativeDrawable from './NativeDrawable';
import { withTheme } from '../contexts/theme';

const getStyles = theme => ({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  circle: {
    borderColor: theme.separatorColor,
    borderWidth: 1,
    padding: 20,
    borderRadius: 60,
  },
  label: {
    marginTop: 5,
    color: theme.textColor,
    fontSize: 12,
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
    color: theme.textColor,
  },
});

const SpeedDial = ({ speedDial, onPress, onLongPress, theme, style = {} }) => {
  const styles = getStyles(theme);
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
      <View
        style={{
          ...styles.container,
          ...style,
        }}
      >
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
        <Text numberOfLines={1} style={styles.label}>
          {name}
        </Text>
      </View>
    </TouchableWithoutFeedback>
  );
};

export default withTheme(SpeedDial);
