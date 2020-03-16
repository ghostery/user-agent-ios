import React from 'react';
import { View, Text, TouchableWithoutFeedback } from 'react-native';
import Logo from './Logo';
import { useStyles } from '../contexts/theme';

const getStyle = theme => ({
  row: {
    flexDirection: 'row',
    flexGrow: 1,
  },
  firstRow: {
    flexDirection: 'row',
  },
  label: {
    color: theme.redColor,
    fontSize: 12,
    top: 1,
    left: 5,
  },
  rowText: {
    color: theme.textColor,
    marginLeft: 10,
    flex: 1,
    justifyContent: 'center',
  },
  rowTitle: {
    color: `${theme.textColor}99`,
  },
  rowDescription: {
    color: theme.textColor,
    fontSize: 13,
    fontWeight: 'bold',
  },
});

export default function ListItem({
  url,
  displayUrl: name,
  title,
  onPress,
  label,
}) {
  const styles = useStyles(getStyle);

  return (
    <TouchableWithoutFeedback onPress={onPress}>
      <View style={styles.row}>
        <Logo url={url} size={48} />
        <View style={styles.rowText}>
          <Text
            numberOfLines={2}
            style={styles.rowDescription}
            allowFontScaling={false}
          >
            {title}
          </Text>
          <View style={styles.firstRow}>
            <Text style={styles.rowTitle} allowFontScaling={false}>
              {name}
            </Text>
            {label && (
              <Text style={styles.label} allowFontScaling={false}>
                {label}
              </Text>
            )}
          </View>
        </View>
      </View>
    </TouchableWithoutFeedback>
  );
}
