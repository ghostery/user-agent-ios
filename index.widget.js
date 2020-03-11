/* eslint-disable react/jsx-filename-extension */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import React, { useState, useEffect } from 'react';
import { AppRegistry, View, Image } from 'react-native';
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

const getMessage = t => t;

const useSnippet = city => {
  const [snippet, setSnippet] = useState();
  useEffect(() => {
    const fetchWeather = async () => {
      const query = encodeURIComponent(`weather ${city}`);

      fetch(`${CONFIG.settings.RESULTS_PROVIDER}${query}`).then(
        searchResultsResponse => {
          searchResultsResponse.json().then(searchResults => {
            if (
              searchResults.results[0] &&
              searchResults.results[0].template === 'weatherEZ'
            ) {
              setSnippet(searchResults.results[0].snippet);
            }
          });
        },
      );
    };
    fetchWeather(city);
  }, [city]);
  return [snippet];
};

const TodayWidget = () => {
  const [snippet] = useSnippet('Munich');

  const theme = {
    backgroundColor: 'transparent',
    textColor: 'black',
    descriptionColor: 'black',
    separatorColor: 'transparent',
  };
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
      backgroundColor: theme.backgroundColor,
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
  };
  return (
    <View>
      {snippet && (
        <Weather
          data={{ snippet }}
          ImageRenderer={ImageRenderer}
          moreButtonText={getMessage('expand')}
          lessButtonText={getMessage('collapse')}
          styles={styles}
        />
      )}
    </View>
  );
};

AppRegistry.registerComponent('Today', () => TodayWidget);
