import React, { useCallback, useMemo } from 'react';
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
  buttonContainer: {
    flex: 2,
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
    flex: 2,
    flexDirection: 'row',
    justifyContent: 'flex-end'
  },
  downIconWrapper: {
    flex: 0,
  },
  breakingNewsDot: {
    height: 7,
    width: 7,
    borderRadius: 7,
    backgroundColor: theme.redColor,
  },
});

export default ({
  scrollToNews,
  news,
  edition,
  telemetry,
}: {
  scrollToNews: any;
  news: News[];
  edition: String;
  telemetry: any;
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
    telemetry.push(
      {
        component: 'home',
        view: 'news-toolbar',
        target: 'read',
        action: 'click',
      },
      'ui.metric.interaction',
    );
    NativeModules.ReadTheNews.read(news, language);
  }, [news, edition, telemetry]);
  const hasBreakingNews = useMemo(
    () => news.some(article => article.breaking_label),
    [news],
  );
  const scrollToNewsTitle = useCallback(() => {
    telemetry.push(
      {
        component: 'home',
        view: 'news-toolbar',
        target: 'title',
        action: 'click',
      },
      'ui.metric.interaction',
    );
    scrollToNews();
  }, [scrollToNews, telemetry]);
  const scrollToNewsDownIcon = useCallback(() => {
    telemetry.push(
      {
        component: 'home',
        view: 'news-toolbar',
        target: 'down-icon',
        action: 'click',
      },
      'ui.metric.interaction',
    );
    scrollToNews();
  }, [scrollToNews, telemetry]);
  return (
    <View style={styles.wrapper}>
      <TouchableHighlight
        onPress={scrollToNewsTitle}
        style={styles.buttonContainer}
      >
        <View style={styles.button}>
          <Text style={styles.buttonText}>
            {t('ActivityStream.News.Header')}
          </Text>
          {hasBreakingNews && <View style={styles.breakingNewsDot} />}
        </View>
      </TouchableHighlight>
      <TouchableHighlight
        onPress={scrollToNewsDownIcon}
        style={styles.downIconWrapper}
      >
        <NativeDrawable
          style={styles.buttonIcon}
          source="arrow-down"
          color={styles.buttonIcon.color}
        />
      </TouchableHighlight>
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
