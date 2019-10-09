import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { parse } from 'tldts';
import Logo from './Logo';

const styles = StyleSheet.create({
  row: {
    padding: 10,
    flexDirection: 'row',
  },
  rowText: {
    marginLeft: 10,
    flex: 1,
    justifyContent: 'center',
  },
  rowTitle: {
    fontSize: 13,
    fontWeight: 'bold',
  },
});

export default function ListItem({ url, title, onPress }) {
  const name = parse(url).domain;

  return (
    <TouchableOpacity
      style={styles.row}
      onPress={onPress}
    >
      <Logo url={url} />
      <View style={styles.rowText}>
        <Text style={styles.rowTitle}>{name}</Text>
        <Text numberOfLines={2}>{title}</Text>
      </View>
    </TouchableOpacity>
  );
}