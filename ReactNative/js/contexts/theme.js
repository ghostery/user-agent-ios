import React, { useMemo, useEffect, useState } from 'react';
import { StyleSheet, useColorScheme, NativeModules } from 'react-native';

global.currentTheme = null;

export const useTheme = () => {
  const [theme, setTheme] = useState(
    global.currentTheme || NativeModules.Constants.initialTheme,
  );
  const colorScheme = useColorScheme();

  useEffect(() => {
    const fetchTheme = async () => {
      if (!global.currentTheme || global.currentTheme.mode !== colorScheme) {
        const newTheme = await NativeModules.Constants.getTheme(colorScheme);
        global.currentTheme = newTheme;
        setTheme(newTheme);
      }
    };
    fetchTheme();
  }, [colorScheme]);

  return theme;
};

export function withTheme(Component) {
  return function ThemeComponent(props) {
    const theme = useTheme();
    // eslint-disable-next-line react/jsx-filename-extension, react/jsx-props-no-spreading
    return <Component {...props} theme={theme} />;
  };
}

export const useStyles = getStyle => {
  const theme = useTheme();
  const styles = useMemo(() => StyleSheet.create(getStyle(theme)), [
    getStyle,
    theme,
  ]);
  return styles;
};
