import React, { useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  NativeModules,
  TouchableHighlight,
  TouchableWithoutFeedback,
} from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';
import { News } from '../hooks/news';

const styles = StyleSheet.create({
  wrapper: {
    width: '100%',
    flexDirection: 'row',
  },
  button: {
    alignItems: 'center',
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
  playbackButtonIcon: {
    color: '#ffffff',
    height: 20,
    width: 20,
    alignSelf: 'center',
    marginLeft: 15,
  },
  spacer: {
    flex: 1,
  },
  playbackControls: {
    flexDirection: 'row',
  },
});

export default ({
  scrollToNews,
  news,
}: {
  scrollToNews: any;
  news: News[];
}) => {
  const read = useCallback(() => {
    NativeModules.ReadTheNews.read(news);
  }, [news]);
  const next = useCallback(() => {
    NativeModules.ReadTheNews.next();
  }, []);
  const previous = useCallback(() => {
    NativeModules.ReadTheNews.previous();
  }, []);
  return (
    <View style={styles.wrapper}>
      <TouchableHighlight onPress={scrollToNews}>
        <View style={styles.button}>
          <Text style={styles.buttonText}>News</Text>
          <NativeDrawable
            style={styles.buttonIcon}
            source="nav-back"
            color={styles.buttonIcon.color}
          />
        </View>
      </TouchableHighlight>
      <View style={styles.spacer} />
      <View style={styles.playbackControls}>
        <TouchableHighlight onPress={previous}>
          <NativeDrawable
            style={styles.playbackButtonIcon}
            source="nav-back"
            color={styles.playbackButtonIcon.color}
          />
        </TouchableHighlight>
        <TouchableHighlight onPress={read}>
          <NativeDrawable
            style={styles.playbackButtonIcon}
            source="nav-refresh"
            color={styles.playbackButtonIcon.color}
          />
        </TouchableHighlight>
        <TouchableHighlight onPress={next}>
          <NativeDrawable
            style={styles.playbackButtonIcon}
            source="nav-forward"
            color={styles.playbackButtonIcon.color}
          />
        </TouchableHighlight>
      </View>
    </View>
  );
};
