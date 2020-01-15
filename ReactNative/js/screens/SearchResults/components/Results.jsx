/* eslint-disable react/prop-types */
import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  ScrollView,
  NativeModules,
  TouchableWithoutFeedback,
} from 'react-native';
import ResultList from './ResultList';
import SpeedDial from '../../../components/SpeedDial';
import NativeDrawable from '../../../components/NativeDrawable';
import { withTheme } from '../../../contexts/theme';
import CliqzProvider from '../../../contexts/cliqz';
import t from '../../../services/i18n';
import { resultTitleFontSize } from '../styles';

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
      height: 1,
      backgroundColor: theme.separatorColor,
    },
    footer: {
      height: 60,
      borderBottomColor: theme.separatorColor,
      borderBottomWidth: 1,
      backgroundColor: theme.separatorColor,
      alignItems: 'center',
      justifyContent: 'center',
      borderBottomLeftRadius: 10,
      borderBottomRightRadius: 10,
    },
    footerWrapper: {
      flexDirection: 'row',
    },
    footerIcon: {
      width: 20,
      height: 20,
    },
    footerText: {
      color: theme.textColor,
      alignSelf: 'center',
      marginLeft: 10,
      fontSize: resultTitleFontSize,
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
      marginTop: 10,
      marginBottom: 100,
      textAlign: 'center',
    },
    searchEnginesGroupContainer: {
      flex: 1,
      flexDirection: 'row',
      justifyContent: 'space-evenly',
      marginTop: 10,
      marginBottom: 10,
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

const BLOCKED_TEMPLATES = ['calculator', 'currency', 'flight'];

function isResultAllowed({ template, provider, type }) {
  return (
    !BLOCKED_TEMPLATES.includes(template) &&
    type !== 'navigate-to' &&
    Boolean(provider) &&
    provider !== 'instant' &&
    provider !== 'rich-header' // promises sometimes arrive to ui
  );
}

function groupBy(arr, n) {
  const group = [];
  for (let i = 0, j = 0; i < arr.length; i += 1) {
    if (i >= n && i % n === 0) {
      j += 1;
    }
    group[j] = group[j] || [];
    group[j].push(arr[i]);
  }
  return group;
}

class Results extends React.Component {
  constructor(props) {
    super(props);
    this.scrollRef = React.createRef();
    this.state = {
      searchEngines: [],
    };
    browser.search.get().then(searchEngines => {
      this.setState({
        searchEngines,
      });
    });
  }

  // eslint-disable-next-line react/no-deprecated
  componentWillReceiveProps(/* { results, query } */) {
    if (this.scrollRef.current) {
      this.scrollRef.current.scrollTo({ y: 0, animated: false });
    }
  }

  openSearchEngineResultsPage = async (searchEngine, query, index) => {
    const { results = {}, cliqz } = this.props;
    const meta = results.meta || {};
    const { favIconUrl: url } = searchEngine;

    await cliqz.search.reportSelection(
      {
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
          kind: [`custom-search|{"class":"${searchEngine.name}"}`],
        },
        resultOrder: meta.resultOrder,
        url,
      },
      {
        contextId: 'mobile-cards',
      },
    );
    browser.search.search({
      query,
      engine: searchEngine.name,
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
    const { searchEngines } = this.state;
    const results = (allResults || []).filter(isResultAllowed);
    const styles = getStyles(_theme);

    NativeModules.BrowserActions.showQuerySuggestions(
      resultsQuery,
      suggestions,
    );

    if (results[0]) {
      const { friendlyUrl, text } = results[0];
      if (friendlyUrl && text) {
        cliqz.mobileCards.handleAutocompletion(friendlyUrl, text);
      }
    }

    return (
      <View style={styles.container}>
        <CliqzProvider.Provider value={cliqz}>
          <ScrollView
            bounces
            ref={this.scrollRef}
            showsVerticalScrollIndicator={false}
            keyboardDismissMode="on-drag"
            keyboardShouldPersistTaps="handled"
            onTouchStart={() => cliqz.mobileCards.hideKeyboard()}
            onScrollEndDrag={() => cliqz.search.reportHighlight()}
          >
            <View style={styles.bouncer} />
            <View
              accessible={false}
              accessibilityLabel="search-results"
              style={styles.searchUI}
            >
              <ResultList
                results={results}
                meta={meta}
                style={styles.cardListStyle}
                header={<View />}
                separator={<View style={styles.separator} />}
                footer={<View />}
              />
            </View>
            <>
              {results.length === 0 && (
                <View style={styles.noResults}>
                  <Text style={styles.noResultsText}>
                    {t('search_no_results')}
                  </Text>
                </View>
              )}

              <TouchableWithoutFeedback
                onPress={() =>
                  this.openSearchEngineResultsPage('Cliqz', query, 0)
                }
              >
                <View style={styles.footer}>
                  <View style={styles.footerWrapper}>
                    <NativeDrawable
                      style={styles.footerIcon}
                      source="nav-menu"
                      color={_theme.brandTintColor}
                    />
                    <Text style={styles.footerText}>{t('search_footer')}</Text>
                  </View>
                </View>
              </TouchableWithoutFeedback>

              <View style={styles.searchEnginesHeader}>
                <Text style={styles.searchEnginesHeaderText}>
                  {t('search_alternative_search_engines_info')}
                </Text>
              </View>
              <View style={styles.searchEnginesContainer}>
                {groupBy(searchEngines, 3).map(
                  (searchEnginesGroup, groupIndex) => (
                    <View
                      style={styles.searchEnginesGroupContainer}
                      key={searchEnginesGroup.map(e => e.name).join('')}
                    >
                      {searchEnginesGroup.map((searchEngine, engineIndex) => (
                        <SpeedDial
                          key={searchEngine.name}
                          styles={{
                            label: {
                              color: _theme.separatorColor,
                            },
                            circle: {
                              borderColor: `${_theme.separatorColor}44`,
                            },
                          }}
                          speedDial={{
                            pinned: false,
                            url: searchEngine.favIconUrl,
                          }}
                          onPress={() =>
                            this.openSearchEngineResultsPage(
                              searchEngine,
                              query,
                              // index 0 is "show more results" Cliqz link
                              1 + groupIndex * 3 + engineIndex,
                            )
                          }
                        />
                      ))}
                    </View>
                  ),
                )}
              </View>
            </>
          </ScrollView>
        </CliqzProvider.Provider>
      </View>
    );
  }
}

export default withTheme(Results);
