import React, { useMemo, useState, useEffect } from 'react';
import { View, StyleSheet, Platform, Image } from 'react-native';
import FastImage from 'react-native-fast-image';

const DAY_OF_MONTH = new Date().getDate();
const BACKGROUND_URL = `https://cdn.cliqz.com/serp/configs/config_${DAY_OF_MONTH}.json`;
let cachedBackgroundUrl;

const styles = {
  mask: [
    StyleSheet.absoluteFill,
    {
      resizeMode: 'stretch',
    },
  ],
};

const useBackgroundImage = () => {
  const [url, setUrl] = useState();
  useEffect(() => {
    const fetchBackground = async () => {
      const responseData = await fetch(BACKGROUND_URL);
      const responseJSON = await responseData.json();
      const backgrounds = Platform.isPad
        ? responseJSON.backgrounds
        : responseJSON.backgrounds_mobile;
      const backgroundIndex = Math.floor(Math.random() * backgrounds.length);
      const background = backgrounds[backgroundIndex];
      if (background) {
        setUrl(background.url);
        cachedBackgroundUrl = background.url;
      }
    };

    if (!cachedBackgroundUrl) {
      fetchBackground();
    }
  });

  return url;
};

export default ({ height, children }) => {
  const backgroundUrl = useBackgroundImage();
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
          uri: backgroundUrl || cachedBackgroundUrl,
          priority: FastImage.priority.normal,
        }}
      />
      <Image
        style={styles.mask}
        source={{
          uri: 'mask',
        }}
      />
      {children}
    </View>
  );
};
