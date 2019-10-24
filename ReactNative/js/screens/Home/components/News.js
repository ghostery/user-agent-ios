import React, { useState, useEffect, useMemo, useContext } from 'react';
import {
  NativeModules,
  View,
  FlatList,
  StyleSheet
} from 'react-native';
import ListItem from '../../../components/ListItem';
import ThemeContext from '../../../contexts/theme';

const getStyles = (theme) => StyleSheet.create({
  container: {
    borderTopWidth: 1,
    borderTopColor: theme.separatorColor,
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
          <ListItem
            url={item.url}
            title={item.title}
            onPress={() => openLink(item.url)}
          />
        }
      />
    </View>
  );
}
