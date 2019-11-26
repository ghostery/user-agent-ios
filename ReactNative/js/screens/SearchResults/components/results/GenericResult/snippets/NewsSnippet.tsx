/* eslint-disable react/prop-types */
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { NewsSnippet } from '@cliqz/component-ui-snippet-news';

const styles = StyleSheet.create({
  container: {
  },
});

export default ({ news }: { news: any }) => {
  return (
    <View style={styles.container}>
      <NewsSnippet data={news} />
    </View>
  );
};
