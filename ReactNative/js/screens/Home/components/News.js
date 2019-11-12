import React, { useState, useEffect, useMemo, useContext } from 'react';
import {
  NativeModules,
  View,
  FlatList,
  StyleSheet,
  Image,
  TouchableWithoutFeedback,
} from 'react-native';
import ListItem from '../../../components/ListItem';
import ThemeContext from '../../../contexts/theme';

const getStyles = (theme) => StyleSheet.create({
  container: {
    borderTopWidth: 1,
    borderTopColor: theme.separatorColor,
    paddingTop: 30,
  },
  image: {
    height: 200,
    marginBottom: 10,
  },
  item: {
    marginLeft: 20,
    marginRight: 20,
    marginTop: 0,
    marginBottom: 20,
  },
  separator: {
    marginTop: 20,
    backgroundColor: theme.separatorColor,
    height: 1,
  },
});

const openLink = url => NativeModules.BrowserActions.openLink(url, "", false);

const useNews = (newsModule) => {
  const [data, setData] = useState([]);

  async function getNews() {
    const { news } = await newsModule.action('getNews');
    setData(news);
  }

  useEffect(() => {
    getNews();
  }, []);

  return data;
};

export default function News({ newsModule }) {
  const theme = useContext(ThemeContext);
  const news = useNews(newsModule);

  const styles = useMemo(() => getStyles(theme), [theme.mode]);

  if (news.length === 0) {
    return null;
  }

  return (
    <View style={styles.container}>
      <FlatList
        scrollEnabled={false}
        data={news}
        keyExtractor={(item) => item.url}
        renderItem={({ item }) =>
          <View style={styles.item}>
            {item.imageUrl &&
              <TouchableWithoutFeedback
                onPress={() => openLink(item.url)}
              >

                <Image
                  style={styles.image}
                  source={{uri: item.imageUrl}}
                />
              </TouchableWithoutFeedback>
            }
            <ListItem
              url={item.url}
              title={item.title}
              label={item.breaking_label ? NativeModules.LocaleConstants['ActivityStream.News.BreakingLabel'] : null}
              onPress={() => openLink(item.url)}
            />
            <View style={styles.separator} />
          </View>
        }
      />
    </View>
  );
}
