import React, { useState, useEffect } from 'react';
import {
  NativeModules,
  View,
  Text,
  StyleSheet,
} from 'react-native';
import { FlatGrid } from 'react-native-super-grid';
import SpeedDial from '../components/SpeedDial';

export const useSpeedDials = () => {
  const [data, setData] = useState([]);
  async function fetchLocations() {
    const speedDials = await NativeModules.History.getTopSites();
    setData(speedDials);
  }

  useEffect(() => {
    fetchLocations();
  }, []);

  return data;
}

const openSpeedDialLink = speedDial => NativeModules.BrowserActions.openLink(speedDial.url, "", false);

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

export default function Home() {
  const speedDials = useSpeedDials();
  return (
    <View style={styles.container}>
      <Text style={styles.header}>
        { NativeModules.LocaleConstants['ActivityStream.TopSites.SectionTitle'] }
      </Text>
      <FlatGrid
        itemDimension={80}
        items={speedDials}
        renderItem={({ item: speedDial }) =>
          SpeedDial({
            speedDial,
            onPress: openSpeedDialLink,
          })
        }
      />
    </View>
  )
}