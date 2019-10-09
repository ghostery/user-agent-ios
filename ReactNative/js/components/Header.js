import React from 'react';
import {
  Text,
  StyleSheet,
} from 'react-native';

const styles = StyleSheet.create({
  header: {
    fontSize: 28,
    marginLeft: 12,
    marginRight: 12,
  },
});

export default function ({ title }) {
  return (
    <Text style={styles.header}>
      { title }
    </Text>
  );
}