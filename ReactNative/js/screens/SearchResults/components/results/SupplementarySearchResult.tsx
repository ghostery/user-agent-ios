import React, { useCallback } from 'react';
import { View, StyleSheet, Text, TouchableWithoutFeedback } from 'react-native';
import { useStyles } from '../../../../contexts/theme';
import NativeDrawable from '../../../../components/NativeDrawable';

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
    },
    searchIcon: {
      width: 20,
      height: 20,
      margin: 4,
      color: theme.separatorColor,
    },
    description: {
      flexShrink: 0,
      flexGrow: 1,
      color: theme.textColor,
      marginLeft: 5,
      fontSize: theme.fontSizeMedium,
    },
  });

const SupplementarySearchResult = ({
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
  const { suggestion } = result;
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
            <NativeDrawable
              style={styles.searchIcon}
              color={styles.searchIcon.color}
              source="search"
            />
          </View>
          <Text
            numberOfLines={2}
            ellipsizeMode="tail"
            style={styles.description}
          >
            {suggestion}
          </Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  );
};

SupplementarySearchResult.isSeparatorDisabled = true;

export default SupplementarySearchResult;
