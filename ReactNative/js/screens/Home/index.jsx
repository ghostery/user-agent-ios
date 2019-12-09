/* eslint-disable react/prop-types */
import React from 'react';
import {
  NativeModules,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  View,
  Image,
} from 'react-native';
import { parse } from 'tldts';
import SpeedDial from '../../components/SpeedDial';
import News from './components/News';

const openSpeedDialLink = speedDial =>
  NativeModules.BrowserActions.openLink(speedDial.url, '', false);
const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const styles = StyleSheet.create({
  container: {
    marginTop: 0,
  },
  contentContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  wrapper: {
    flex: 1,
    maxWidth: 414,
    flexDirection: 'column',
    justifyContent: 'space-between',
  },
  header: {
    fontSize: 28,
    marginLeft: 12,
    marginRight: 12,
  },
  speedDialsContainer: {
    marginBottom: 25,
  },
  speedDials: {
    marginTop: 0,
    marginBottom: 0,
    padding: 0,
    flexDirection: 'row',
    flex: 1,
    flexWrap: 'wrap',
    alignItems: 'center',
    alignSelf: 'center',
    width: '100%',
    justifyContent: 'space-evenly',
  },
  speedDial: {
    flex: 0,
    marginVertical: 10,
    width: 80,
  },
  logoWrapper: {
    flex: 1,
    marginTop: 40 - 8,
    marginBottom: 30,
  },
  logo: {
    height: 65,
  },
});

const EmptySpeedDial = () => <View style={styles.speedDial} />;

const SpeedDialRow = ({ dials, limit = 4 }) => {
  if (dials.length === 0) {
    return null;
  }
  const emptyCount = limit - dials.length < 0 ? 0 : limit - dials.length;
  const allDials = [
    ...dials.map(dial => (
      <SpeedDial
        key={dial.url}
        style={styles.speedDial}
        speedDial={dial}
        onPress={openSpeedDialLink}
      />
    )),
    Array(emptyCount)
      .fill(null)
      // eslint-disable-next-line react/no-array-index-key
      .map((_, i) => <EmptySpeedDial key={i} />),
  ];

  return <View style={styles.speedDials}>{allDials}</View>;
};

export default function Home({
  speedDials,
  pinnedSites,
  newsModule,
  isNewsEnabled,
  isNewsImagesEnabled,
}) {
  const pinnedDomains = new Set([...pinnedSites.map(s => parse(s.url).domain)]);
  const dials = [
    ...pinnedSites.map(dial => ({ ...dial, pinned: true })),
    ...speedDials.filter(dial => !pinnedDomains.has(parse(dial.url).domain)),
  ].slice(0, 8);
  const firstRow = dials.slice(0, 4);
  const secondRow = dials.slice(4, 8);

  return (
    <SafeAreaView>
      <ScrollView
        style={styles.container}
        onScroll={hideKeyboard}
        contentContainerStyle={styles.contentContainer}
      >
        <View style={styles.wrapper}>
          <View style={styles.logoWrapper}>
            <Image
              style={styles.logo}
              source={{ uri: 'logo' }}
              resizeMode="contain"
            />
          </View>
          <View style={styles.speedDialsContainer}>
            <SpeedDialRow dials={firstRow} />
            <SpeedDialRow dials={secondRow} />
          </View>
          {isNewsEnabled && (
            <News
              newsModule={newsModule}
              isImagesEnabled={isNewsImagesEnabled}
            />
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
