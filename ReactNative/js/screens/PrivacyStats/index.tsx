import React, { useState, useCallback, useEffect, useMemo } from 'react';
import { Text, View, NativeModules } from 'react-native';
import NativeDrawable from '../../components/NativeDrawable';
import { useStyles } from '../../contexts/theme';
import t from '../../services/i18n';

const getStyle = (theme: {
  fontSizeLarge: number;
  fontSizeSmall: number;
  textColor: string;
  descriptionColor: string;
  brandTintColor: string;
  separatorColor: string;
}) => ({
  container: {
    minHeight: 100,
    maxWidth: 358, // as PhotonActionSheetUX MaxWidth is fixed
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
    color: theme.brandTintColor,
    fontSize: 30,
    fontWeight: '500',
  },
  statsTitle: {
    fontSize: theme.fontSizeSmall,
    color: theme.textColor,
  },
  searchIcon: {
    color: theme.brandTintColor,
  },
  row: {
    width: '100%',
    marginBottom: 15,
  },
  leftRightRow: {
    justifyContent: 'space-between',
    flexDirection: 'row',
  },
  right: {
    alignSelf: 'flex-end',
    color: theme.descriptionColor,
  },
  bar: {
    backgroundColor: theme.descriptionColor,
    height: 8,
    marginVertical: 5,
    width: '50%',
    borderRadius: 5,
  },
  activeBar: {
    backgroundColor: theme.brandTintColor,
  },
  boldText: {
    color: theme.textColor,
    fontWeight: 'bold',
  },
});

interface BrowserCoreModule {
  action(moduleName: string, args?: any[]): any;
}

const useSearchStats = (insightsModule: BrowserCoreModule) => {
  const [stats, setStats] = useState({
    cliqzSearch: 0,
    otherSearch: 0,
  });

  useEffect(() => {
    async function getStats() {
      const searchStats = await insightsModule.action('getSearchStats');
      const cliqzSearch = searchStats.cliqzSearch || 0;
      const otherSearch = searchStats.otherSearch || 0;

      const total = cliqzSearch + otherSearch;
      if (total === 0) {
        setStats({
          cliqzSearch: 1,
          otherSearch: 0,
        });
        return;
      }
      setStats({
        cliqzSearch: cliqzSearch / total,
        otherSearch: otherSearch / total,
      });
    }

    getStats();
  }, [insightsModule]);
  return stats;
};

const usePrivacyStats = (insightsModule: BrowserCoreModule) => {
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
      if (!adsBlocked) {
        adsBlocked = 0;
      }
      if (!trackersBlocked) {
        trackersBlocked = 0;
      }

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

const formatPercent = (number: number) =>
  number.toLocaleString(undefined, {
    style: 'percent',
    minimumFractionDigits: 0,
  });

const mergeStyles = ([...styles], deps: any) => {
  // eslint-disable-next-line
  const mergedStyles = useMemo(() => styles, deps);
  return mergedStyles;
};

export default ({
  insightsModule,
  Features,
}: {
  insightsModule: BrowserCoreModule;
  Features: any;
}) => {
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
  const privacyStats = usePrivacyStats(insightsModule);
  const searchStats = useSearchStats(insightsModule);
  const cliqzSearchBarStyle = mergeStyles(
    [
      styles.bar,
      styles.activeBar,
      { width: formatPercent(searchStats.cliqzSearch) },
    ],
    [styles, searchStats.cliqzSearch],
  );
  const otherSearchBarStyle = mergeStyles(
    [styles.bar, { width: formatPercent(searchStats.otherSearch) }],
    [styles, searchStats.otherSearch],
  );
  const otherSearchStatsLabelStyle = mergeStyles(
    [styles.statsTitle, styles.right],
    [styles],
  );

  return (
    <View style={styles.container}>
      {Features.ControlCenter.PrivacyStats.SearchStats.isEnabled && (
        <>
          <View style={styles.titleContainer}>
            <NativeDrawable
              style={styles.icon}
              source="search"
              color={styles.searchIcon.color}
            />
            <Text style={styles.title} allowFontScaling={false}>
              {t('ControlCenter.SearchStats.Title')}
            </Text>
          </View>
          <View style={styles.statsWrapper}>
            <View style={styles.row}>
              <View style={styles.leftRightRow}>
                <Text style={styles.boldText} allowFontScaling={false}>
                  {formatPercent(searchStats.cliqzSearch)}
                </Text>
                <Text style={styles.right} allowFontScaling={false}>
                  {formatPercent(searchStats.otherSearch)}
                </Text>
              </View>
              <View style={styles.leftRightRow}>
                <View style={cliqzSearchBarStyle} />
                <View style={otherSearchBarStyle} />
              </View>
              <View style={styles.leftRightRow}>
                <Text style={styles.statsTitle} allowFontScaling={false}>
                  {t('ControlCenter.SearchStats.CliqzSearch')}
                </Text>
                <Text
                  style={otherSearchStatsLabelStyle}
                  allowFontScaling={false}
                >
                  {t('ControlCenter.SearchStats.OtherSearch')}
                </Text>
              </View>
            </View>
          </View>
        </>
      )}

      <View style={styles.titleContainer}>
        <NativeDrawable
          style={styles.icon}
          source="privacy-stats"
          color={styles.searchIcon.color}
        />
        <Text style={styles.title} allowFontScaling={false}>
          {t('ControlCenter.PrivacyProtection.Title')}
        </Text>
      </View>
      <View style={styles.statsWrapper}>
        <Stats
          title={t('ControlCenter.PrivacyProtection.TrackersBlocked')}
          count={privacyStats.trackersBlocked}
        />
        <Stats
          title={t('ControlCenter.PrivacyProtection.AdsBlocked')}
          count={privacyStats.adsBlocked}
        />
      </View>
    </View>
  );
};
