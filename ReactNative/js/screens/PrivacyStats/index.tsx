import React, { useState, useCallback, useEffect } from 'react';
import { Text, View, NativeModules } from 'react-native';
import NativeDrawable from '../../components/NativeDrawable';
import { useStyles } from '../../contexts/theme';
import t from '../../services/i18n';
import { number } from 'prop-types';

const getStyle = (theme: {
  fontSizeLarge: number;
  fontSizeSmall: number;
  textColor: string;
  descriptionColor: string;
}) => ({
  container: {
    minHeight: 100,
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
    fontSize: theme.fontSizeSmall,
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
    async function getStats() {
      const [tabsState, dashboardStats] = await Promise.all([
        NativeModules.InsightsFeature.getTabsState(),
        insightsModule.action('getDashboardStats', ['']),
      ]);
      let { adsBlocked, trackersBlocked } = dashboardStats;

      tabsState.forEach(
        (tabState: { adsBlocked: number; trackersBlocked: number }) => {
          adsBlocked += tabState.adsBlocked;
          trackersBlocked += tabState.trackersBlocked;
        },
      );

      setStats({
        adsBlocked,
        trackersBlocked,
      });
    }

    getStats();
  }, [insightsModule]);
  return stats;
};

export default ({ insightsModule }: { insightsModule: BrowserCoreModule }) => {
  const styles = useStyles(getStyle);

  const Stats = useCallback(
    ({ title, count }: { title: string; count: number }) => {
      return (
        <View style={styles.statsContainer}>
          <Text style={styles.statsCount} allowFontScaling={false}>
            {count}
          </Text>
          <Text
            numberOfLines={2}
            ellipsizeMode="tail"
            style={styles.statsTitle}
            allowFontScaling={false}
          >
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
        <Text style={styles.title} allowFontScaling={false}>
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
