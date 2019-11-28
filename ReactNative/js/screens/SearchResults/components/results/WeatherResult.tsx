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
