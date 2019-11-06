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
    paddingLeft: 20,
    paddingRight: 20,
    paddingTop: 10,
    paddingBottom: 10,
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
    color: theme.textColor + '99',
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
        <Logo url={url} size={48} />
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