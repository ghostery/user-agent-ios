/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
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
