import { useState } from 'react';

export interface News {
  url: string;
}

const deepEqualNews = (oldNews: News[], news: News[]) => {
  return oldNews.every((_, index) => {
    try {
      return oldNews[index].url === news[index].url;
    } catch (e) {
      return false;
    }
  });
};

export default (newsModule: any) => {
  const [data, setData] = useState<News[]>([]);
  newsModule.action('getNews').then(({ news }: { news: News[] }) => {
    if (data.length === 0 || !deepEqualNews(data, news)) {
      setData(news);
    }
  });

  return data;
};
