import 'react-native-gesture-handler';
import { NavigationContainer } from '@react-navigation/native';
import { styles } from './index';
import React from 'react';
import { View } from 'react-native';
import TRTCVideoView from './video-view.js';
import { Button } from 'react-native-elements';
import { NativeEventEmitter, NativeModules } from 'react-native';

const reactNativeTRTC = NativeModules.ReactNativeTRTC;
const reactNativeTRTCEmitter = new NativeEventEmitter(reactNativeTRTC);
class LivePlayView extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            remoteUsers: [],                                       //存储远程通话的用户ID
        };
      }

    componentDidMount() {
        reactNativeTRTCEmitter.addListener(
            'ReactNativeTRTC_onEnterRoom',
            (data) => {
                this.setState({
                    enterRoomResult: data.result,
                });
            }
        );
        reactNativeTRTCEmitter.addListener(
            'ReactNativeTRTC_onRemoteUserEnterRoom',
            (data) => {
                const { remoteUsers } = this.state;
                this.setState({
                    remoteUsers: [...remoteUsers, data.userId],
                });
            }
        );
    }

    LivePlayView() {
        return (
            <View style={styles.videoContainer}>
                {
                    this.state.remoteUsers.length > 2                   //显示三路远程画面
                        ? <View style={styles.full}>
                            <View style={styles.halfViewRow}>
                                <TRTCVideoView remoteUserID={this.state.remoteUsers[0]} style={{ flex: 1 }} />
                            </View>
                            <View style={styles.halfViewRow}>
                                <TRTCVideoView remoteUserID={this.state.remoteUsers[1]} style={{ flex: 1 }} />
                                <TRTCVideoView remoteUserID={this.state.remoteUsers[2]} style={{ flex: 1 }} />
                            </View>
                        </View>
                        : this.state.remoteUsers.length > 1             //显示两路远程画面
                            ? <View style={styles.full}>
                                <View style={styles.halfViewRow}>
                                    <TRTCVideoView remoteUserID={this.state.remoteUsers[0]} style={{ flex: 1 }} />
                                    <TRTCVideoView remoteUserID={this.state.remoteUsers[1]} style={{ flex: 1 }} />
                                </View>
                            </View>
                            : this.state.remoteUsers.length > 0         //显示一路远程画面
                                ? <View style={styles.full}>
                                    <TRTCVideoView remoteUserID={this.state.remoteUsers[0]} style={{ flex: 1 }} />
                                </View> :                               //不显示远程画面
                                null
                }
                
                <TRTCVideoView showLocalPreview={true} style={{ flex: 1 }} />{/* 显示本地画面 */}
                <View style={{ height: 50, alignItems: 'center' }}>
                    {/* <View style={styles.buttonContainer}><Button title="开启本地画面" onPress={() => reactNativeTRTC.startLocalPreview(false)}></Button></View> */}
                </View>
            </View>
        );

    }
    render() {
        return this.LivePlayView();
    }


}
export default LivePlayView 