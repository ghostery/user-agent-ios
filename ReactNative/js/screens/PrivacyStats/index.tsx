import React, { useState, useCallback, useEffect } from 'react';
import { Text, View } from 'react-native';
import NativeDrawable from '../../components/NativeDrawable';
import { useStyles } from '../../contexts/theme';
import t from '../../services/i18n';

const getStyle = (theme: {
  fontSizeLarge: number;
  textColor: string;
  descriptionColor: string;
}) => ({
  container: {
    height: 100,
  },
  icon: {
    height: 24,
    width: 24,
    marginRight: 16,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  title: {
    flex: 1,
    fontSize: theme.fontSizeLarge,
    color: theme.textColor,
  },
  statsWrapper: {
    marginTop: 5,
    flexDirection: 'row',
    marginLeft: 40,
  },
  statsContainer: {
    width: 100,
    flexDirection: 'column',
    marginRight: 30,
  },
  statsCount: {
    color: theme.textColor,
    fontSize: 30,
    fontWeight: '500',
  },
  statsTitle: {
    color: theme.descriptionColor,
  },
});

interface BrowserCoreModule {
  action(moduleName: string, args: any[]): any;
}

const useStats = (insightsModule: BrowserCoreModule) => {
  const [stats, setStats] = useState({
    adsBlocked: 0,
    trackersBlocked: 0,
  });
  useEffect(() => {
    insightsModule
      .action('getDashboardStats', [''])
      .then(
        ({
          adsBlocked,
          trackersBlocked,
        }: {
          adsBlocked: number;
          trackersBlocked: number;
        }) => {
          setStats({
            adsBlocked,
            trackersBlocked,
          });
        },
      );
  }, [insightsModule]);
  return stats;
};

export default ({ insightsModule }: { insightsModule: BrowserCoreModule }) => {
  const styles = useStyles(getStyle);

  const Stats = useCallback(
    ({ title, count }: { title: string; count: number }) => {
      return (
        <View style={styles.statsContainer}>
          <Text style={styles.statsCount}>{count}</Text>
          <Text numberOfLines={2} style={styles.statsTitle}>
            {title}
          </Text>
        </View>
      );
    },
    [styles],
  );

  const stats = useStats(insightsModule);

  return (
    <View style={styles.container}>
      <View style={styles.titleContainer}>
        <NativeDrawable style={styles.icon} source="privacy-stats" />
        <Text style={styles.title}>
          {t('ControlCenter.PrivacyProtection.Title')}
        </Text>
      </View>
      <View style={styles.statsWrapper}>
        <Stats
          title={t('ControlCenter.PrivacyProtection.TrackersBlocked')}
          count={stats.trackersBlocked}
        />
        <Stats
          title={t('ControlCenter.PrivacyProtection.AdsBlocked')}
          count={stats.adsBlocked}
        />
      </View>
    </View>
  );
};
