import React from 'react';
import {
  NativeModules,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';
import SpeedDial from '../../components/SpeedDial';
import News from './components/News';
import NativeDrawable, { normalizeUrl } from 'browser-core-user-agent-ios/build/modules/mobile-cards/components/custom/NativeDrawable';

const openSpeedDialLink = speedDial => NativeModules.BrowserActions.openLink(speedDial.url, "", false);
const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const styles = StyleSheet.create({
  container: {
    marginTop: 0,
  },
  contentContainer: {
    flexDirection:'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  wrapper: {
    flex:1,
    maxWidth: 414,
    flexDirection:'column',
    justifyContent:'space-between',
  },
  header: {
    fontSize: 28,
    marginLeft: 12,
    marginRight: 12,
  },
  speedDials: {
    marginTop: 0,
    marginBottom: 25,
    padding: 0,
    flexDirection: 'row',
    flex: 1,
    flexWrap: 'wrap',
    alignItems: 'center',
    alignSelf: 'center',
    width: (70+10+10)*4,
  },
  speedDial: {
    flex: 0,
    marginHorizontal: 5,
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

export default function Home({ speedDials, pinnedSites, newsModule }) {
  const dials = [
    ...pinnedSites.map(dial => ({ ...dial, pinned: true })),
    ...speedDials,
  ].slice(0, 8)

  return (
    <SafeAreaView>
      <ScrollView
        style={styles.container}
        onScroll={hideKeyboard}
        contentContainerStyle={styles.contentContainer}
      >
        <View style={styles.wrapper}>
          <View style={styles.logoWrapper}>
            <NativeDrawable
              style={styles.logo}
              source={normalizeUrl('logo.svg')}
            />
          </View>
          {dials.length > 0 && (
            <View
              style={styles.speedDials}
            >
              {dials.map(dial =>
                <SpeedDial
                  key={dial.url}
                  style={styles.speedDial}
                  speedDial={dial}
                  onPress={openSpeedDialLink}
                />
              )}
            </View>
          )}
          <News newsModule={newsModule} />
        </View>
      </ScrollView>
    </SafeAreaView>
  )
}