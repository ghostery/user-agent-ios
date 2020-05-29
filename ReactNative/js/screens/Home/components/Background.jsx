import React, { useMemo, useState, useEffect } from 'react';
import { View, StyleSheet, Platform, Image, Settings } from 'react-native';
import FastImage from 'react-native-fast-image';

const DAY_OF_MONTH = new Date().getDate();
const BACKGROUND_URL = `https://cdn.cliqz.com/serp/configs/config_${DAY_OF_MONTH}.json`;
const styles = {
  mask: [
    StyleSheet.absoluteFill,
    {
      resizeMode: 'stretch',
    },
  ],
};
const fallbackImageSource = { uri: 'home-background' };
const maskSource = { uri: 'mask' };

const useBackgroundImage = hasDynamicBackground => {
  const [url, setUrl] = useState(Settings.get('backgroundUrl'));
  useEffect(() => {
    const fetchBackground = async () => {
      const responseData = await fetch(BACKGROUND_URL, { cache: 'no-cache' });
      const responseJSON = await responseData.json();
      const backgrounds = Platform.isPad
        ? responseJSON.backgrounds
        : responseJSON.backgrounds_mobile;
      const backgroundIndex = Math.floor(Math.random() * backgrounds.length);
      const background = backgrounds[backgroundIndex];
      if (background && background.url !== url) {
        const newUrl = background.url;
        setUrl(newUrl);
        Settings.set({
          backgroundUrl: newUrl,
          backgroundTimestamp: Date.now(),
        });
      }
    };
    if (!hasDynamicBackground) {
      return;
    }
    if (
      !url ||
      Settings.get('backgroundTimestamp') < Date.now() - 1000 * 60 * 60 * 4 // check every 4h
    ) {
      fetchBackground();
    }
  });

  return url;
};

export default ({ height, children, Features }) => {
  const hasDynamicBackground = Features.Home.DynamicBackgrounds.isEnabled;
  const backgroundUrl = useBackgroundImage(hasDynamicBackground);
  const style = useMemo(
    () => ({
      width: '100%',
      minHeight: height,
      flex: 1,
    }),
    [height],
  );
  const backgroundSource = useMemo(
    () => ({
      uri: backgroundUrl,
      priority: FastImage.priority.normal,
    }),
    [backgroundUrl],
  );
  const [hasError, setError] = useState(false);
  return (
    <View style={style} accessibilityIgnoresInvertColors>
      {hasError || !hasDynamicBackground ? (
        <Image style={StyleSheet.absoluteFill} source={fallbackImageSource} />
      ) : (
        <FastImage
          style={StyleSheet.absoluteFill}
          source={backgroundSource}
          onError={setError}
        />
      )}
      {hasDynamicBackground && (
        <Image style={styles.mask} source={maskSource} />
      )}
      {children}
    </View>
  );
};
