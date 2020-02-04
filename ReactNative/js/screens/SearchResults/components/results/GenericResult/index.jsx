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
import { GenericSnippet } from '@cliqz/component-ui-snippet-generic';
import NewsSnippet from './snippets/NewsSnippet';
import SnippetList from './snippets/SnippetList';
import NativeDrawable from '../../../../../components/NativeDrawable';
import t from '../../../../../services/i18n';
import Logo from '../../../../../components/Logo';
import { useStyles } from '../../../../../contexts/theme';
import { resultTitleFontSize } from '../../../styles';

const SUPPORTED_DEEP_RESULTS = ['streaming', 'simple_links', 'buttons'];

const getStyles = theme =>
  StyleSheet.create({
    container: {
      flexDirection: 'column',
      marginVertical: 10,
      backgroundColor: theme.backgroundColor,
      borderRadius: 9,
    },
    wrapper: {
      paddingLeft: 7,
      paddingRight: 7,
    },
  });

const getSnippetStyles = theme =>
  StyleSheet.create({
    mainTitle: {
      color: theme.linkColor,
      fontSize: resultTitleFontSize,
    },
    subTitle: {
      color: theme.linkColor,
    },
    visitedTitle: {
      color: theme.visitedColor,
    },
    url: {
      color: theme.urlColor,
    },
    lockColor: {
      color: theme.urlColor,
    },
    lockBreakColor: {
      color: theme.unsafeUrlColor,
    },
    description: {
      color: theme.descriptionColor,
    },
    switchToTabText: {
      color: theme.descriptionColor,
      backgroundColor: theme.backgroundColor,
    },
  });

const ImageRendererComponent = ({ source, color, style }) => {
  return <NativeDrawable style={style} color={color} source={source} />;
};

const LogoComponent = ({ size, url }) => {
  return <Logo size={size} url={url} />;
};

const Snippet = ({ openLink, result, type, styles }) => {
  return (
    <GenericSnippet
      openLink={openLink}
      result={result}
      type={type}
      isUrlsSelecable={false}
      ImageRendererComponent={ImageRendererComponent}
      LogoComponent={LogoComponent}
      t={t}
      styles={styles}
    />
  );
};

export default ({ result, openLink }) => {
  const styles = useStyles(getStyles);
  const snippetStyles = useStyles(getSnippetStyles);
  const { url } = result;
  const urls = result.data.urls || [];
  const deepResults = result.data.deepResults || [];
  const snippets = deepResults.filter(dr =>
    SUPPORTED_DEEP_RESULTS.includes(dr.type),
  );
  const news = deepResults.find(
    r => r.type === 'news' || r.type === 'top-news',
  ) || { links: [] };
  const { logo } = result.meta;
  return (
    <View style={styles.container}>
      <View style={styles.wrapper}>
        <Snippet
          result={result}
          type="main"
          openLink={openLink}
          styles={snippetStyles}
        />
        {urls.length > 0 && (
          <SnippetList
            limit={3}
            expandStep={5}
            list={urls.map(snippet => (
              <Snippet
                key={snippet.url}
                openLink={openLink}
                result={snippet}
                type="history"
                styles={snippetStyles}
              />
            ))}
          />
        )}
      </View>
      {news.links.length > 0 && <NewsSnippet news={news} openLink={openLink} />}
      <View style={styles.wrapper}>
        {snippets.map(snippet => (
          <SnippetList
            key={url + snippet.type}
            limit={3}
            expandStep={5}
            list={snippet.links.map(link => (
              <Snippet
                key={link.url}
                openLink={openLink}
                result={link}
                type={snippet.type}
                styles={snippetStyles}
              />
            ))}
          />
        ))}
      </View>
    </View>
  );
};
