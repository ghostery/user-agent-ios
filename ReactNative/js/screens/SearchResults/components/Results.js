import React from 'react';
import {
  StyleSheet, View,
  Text,
  ScrollView,
  TouchableWithoutFeedback,
  NativeModules,
} from 'react-native';
import SearchUIVertical from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards/cliqz';
import { Provider as ThemeProvider } from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/withTheme';
import { baseTheme, mergeStyles } from 'browser-core-user-agent-ios/build/modules/mobile-cards-vertical/themes';
import NativeDrawable, { normalizeUrl } from 'browser-core-user-agent-ios/build/modules/mobile-cards/components/custom/NativeDrawable';

import t from '../../../services/i18n';

const getTheme = (theme) => mergeStyles(baseTheme, {

});

const getStyles = (theme) => StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: theme.backgroundColor,
  },
  footer: {
    height: 30,
    backgroundColor: '#a2a6ae',
    alignItems: 'center',
    justifyContent: 'center',
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
  },
  footerText: {
    color: 'white',
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
    color: 'black',
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
    color: 'black',
    textAlign: 'center',
    fontSize: 12,
  },
});

export default class Results extends React.Component {
  constructor(props) {
    super(props);
    this.scrollRef = React.createRef();
  }

  componentWillReceiveProps({ results, query }) {
    if (this.scrollRef.current) {
      this.scrollRef.current.scrollTo({ y: 0, animated: false });
    }
  }

  openSearchEngineLink = async (url, index) => {
    const results = this.props.results || {};
    const meta = results.meta || {};
    const query = this.props.query;
    await this.props.cliqz.mobileCards.openLink(url, {
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
    const { results: allResults, suggestions, meta } = this.props.results;
    const query = this.props.query;
    const results = (allResults || []).filter(r => r.provider !== 'instant')
    const styles = getStyles(this.props.theme);
    const theme = getTheme(this.props.theme);

    NativeModules.BrowserActions.showQuerySuggestions(this.props.results.query, suggestions);

    return (
      <View style={styles.container}>
        <CliqzProvider value={this.props.cliqz}>
          <ThemeProvider value={theme}>
            <ScrollView
              bounces={false}
              ref={this.scrollRef}
            >
              <SearchUIVertical
                results={results}
                meta={meta}
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
                        color={'#a2a6ae'}
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
                        color={'#a2a6ae'}
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
                        color={'#a2a6ae'}
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
