import React from 'react';
import { Logo } from '@cliqz/component-ui-logo';
import getLogo from 'cliqz-logo-database';

const convertLogoUrl = logo => ({
  ...logo,
  url: (logo.url || '').replace('logos', 'pngs').replace('.svg', '_192.png'),
});

const DEFAULT_SIZE = 60;
const DEFAULT_FONT_SIZE = 28;

export default ({ url, size: _size, fontSize: _fontSize }) => {
  const size = _size || DEFAULT_SIZE;
  let fontSize = _fontSize || DEFAULT_FONT_SIZE;

  if (size !== DEFAULT_SIZE && !_fontSize) {
    fontSize = (DEFAULT_FONT_SIZE / DEFAULT_SIZE) * size;
  }
  return (
    <Logo
      key={url}
      logo={convertLogoUrl(getLogo(url) || {})}
      size={size}
      borderRadius={5}
      logoSize={size}
      fontSize={fontSize}
    />
  );
};
