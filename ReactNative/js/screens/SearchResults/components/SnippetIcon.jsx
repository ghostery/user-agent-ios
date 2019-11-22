/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { StyleSheet, View } from 'react-native';
import { withStyles } from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/withTheme';

import NativeDrawable from '../../../components/NativeDrawable';
import Logo from '../../../components/Logo';

const styles = theme => StyleSheet.create({
  history: {
    width: theme.snippet.historyIconSize,
    height: theme.snippet.historyIconSize,
    marginTop: (theme.snippet.titleLineHeight - theme.snippet.historyIconSize) / 2,
  },
  symbolContainer: {
    width: theme.snippet.mainIconSize,
    backgroundColor: 'transparent',
    justifyContent: 'flex-start',
    alignItems: 'center',
    marginRight: theme.snippet.iconMarginRight,
  },
  iconARGB: {
    color: theme.snippet.iconColorARGB,
  },
  bullet: {
    backgroundColor: theme.snippet.iconColor,
    borderColor: theme.snippet.iconColor,
    width: theme.snippet.bulletIconSize,
    height: theme.snippet.bulletIconSize,
    marginTop: (theme.snippet.titleLineHeight - theme.snippet.bulletIconSize) / 2,
    borderRadius: 1,
  },
});

function getHistorySymbol(props) {
  return (
    <NativeDrawable
      style={props.classes.history}
      source="ic_ez_ic_history_white"
      color={props.classes.iconARGB.color}
    />
  );
}

function getIcon(url) {
  return (
    <Logo
      size={28}
      url={url}
    />
  );
}

const SnippetIcon = (props) => {
  const { logo, type, url, provider } = props;
  let symbol;
  if (type !== 'main' && provider === 'history') {
    symbol = getHistorySymbol(props);
  } else {
    switch (type) {
      case 'main':
        symbol = getIcon(url);
        break;
      default:
        symbol = <View style={props.classes.bullet} />;
    }
  }
  return (
    <View style={props.classes.symbolContainer}>
      {symbol}
    </View>
  );
};

export default withStyles(styles)(SnippetIcon);
