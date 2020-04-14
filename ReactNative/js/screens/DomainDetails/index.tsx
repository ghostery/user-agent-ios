import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { NativeModules, View } from 'react-native';
import { GiftedChat } from 'react-native-gifted-chat';
import { URL } from '@cliqz/url-parser';
import { useStyles } from '../../contexts/theme';
import ToolbarArea from '../../components/ToolbarArea';
import KeyboardSpacer from './components/KeyboardSpacer';

const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();
const startSearch = (query: String) =>
  NativeModules.BrowserActions.startSearch(query);

const getStyle = (theme: {
  backgroundColor: string;
  fontSizeLarge: number;
  fontSizeSmall: number;
  textColor: string;
  descriptionColor: string;
  brandTintColor: string;
  separatorColor: string;
}) => ({
  container: {
    backgroundColor: theme.backgroundColor,
    flex: 1,
  },
  url: {
    color: 'rgb(26, 13, 171)',
    textDecorationLine: 'underline',
  },
});

interface Visit {
  url: string;
  title: string;
  visitedAt: number;
}

const PAGE_SIZE = 15;

const useVisits = (domain: string): [Visit[], any, any] => {
  const [visits, setVisits] = useState<Visit[]>([]);
  const [page, setPage] = useState(0);
  const [lastLoadedPage, setLastLoadedPage] = useState(-1);

  const loadMore = () => {
    if (page === lastLoadedPage) {
      setPage(page + 1);
    }
  };

  useEffect(() => {
    const fetchVisits = async () => {
      let data: Visit[] = [];
      try {
        data = await NativeModules.History.getVisits(
          domain,
          PAGE_SIZE,
          page * PAGE_SIZE,
        );
      } catch (e) {
        // In case of the problems with db
      }
      setVisits(prevState => {
        return [...prevState, ...data];
      });
      if (data.length > 0) {
        setLastLoadedPage(page);
      }
    };

    if (page !== lastLoadedPage) {
      fetchVisits();
    }
  }, [page, domain, lastLoadedPage, setVisits]);

  const removeVisit = (visitedAt: number) => {
    setVisits(prevState => {
      const visitToRemoveIndex = prevState.findIndex(
        visit => visit.visitedAt === visitedAt,
      );

      return [
        ...prevState.slice(0, visitToRemoveIndex),
        ...prevState.slice(visitToRemoveIndex + 1),
      ];
    });
  };

  return [visits, loadMore, removeVisit];
};

const user = {
  _id: -1,
};

const searchUser = {
  _id: 1,
};

export default ({
  domain,
  toolbarHeight,
}: {
  domain: string;
  toolbarHeight: number;
}) => {
  const styles = useStyles(getStyle);

  const [visits, loadMore, removeVisit] = useVisits(domain);
  const history = useMemo(
    () =>
      visits
        .map(visit => {
          const url = new URL(visit.url);
          const isSearch = url.scheme === 'search';
          if (isSearch && url.searchParams.has('redirected')) {
            return null;
          }
          return {
            _id: visit.visitedAt,
            url: visit.url,
            text: isSearch
              ? `search://${url.searchParams.get('query') || ''}`
              : [visit.title, visit.url].join('\n'),
            createdAt: visit.visitedAt / 1000,
            user: isSearch ? searchUser : user,
          };
        })
        .filter(Boolean),
    [visits],
  );

  function handleUrlPress(url: string) {
    NativeModules.BrowserActions.openLink(url, '');
  }

  async function onLongPress(context: any, message: any) {
    const { action } = await NativeModules.ContextMenu.visit(
      message.url,
      message.text.split('\n')[0],
      true,
    );
    if (action === 'deleteFromHistory') {
      const messages = history.filter(item => item.url === message.url);
      messages.forEach((m: any) => {
        removeVisit(m.createdAt * 1000);
      });
    }
  }

  const onLongPressOnUrl = (url: string) => {
    const message = history.find(m => m.url === url);
    if (!message) {
      return;
    }
    onLongPress(null, message);
  };

  const parsePatterns = () => [
    {
      type: 'url',
      style: styles.url,
      onPress: handleUrlPress,
      onLongPress: onLongPressOnUrl,
    },
    {
      pattern: /search:\/\/.*/i,
      renderText(matchingString: String) {
        return matchingString.split('://')[1];
      },
      onLongPress: () => {},
      onPress: (matchingString: String) => {
        startSearch(matchingString.split('://')[1]);
      },
    },
  ];

  const renderEmpty = () => null;

  return (
    <View style={styles.container}>
      <GiftedChat
        messages={history}
        renderInputToolbar={renderEmpty}
        renderComposer={renderEmpty}
        renderLoading={renderEmpty}
        minInputToolbarHeight={0}
        onLongPress={onLongPress}
        parsePatterns={parsePatterns}
        listViewProps={{
          onEndReached: loadMore,
          onEndReachedThreshold: 0.5,
          initialNumToRender: PAGE_SIZE,
          onScroll: hideKeyboard,
        }}
        user={searchUser}
      />
      <KeyboardSpacer />
      <ToolbarArea height={toolbarHeight} />
    </View>
  );
};
