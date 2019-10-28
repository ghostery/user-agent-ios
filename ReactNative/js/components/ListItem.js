import React from 'react';
import {
  View,
  Text,
  TouchableWithoutFeedback,
} from 'react-native';
import { parse } from 'tldts';
import Logo from './Logo';
import { useStyles } from '../contexts/theme';

const getStyle = (theme) => ({
  row: {
    padding: 10,
    flexDirection: 'row',
  },
  rowText: {
    color: theme.textColor,
    marginLeft: 10,
    flex: 1,
    justifyContent: 'center',
  },
  rowTitle: {
    color: theme.textColor,
    fontSize: 13,
    fontWeight: 'bold',
  },
  rowDescription: {
    color: theme.textColor,
  },
});

export default function ListItem({ url, title, onPress }) {
  const styles = useStyles(getStyle);

  const name = parse(url).domain;

  return (
    <TouchableWithoutFeedback
      onPress={onPress}
    >
      <View style={styles.row}>
        <Logo url={url} />
        <View style={styles.rowText}>
          <Text style={styles.rowTitle}>{name}</Text>
          <Text
            numberOfLines={2}
            style={styles.rowDescription}
          >{title}</Text>
        </View>
      </View>
    </TouchableWithoutFeedback>
  );
}