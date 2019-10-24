import React, { useEffect, useState } from 'react';

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

export const ThemeWrapperComponentProvider = (bridgeManager) => ({ initialProps }) => (props) => {
  if (!initialProps.theme) {
    return props.children;
  }

  const [theme, updateTheme] = useState(initialProps.theme);

  useEffect(() => {
    const onAction = ({ module, action, args, id }) => {
      if (module === 'BrowserCore' && action === 'changeTheme') {
        updateTheme(args[0]);
        return true;
      }
    };
    bridgeManager.addActionListener(onAction);
    return () => {
      bridgeManager.removeActionListener(onAction);
    };
  });

  return (
    <ThemeContext.Provider value={theme}>
      {props.children}
    </ThemeContext.Provider>
  );
}

export default ThemeContext;