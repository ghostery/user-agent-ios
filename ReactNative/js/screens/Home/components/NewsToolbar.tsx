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
  left: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  center: {
    flex: 0,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  right: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  controlWrapper: {
    alignItems: 'center',
    flexDirection: 'row',
    padding: 10,
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
      <View style={styles.left}>
        <TouchableHighlight onPress={scrollToNewsTitle}>
          <View style={styles.controlWrapper}>
            <Text style={styles.buttonText} allowFontScaling={false}>
              {t('ActivityStream.News.Header')}
            </Text>
            {hasBreakingNews && <View style={styles.breakingNewsDot} />}
          </View>
        </TouchableHighlight>
      </View>

      <View style={styles.center}>
        <TouchableHighlight onPress={scrollToNewsDownIcon}>
          <View style={styles.controlWrapper}>
            <NativeDrawable
              style={styles.buttonIcon}
              source="arrow-down"
              color={styles.buttonIcon.color}
            />
          </View>
        </TouchableHighlight>
      </View>

      <View style={styles.right}>
        <TouchableHighlight onPress={read}>
          <View style={styles.controlWrapper}>
            <NativeDrawable
              style={styles.playbackButtonIcon}
              source="play-pause"
              color={styles.playbackButtonIcon.color}
            />
          </View>
        </TouchableHighlight>
      </View>
    </View>
  );
};
