import { useState, useEffect } from 'react';
import { Settings } from 'react-native';

export interface News {
  url: string;
  breaking_label: boolean;
}

export default (newsModule: any) => {
  const [data, setData] = useState<News[]>([]);
  const [edition, setEdition] = useState('de');
  const [updateCounter, setUpdateCounter] = useState(0);
  const newsSettings = Settings.get('news') || {};

  if (
    updateCounter > 0 &&
    newsSettings.lastUpdate < Date.now() - 1000 * 60 * 20
  ) {
    Settings.set({
      news: {
        lastUpdate: Date.now(),
      },
    });
    setUpdateCounter(updateCounter + 1);
  }

  useEffect(() => {
    const fetchNews = async () => {
      try {
        const [{ news }, lang]: [{ news: News[] }, string] = await Promise.all([
          newsModule.action('getNews'),
          newsModule.action('getLanguage'),
        ]);
        setData(news);
        setEdition(lang);
      } catch (e) {
        //
      }
    };
    fetchNews();
  }, [updateCounter, newsModule]);

  return [data, edition];
};
