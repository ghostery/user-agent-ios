import React, { useCallback, useState, useMemo } from 'react';
import {
  NativeModules,
  View,
  StyleSheet,
  Image,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import Logo from '../../../components/Logo';
import { withTheme } from '../../../contexts/theme';

const getStyles = theme =>
  StyleSheet.create({
    container: {
      borderTopWidth: 1,
      borderTopColor: theme.separatorColor,
      paddingTop: 30,
      marginHorizontal: 20,
    },
    logoWrapper: {
      position: 'absolute',
      top: 10,
      left: 10,
    },
    image: {
      height: 150,
      flexShrink: 0,
      marginBottom: 10,
    },
    item: {
      marginBottom: 20,
    },
    separator: {
      marginTop: 20,
      backgroundColor: theme.separatorColor,
      height: 1,
    },
    title: {
      fontWeight: '600',
      marginBottom: 10,
      color: theme.textColor,
    },
    description: {
      flex: 1,
      color: theme.descriptionColor,
      fontSize: 12,
      marginBottom: 10,
    },
    domain: {
      color: theme.descriptionColor,
      fontSize: 12,
    },
    secondRow: {
      flexDirection: 'column',
    },
    breaking: {
      color: theme.redColor,
      paddingLeft: 10,
      fontSize: 12,
    },
    domainRow: {
      flexDirection: 'row',
    },
  });

const openLink = url => NativeModules.BrowserActions.openLink(url, '');

const deepEqualNews = (oldNews, news) => {
  return oldNews.every((_, index) => {
    try {
      return oldNews[index].url === news[index].url;
    } catch (e) {
      return false;
    }
  });
};

const useNews = newsModule => {
  const [data, setData] = useState([]);
  newsModule.action('getNews').then(({ news }) => {
    if (data.length === 0 || !deepEqualNews(data, news)) {
      setData(news);
    }
  });

  return data;
};

const HiddableImage = props => {
  const { style, source } = props;
  const [isHidden, setHidden] = useState(false, [source]);
  const hide = useCallback(() => setHidden(true), [setHidden]);
  const hiddenStyle = useMemo(
    () => (isHidden ? { height: 0, marginBottom: 0 } : null),
    [isHidden],
  );
  return (
    <Image
      // eslint-disable-next-line react/jsx-props-no-spreading
      {...props}
      style={[style, hiddenStyle]}
      source={{ uri: source }}
      onError={hide}
    />
  );
};

function News({ newsModule, isImagesEnabled, theme }) {
  const news = useNews(newsModule);

  const styles = useMemo(() => getStyles(theme), [theme]);

  if (news.length === 0) {
    return null;
  }
  /* eslint-disable prettier/prettier */
  return (
    <View style={styles.container}>
      {news.map(item => (
        <View
          style={styles.item}
          key={item.url}
        >
          <TouchableWithoutFeedback onPress={() => openLink(item.url)}>
            <View>
              {isImagesEnabled && item.imageUrl &&
                <View>
                  <HiddableImage style={styles.image} source={item.imageUrl} />
                  <View style={styles.logoWrapper}>
                    <Logo url={item.url} size={30} />
                  </View>
                </View>
              }
              <View style={styles.secondRow}>
                <Text style={styles.title} allowFontScaling={false}>
                  {item.title}
                </Text>
                <Text style={styles.description} allowFontScaling={false}>
                  {item.description}
                </Text>
                <View style={styles.domainRow} allowFontScaling={false}>
                  <Text style={styles.domain} allowFontScaling={false}>
                    {item.domain}
                  </Text>
                  {item.breaking_label && (
                    <Text style={styles.breaking} allowFontScaling={false}>
                      {NativeModules.LocaleConstants['ActivityStream.News.BreakingLabel']}
                    </Text>
                  )}
                </View>
              </View>
            </View>
          </TouchableWithoutFeedback>
          <View style={styles.separator} />
        </View>
      ))}
    </View>
  );
  /* eslint-enable prettier/prettier */
}

export default withTheme(News);