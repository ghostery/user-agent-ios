import React, { useContext } from 'react';
import {
  NativeModules,
  ScrollView,
  StyleSheet,
  View,
  Image,
  ImageBackground,
  Text,
} from 'react-native';
import { parse } from 'tldts';
import SpeedDial from '../../components/SpeedDial';
import News from './components/News';
import NativeDrawable from '../../components/NativeDrawable';
import ThemeContext from '../../contexts/theme';

const openSpeedDialLink = speedDial =>
  NativeModules.BrowserActions.openLink(speedDial.url, '');
const longPressSpeedDial = speedDial =>
  NativeModules.ContextMenu.speedDial(speedDial.url, speedDial.pinned || false);
const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const styles = StyleSheet.create({
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
    width: 414,
    alignSelf: 'center',
    flexDirection: 'column',
  },
  header: {
    fontSize: 28,
    marginLeft: 12,
    marginRight: 12,
  },
  speedDialsContainer: {
    marginBottom: 25,
    width: '100%',
  },
  speedDials: {
    marginTop: 0,
    marginBottom: 0,
    padding: 0,
    flexDirection: 'row',
    flex: 1,
    width: '100%',
    justifyContent: 'space-evenly',
  },
  speedDial: {
    flex: 0,
    marginVertical: 10,
    width: 80,
  },
  logoWrapper: {
    marginTop: 40 - 8,
    marginBottom: 30,
    width: '100%',
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
        styles={{
          container: styles.speedDial,
        }}
        speedDial={dial}
        onPress={openSpeedDialLink}
        onLongPress={longPressSpeedDial}
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
  height,
}) {
  const theme = useContext(ThemeContext);
  const pinnedDomains = new Set([...pinnedSites.map(s => parse(s.url).domain)]);
  const dials = [
    ...pinnedSites.map(dial => ({ ...dial, pinned: true })),
    ...speedDials.filter(dial => !pinnedDomains.has(parse(dial.url).domain)),
  ].slice(0, 8);
  const firstRow = dials.slice(0, 4);
  const secondRow = dials.slice(4, 8);

  return (
    <View style={styles.safeArea}>
      <ScrollView
        style={styles.container}
        onScroll={hideKeyboard}
        scrollEventThrottle={1}
        contentContainerStyle={styles.contentContainer}
      >
        <ImageBackground
          source={{url: 'https://cdn.cliqz.com/serp/background/simon-rae-9teLSxO0-Ac-unsplash_mobile.jpg'}}
          style={{width: '100%', minHeight: height, flex: 1 }}
        >
          <View style={[styles.wrapper, { justifyContent: 'space-evenly'}]}>
            <View style={styles.logoWrapper}>
              <Image
                style={styles.logo}
                source={{ uri: 'logo' }}
                resizeMode="contain"
              />
            </View>
            <View style={{ paddingHorizontal: 10, marginBottom: 30, width: '100%' }}>
              <View style={{ height: 40, widht: '100%', paddingHorizontal: 20, borderRadius: 40, backgroundColor: 'white', flexDirection: 'row'}}>
                <Text style={{ alignSelf: 'center', flexGrow: 1, color: theme.descriptionColor }}>Search Privately</Text>
                <View style={{ justifySelf: 'flex-end', width: 20, height: '100%'}}>
                  <NativeDrawable
                    style={{ height: '100%' }}
                    color={theme.brandColor}
                    source="search"
                  />
                </View>
              </View>
            </View>

            <View style={styles.speedDialsContainer}>
              <SpeedDialRow dials={firstRow} />
              <SpeedDialRow dials={secondRow} />
            </View>
          </View>
        </ImageBackground>
        {isNewsEnabled && (
          <View style={styles.wrapper}>
            <News
              newsModule={newsModule}
              isImagesEnabled={isNewsImagesEnabled}
            />
          </View>
        )}
      </ScrollView>
    </View>
  );
}
