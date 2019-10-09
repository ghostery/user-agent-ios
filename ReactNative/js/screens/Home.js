import React from 'react';
import {
  NativeModules,
  View,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { FlatGrid } from 'react-native-super-grid';
import SpeedDial from '../components/SpeedDial';
import Header from '../components/Header';
import News from './Home/News';

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

const Section = ({ title, sites }) => {
  return (
    <View>
      <Header title={title} />
      <FlatGrid
        itemDimension={80}
        items={sites}
        scrollEnabled={false}
        renderItem={({ item: speedDial }) =>
          SpeedDial({
            speedDial,
            onPress: openSpeedDialLink,
          })
        }
      />
    </View>
  );
}

export default function Home({ speedDials, pinnedSites, newsModule }) {
  return (
    <ScrollView
      style={styles.container}
      onScroll={hideKeyboard}
    >
      {pinnedSites.length > 0 && (
        <Section
          title={NativeModules.LocaleConstants['ActivityStream.PinnedSites.SectionTitle']}
          sites={pinnedSites}
        />
      )}
      {speedDials.length > 0 && (
        <Section
          title={NativeModules.LocaleConstants['ActivityStream.TopSites.SectionTitle']}
          sites={speedDials}
        />
      )}
      <News newsModule={newsModule} />
    </ScrollView>
  )
}