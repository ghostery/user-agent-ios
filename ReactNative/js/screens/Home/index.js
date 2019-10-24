import React from 'react';
import {
  NativeModules,
  SafeAreaView,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { FlatGrid } from 'react-native-super-grid';
import SpeedDial from '../../components/SpeedDial';
import News from './components/News';

const openSpeedDialLink = speedDial => NativeModules.BrowserActions.openLink(speedDial.url, "", false);
const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const styles = StyleSheet.create({
  container: {
    marginTop: 8,
  },
  header: {
    fontSize: 28,
    marginLeft: 12,
    marginRight: 12,
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
      >
        {dials.length > 0 && (
          <FlatGrid
            itemDimension={80}
            items={dials}
            scrollEnabled={false}
            renderItem={({ item: speedDial }) =>
              SpeedDial({
                speedDial,
                onPress: openSpeedDialLink,
              })
            }
          />
        )}
        <News newsModule={newsModule} />
      </ScrollView>
    </SafeAreaView>
  )
}