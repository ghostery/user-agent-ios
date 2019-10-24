import React from 'react';
import {
  StyleSheet,
  View,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import { parse } from 'tldts';
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
    marginTop: 10,
    color: theme.textColor,
    fontSize: 12,
  },
  pin: {
    position: 'absolute',
    top: 2,
    zIndex: 10,
    alignSelf: 'center',
    width: 20,
    height: 20,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

const SpeedDial = ({ speedDial, onPress, theme}) => {
  const styles = getStyles(theme)
  const url = speedDial.url;
  const name = parse(url).domain;
  return (
    <TouchableWithoutFeedback
      onPress={() => onPress(speedDial)}
    >
      <View style={styles.container}>
        <View style={styles.circle}>
          {speedDial.pinned &&
            <View style={styles.pin}>
              <Text style={{ color: 'white' }}>P</Text>
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