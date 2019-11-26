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
import NewsSnippet from './snippets/NewsSnippet';
import Snippet from './snippets/Snippet';
import SnippetList from './snippets/SnippetList';
import { useStyles } from '../../../../../contexts/theme';

const SUPPORTED_DEEP_RESULTS = ['streaming', 'simple_links', 'buttons'];

const getStyles = theme =>
  StyleSheet.create({
    container: {
      flexDirection: 'column',
      marginVertical: 10,
      backgroundColor: theme.backgroundColor,
      borderRadius: 9,
    },
    wrapper:  {
      paddingLeft: 7,
      paddingRight: 7,
    },
  });

export default ({ result, openLink }) => {
  const styles = useStyles(getStyles);
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
        <Snippet openLink={openLink} data={result} type="main" logo={logo} />
        {urls.length > 0 && (
          <SnippetList
            limit={3}
            expandStep={5}
            list={urls.map(snippet => (
              <Snippet
                key={snippet.url}
                openLink={openLink}
                data={snippet}
                type="history"
              />
            ))}
          />
        )}
      </View>
      {news.links.length > 0 && <NewsSnippet news={news} />}
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
                data={link}
                type={snippet.type}
              />
            ))}
          />
        ))}
      </View>
    </View>
  );
};
