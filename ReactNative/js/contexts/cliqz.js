import React from 'react';

const CliqzContext = React.createContext();

export function withCliqz(Component) {
  return function CliqzComponent(props) {
    /* eslint-disable react/jsx-props-no-spreading */
    return (
      // eslint-disable-next-line react/jsx-filename-extension
      <CliqzContext.Consumer>
        {cliqz => <Component {...props} cliqz={cliqz} />}
      </CliqzContext.Consumer>
    );
  };
  /* eslint-enable react/jsx-props-no-spreading */
}

export default CliqzContext;
