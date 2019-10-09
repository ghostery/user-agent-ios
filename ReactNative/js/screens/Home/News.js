import React, { useState, useEffect, useCallback } from 'react';
import {
  NativeModules,
  View,
  FlatList,
} from 'react-native';
import Header from '../../components/Header';
import ListItem from '../../components/ListItem';

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

export default function ({ newsModule }) {
  const news = useNews(newsModule);

  if (news.length === 0) {
    return null;
  }

  return (
    <View>
      <Header title={"News"} />
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
