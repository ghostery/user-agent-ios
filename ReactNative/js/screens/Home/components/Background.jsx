import React, { useMemo, useState, useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import FastImage from 'react-native-fast-image'

const DAY_OF_MONTH = new Date().getDate();
const BACKGROUND_URL = `https://cdn.cliqz.com/serp/configs/config_${DAY_OF_MONTH}.json`;
let backgroundSource;

const useBackgroundImage = () => {
  const [source, setSource] = useState();
  useEffect(() => {
    const fetchBackground = async () => {
      const response = await fetch(BACKGROUND_URL);
      const backgrounds = await response.json();
      const mobileBackground =
        backgrounds.backgrounds_mobile && backgrounds.backgrounds_mobile[0];
      if (mobileBackground) {
        setSource(mobileBackground.url);
        backgroundSource = mobileBackground.url;
      }
    };

    if (!backgroundSource) {
      fetchBackground();
    }
  });

  return source;
};

export default ({ height, children }) => {
  const backgroundImageUrl = useBackgroundImage();
  const style = useMemo(
    () => ({
      width: '100%',
      minHeight: height,
      flex: 1,
    }),
    [height],
  );

  return (
    <View style={style} accessibilityIgnoresInvertColors>
      <FastImage
        style={StyleSheet.absoluteFill}
        source={{
          uri: backgroundImageUrl || backgroundSource,
          priority: FastImage.priority.normal,
        }}
      />
      {children}
    </View>
  );
};
