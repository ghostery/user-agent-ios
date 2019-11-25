/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import {
  FlatList,
  View,
  Text,
  TouchableWithoutFeedback,
  StyleSheet,
} from 'react-native';
import { getMessage } from 'browser-core-user-agent-ios/build/modules/core/i18n';

import { withTheme } from '../../../contexts/theme';
import NativeDrawable from '../../../components/NativeDrawable';

const getStyles = theme =>
  StyleSheet.create({
    list: {
      marginTop: 4,
    },
    footer: {
      flexDirection: 'row',
      paddingTop: 11,
      paddingBottom: 8,
      justifyContent: 'center',
      alignItems: 'center',
    },
    footerText: {
      fontSize: 12.5,
      color: theme.descriptionColor,
    },
    arrow: {
      height: 8,
      width: 12,
      marginLeft: 5,
    },
    separatorStyle: {
      marginTop: 0,
      marginBottom: 0,
      borderTopColor: theme.separatorColor,
      borderTopWidth: 0.5,
      marginLeft: 29,
    },
  });

class SnippetList extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      limit: props.limit,
    };
  }

  onFooterPressed = isCollapsed => {
    const { expandStep, limit } = this.props;
    if (isCollapsed) {
      this.setState(({ limit: previousLimit }) => ({
        limit: previousLimit + expandStep,
      }));
    } else {
      this.setState({ limit });
    }
  };

  getFooter = (isCollapsed, styles) => {
    const { list, limit } = this.props;

    if (list.length <= limit) {
      return null;
    }
    const footerText = getMessage(isCollapsed ? 'expand' : 'collapse');
    const arrowAngle = {
      transform: [{ rotateX: isCollapsed ? '0deg' : '180deg' }],
    };
    return (
      <TouchableWithoutFeedback
        onPress={() => this.onFooterPressed(isCollapsed)}
      >
        <View style={styles.footer}>
          <Text style={styles.footerText}>{footerText.toUpperCase()}</Text>
          <NativeDrawable
            source="ic_ez_arrow-down"
            style={[styles.arrow, arrowAngle]}
            color="#9c9c9c"
          />
        </View>
      </TouchableWithoutFeedback>
    );
  };

  render() {
    const { theme, list, listKey } = this.props;
    const styles = getStyles(theme);
    const { limit } = this.state;
    const isCollapsed = list.length > limit;
    const data = list.slice(0, limit);
    return (
      <FlatList
        style={styles.list}
        keyExtractor={item => item.key}
        data={data}
        renderItem={({ item }) => item}
        ItemSeparatorComponent={() => <View style={styles.separatorStyle} />}
        ListFooterComponent={this.getFooter(isCollapsed, styles)}
        ListHeaderComponent={() => <View style={styles.separatorStyle} />}
        listKey={listKey}
      />
    );
  }
}

export default withTheme(SnippetList);
