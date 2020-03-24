import React, { useMemo, useState, useEffect } from 'react';
import { ImageBackground } from 'react-native';

const DAY_OF_MONTH = new Date().getDate();
const BACKGROUND_URL = `https://cdn.cliqz.com/serp/configs/config_${DAY_OF_MONTH}.json`;
let backgroundSource;

const useSource = () => {
  const [source, setSource] = useState();
  useEffect(() => {
    const fetchBackground = async () => {
      const response = await fetch(BACKGROUND_URL);
      const backgrounds = await response.json();
      const mobileBackground =
        backgrounds.backgrounds_mobile && backgrounds.backgrounds_mobile[0];
      if (mobileBackground) {
        const background = { url: mobileBackground.url };
        setSource(background);
        backgroundSource = background;
      }
    };

    if (!backgroundSource) {
      fetchBackground();
    }
  });

  return source;
};

export default ({ height, children }) => {
  const source = useSource();
  const style = useMemo(
    () => ({
      width: '100%',
      minHeight: height,
      flex: 1,
    }),
    [height],
  );
  return (
    <ImageBackground source={source || backgroundSource} style={style}>
      {children}
    </ImageBackground>
  );
};
