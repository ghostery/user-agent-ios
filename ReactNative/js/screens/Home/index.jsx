import React, { useMemo, useRef, useCallback } from 'react';
import {
  Dimensions,
  NativeModules,
  ScrollView,
  StyleSheet,
  View,
  Image,
  findNodeHandle,
} from 'react-native';
import { parse } from 'tldts';
import ToolbarArea from '../../components/ToolbarArea';
import News from './components/News';
import SpeedDialRow from './components/SpeedDialsRow';
import UrlBar from './components/UrlBar';
import Background from './components/Background';
import NewsToolbar from './components/NewsToolbar';
import useNews from './hooks/news';

const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const getStyles = toolbarHeight => {
  const maxWidth = Math.min(
    Dimensions.get('window').width,
    Dimensions.get('window').height,
  );

  const logoHeight = 47;
  const newsToolbarHeight = 50;

  return StyleSheet.create({
    safeArea: {
      flex: 1,
    },
    container: {
      marginTop: 0,
    },
    contentContainer: {
      flexDirection: 'column',
      alignItems: 'flex-start',
      justifyContent: 'center',
    },
    wrapper: {
      flex: 1,
      maxWidth: 414,
      alignSelf: 'center',
      flexDirection: 'column',
      justifyContent: 'space-evenly',
    },
    logoWrapper: {
      paddingTop: newsToolbarHeight + toolbarHeight,
      justifyContent: 'flex-end',
      flexGrow: 1,
    },
    logo: {
      height: logoHeight,
    },
    urlBarWrapper: {
      paddingHorizontal: 10,
      width: '100%',
      paddingVertical: logoHeight,
    },
    speedDialsContainer: {
      width: '100%',
      flexGrow: 1,
    },
    newsToolbarWrapper: {
      width: maxWidth,
      paddingHorizontal: 20,
      alignSelf: 'center',
      height: newsToolbarHeight,
      justifyContent: 'center',
      backgroundColor: '#00000055',
    },
    newsToolbarWrapperInternal: {
      width: maxWidth,
      alignSelf: 'center',
      paddingHorizontal: 15,
    },
    newsWrapper: {
      flex: 1,
      width: 360,
      alignSelf: 'center',
      paddingHorizontal: 20,
    },
  });
};

export default function Home({
  speedDials,
  pinnedSites,
  newsModule,
  telemetry,
  isNewsEnabled,
  isNewsImagesEnabled,
  height,
  toolbarHeight,
}) {
  const [news, edition] = useNews(newsModule);
  const scrollViewElement = useRef(null);
  const newsElement = useRef(null);
  const styles = getStyles(toolbarHeight);
  const [firstRow, secondRow] = useMemo(() => {
    const pinnedDomains = new Set([
      ...pinnedSites.map(s => parse(s.url).domain),
    ]);
    const dials = [
      ...pinnedSites.map(dial => ({ ...dial, pinned: true })),
      ...speedDials.filter(dial => !pinnedDomains.has(parse(dial.url).domain)),
    ].slice(0, 8);
    return [dials.slice(0, 4), dials.slice(4, 8)];
  }, [pinnedSites, speedDials]);

  const scrollToNews = useCallback(() => {
    if (!scrollViewElement.current || !newsElement.current) {
      return;
    }
    scrollViewElement.current.scrollTo({ x: 0, y: 100 });
    newsElement.current.measureLayout(
      findNodeHandle(scrollViewElement.current),
      (x, y) => {
        scrollViewElement.current.scrollTo({ x, y });
      },
    );
  }, [scrollViewElement]);
  const onScroll = useCallback(() => {
    telemetry.push(
      {
        component: 'home',
        action: 'scroll',
      },
      'ui.metric.interaction',
    );
    hideKeyboard();
  }, [telemetry]);

  return (
    <ScrollView
      ref={scrollViewElement}
      style={styles.container}
      onScroll={onScroll}
      scrollEventThrottle={0}
      contentContainerStyle={styles.contentContainer}
      scrollEnabled={isNewsEnabled}
    >
      <Background height={height - toolbarHeight}>
        <View style={styles.wrapper}>
          <View style={styles.logoWrapper}>
            <Image
              style={styles.logo}
              source={{ uri: 'logo' }}
              resizeMode="contain"
            />
          </View>

          <View style={styles.urlBarWrapper}>
            <UrlBar />
          </View>

          <View style={styles.speedDialsContainer}>
            <SpeedDialRow dials={firstRow} />
            <SpeedDialRow dials={secondRow} />
          </View>
        </View>

        {isNewsEnabled && (
          <View style={styles.newsToolbarWrapper}>
            <View style={styles.newsToolbarWrapperInternal}>
              <NewsToolbar
                news={news}
                scrollToNews={scrollToNews}
                edition={edition}
                telemetry={telemetry}
              />
            </View>
          </View>
        )}
      </Background>
      {isNewsEnabled && (
        <View style={styles.newsWrapper} ref={newsElement}>
          <News
            news={news}
            isImagesEnabled={isNewsImagesEnabled}
            telemetry={telemetry}
          />
        </View>
      )}
      <ToolbarArea height={toolbarHeight} />
    </ScrollView>
  );
}
