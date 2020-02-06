/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { View, StyleSheet, NativeModules } from 'react-native';
import GenericResult from './results/GenericResult';
import WeatherSnippet from './results/WeatherResult';
import { withCliqz } from '../../../contexts/cliqz';
import { isSwitchToTab } from './helpers';

const styles = StyleSheet.create({
  defaultSeparator: {
    marginTop: 16,
  },
});

const onLongPress = (url, { isHistory } = {}) =>
  NativeModules.ContextMenu.result(url, isHistory);

class CardList extends React.PureComponent {
  constructor(props) {
    super(props);
    this.lastText = '';
    this.lastUrl = '';
  }

  getSelection = (result, url, elementName) => {
    const { meta, index } = this.props;
    const selection = {
      action: 'click',
      elementName,
      isFromAutoCompletedUrl: false,
      isNewTab: false,
      isPrivateMode: false,
      isPrivateResult: meta.isPrivate,
      query: result.text,
      rawResult: {
        index,
        ...result,
      },
      resultOrder: meta.resultOrder,
      url,
    };
    return selection;
  };

  openLink = (result, url, elementName = '') => {
    const { cliqz } = this.props;
    const selection = this.getSelection(result, url, elementName);
    let actionUrl = url;
    if (isSwitchToTab(result)) {
      actionUrl = `moz-action:switchtab,${JSON.stringify({ url })}`;
    }
    cliqz.mobileCards.openLink(actionUrl, selection);
  };

  getComponent = ({ item, index }) => {
    let Component = GenericResult;
    switch (item.template) {
      case 'weatherEZ':
        Component = WeatherSnippet;
        break;
      default:
        break;
    }

    return (
      <Component
        key={item.meta.domain}
        onPress={(...args) => this.openLink(item, ...args)}
        onLongPress={() =>
          onLongPress(item.url, { isHistory: item.provider === 'history' })
        }
        result={item}
        index={index}
      />
    );
  };

  render() {
    const { results, style, separator, header, footer } = this.props;
    if (!results.length) {
      return null;
    }
    const listStyle = {
      paddingLeft: 10,
      paddingRight: 10,
      ...(style || {}),
    };

    return (
      <View style={listStyle}>
        {header || <View style={styles.defaultSeparator} />}
        {results.map(result => (
          <View key={result.url}>
            {this.getComponent({ item: result })}
            {separator || <View style={styles.defaultSeparator} />}
          </View>
        ))}
        {footer || <View style={styles.defaultSeparator} />}
      </View>
    );
  }
}

export default withCliqz(CardList);
