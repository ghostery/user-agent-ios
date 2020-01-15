/* eslint-disable react/prop-types */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { Text, View, StyleSheet } from 'react-native';
import SnippetIcon from './SnippetIcon';
import Link from './Link';
import NativeDrawable from '../../../../../../components/NativeDrawable';
import { useStyles } from '../../../../../../contexts/theme';
import t from '../../../../../../services/i18n';
import { isSwitchToTab } from '../../../helpers';
import { resultTitleFontSize } from '../../../../styles';


const httpsLockWidth = 9;
const httpsLockMarginRight = 5;

const getStyles = theme =>
  StyleSheet.create({
    container: {
      flexDirection: 'row',
      paddingTop: 7,
      paddingBottom: 6,
      paddingRight: 2,
    },
    rightContainer: {
      flex: 1,
      flexGrow: 1,
      paddingRight: 0,
    },
    mainTitle: {
      color: theme.linkColor,
      fontSize: resultTitleFontSize,
      lineHeight: 20,
      marginTop: (28 - 20) / 2,
    },
    subTitle: {
      color: theme.linkColor,
      fontSize: 14.5,
      lineHeight: 20,
    },
    visitedTitle: {
      color: theme.visitedColor,
    },
    urlContainer: {
      flexDirection: 'row',
      paddingRight: httpsLockWidth + httpsLockMarginRight,
      alignItems: 'center',
      paddingBottom: 2,
    },
    url: {
      color: theme.urlColor,
      fontSize: 13.5,
    },
    lock: {
      width: httpsLockWidth,
      height: httpsLockWidth * 1.3,
      marginRight: httpsLockMarginRight,
    },
    lockColor: {
      color: theme.urlColor,
    },
    description: {
      color: theme.descriptionColor,
      fontSize: 14.5,
      marginTop: 2,
    },
    switchToTabText: {
      color: theme.descriptionColor,
      fontSize: 9,
      textAlign: 'right',
      lineHeight: 9,
      position: 'absolute',
      top: -8,
      right: 0,
      fontWeight: '300',
      backgroundColor: theme.backgroundColor,
      paddingLeft: 5,
    },
  });

const isHistory = props =>
  props.data.provider === 'history' || props.data.provider === 'tabs';

export default props => {
  const styles = useStyles(getStyles);
  const { type, logo, data } = props;
  const { title, friendlyUrl, description, provider, url } = data;
  const titleLines = type === 'main' ? 2 : 1;
  const titleStyle = type === 'main' ? [styles.mainTitle] : [styles.subTitle];
  if (isHistory(props)) {
    titleStyle.push(styles.visitedTitle);
  }
  return (
    // eslint-disable-next-line jsx-a11y/anchor-is-valid
    <Link onPress={() => props.openLink(url, type)}>
      <View style={styles.container}>
        <SnippetIcon type={type} logo={logo} provider={provider} url={url} />
        <View style={styles.rightContainer}>
          {isSwitchToTab(data) && (
            <Text style={styles.switchToTabText}>
              {t('search_switch_to_tab')}
            </Text>
          )}
          <Text numberOfLines={titleLines} style={titleStyle}>
            {title}
          </Text>
          <View
            accessibilityLabel="https-lock"
            accessible={false}
            style={styles.urlContainer}
          >
            <NativeDrawable
              style={styles.lock}
              color={styles.lockColor.color}
              source="ic_ez_https_lock"
            />
            <Text numberOfLines={1} style={styles.url}>
              {friendlyUrl}
            </Text>
          </View>
          {description ? (
            <Text numberOfLines={2} style={styles.description}>
              {description}
            </Text>
          ) : null}
        </View>
      </View>
    </Link>
  );
};
