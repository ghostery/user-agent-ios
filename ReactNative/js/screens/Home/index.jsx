import React, { useMemo } from 'react';
import {
  Dimensions,
  NativeModules,
  ScrollView,
  StyleSheet,
  View,
  Image,
} from 'react-native';
import { parse } from 'tldts';
import ToolbarArea from '../../components/ToolbarArea';
import News from './components/News';
import SpeedDialRow from './components/SpeedDialsRow';
import UrlBar from './components/UrlBar';
import Background from './components/Background';

const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const getStyles = () =>
  StyleSheet.create({
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
    newsWrapper: {
      flex: 1,
      width: Math.min(
        Dimensions.get('window').width,
        Dimensions.get('window').height,
      ),
      alignSelf: 'center',
      paddingHorizontal: 20,
    },
    speedDialsContainer: {
      marginBottom: 25,
      width: '100%',
    },
    logoWrapper: {
      marginTop: 40 - 8,
      marginBottom: 30,
    },
    logo: {
      height: 65,
    },
    urlBarWrapper: {
      paddingHorizontal: 10,
      marginBottom: 30,
      width: '100%',
    },
    footer: {
      height: 80,
    },
  });

export default function Home({
  speedDials,
  pinnedSites,
  newsModule,
  isNewsEnabled,
  isNewsImagesEnabled,
  height,
  toolbarHeight,
}) {
  const styles = getStyles();
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

  return (
    <ScrollView
      style={styles.container}
      onScroll={hideKeyboard}
      scrollEventThrottle={1}
      contentContainerStyle={styles.contentContainer}
    >
      <Background height={height}>
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
        <ToolbarArea height={toolbarHeight} />
      </Background>
      {isNewsEnabled && (
        <View style={styles.newsWrapper}>
          <News newsModule={newsModule} isImagesEnabled={isNewsImagesEnabled} />
        </View>
      )}
      <ToolbarArea height={toolbarHeight} />
    </ScrollView>
  );
}
