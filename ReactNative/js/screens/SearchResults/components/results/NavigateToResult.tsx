import React, { useCallback } from 'react';
import { View, StyleSheet, Text, TouchableWithoutFeedback } from 'react-native';
import { useStyles } from '../../../../contexts/theme';
import Logo from '../../../../components/Logo';
import t from '../../../../services/i18n';

const getStyles = (theme: any) =>
  StyleSheet.create({
    container: {
      flexDirection: 'column',
      marginVertical: 10,
      backgroundColor: theme.backgroundColor,
      borderRadius: 9,
    },
    wrapper: {
      paddingLeft: 7,
      paddingRight: 7,
      flexDirection: 'row',
      alignItems: 'center',
    },
    logoWrapper: {
      flex: 0,
      marginRight: 7,
    },
    link: {
      color: theme.linkColor,
      flexGrow: 0,
      flexShrink: 1,
      flexWrap: 'nowrap',
    },
    description: {
      flexShrink: 0,
      flexGrow: 1,
      color: theme.descriptionColor,
      marginLeft: 5,
    },
  });

export default ({
  result,
  onPress,
  onLongPress,
  index,
}: {
  result: any;
  onPress: any;
  onLongPress: any;
  index: number;
}) => {
  const { url, friendlyUrl } = result;
  const styles = useStyles(getStyles);
  const onPressCallback = useCallback(() => {
    onPress(result, { isHistory: false, type: 'navigate-to', index });
  }, [result, index, onPress]);
  const onLongPressCallback = useCallback(() => {
    onLongPress(result, { isHistory: false, type: 'navigate-to', index });
  }, [result, index, onLongPress]);

  return (
    <View style={styles.container}>
      <TouchableWithoutFeedback
        onPress={onPressCallback}
        onLongPress={onLongPressCallback}
      >
        <View style={styles.wrapper}>
          <View style={styles.logoWrapper}>
            <Logo size={28} url={url} />
          </View>
          <Text numberOfLines={2} ellipsizeMode="tail" style={styles.link}>
            {friendlyUrl}
          </Text>
          <Text numberOfLines={1} style={styles.description}>
            — {t('Search.Visit')}
          </Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  );
};
