/* eslint-disable no-nested-ternary */
/* eslint-disable react/jsx-filename-extension */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import React, { useState, useEffect, useCallback } from 'react';
import {
  AppRegistry,
  View,
  Image,
  ActivityIndicator,
  Button,
  NativeModules,
  Settings,
} from 'react-native';
import {
  Weather,
  styles as weatherStyles,
} from '@cliqz/component-ui-snippet-weather';
import CONFIG from 'browser-core-user-agent-ios/build/modules/core/config';

const ImageRenderer = ({ uri, height, width }) => {
  return (
    <Image
      source={{ uri: `${uri.slice(0, -3)}png` }}
      style={{
        width,
        height,
      }}
    />
  );
};

const configure = () => NativeModules.Bridge.configure();

const useSnippet = (city, locale) => {
  const [snippet, setSnippet] = useState();
  const [loading, setLoading] = useState(true);

  const fetchWeather = useCallback(async () => {
    setLoading(true);
    const query = encodeURIComponent(`weather ${city}`);
    const searchResultsResponse = await fetch(
      `${CONFIG.settings.RESULTS_PROVIDER}${query}&blocking=1&locale=${locale}`,
    );
    const searchResults = await searchResultsResponse.json();
    if (
      searchResults.results[0] &&
      searchResults.results[0].template === 'weatherEZ'
    ) {
      const snippetData = searchResults.results[0].snippet;
      setSnippet(snippetData);
      Settings.set({
        weather: {
          city,
          snippet: snippetData,
          timestamp: Date.now(),
        },
      });
    }
    setLoading(false);
  }, [city, locale]);

  useEffect(() => {
    const cachedWeather = Settings.get('weather');
    if (
      cachedWeather &&
      cachedWeather.city === city &&
      cachedWeather.snippet &&
      cachedWeather.timestamp > Date.now() - 1000 * 60 * 20
    ) {
      setSnippet(cachedWeather.snippet);
      setLoading(false);
    } else {
      fetchWeather(city);
    }
  }, [city, fetchWeather]);
  return [snippet, loading, fetchWeather];
};

const TodayWidget = ({ city, theme, i18n, locale }) => {
  const [snippet, loading, update] = useSnippet(city, locale);

  const styles = {
    container: {
      marginVertical: 10,
    },
    activeText: {
      color: theme.textColor,
    },
    dayText: {
      color: theme.textColor,
    },
    daysContainer: {
      marginHorizontal: 7,
    },
    divider: {
      backgroundColor: 'transparent',
    },
    grid: {
      borderLeftColor: theme.separatorColor,
    },
    h1: {
      color: theme.textColor,
    },
    h3: {
      color: theme.textColor,
    },
    h5: {
      color: theme.descriptionColor,
    },
    moreLessButtonText: {
      color: theme.descriptionColor,
      fontSize: 12,
    },
    unitSelectionButtonText: {
      backgroundColor: theme.separatorColor,
      color: theme.textColor,
    },
    windText: {
      color: theme.descriptionColor,
    },
    dayWrapperActive: {
      borderColor: theme.separatorColor,
    },
    overline: {
      color: theme.descriptionColor,
      marginHorizontal: 10,
    },
    timelineText: {
      color: theme.descriptionColor,
    },
    headerLeftColumn: {
      marginLeft: 15,
    },
    rightSideInfo: {
      marginRight: 15,
    },
    svgText: {
      color: theme.descriptionColor,
      activeColor: theme.textColor,
    },
    temperatureGraphGradient: {
      startColor: weatherStyles.temperatureGraphGradient.stopColor,
      stopColor: weatherStyles.temperatureGraphGradient.stopColor,
    },
    precipitationGraphGradient: {
      startColor: weatherStyles.precipitationGraphGradient.stopColor,
      stopColor: weatherStyles.precipitationGraphGradient.stopColor,
    },
    timelineWrapper: {
      marginTop: 30,
    },
    moreLessButtonWrapper: {
      display: 'none',
    },
    svgWrapper: {
      height: 70,
      marginBottom: 0,
    },
    center: {
      marginTop: 30,
    },
  };
  if (!city) {
    return (
      <View style={styles.center}>
        <Button title={i18n.configure} onPress={configure} />
      </View>
    );
  }
  return (
    <View>
      {loading ? (
        <ActivityIndicator size="large" style={styles.center} />
      ) : snippet ? (
        <Weather
          data={{ snippet }}
          ImageRenderer={ImageRenderer}
          moreButtonText={i18n.expand}
          lessButtonText={i18n.collapse}
          styles={styles}
        />
      ) : (
        <View style={styles.center}>
          <Button title={i18n.reload} onPress={update} />
        </View>
      )}
    </View>
  );
};

AppRegistry.registerComponent('Today', () => TodayWidget);
