import React from 'react';
import { Logo } from '@cliqz/component-ui-logo';
import getLogo from 'cliqz-logo-database';

const convertLogoUrl = logo => ({
  ...logo,
  url: (logo.url || '')
    .replace('logos', 'pngs')
    .replace('.svg', '_192.png'),
});

export default function ({
  url,
  size = 60,
  borderRadius = 5,
  logoSize = 60,
  fontSize = 28
}) {
  return (
    <Logo
      key={url}
      logo={convertLogoUrl(getLogo(url))}
      size={size}
      borderRadius={borderRadius}
      logoSize={logoSize}
      fontSize={fontSize}
    />
  );
}