import React from 'react';
import { TouchableWithoutFeedback, View, Text, StyleSheet } from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';

const styles = StyleSheet.create({
  wrapper: {
    width: '100%',
  },
  button: {
    flexDirection: 'row',
  },
  buttonText: {
    color: 'white',
    fontSize: 15,
    marginRight: 5,
  },
  buttonIcon: {
    color: '#ffffff',
    height: 20,
    width: 20,
    transform: [{ rotate: '-90deg' }],
  },
});

export default ({ scrollToNews }: { scrollToNews: any }) => {
  return (
    <View style={styles.wrapper}>
      <TouchableWithoutFeedback onPress={scrollToNews}>
        <View style={styles.button}>
          <Text style={styles.buttonText}>News</Text>
          <NativeDrawable
            style={styles.buttonIcon}
            source="nav-back"
            color={styles.buttonIcon.color}
          />
        </View>
      </TouchableWithoutFeedback>
    </View>
  );
};
