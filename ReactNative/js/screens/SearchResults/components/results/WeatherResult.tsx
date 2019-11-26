/* eslint-disable react/prop-types */
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Weather } from '@cliqz/component-ui-snippet-weather';

const styles = StyleSheet.create({
  container: {
  },
});

export default ({ result }: { result: any }) => {
  return (
    <View style={styles.container}>
      <Weather data={{ snippet: result.data }} />
    </View>
  );
};
