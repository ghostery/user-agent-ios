import React, { useCallback, useState, useMemo, useContext } from 'react';
import {
  NativeModules,
  View,
  StyleSheet,
  Image,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import ListItem from '../../../components/ListItem';
import ThemeContext from '../../../contexts/theme';

const getStyles = theme =>
  StyleSheet.create({
    container: {
      borderTopWidth: 1,
      borderTopColor: theme.separatorColor,
      paddingTop: 30,
    },
    image: {
      height: 100,
      width: 150,
      flexShrink: 0,
      marginLeft: 10,
    },
    item: {
      marginBottom: 20,
    },
    separator: {
      marginTop: 20,
      backgroundColor: theme.separatorColor,
      height: 1,
    },
    description: {
      flex: 1,
      color: theme.textColor,
      fontSize: 12,
    },
    secondRow: {
      marginTop: 5,
      flex: 1,
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

const noop = () => {};

export default function News({ newsModule, isImagesEnabled }) {
  const theme = useContext(ThemeContext);
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
              <ListItem
                url={item.url}
                title={item.title}
                displayUrl={item.domain}
                label={item.breaking_label ? NativeModules.LocaleConstants['ActivityStream.News.BreakingLabel'] : null}
                onPress={noop}
              />
              <View style={styles.secondRow}>
                <Text style={styles.description} allowFontScaling={false}>
                  {item.description}
                </Text>
                {isImagesEnabled && item.imageUrl &&
                  <HiddableImage style={styles.image} source={item.imageUrl} />
                }
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
