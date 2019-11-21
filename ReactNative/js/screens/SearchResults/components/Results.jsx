/* eslint-disable react/prop-types */
import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  ScrollView,
  TouchableWithoutFeedback,
  NativeModules,
} from 'react-native';
import SearchUIVertical from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards/cliqz';
import { Provider as ThemeProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/withTheme';
import {
  baseTheme,
  mergeStyles,
} from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/themes';
import NativeDrawable, {
  normalizeUrl,
} from 'browser-core-user-agent-ios/build/modules/mobile-cards/components/custom/NativeDrawable';

import { withTheme } from '../../../contexts/theme';
import t from '../../../services/i18n';

const getTheme = theme =>
  mergeStyles(baseTheme, {
    card: {
      bgColor: theme.backgroundColor,
    },
    snippet: {
      titleColor: theme.linkColor,
      urlColor: theme.urlColor,
      descriptionColor: theme.descriptionColor,
      visitedTitleColor: theme.visitedColor,
      separatorColor: theme.separatorColor,
    },
  });

const getStyles = theme =>
  StyleSheet.create({
    container: {
      flex: 1,
      flexDirection: 'column',
    },
    searchUI: {
      paddingTop: 20,
      backgroundColor: theme.backgroundColor,
    },
    bouncer: {
      backgroundColor: theme.backgroundColor,
      height: 500,
      position: 'absolute',
      top: -500,
      left: 0,
      right: 0,
    },
    separator: {
      height: 0.5,
      backgroundColor: theme.separatorColor,
    },
    footer: {
      height: 50,
      borderTopColor: theme.separatorColor,
      borderTopWidth: 1,
      backgroundColor: theme.backgroundColor,
      alignItems: 'center',
      justifyContent: 'center',
      borderBottomLeftRadius: 10,
      borderBottomRightRadius: 10,
    },
    footerText: {
      color: theme.textColor,
      fontSize: 9,
    },
    noResults: {
      backgroundColor: theme.backgroundColor,
      paddingTop: 24,
      paddingBottom: 24,
      alignItems: 'center',
      justifyContent: 'center',
    },
    noResultsText: {
      color: theme.textColor,
      fontSize: 14,
    },
    searchEnginesHeader: {
      alignItems: 'center',
      justifyContent: 'center',
      marginTop: 30,
    },
    searchEnginesHeaderText: {
      color: 'white',
      fontSize: 12,
    },
    searchEnginesContainer: {
      flexDirection: 'row',
      justifyContent: 'space-evenly',
      marginTop: 10,
      marginBottom: 100,
      textAlign: 'center',
    },
    searchEngineIcon: {
      height: 74,
      width: 74,
      borderRadius: 10,
      overflow: 'hidden',
    },
    searchEngineText: {
      color: 'white',
      textAlign: 'center',
      fontSize: 12,
    },
    cardListStyle: {
      paddingLeft: 0,
      paddingRight: 0,
    },
  });

class Results extends React.Component {
  constructor(props) {
    super(props);
    this.scrollRef = React.createRef();
  }

  // eslint-disable-next-line react/no-deprecated
  componentWillReceiveProps(/* { results, query } */) {
    if (this.scrollRef.current) {
      this.scrollRef.current.scrollTo({ y: 0, animated: false });
    }
  }

  openSearchEngineLink = async (url, index) => {
    const { results = {}, query, cliqz } = this.props;
    const meta = results.meta || {};
    await cliqz.mobileCards.openLink(url, {
      action: 'click',
      elementName: 'icon',
      isFromAutoCompletedUrl: false,
      isNewTab: false,
      isPrivateMode: false,
      isPrivateResult: meta.isPrivate,
      query,
      isSearchEngine: true,
      rawResult: {
        index,
        url,
        provider: 'instant',
        type: 'supplementary-search',
      },
      resultOrder: meta.resultOrder,
      url,
    });
  };

  render() {
    const { results: _results, query, theme: _theme, cliqz } = this.props;
    const {
      results: allResults,
      suggestions,
      meta,
      query: resultsQuery,
    } = _results;
    const results = (allResults || []).filter(r => r.provider !== 'instant');
    const styles = getStyles(_theme);
    const theme = getTheme(_theme);

    NativeModules.BrowserActions.showQuerySuggestions(
      resultsQuery,
      suggestions,
    );

    return (
      <View style={styles.container}>
        <CliqzProvider value={cliqz}>
          <ThemeProvider value={theme}>
            <ScrollView
              bounces
              ref={this.scrollRef}
              showsVerticalScrollIndicator={false}
            >
              <View style={styles.bouncer} />
              <SearchUIVertical
                results={results}
                meta={meta}
                style={styles.searchUI}
                cardListStyle={styles.cardListStyle}
                header={<View />}
                separator={<View style={styles.separator} />}
                footer={<View />}
              />
              <>
                {results.length === 0 && (
                  <View style={styles.noResults}>
                    <Text style={styles.noResultsText}>
                      {t('search_no_results')}
                    </Text>
                  </View>
                )}
                <View style={styles.footer}>
                  <Text style={styles.footerText}>{t('search_footer')}</Text>
                </View>
                <View style={styles.searchEnginesHeader}>
                  <Text style={styles.searchEnginesHeaderText}>
                    {t('search_alternative_search_engines_info')}
                  </Text>
                </View>
                <View style={styles.searchEnginesContainer}>
                  <TouchableWithoutFeedback
                    onPress={() =>
                      this.openSearchEngineLink(
                        `https://beta.cliqz.com/search?q=${encodeURIComponent(
                          query,
                        )}#channel=ios`,
                        2,
                      )
                    }
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        color="#ffffff"
                        source={normalizeUrl('cliqz.svg')}
                      />
                      <Text style={styles.searchEngineText}>Cliqz</Text>
                    </View>
                  </TouchableWithoutFeedback>
                  <TouchableWithoutFeedback
                    onPress={() =>
                      this.openSearchEngineLink(
                        `https://google.com/search?q=${encodeURIComponent(
                          query,
                        )}`,
                        0,
                      )
                    }
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        color="#ffffff"
                        source={normalizeUrl('google.svg')}
                      />
                      <Text style={styles.searchEngineText}>Google</Text>
                    </View>
                  </TouchableWithoutFeedback>
                  <TouchableWithoutFeedback
                    onPress={() =>
                      this.openSearchEngineLink(
                        `https://duckduckgo.com/?q=${encodeURIComponent(
                          query,
                        )}`,
                        1,
                      )
                    }
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        color="#ffffff"
                        source={normalizeUrl('ddg.svg')}
                      />
                      <Text style={styles.searchEngineText}>DuckDuckGo</Text>
                    </View>
                  </TouchableWithoutFeedback>
                </View>
              </>
            </ScrollView>
          </ThemeProvider>
        </CliqzProvider>
      </View>
    );
  }
}

export default withTheme(Results);
