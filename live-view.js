import 'react-native-gesture-handler';
import { styles } from './index';
import React from 'react';
import { View } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import { Input, Button } from 'react-native-elements';
import { NativeModules } from 'react-native';

const reactNativeTRTC = NativeModules.ReactNativeTRTC;

export default function LiveView({ navigation }) {
    var roomID, userID;
    return (
        <View style={styles.container}>
            <Input
                containerStyle={{ height: 60, width: 300 }}
                placeholder='  请输入房间号：'
                leftIcon={
                    <Icon
                        name='play'
                        size={30}
                        color='black'
                    />
                }
                onChangeText={(text) => roomID = text}
            />
            <Input
                containerStyle={{ height: 60, width: 300 }}
                placeholder='  请输入用户名：'
                leftIcon={
                    <Icon
                        name='user'
                        size={30}
                        color='black'
                    />
                }
                onChangeText={(text) => userID = text}
            />
            <Button title="进入房间" onPress={() => enterRoom(roomID, userID, { navigation })}></Button>
        </View>
    );
}

function enterRoom(roomID, userID, { navigation }) {
    console.log(roomID);
    console.log(userID);

    // ReactNativeTRTC.init();
    navigation.navigate('LivePlayView')
    reactNativeTRTC.enterRoom({ 'sdkAppId': 1400188366, 'roomId': Number(roomID), 'userId': userID, 'role':20, 'trtcAppScene':0});

}