import React, { useState, useEffect } from 'react';
import {
  NativeModules,
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

export default function Home() {
  const speedDials = useSpeedDials();
  return (
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
  )
}