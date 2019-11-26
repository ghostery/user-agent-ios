/* eslint-disable react/prop-types */
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { NewsSnippet } from '@cliqz/component-ui-snippet-news';

const styles = StyleSheet.create({
  container: {
    marginVertical: 10,
    paddingLeft: 7,
    paddingRight: 7,
  },
});

export default ({ result }: { result: any }) => {
  console.warn(result);
  const news = ((result.data || {}).deepResults || []).find((r: any) => r.type === 'top-news') || [];
  return (
    <View style={styles.container}>
      <NewsSnippet data={news} />
    </View>
  );
};
