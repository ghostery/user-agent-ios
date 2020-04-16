import { useState } from 'react';

export interface News {
  url: string;
  breaking_label: boolean;
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
  const [edition, setEdition] = useState('de');
  newsModule.action('getNews').then(async ({ news }: { news: News[] }) => {
    const lang = await newsModule.action('getLanguage');
    if (data.length === 0 || !deepEqualNews(data, news)) {
      setData(news);
      setEdition(lang);
    }
  });

  return [data, edition];
};
