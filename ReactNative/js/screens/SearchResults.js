import React from 'react';
import {
  StyleSheet,
  Text,
  View,
} from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
});

export default class Home extends React.Component {
  render() {

    return (
      <View style={styles.container}>
        <Text>
          Search Results
        </Text>
      </View>
    );
  }
}