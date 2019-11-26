/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { StyleSheet, View } from 'react-native';

import { useStyles } from '../../../contexts/theme';
import NativeDrawable from '../../../components/NativeDrawable';
import Logo from '../../../components/Logo';

const getStyles = () =>
  StyleSheet.create({
    history: {
      width: 17,
      height: 17,
      marginTop: (20 - 17) / 2,
    },
    symbolContainer: {
      width: 28,
      backgroundColor: 'transparent',
      justifyContent: 'flex-start',
      alignItems: 'center',
      marginRight: 6,
    },
    iconARGB: {
      color: '#9B000000',
    },
    bullet: {
      backgroundColor: 'rgba(0, 0, 0, 0.61)',
      borderColor: 'rgba(0, 0, 0, 0.61)',
      width: 5,
      height: 5,
      marginTop: (20 - 5) / 2,
      borderRadius: 1,
    },
  });

export default ({ type, url, provider }) => {
  const styles = useStyles(getStyles);
  let symbol;
  if (type !== 'main' && provider === 'history') {
    symbol = (
      <NativeDrawable
        style={styles.history}
        source="ic_ez_ic_history_white"
        color={styles.iconARGB.color}
      />
    );
  } else {
    switch (type) {
      case 'main':
        symbol = <Logo size={28} url={url} />;
        break;
      default:
        symbol = <View style={styles.bullet} />;
    }
  }
  return <View style={styles.symbolContainer}>{symbol}</View>;
};
