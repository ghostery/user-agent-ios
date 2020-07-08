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
import NavigateToResult from './results/NavigateToResult';
import SupplementarySearchResult from './results/SupplementarySearchResult';
import { isSwitchToTab } from './helpers';

const styles = StyleSheet.create({
  defaultSeparator: {
    marginTop: 16,
  },
});

const onLongPress = ({ url, title, isHistory, query } = {}) =>
  NativeModules.ContextMenu.result(url, title, isHistory, query);
const openLink = (url, query) =>
  NativeModules.BrowserActions.openLink(url, query);

export default class CardList extends React.PureComponent {
  constructor(props) {
    super(props);
    this.lastText = '';
    this.lastUrl = '';
  }

  openLink = async ({ result, resultIndex, subResult, subResultMeta }) => {
    const { searchModule, insightsModule } = this.props;
    const { url } = subResult;
    const isSubResult = result.url !== subResult.url;
    const selection = {
      action: 'click',
      elementName: '',
      isFromAutoCompletedUrl: false,
      isNewTab: false,
      isPrivateMode: false,
      query: result.text,
      rawResult: {
        ...result,
        index: resultIndex,
        subResult: isSubResult
          ? {
              type: subResultMeta.type,
              index: subResultMeta.index,
            }
          : {},
      },
      url: result.url,
    };
    let actionUrl = url;
    if (isSwitchToTab(result)) {
      actionUrl = `moz-action:switchtab,${JSON.stringify({ url })}`;
    }

    await searchModule.action('reportSelection', selection, {
      contextId: 'mobile-cards',
    });

    insightsModule.action('insertSearchStats', {
      cliqzSearch: 1,
    });

    openLink(actionUrl, selection.query);
  };

  getComponent = ({ result, resultIndex }) => {
    let Component = GenericResult;

    switch (result.template) {
      case 'weatherEZ':
        Component = WeatherSnippet;
        break;
      default:
        break;
    }

    switch (result.type) {
      case 'navigate-to':
        Component = NavigateToResult;
        break;
      case 'supplementary-search':
        Component = SupplementarySearchResult;
        break;
      default:
        break;
    }

    const component = (
      <Component
        key={result.meta.domain}
        onPress={(link, linkMeta) =>
          this.openLink({
            result,
            resultIndex,
            subResult: link,
            subResultMeta: linkMeta,
          })
        }
        onLongPress={({ url, title }, { isHistory }) =>
          onLongPress({
            url,
            title,
            isHistory,
            query: result.text,
          })
        }
        result={result}
        index={resultIndex}
      />
    );
    const { isSeparatorDisabled } = Component;
    return {
      component,
      isSeparatorDisabled,
    };
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
        {results.map((result, resultIndex) => {
          const { component, isSeparatorDisabled } = this.getComponent({ result, resultIndex });
          return (
            <View key={result.url}>
              {component}
              {!isSeparatorDisabled && (
                separator || <View style={styles.defaultSeparator} />
              )}
            </View>
          );
        })}
        {footer || <View style={styles.defaultSeparator} />}
      </View>
    );
  }
}
