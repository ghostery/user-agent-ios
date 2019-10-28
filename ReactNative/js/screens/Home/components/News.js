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
    paddingTop: 25,
  },
  image: {
    height: 200,
    marginLeft: 10,
    marginRight: 10,
  },
  item: {
    marginBottom: 25,
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

  const styles = useMemo(() => getStyles(theme), theme);

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
            <TouchableWithoutFeedback
              onPress={() => openLink(item.url)}
            >
              <Image
                style={styles.image}
                source={{uri: item.imageUrl}}
              />
            </TouchableWithoutFeedback>
            <ListItem
              url={item.url}
              title={item.title}
              onPress={() => openLink(item.url)}
            />
          </View>
        }
      />
    </View>
  );
}
