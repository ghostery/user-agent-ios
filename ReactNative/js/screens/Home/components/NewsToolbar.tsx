import React, { useCallback } from 'react';
import { View, Text, NativeModules, TouchableHighlight } from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';
import { useStyles } from '../../../contexts/theme';
import t from '../../../services/i18n';
import { News } from '../hooks/news';

const getStyles = (theme: any) => ({
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
    textTransform: 'uppercase',
  },
  buttonIcon: {
    color: theme.brandTintColor,
    height: 20,
    width: 20,
  },
  playbackButtonIcon: {
    color: '#ffffff',
    height: 20,
    width: 20,
    alignSelf: 'center',
  },
  spacer: {
    flex: 1,
    alignItems: 'center',
  },
  playbackControls: {
    flexDirection: 'row',
  },
  downIconWrapper: {
    position: 'absolute',
    width: '100%',
    alignItems: 'center',
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
  const styles = useStyles(getStyles);
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
  return (
    <View style={styles.wrapper}>
      <View style={styles.downIconWrapper}>
        <NativeDrawable
          style={styles.buttonIcon}
          source="arrow-down"
          color={styles.buttonIcon.color}
        />
      </View>
      <TouchableHighlight onPress={scrollToNews}>
        <View style={styles.button}>
          <Text style={styles.buttonText}>
            {t('ActivityStream.News.Header')}
          </Text>
        </View>
      </TouchableHighlight>
      <View style={styles.spacer} />
      <View style={styles.playbackControls}>
        <TouchableHighlight onPress={read}>
          <NativeDrawable
            style={styles.playbackButtonIcon}
            source="play-pause"
            color={styles.playbackButtonIcon.color}
          />
        </TouchableHighlight>
      </View>
    </View>
  );
};
