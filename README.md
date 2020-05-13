# TRTC React Native Demo 【IOS】

这个开源示例Demo主要演示如何基于 [TRTC 实时音视频 SDK](https://cloud.tencent.com/document/product/647/32689)，使用React Native快速开发ios端的基本功能。

在这个示例项目中包含了以下场景：

- 视频通话（React Native调用官方Demo的视频通话界面Native代码）
- 视频互动直播（使用JavaScript编写界面，调用封装好的ReactNativeTRTC）

## 环境要求
- Xcode 10.2及以上版本
- 请确保您的项目已设置有效的开发者签名
- 请确保您已安装npm、CocoaPods

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。
您已取得腾讯实时音视频控制台的 SDKAppID 和密钥信息

## 运行Demo
### 步骤1：下载Demo源码

### 步骤2：安装依赖
1. 在项目根目录（react-native-trtc）下使用控制台运行
```
npm install
```

2. 在react-native-trtc/ios/TRTCSimpleDemo/目录下运行
```
pod install
```

### 步骤3：配置 Demo 工程中的AppID和密钥
1. 打开[GenerateTestUserSig.h](ios/TRTCSimpleDemo/debug/GenerateTestUserSig.h)文件
2. 配置`GenerateTestUserSig.h`文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
    <img src="https://main.qcloudimg.com/raw/15d986c5f4bc340e555630a070b90d63.png">

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤4：编译运行
1. 在react-native-trtc/ios/运行
```
npm start
```
2. 确保手机与开发电脑在同一局域网下，配置[MainViewController.swift](ios/TRTCSimpleDemo/Main/MainViewController.swift )中的“jsCodeLocation”
```
override func loadView() {
    let jsCodeLocation = URL(string: "http://【在这里填写开发服务器的地址】:8081/index.bundle?platform=ios")
    let rootView = RCTRootView(
        bundleURL: jsCodeLocation!,
        moduleName: "MainView",
        initialProperties: nil,
        launchOptions: nil
    )
    super.viewDidLoad()
    self.view = rootView
}
```
3. 使用XCode（10.2及以上的版本）打开源码目录下的【TRTCSimpleDemo.xcworkspace（不是TRTCSimpleDemo.xcodeproj！） 工程，设置有效的开发者签名，连接 iPhone／iPad 测试设备后，编译并运行 Demo 工程即可。
4. 主界面有两个按钮“RTC”和“Live”，点击“RTC”按钮将跳转到Swift编写的视频通话界面（这里直接引用官网Demo代码）。点击“Live”跳转到React Native编写的直播界面。

## 集成ReactNativeTRTC到现有项目
### 步骤1：下载Demo源码

### 步骤2：复制代码
1. 将“react-native-trtc/ios/TRTCSimpleDemo/RCTWrapper”目录拷贝到您的React Native项目

### 步骤3：在React Native中调用ReactNativeTRTC
以[live-play-view.js](live-play-view.js)文件为例：
```
import { NativeEventEmitter, NativeModules } from 'react-native';

const reactNativeTRTC = NativeModules.ReactNativeTRTC;//用于从JS层调用TRTC接口
const reactNativeTRTCEmitter = new NativeEventEmitter(reactNativeTRTC);//从JS层监听TRTCCloudDelegate回调的事件
```
调用TRTC接口（示例，全部支持接口请查看[ReactNativeTRTC.m](ios/TRTCSimpleDemo/RCTWrapper/ReactNativeTRTC.m)）
```
reactNativeTRTC.startLocalPreview(false);
```
监听TRTCCloudDelegate回调（示例，全部支持接口请查看[ReactNativeTRTC.m](ios/TRTCSimpleDemo/RCTWrapper/ReactNativeTRTC.m)）
```
componentDidMount() {
    reactNativeTRTCEmitter.addListener(
        'ReactNativeTRTC_onEnterRoom',
        (data) => {
        //接收到回调后需要做的事
            this.setState({
                enterRoomResult: data.result,
            });
        }
    );
    reactNativeTRTCEmitter.addListener(
        'ReactNativeTRTC_onRemoteUserEnterRoom',
        (data) => {
        //接收到回调后需要做的事
            const { remoteUsers } = this.state;
            this.setState({
                remoteUsers: [...remoteUsers, data.userId],
            });
        }
    );
}
```
项目根目录下的[video-view.js](video-view.js)（视频控件）、[live-view.js](live-view.js)（直播进房界面）、[live-play-view.js](live-play-view.js)（直播画面播放界面）展示了部分ReactNativeTRTC的用法，目前文档还不完善，您可以按需翻阅
## TODO
- 完善TRTCVideoView视频控件的功能
- 测试
- 完善ReactNativeTRTC支持的接口（目前有部分复杂传参的接口暂未支持）
- 封装Android端
- 完善文档


