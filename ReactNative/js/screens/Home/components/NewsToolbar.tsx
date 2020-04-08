import React, { useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  NativeModules,
  TouchableHighlight,
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
  edition,
}: {
  scrollToNews: any;
  news: News[];
  edition: String;
}) => {
  const read = useCallback(() => {
    let language;
    switch (edition) {
      case 'us':
      case 'de-tr-en':
      case 'intl':
        language = 'en-US';
        break;
      case 'gb':
        language = 'en-GB';
        break;
      case 'es':
        language = 'es-ES';
        break;
      case 'it':
        language = 'it-IT';
        break;
      case 'fr':
        language = 'fr-CA';
        break;
      case 'de':
      default:
        language = 'de-DE';
    }
    NativeModules.ReadTheNews.read(news, language);
  }, [news, edition]);
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
