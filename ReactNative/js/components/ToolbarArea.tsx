import React, { useMemo } from 'react';
import { View } from 'react-native';

export default ({ height }: { height: number }) => {
  const style = useMemo(() => ({ height }), [height]);
  return <View style={style} />;
};
