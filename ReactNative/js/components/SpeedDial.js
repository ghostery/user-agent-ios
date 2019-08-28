import React from 'react';
import {
  StyleSheet,
  View,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import { parse } from 'tldts';
import getLogo from 'cliqz-logo-database';
import { Logo } from '@cliqz/component-ui-logo';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

const convertLogoUrl = logo => ({
  ...logo,
  url: (logo.url || '')
    .replace('logos', 'pngs')
    .replace('.svg', '_192.png'),
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
          logo={convertLogoUrl(getLogo(url))}
          size={60}
          borderRadius={5}
          logoSize={60}
        />
        <Text numberOfLines={1}>{name}</Text>
      </View>
    </TouchableWithoutFeedback>
  );
};