import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableWithoutFeedback,
  NativeModules,
} from 'react-native';
import { SwipeListView } from 'react-native-swipe-list-view';
import ListItem from '../../components/ListItem';
import ToolbarArea from '../../components/ToolbarArea';
import moment from '../../services/moment';
import { useStyles } from '../../contexts/theme';
import t from '../../services/i18n';
import NativeDrawable from '../../components/NativeDrawable';

const hideKeyboard = () => NativeModules.BrowserActions.hideKeyboard();

const getStyle = (theme: {
  backgroundColor: string;
  fontSizeLarge: number;
  fontSizeSmall: number;
  textColor: string;
  tintColor: string;
  descriptionColor: string;
  brandTintColor: string;
  separatorColor: string;
}) => ({
  list: {},
  rowFront: {
    backgroundColor: theme.backgroundColor,
    borderBottomColor: 'black',
    borderBottomWidth: 0,
    justifyContent: 'center',
    paddingHorizontal: 8,
    paddingVertical: 3,
    alignItems: 'stretch',
  },
  rowFrontWrapper: {
    flexDirection: 'row',
    flexGrow: 1,
  },
  backTextWhite: {
    color: '#FFF',
  },
  rowBack: {
    alignItems: 'center',
    backgroundColor: 'red',
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingLeft: 15,
  },
  backRightBtn: {
    alignItems: 'center',
    bottom: 0,
    justifyContent: 'center',
    position: 'absolute',
    top: 0,
    width: 75,
  },
  backRightBtnRight: {
    backgroundColor: 'red',
    right: 0,
  },
  showDetailsIcon: {
    color: theme.tintColor,
    width: 20,
    height: '100%',
    paddingLeft: 20,
    transform: [{ rotate: '180deg' }],
  },
  showDetailsIconWrapper: {
    width: 40,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
});

interface Domain {
  name: string;
  latestVisitDate: number;
}

const PAGE_SIZE = 15;

const useDomains = (): [Domain[], any, any] => {
  const [domains, setDomains] = useState<Domain[]>([]);
  const [page, setPage] = useState(0);
  const [lastLoadedPage, setLastLoadedPage] = useState(-1);

  const loadMore = () => {
    if (page === lastLoadedPage) {
      setPage(page + 1);
    }
  };

  useEffect(() => {
    const fetchDomains = async () => {
      let data: Domain[] = [];
      try {
        data = await NativeModules.History.getDomains(
          PAGE_SIZE,
          page * PAGE_SIZE,
        );
      } catch (e) {
        // In case of the problems with db
      }
      setDomains(prevState => {
        return [...prevState, ...data];
      });
      if (data.length > 0) {
        setLastLoadedPage(page);
      }
    };

    if (page !== lastLoadedPage) {
      fetchDomains();
    }
  }, [page, lastLoadedPage]);

  return [domains, loadMore, setDomains];
};

export default ({ toolbarHeight }: { toolbarHeight: number }) => {
  const styles = useStyles(getStyle);

  const [domains, loadMore, setDomains] = useDomains();

  const ToolbarAreaComponent = useCallback(() => {
    return <ToolbarArea height={toolbarHeight} />;
  }, [toolbarHeight]);

  const renderItem = (data: any) => {
    const { item } = data;
    const openDomain = () => NativeModules.BrowserActions.openDomain(item.name);
    const openDomainDetails = () => {
      hideKeyboard();
      NativeModules.HomeViewNavigation.showDomainDetails(
        item.name,
        toolbarHeight,
      );
    };

    return (
      <View style={styles.rowFront}>
        <View style={styles.rowFrontWrapper}>
          <ListItem
            url={item.name}
            title={item.name}
            displayUrl={moment(item.latestVisitDate / 1000).fromNow()}
            onPress={openDomain}
            label={null}
          />
          <TouchableWithoutFeedback onPress={openDomainDetails}>
            <View style={styles.showDetailsIconWrapper}>
              <NativeDrawable
                style={styles.showDetailsIcon}
                source="goBack"
                color={styles.showDetailsIcon.color}
              />
            </View>
          </TouchableWithoutFeedback>
        </View>
      </View>
    );
  };

  const keyExtractor = (item: Domain) => item.name;

  const renderHiddenItem = (data: { item: Domain }) => {
    const { name } = data.item;
    const onPress = async () => {
      await NativeModules.History.removeDomain(name);
      const newData = [...domains];
      const domainToRemoveIndex = domains.findIndex(item => item.name === name);
      newData.splice(domainToRemoveIndex, 1);
      setDomains(newData);
    };

    return (
      <TouchableWithoutFeedback onPress={onPress}>
        <View style={styles.rowBack}>
          <View style={[styles.backRightBtn, styles.backRightBtnRight]}>
            <Text style={styles.backTextWhite}>{t('Delete')}</Text>
          </View>
        </View>
      </TouchableWithoutFeedback>
    );
  };

  return (
    <View>
      <SwipeListView
        style={styles.list}
        data={domains}
        disableRightSwipe
        renderItem={renderItem}
        keyExtractor={keyExtractor}
        renderHiddenItem={renderHiddenItem}
        rightOpenValue={-75}
        onEndReached={loadMore}
        onEndReachedThreshold={0.5}
        initialNumToRender={PAGE_SIZE}
        recalculateHiddenLayout
        onScroll={hideKeyboard}
        ListFooterComponent={ToolbarAreaComponent}
      />
    </View>
  );
};
