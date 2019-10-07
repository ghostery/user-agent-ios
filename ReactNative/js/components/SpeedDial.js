import React from 'react';
import {
  StyleSheet,
  View,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import { parse } from 'tldts';
import Logo from './Logo';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default ({ speedDial, onPress }) => {
  const url = speedDial.url;
  const name = parse(url).domain;
  return (
    <TouchableWithoutFeedback
      onPress={() => onPress(speedDial)}
    >
      <View style={styles.container}>
        <Logo
          key={speedDial.url}
          url={speedDial.url}
        />
        <Text numberOfLines={1}>{name}</Text>
      </View>
    </TouchableWithoutFeedback>
  );
};