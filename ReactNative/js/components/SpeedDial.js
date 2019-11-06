import React from 'react';
import {
  StyleSheet,
  View,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import { parse } from 'tldts';
import NativeDrawable, { normalizeUrl } from 'browser-core-user-agent-ios/build/modules/mobile-cards/components/custom/NativeDrawable';
import Logo from './Logo';
import { withTheme } from '../contexts/theme';

const getStyles = (theme) => ({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  circle: {
    backgroundColor: theme.separatorColor,
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

const SpeedDial = ({ speedDial, onPress, theme, style = {} }) => {
  const styles = getStyles(theme)
  const url = speedDial.url;
  const name = parse(url).domain;
  return (
    <TouchableWithoutFeedback
      onPress={() => onPress(speedDial)}
    >
      <View
        style={{
          ...styles.container,
          ...style,
        }}
      >
        <View style={styles.circle}>
          {speedDial.pinned &&
            <View style={styles.pin}>
              <NativeDrawable
                style={styles.pinIcon}
                color={styles.pinIcon.color}
                source={normalizeUrl('pin.svg')}
              />
            </View>
          }
          <Logo
            key={speedDial.url}
            url={speedDial.url}
            size={30}
          />
        </View>
        <Text
          numberOfLines={1}
          style={styles.label}
        >{name}</Text>
      </View>
    </TouchableWithoutFeedback>
  );
};

export default withTheme(SpeedDial);