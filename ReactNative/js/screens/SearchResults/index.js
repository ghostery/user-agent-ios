import React from 'react';
import {
  StyleSheet, View,
  Text,
  ScrollView,
  TouchableWithoutFeedback,
} from 'react-native';
import SearchUIVertical from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards/cliqz';
import { Provider as ThemeProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/withTheme';
import inject from 'browser-core-user-agent-ios/build/modules/core/kord/inject';
import NativeDrawable, { normalizeUrl } from 'browser-core-user-agent-ios/build/modules/mobile-cards/components/custom/NativeDrawable';

import Cliqz from './services/cliqz-wrapper';
import t from '../../services/i18n';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'gray',
  },
  footer: {
    height: 40,
    backgroundColor: '#464961',
    alignItems: 'center',
    justifyContent: 'center',
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
  },
  footerText: {
    color: '#A3A4B0',
    fontSize: 11.5,
  },
  noResults: {
    backgroundColor: 'white',
    paddingTop: 24,
    paddingBottom: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  noResultsText: {
    color: '#656d7e',
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
});

export default class SearchResults extends React.Component {
  constructor(props) {
    super(props);

    const results = props.results || {
      results: [],
      meta: {},
    };

    this.state = {
      results,
      isReady: true,
      hasQuery: false,
      query: this.props.query,
    };

    this.cliqz = new Cliqz(inject);
    this.scrollRef = React.createRef();
  }

  componentWillReceiveProps({ results, query }) {
    if (this.scrollRef.current) {
      this.scrollRef.current.scrollTo({ y: 0, animated: false });
    }
    if (results) {
      this.setState({ results });
    }
    if (typeof query === 'string') {
      this.setState({ query });
    }
  }

  reset() {
    this.setState({
      results: {
        results: [],
        meta: {},
      },
    });
  }

  openSearchEngineLink = async (url, index) => {
    const results = this.state.results || {};
    const meta = results.meta || {};
    const query = this.state.query;
    await this.cliqz.mobileCards.openLink(url, {
      action: 'click',
      elementName: 'icon',
      isFromAutoCompletedUrl: false,
      isNewTab: false,
      isPrivateMode: false,
      isPrivateResult: meta.isPrivate,
      query,
      isSearchEngine: true,
      rawResult: {
        index: index,
        url,
        provider: 'instant',
        type: 'supplementary-search',
      },
      resultOrder: meta.resultOrder,
      url,
    });
  }

  render() {
    const { results: allResults, suggestions, meta } = this.state.results;
    const query = this.state.query;
    const appearance = 'lumen-light';
    const SearchComponent = SearchUIVertical;
    const results = allResults.filter(r => r.provider !== 'instant')

    // NativeModules.QuerySuggestion.showQuerySuggestions(query, suggestions);
    return (
      <View style={styles.container}>
        <CliqzProvider value={this.cliqz}>
          <ThemeProvider value={appearance}>
            <ScrollView
              bounces={false}
              ref={this.scrollRef}
            >
              <SearchComponent
                results={results}
                meta={meta}
                theme={appearance}
                style={{ backgroundColor: 'white', paddingTop: 9 }}
                cardListStyle={{ paddingLeft: 0, paddingRight: 0 }}
                header={<View />}
                separator={<View style={{ height: 0.5, backgroundColor: '#D9D9D9' }} />}
                footer={<View />}
              />
              <>
                {results.length === 0 &&
                  <View style={styles.noResults}>
                    <Text style={styles.noResultsText}>{t('search_no_results')}</Text>
                  </View>
                }
                <View style={styles.footer}>
                  <Text style={styles.footerText}>
                    {t('search_footer')}
                  </Text>
                </View>
                <View style={styles.searchEnginesHeader}>
                  <Text style={styles.searchEnginesHeaderText}>{t('search_alternative_search_engines_info')}</Text>
                </View>
                <View style={styles.searchEnginesContainer}>
                  <TouchableWithoutFeedback
                    onPress={() => this.openSearchEngineLink(`https://google.com/search?q=${encodeURIComponent(query)}`, 0)}
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        source={normalizeUrl('google.svg')}
                      />
                      <Text style={styles.searchEngineText}>Google</Text>
                    </View>
                  </TouchableWithoutFeedback>
                  <TouchableWithoutFeedback
                    onPress={() => this.openSearchEngineLink(`https://duckduckgo.com/?q=${encodeURIComponent(query)}`, 1)}
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        source={normalizeUrl('ddg.svg')}
                      />
                      <Text style={styles.searchEngineText}>DuckDuckGo</Text>
                    </View>
                  </TouchableWithoutFeedback>
                  <TouchableWithoutFeedback
                    onPress={() => this.openSearchEngineLink(`https://www.bing.com/search?q=${encodeURIComponent(query)}`, 2)}
                  >
                    <View>
                      <NativeDrawable
                        style={styles.searchEngineIcon}
                        source={normalizeUrl('bing.svg')}
                      />
                      <Text style={styles.searchEngineText}>Bing</Text>
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
