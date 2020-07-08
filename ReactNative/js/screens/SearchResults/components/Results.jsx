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
      borderBottomColor: theme.separatorColor,
      borderBottomWidth: 0,
      top: -1,
      backgroundColor: theme.backgroundColor,
      alignItems: 'center',
      justifyContent: 'center',
      borderBottomLeftRadius: 17,
      borderBottomRightRadius: 17,
      flexDirection: 'row',
    },
    showMoreButtonWrapper: {
      backgroundColor: theme.brandTintColor,
      borderRadius: 10,
      paddingVertical: 20,
      marginVertical: 14,
      marginHorizontal: 14,
      flexGrow: 1,
      flexDirection: 'column',
    },
    showMoreButton: {
      flexDirection: 'row',
      alignSelf: 'center',
    },
    footerIcon: {
      width: 20,
      height: 20,
    },
    footerText: {
      color: 'white',
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

function reportSearchStats(insightsModule, searchEngine) {
  const searchStats = {};

  if (searchEngine.name === 'Cliqz') {
    searchStats.cliqzSearch = 1;
  } else {
    searchStats.otherSearch = 1;
  }

  insightsModule.action('insertSearchStats', searchStats);
}

function isResultAllowed({ template }) {
  return !BLOCKED_TEMPLATES.includes(template);
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

function handleAutocompletion(url = '', query = '') {
  const trimmedUrl = url.replace(/http([s]?):\/\/(www.)?/, '').toLowerCase();
  const searchLower = query.toLowerCase();
  if (trimmedUrl.startsWith(searchLower)) {
    NativeModules.AutoCompletion.autoComplete(trimmedUrl);
  } else {
    NativeModules.AutoCompletion.autoComplete(query);
  }
}

const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

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
    if (!searchEngine) {
      const { searchEngines } = this.state;
      const { Features } = this.props;
      if (Features.Search.QuickSearch.isEnabled) {
        // eslint-disable-next-line no-param-reassign
        searchEngine = { name: 'Cliqz' };
      } else {
        // eslint-disable-next-line no-param-reassign
        searchEngine = searchEngines.find(e => e.isDefault);
      }
    }
    const { results = {}, searchModule, insightsModule } = this.props;
    const meta = results.meta || {};
    const { favIconUrl: url } = searchEngine;

    await searchModule.action(
      'reportSelection',
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

    reportSearchStats(insightsModule, searchEngine);

    browser.search.search({
      query,
      engine: searchEngine.name,
    });
  };

  reportHighlight = () => {
    const { searchModule } = this.props;
    searchModule.action('reportHighlight');
  };

  render() {
    const {
      results: _results,
      query,
      theme: _theme,
      searchModule,
      insightsModule,
      Features,
    } = this.props;
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
        handleAutocompletion(friendlyUrl, text);
      }
    }

    return (
      <View style={styles.container}>
        <ScrollView
          bounces
          ref={this.scrollRef}
          showsVerticalScrollIndicator={false}
          keyboardDismissMode="on-drag"
          keyboardShouldPersistTaps="handled"
          onTouchStart={hideKeyboard}
          onScrollEndDrag={this.reportHighlight}
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
              searchModule={searchModule}
              insightsModule={insightsModule}
            />
          </View>
          <>
            {Features.Search.QuickSearch.isEnabled && results.length === 0 && (
              <View style={styles.noResults}>
                <Text style={styles.noResultsText}>
                  {t('Search.UI.NoResults')}
                </Text>
              </View>
            )}

            <View style={styles.footer}>
              <TouchableWithoutFeedback
                onPress={() => this.openSearchEngineResultsPage(null, query, 0)}
              >
                <View style={styles.showMoreButtonWrapper}>
                  <View style={styles.showMoreButton}>
                    {Features.Search.QuickSearch.isEnabled && (
                      <NativeDrawable
                        style={styles.footerIcon}
                        source="nav-menu"
                        color="#ffffff"
                      />
                    )}
                    <Text style={styles.footerText} allowFontScaling={false}>
                      {t('Search.UI.Footer')}
                    </Text>
                  </View>
                </View>
              </TouchableWithoutFeedback>
            </View>
            {Features.Search.AdditionalSearchEngines.isEnabled && (
              <>
                <View style={styles.searchEnginesHeader}>
                  <Text style={styles.searchEnginesHeaderText}>
                    {t('Search.UI.AdditionalSearchEnginesHeader')}
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
                                color: 'white',
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
            )}
          </>
        </ScrollView>
      </View>
    );
  }
}

export default withTheme(Results);
