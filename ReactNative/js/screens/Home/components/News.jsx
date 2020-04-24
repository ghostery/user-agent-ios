import React, { useCallback, useState, useMemo } from 'react';
import {
  NativeModules,
  View,
  StyleSheet,
  Image,
  TouchableWithoutFeedback,
  Text,
} from 'react-native';
import Logo from '../../../components/Logo';
import { withTheme } from '../../../contexts/theme';

const getStyles = theme =>
  StyleSheet.create({
    container: {
      borderTopWidth: 1,
      borderTopColor: theme.separatorColor,
      paddingTop: 30,
      marginHorizontal: 20,
    },
    logoWrapper: {
      position: 'absolute',
      top: 10,
      left: 10,
    },
    image: {
      height: 150,
      flexShrink: 0,
      marginBottom: 10,
    },
    item: {
      marginBottom: 20,
    },
    separator: {
      marginTop: 20,
      backgroundColor: theme.separatorColor,
      height: 1,
    },
    title: {
      fontWeight: '600',
      marginBottom: 10,
      fontSize: 15,
      color: theme.textColor,
    },
    description: {
      flex: 1,
      color: theme.descriptionColor,
      marginBottom: 10,
    },
    domain: {
      color: theme.descriptionColor,
    },
    secondRow: {
      flexDirection: 'column',
    },
    breaking: {
      color: theme.redColor,
      paddingLeft: 10,
    },
    domainRow: {
      flexDirection: 'row',
    },
  });

const HiddableImage = props => {
  const { style, source, children } = props;
  const [isHidden, setHidden] = useState(false, [source]);
  const hide = useCallback(() => setHidden(true), [setHidden]);
  const hiddenStyle = useMemo(
    () => (isHidden ? { height: 0, marginBottom: 0, display: 'none' } : null),
    [isHidden],
  );
  return (
    <View style={hiddenStyle}>
      <Image style={style} source={{ uri: source }} onError={hide} />
      {children}
    </View>
  );
};

function News({ news, isImagesEnabled, theme, telemetry }) {
  const styles = useMemo(() => getStyles(theme), [theme]);

  const onClick = useCallback(
    url => () => {
      telemetry.push(
        {
          component: 'home',
          view: 'news',
          target: 'article',
          action: 'click',
        },
        'ui.metric.interaction',
      );
      NativeModules.BrowserActions.openLink(url, '');
    },
    [telemetry],
  );

  const onLongPress = useCallback(
    (url, title) => () => {
      NativeModules.ContextMenu.visit(url, title, false);
    },
    [],
  );

  if (news.length === 0) {
    return null;
  }

  /* eslint-disable prettier/prettier */
  return (
    <View style={styles.container}>
      {news.map(item => (
        <View
          style={styles.item}
          key={item.url}
        >
          <TouchableWithoutFeedback onPress={onClick(item.url)} onLongPress={onLongPress(item.url, item.title)}>
            <View>
              {isImagesEnabled && item.imageUrl &&
                <HiddableImage style={styles.image} source={item.imageUrl}>
                  <View style={styles.logoWrapper}>
                    <Logo url={item.url} size={30} />
                  </View>
                </HiddableImage>
              }
              <View style={styles.secondRow}>
                <Text style={styles.title}>
                  {item.title}
                </Text>
                <Text style={styles.description}>
                  {item.description}
                </Text>
                <View style={styles.domainRow}>
                  <Text style={styles.domain}>
                    {item.domain}
                  </Text>
                  {item.breaking_label && (
                    <Text style={styles.breaking}>
                      {NativeModules.LocaleConstants['ActivityStream.News.BreakingLabel']}
                    </Text>
                  )}
                </View>
              </View>
            </View>
          </TouchableWithoutFeedback>
          <View style={styles.separator} />
        </View>
      ))}
    </View>
  );
  /* eslint-enable prettier/prettier */
}

export default withTheme(News);
