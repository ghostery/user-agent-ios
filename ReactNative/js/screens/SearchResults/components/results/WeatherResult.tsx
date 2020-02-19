/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import { getMessage } from 'browser-core-user-agent-ios/build/modules/core/i18n';
import React from 'react';
import { Image, View, StyleSheet } from 'react-native';
import {
  Weather,
  styles as weatherStyles,
  ImageRenderer as ImageRendererI,
} from '@cliqz/component-ui-snippet-weather';
import { withTheme } from '../../../../contexts/theme';

const styles = StyleSheet.create({
  container: {},
});

const ImageRenderer: ImageRendererI = ({ uri, height, width }) => {
  return (
    <Image
      source={{ uri }}
      style={{
        width,
        height,
      }}
    />
  );
};

const WeatherResult = ({ result, theme }: { result: any; theme: any }) => {
  return (
    <View style={styles.container}>
      <Weather
        data={{ snippet: result.data }}
        ImageRenderer={ImageRenderer}
        moreButtonText={getMessage('expand')}
        lessButtonText={getMessage('collapse')}
        styles={{
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
            startColor: theme.backgroundColor,
            stopColor: weatherStyles.temperatureGraphGradient.stopColor,
          },
          precipitationGraphGradient: {
            startColor: theme.backgroundColor,
            stopColor: weatherStyles.precipitationGraphGradient.stopColor,
          },
        }}
      />
    </View>
  );
};

export default withTheme(WeatherResult);
