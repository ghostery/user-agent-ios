import React, { useEffect, useState, useContext, useMemo } from 'react';
import { StyleSheet } from 'react-native';

const ThemeContext = React.createContext();

export function withTheme(Component) {
  return function ThemeComponent(props) {
    return (
      <ThemeContext.Consumer>
        {(theme) => <Component {...props} theme={theme} />}
      </ThemeContext.Consumer>
    );
  };
}

//  would be perfect to avoid a global value here
let updateTheme = () => {}
const onAction = ({ module, action, args, id }) => {
  if (module === 'BrowserCore' && action === 'changeTheme') {
    updateTheme(args[0]);
    return true;
  }
};

export const ThemeWrapperComponentProvider = (bridgeManager) => ({ initialProps }) => (props) => {
  if (!initialProps.theme) {
    return props.children;
  }

  const [theme, setData] = useState(initialProps.theme, [initialProps.theme]);
  updateTheme = setData;

  useEffect(() => {

    bridgeManager.addActionListener(onAction);
    return () => {
      // no need to unload - one listener per app is sufficient
    };
  });

  return (
    <ThemeContext.Provider value={theme}>
      {props.children}
    </ThemeContext.Provider>
  );
}

export const useStyles = (getStyle) => {
  const theme = useContext(ThemeContext);
  const styles = useMemo(() => StyleSheet.create(getStyle(theme)), [theme.mode]);
  return styles;
}

export default ThemeContext;