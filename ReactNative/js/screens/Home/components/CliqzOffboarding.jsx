import React, { useState } from 'react';
import {
  Modal,
  View,
  StyleSheet,
  Text,
  Image,
  Linking,
  Pressable,
} from 'react-native';
import t from '../../../services/i18n';

const styles = StyleSheet.create({
  container: {},
  logo: {
    height: 40,
    width: 40,
    marginBottom: 15,
  },
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 22,
  },
  modalView: {
    marginHorizontal: 20,
    backgroundColor: '#eeeeee',
    borderRadius: 20,
    paddingHorizontal: 35,
    paddingVertical: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  button: {
    borderRadius: 20,
    padding: 10,
    elevation: 2,
  },
  buttonClose: {
    marginTop: 25,
    backgroundColor: '#00aef0',
    paddingHorizontal: 45,
  },
  textStyle: {
    color: 'white',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  modalText: {
    marginBottom: 15,
    textAlign: 'center',
    fontSize: 15,
  },
  browserLink: {
    borderWidth: 1,
    borderColor: '#0078ca',
    width: 200,
    paddingVertical: 5,
    alignItems: 'center',
    marginVertical: 5,
    backgroundColor: 'white',
  },
  browserLinkText: {
    color: '#0078ca',
    fontSize: 16,
    fontWeight: '500',
  },
  alternativesHeaderText: {
    textTransform: 'uppercase',
    color: '#9e9a9a',
    fontSize: 10,
    fontWeight: '500',
    letterSpacing: 1.2,
    marginBottom: 10,
  },
  footerText: {
    marginTop: 5,
    fontSize: 13,
    fontWeight: '500',
    color: '#9e9a9a',
  },
});

export default function CliqzOffboarding() {
  const [modalVisible, setModalVisible] = useState(true);
  return (
    <View style={styles.container}>
      <Modal
        animationType="slide"
        transparent
        visible={modalVisible}
        onRequestClose={() => {
          setModalVisible(!modalVisible);
        }}
      >
        <View style={styles.centeredView}>
          <View style={styles.modalView}>
            <Image
              style={styles.logo}
              source={{ uri: 'splash-Icon' }}
              resizeMode="contain"
            />
            <Text style={styles.modalText}>
              {t('HomeView.CliqzOffboarding.Header')}
            </Text>
            <View>
              <Text style={styles.modalText}>
                {t('HomeView.CliqzOffboarding.Text1')}
                <Text style={{ fontWeight: '800' }}>
                  {' '}
                  {t('HomeView.CliqzOffboarding.Text2')} 😕
                </Text>
              </Text>
            </View>
            <Text style={styles.modalText}>
              {t('HomeView.CliqzOffboarding.Text3')}
            </Text>
            <Text style={styles.alternativesHeaderText}>
              {t('HomeView.CliqzOffboarding.Alternatives')}
            </Text>
            <Pressable
              style={styles.browserLink}
              onPress={() =>
                Linking.openURL(
                  'https://apps.apple.com/us/app/ghostery-privacy-browser/id472789016',
                )
              }
            >
              <Text style={styles.browserLinkText}>Ghostery</Text>
            </Pressable>
            <Pressable
              style={styles.browserLink}
              onPress={() =>
                Linking.openURL(
                  'https://apps.apple.com/us/app/firefox-web-browser/id989804926',
                )
              }
            >
              <Text style={styles.browserLinkText}>Firefox</Text>
            </Pressable>
            <Pressable
              style={styles.browserLink}
              onPress={() =>
                Linking.openURL(
                  'https://apps.apple.com/app/brave-private-web-browser/id1052879175?',
                )
              }
            >
              <Text style={styles.browserLinkText}>Brave</Text>
            </Pressable>

            <Pressable
              style={[styles.button, styles.buttonClose]}
              onPress={() => setModalVisible(!modalVisible)}
            >
              <Text style={styles.textStyle}>
                {t('HomeView.CliqzOffboarding.CTA')}
              </Text>
            </Pressable>
            <Text style={styles.footerText}>
              {t('HomeView.CliqzOffboarding.Footer')}
            </Text>
          </View>
        </View>
      </Modal>
    </View>
  );
}
