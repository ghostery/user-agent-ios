/* eslint-disable no-underscore-dangle */
/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { FlatList, View, StyleSheet } from 'react-native';
import Card from './Card';
import { withCliqz } from '../../../contexts/cliqz';

const styles = StyleSheet.create({
  defaultSeparator: {
    marginTop: 16,
  },
});

class CardList extends React.PureComponent {
  constructor(props) {
    super(props);
    this.viewabilityConfig = {
      itemVisiblePercentThreshold: 50, // TODO: to be configured
    };
    this.lastText = '';
    this.lastUrl = '';
  }

  componentDidUpdate() {
    if (!this._cardsList) {
      return;
    }
    this._cardsList.scrollToIndex({ index: 0 });
  }

  componentWillUnmount() {
    this._cardsList = null;
  }

  onViewableItemsChanged = ({ viewableItems: [{ item } = {}] }) => {
    const { cliqz } = this.props;
    if (!item) {
      // TODO: check logic when no items viewed
      return;
    }
    const { friendlyUrl, text } = item;
    if (friendlyUrl !== this.lastUrl || text !== this.lastText) {
      cliqz.mobileCards.handleAutocompletion(friendlyUrl, text);
      this.lastUrl = friendlyUrl;
      this.lastText = text;
    }
  };

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
    cliqz.mobileCards.openLink(url, selection);
  };

  getComponent = ({ item, index }) => {
    let Component;
    switch (item.type) {
      default:
        Component = Card;
    }
    return (
      <Component
        key={item.meta.domain}
        openLink={(...args) => this.openLink(item, ...args)}
        result={item}
        index={index}
      />
    );
  };

  render() {
    const { results, cliqz, style, separator, header, footer } = this.props;
    if (!results.length) {
      return null;
    }
    const listStyle = {
      paddingLeft: 10,
      paddingRight: 10,
      ...(style || {}),
    };

    return (
      <FlatList
        ref={cardsList => {
          this._cardsList = cardsList;
        }}
        bounces={false}
        data={results}
        keyExtractor={item => item.url}
        renderItem={this.getComponent}
        keyboardDismissMode="on-drag"
        keyboardShouldPersistTaps="handled"
        ItemSeparatorComponent={() =>
          separator || <View style={styles.defaultSeparator} />
        }
        ListHeaderComponent={() =>
          header || <View style={styles.defaultSeparator} />
        }
        ListFooterComponent={() =>
          footer || <View style={styles.defaultSeparator} />
        }
        onTouchStart={() => cliqz.mobileCards.hideKeyboard()}
        onScrollEndDrag={() => cliqz.search.reportHighlight()}
        viewabilityConfig={this.viewabilityConfig}
        onViewableItemsChanged={this.onViewableItemsChanged}
        listKey="cards"
        style={listStyle}
      />
    );
  }
}

export default withCliqz(CardList);
