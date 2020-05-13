import 'react-native-gesture-handler';
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { AppRegistry, StyleSheet, Text, View } from 'react-native';
import { Button } from 'react-native-elements';
import { NativeModules } from 'react-native';
import LiveView from './live-view';
import LivePlayView from './live-play-view';

var MainViewController = NativeModules.MainViewController;

function HomeScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Text></Text><Text></Text>
      <Text style={styles.Title}> 腾讯云 TRTC</Text>
      <View style={styles.buttonContainer}>
        <Button title="RTC" onPress={() => MainViewController.presentStoryboard('RTC')}></Button>
        <Text></Text><Text></Text>
        <Button title="Live" onPress={() => navigation.navigate('LiveView')}></Button>
      </View>
    </View>
  );
}

const Stack = createStackNavigator();

function MainView() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} options={{
          headerTitle: "TRTC React Native 示例",
        }} />
        <Stack.Screen name="LiveView" component={LiveView} options={{
          headerTitle: "房间设置",
        }} />
        <Stack.Screen name="LivePlayView" component={LivePlayView} options={{
          headerTitle: "直播",
        }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}




export var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  videoContainer: {
    alignSelf: 'stretch',
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  buttonContainer: {
    flex: 1,
    height: 50,
    width: 200,
    justifyContent: 'center',
    backgroundColor: '#FFFFFF',
  },
  Title: {
    fontSize: 25,
    textAlign: 'center',
    margin: 10,
  },
  halfViewRow: {
    flex: 1 / 2,
    flexDirection: 'row',
  },
  full: {
    flex: 1,
  },
  half: {
    flex: 1 / 2,
  },
  noUserText: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    color: '#0093E9',
},
});

// Module name
AppRegistry.registerComponent('MainView', () => MainView);