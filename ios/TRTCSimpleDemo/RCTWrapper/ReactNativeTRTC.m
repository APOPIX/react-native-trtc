//
//  ReactNativeTRTC.m
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/5/1.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactNativeTRTC.h"
#import "TRTCCloud.h"
#import <React/RCTBridge.h>
#import "GenerateTestUserSig.h"

@implementation ReactNativeTRTC

RCT_EXPORT_MODULE(ReactNativeTRTC);

static ReactNativeTRTC *instance = nil;

- (instancetype)init
{
    if (self = [super init]) {
        instance.remoteViewDic = [[NSMutableDictionary alloc]init];
        self.trtcCloud = [TRTCCloud sharedInstance];
        self.trtcCloud.delegate = self;
        //初始化videoEncParam
        // 设置视频通话的画质（帧率 15fps，码率550, 分辨率 360*640）
        TRTCVideoEncParam *videoEncParam =[[TRTCVideoEncParam alloc]init];
        videoEncParam.videoResolution = TRTCVideoResolution_640_360;
        videoEncParam.videoBitrate = 550;
        videoEncParam.videoFps = 15;
        [self.trtcCloud setVideoEncoderParam:videoEncParam];
    }
    return self;
}

+(BOOL)requiresMainQueueSetup {
  return YES;
}

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init] ;
        
    }) ;
    return instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [ReactNativeTRTC shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [ReactNativeTRTC shareInstance] ;
}

-(void) addRemoteView:(UIView *)view userId:(NSString *)userId{
    [self.remoteViewDic setObject:view forKey:userId];
}

-(void) removeRemoteView:(NSString *)userId{
    [self.remoteViewDic removeObjectForKey:userId];
}

-(NSArray <NSString *> *)supportedEvents {
return@[
        @"ReactNativeTRTC_onError",
        @"ReactNativeTRTC_onWarning",
        @"ReactNativeTRTC_onEnterRoom",
        @"ReactNativeTRTC_onExitRoom",
        @"ReactNativeTRTC_onSwitchRole",
        @"ReactNativeTRTC_onConnectOtherRoom",
        @"ReactNativeTRTC_onDisconnectOtherRoom",
        @"ReactNativeTRTC_onRemoteUserEnterRoom",
        @"ReactNativeTRTC_onRemoteUserLeaveRoom",
        @"ReactNativeTRTC_onUserVideoAvailable",
        @"ReactNativeTRTC_onUserSubStreamAvailable",
        @"ReactNativeTRTC_onUserAudioAvailable",
        @"ReactNativeTRTC_onFirstVideoFrame",
        @"ReactNativeTRTC_onFirstAudioFrame",
        @"ReactNativeTRTC_onSendFirstLocalVideoFrame",
        @"ReactNativeTRTC_onSendFirstLocalAudioFrame",
        @"ReactNativeTRTC_onUserEnter",
        @"ReactNativeTRTC_onUserExit",
        @"ReactNativeTRTC_onNetworkQuality",
        @"ReactNativeTRTC_onStatistics",
        @"ReactNativeTRTC_onConnectionLost",
        @"ReactNativeTRTC_onTryToReconnect",
        @"ReactNativeTRTC_onConnectionRecovery",
        @"ReactNativeTRTC_onCameraDidReady",
        @"ReactNativeTRTC_onMicDidReady",
        @"ReactNativeTRTC_onAudioRouteChanged",
        @"ReactNativeTRTC_onUserVoiceVolume",
        @"ReactNativeTRTC_onDevice",
        @"ReactNativeTRTC_onRecvCustomCmdMsgUserId",
        @"ReactNativeTRTC_onMissCustomCmdMsgUserId",
        @"ReactNativeTRTC_onRecvSEIMsg",
        @"ReactNativeTRTC_onStartPublishing",
        @"ReactNativeTRTC_onStopPublishing",
        @"ReactNativeTRTC_onStartPublishCDNStream",
        @"ReactNativeTRTC_onStopPublishCDNStream",
        @"ReactNativeTRTC_onSetMixTranscodingConfig",
        @"ReactNativeTRTC_onAudioEffectFinished",
        @"ReactNativeTRTC_onScreenCaptureStarted",
        @"ReactNativeTRTC_onScreenCapturePaused",
        @"ReactNativeTRTC_onScreenCaptureResumed",
        @"ReactNativeTRTC_onScreenCaptureStoped",
        //TODO 暂未实现TRTCAudioFrameDelegate、TRTCVideoRenderDelegate、TRTCLogDelegate回调
        ];
}

/////////////////////////////////////////////////////////////////////////////////
//
//                      SDK 基础函数
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  初始化ReactNativeTRTC
 */

/**
 *  销毁 TRTC 单例
 */

RCT_EXPORT_METHOD(destroyTRTCSharedIntance) {
    NSLog(@"ReactNativeTRTC destroyTRTCSharedIntance");
    [TRTCCloud destroySharedIntance];
}



/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）房间相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

RCT_EXPORT_METHOD(enterRoom:(NSDictionary *)options) {
    NSLog(@"ReactNativeTRTC enterRoom appScene=%@", [options descriptionWithLocale:nil] );
    //初始化trtcParam
    TRTCParams *trtcParam = [[TRTCParams alloc]init];
    trtcParam.sdkAppId = (UInt32)[options[@"sdkAppId"] integerValue];
    trtcParam.roomId = (UInt32)[options[@"roomId"] integerValue];
    trtcParam.userId = options[@"userId"];
    trtcParam.role = [options[@"role"] integerValue];
    //    self.trtcParam.userSig = [options[@"userSig"] stringValue];
    trtcParam.userSig = [GenerateTestUserSig genTestUserSig:trtcParam.userId];//TODO 暂时用测试签名替代
    [self.trtcCloud enterRoom:trtcParam appScene:[options[@"trtcAppScene"] integerValue]];
}

RCT_EXPORT_METHOD(exitRoom) {
    NSLog(@"ReactNativeTRTC exitRoom");
    [self.trtcCloud exitRoom];
}

/**
 * 1.3 切换角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
 *
 * 在直播场景下，一个用户可能需要在“观众”和“主播”之间来回切换。
 * 您可以在进房前通过 TRTCParams 中的 role 字段确定角色，也可以通过 switchRole 在进房后切换角色。
 *
 * @param role 目标角色，默认为主播：
 *  - {@link TRTCRoleAnchor} 主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。
 *  - {@link TRTCRoleAudience} 观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。
 */
RCT_EXPORT_METHOD(switchRole:(NSInteger)role) {
    NSLog(@"ReactNativeTRTC switchRole role=%ld", (long)role);
    [self.trtcCloud switchRole:role];
}

/**
 * 1.4 请求跨房通话（主播 PK）
 *
 * TRTC 中两个不同音视频房间中的主播，可以通过“跨房通话”功能拉通连麦通话功能。使用此功能时，
 * 两个主播无需退出各自原来的直播间即可进行“连麦 PK”。
 *
 * 例如：当房间“001”中的主播 A 通过 connectOtherRoom() 跟房间“002”中的主播 B 拉通跨房通话后，
 * 房间“001”中的用户都会收到主播 B 的 onUserEnter(B) 回调和 onUserVideoAvailable(B,YES) 回调。
 * 房间“002”中的用户都会收到主播 A 的 onUserEnter(A) 回调和 onUserVideoAvailable(A,YES) 回调。
 *
 * 简言之，跨房通话的本质，就是把两个不同房间中的主播相互分享，让每个房间里的观众都能看到两个主播。
 *
 * <pre>
 *                 房间 001                     房间 002
 *               -------------               ------------
 *  跨房通话前：| 主播 A      |             | 主播 B     |
 *              | 观众 U V W  |             | 观众 X Y Z |
 *               -------------               ------------
 *
 *                 房间 001                     房间 002
 *               -------------               ------------
 *  跨房通话后：| 主播 A B    |             | 主播 B A   |
 *              | 观众 U V W  |             | 观众 X Y Z |
 *               -------------               ------------
 * </pre>
 *
 * 跨房通话的参数考虑到后续扩展字段的兼容性问题，暂时采用了 JSON 格式的参数，要求至少包含两个字段：
 * - roomId：房间“001”中的主播 A 要跟房间“002”中的主播 B 连麦，主播 A 调用 connectOtherRoom() 时 roomId 应指定为“002”。
 * - userId：房间“001”中的主播 A 要跟房间“002”中的主播 B 连麦，主播 A 调用 connectOtherRoom() 时 userId 应指定为 B 的 userId。
 *
 * 跨房通话的请求结果会通过 TRTCCloudDelegate 中的 onConnectOtherRoom() 回调通知给您。
 *
 * <pre>
 *   NSMutableDictionary * jsonDict = [[NSMutableDictionary alloc] init];
 *   [jsonDict setObject:@(002) forKey:@"roomId"];
 *   [jsonDict setObject:@"userB" forKey:@"userId"];
 *   NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
 *   NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
 *   [trtc connectOtherRoom:jsonString];
 * </pre>
 *
 * @param param JSON 字符串连麦参数，roomId 代表目标房间号，userId 代表目标用户 ID。
 *
 **/
RCT_EXPORT_METHOD(connectOtherRoom:(NSString *)param) {
    NSLog(@"ReactNativeTRTC connectOtherRoom param=%@", param);
    [self.trtcCloud connectOtherRoom:param];
}



/**
 * 1.5 退出跨房通话
 *
 * 跨房通话的退出结果会通过 TRTCCloudDelegate 中的 onDisconnectOtherRoom() 回调通知给您。
 **/
RCT_EXPORT_METHOD(disconnectOtherRoom) {
    NSLog(@"ReactNativeTRTC disconnectOtherRoom");
    [self.trtcCloud disconnectOtherRoom];
}

/**
 * 1.6 设置音视频数据接收模式（需要在进房前设置才能生效）
 *
 * 为实现进房秒开的绝佳体验，SDK 默认进房后自动接收音视频。即在您进房成功的同时，您将立刻收到远端所有用户的音视频数据。
 * 若您没有调用 startRemoteView，视频数据将自动超时取消。
 * 若您主要用于语音聊天等没有自动接收视频数据需求的场景，您可以根据实际需求选择接收模式。
 *
 * @param autoRecvAudio YES：自动接收音频数据；NO：需要调用 muteRemoteAudio 进行请求或取消。默认值：YES
 * @param autoRecvVideo YES：自动接收视频数据；NO：需要调用 startRemoteView/stopRemoteView 进行请求或取消。默认值：YES
 *
 * @note 需要在进房前设置才能生效。
 **/
RCT_EXPORT_METHOD(setDefaultStreamRecvMode:(BOOL)autoRecvAudio video:(BOOL)autoRecvVideo) {
    NSLog(@"ReactNativeTRTC setDefaultStreamRecvMode autoRecvAudio=%@, autoRecvVideo=%@", autoRecvAudio?@"YES":@"NO", autoRecvVideo?@"YES":@"NO");
    [self.trtcCloud setDefaultStreamRecvMode:autoRecvAudio video:autoRecvVideo];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）CDN 相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - CDN 相关接口函数

/// @name CDN 相关接口函数
/// @{

/**
 * 2.1 开始向腾讯云的直播 CDN 推流
 *
 * 该接口会指定当前用户的音视频流在腾讯云 CDN 所对应的 StreamId，进而可以指定当前用户的 CDN 播放地址。
 *
 * 例如：如果我们采用如下代码设置当前用户的主画面 StreamId 为 user_stream_001，那么该用户主画面对应的 CDN 播放地址为：
 * “http://yourdomain/live/user_stream_001.flv”，其中 yourdomain 为您自己备案的播放域名，
 * 您可以在直播[控制台](https://console.cloud.tencent.com/live) 配置您的播放域名，腾讯云不提供默认的播放域名。
 *
 * <pre>
 *  TRTCCloud *trtcCloud = [TRTCCloud sharedInstance];
 *  [trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 *  [trtcCloud startLocalPreview:frontCamera view:localView];
 *  [trtcCloud startLocalAudio];
 *  [trtcCloud startPublishing: @"user_stream_001" type:TRTCVideoStreamTypeBig];
 *
 * </pre>
 *
 * 您也可以在设置 enterRoom 的参数 TRTCParams 时指定 streamId, 而且我们更推荐您采用这种方案。
 *
 * @param streamId 自定义流 Id。
 * @param type 仅支持TRTCVideoStreamTypeBig 和 TRTCVideoStreamTypeSub。
 * @note 您需要先在实时音视频 [控制台](https://console.cloud.tencent.com/rav/) 中的功能配置页开启“启动自动旁路直播”才能生效。
 */
RCT_EXPORT_METHOD(startPublishing:(NSString *)streamId type:(NSInteger)type) {
    NSLog(@"ReactNativeTRTC startPublishing streamId=%@, type=%ld", streamId, (long)type);
    [self.trtcCloud startPublishing:streamId type:type];
}

/**
 * 2.2 停止向腾讯云的直播 CDN 推流
 */
RCT_EXPORT_METHOD(stopPublishing) {
    NSLog(@"ReactNativeTRTC stopPublishing");
    [self.trtcCloud stopPublishing];
}

/**
 * 2.3 开始向友商云的直播 CDN 转推
 *
 * 该接口跟 startPublishing() 类似，但 startPublishCDNStream() 支持向非腾讯云的直播 CDN 转推。
 * 使用 startPublishing() 绑定腾讯云直播 CDN 不收取额外的费用。
 * 使用 startPublishCDNStream() 绑定非腾讯云直播 CDN 需要收取转推费用，且需要通过工单联系我们开通。
 */
RCT_EXPORT_METHOD(startPublishCDNStream:(TRTCPublishCDNParam*)param) {
    NSLog(@"ReactNativeTRTC startPublishCDNStream TRTCPublishCDNParam=%@", param);
        //TODO 字典生成Param
    [self.trtcCloud startPublishCDNStream:param];
}

/**
 * 2.4 停止向非腾讯云地址转推
 */
RCT_EXPORT_METHOD(stopPublishCDNStream) {
    NSLog(@"ReactNativeTRTC stopPublishCDNStream");
    [self.trtcCloud stopPublishCDNStream];
}

/**
 * 2.5 设置云端的混流转码参数
 *
 * 如果您在实时音视频 [控制台](https://console.cloud.tencent.com/trtc/) 中的功能配置页开启了“启动自动旁路直播”功能，
 * 房间里的每一路画面都会有一个默认的直播 [CDN 地址](https://cloud.tencent.com/document/product/647/16826)。
 *
 * 一个直播间中可能有不止一位主播，而且每个主播都有自己的画面和声音，但对于 CDN 观众来说，他们只需要一路直播流，
 * 所以您需要将多路音视频流混成一路标准的直播流，这就需要混流转码。
 *
 * 当您调用 setMixTranscodingConfig() 接口时，SDK 会向腾讯云的转码服务器发送一条指令，目的是将房间里的多路音视频流混合为一路,
 * 您可以通过 mixUsers 参数来调整每一路画面的位置，以及是否只混合声音，也可以通过 videoWidth、videoHeight、videoBitrate 等参数控制混合音视频流的编码参数。
 *
 * <pre>
 * 【画面1】=> 解码 ====> \
 *                         \
 * 【画面2】=> 解码 =>  画面混合 => 编码 => 【混合后的画面】
 *                         /
 * 【画面3】=> 解码 ====> /
 *
 * 【声音1】=> 解码 ====> \
 *                         \
 * 【声音2】=> 解码 =>  声音混合 => 编码 => 【混合后的声音】
 *                         /
 * 【声音3】=> 解码 ====> /
 * </pre>
 *
 * 参考文档：[云端混流转码](https://cloud.tencent.com/document/product/647/16827)。
 *
 * @param config 请参考 TRTCCloudDef.h 中关于 TRTCTranscodingConfig 的介绍。如果传入 nil 则取消云端混流转码。
 * @note 关于云端混流的注意事项：
 *  - 云端转码会引入一定的 CDN 观看延时，大概会增加1 - 2秒。
 *  - 调用该函数的用户，会将连麦中的多路画面混合到自己当前这路画面中。
 */
RCT_EXPORT_METHOD(setMixTranscodingConfig:(TRTCTranscodingConfig*)config) {
    //TODO 字典生成config
    NSLog(@"ReactNativeTRTC setMixTranscodingConfig TRTCTranscodingConfig=%@", config);
    [self.trtcCloud setMixTranscodingConfig:config];
}

//@}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）视频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 视频相关接口函数
/// @name 视频相关接口函数
/// @{

#if TARGET_OS_IPHONE
/**
 * 3.1 开启本地视频的预览画面 (iOS 版本)
 *
 * 当开始渲染首帧摄像头画面时，您会收到 TRTCCloudDelegate 中的 onFirstVideoFrame(nil) 回调。
 *
 * @param frontCamera YES：前置摄像头；NO：后置摄像头。
 */
RCT_EXPORT_METHOD(startLocalPreview:(BOOL)frontCamera) {
    NSLog(@"ReactNativeTRTC startLocalPreview frontCamera=%@", frontCamera?@"YES":@"NO");
    [self.trtcCloud startLocalPreview:frontCamera view:[ReactNativeTRTC shareInstance].localVideoView];
}
#elif TARGET_OS_MAC
/**
 * 3.1 开启本地视频的预览画面 (Mac 版本)
 *
 * 在调用该方法前，可以先调用 setCurrentCameraDevice 选择使用 Mac 自带摄像头或外接摄像头。
 * 当开始渲染首帧摄像头画面时，您会收到 TRTCCloudDelegate 中的 onFirstVideoFrame(nil) 回调。
 *
 */
RCT_EXPORT_METHOD(startLocalPreview) {
    NSLog(@"ReactNativeTRTC startLocalPreview");
    [self.trtcCloud startLocalPreview:[ReactNativeTRTC shareInstance].localVideoView];
}
#endif

/**
 * 3.2 停止本地视频采集及预览
 */
RCT_EXPORT_METHOD(stopLocalPreview) {
    NSLog(@"ReactNativeTRTC stopLocalPreview");
    [self.trtcCloud stopLocalPreview];
}

/**
 * 3.3 暂停/恢复推送本地的视频数据
 *
 * 当暂停推送本地视频后，房间里的其它成员将会收到 onUserVideoAvailable(userId, NO) 回调通知
 * 当恢复推送本地视频后，房间里的其它成员将会收到 onUserVideoAvailable(userId, YES) 回调通知
 *
 * @param mute YES：暂停；NO：恢复
 */
RCT_EXPORT_METHOD(muteLocalVideo:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteLocalVideo mute=%@", mute?@"YES":@"NO");
    [self.trtcCloud muteLocalVideo:mute];
}

/**
 * 3.4 开始显示远端视频画面
 *
 * 在收到 SDK 的 onUserVideoAvailable(userid, YES) 通知时，可以获知该远程用户开启了视频，
 * 此后调用 startRemoteView(userid) 接口加载该用户的远程画面，此时可以用 loading 动画优化加载过程中的等待体验。
 * 待该用户的首帧画面开始显示时，您会收到 onFirstVideoFrame(userId) 事件回调。
 *
 * @param userId 对方的用户标识
 * @param view 承载视频画面的控件
 */
RCT_EXPORT_METHOD(startRemoteView:(NSString *)userId) {
    NSLog(@"ReactNativeTRTC startRemoteView userId=%@", userId);
    [self.trtcCloud startRemoteView:userId view:[[ReactNativeTRTC shareInstance].remoteViewDic objectForKey:userId]];
}

/**
 * 3.5 停止显示远端视频画面，同时不再拉取该远端用户的视频数据流
 *
 * 调用此接口后，SDK 会停止接收该用户的远程视频流，同时会清理相关的视频显示资源。
 *
 * @param userId 对方的用户标识
 */
RCT_EXPORT_METHOD(stopRemoteView:(NSString *)userId) {
    NSLog(@"ReactNativeTRTC stopRemoteView userId=%@", userId);
//    TODO
    [self.trtcCloud stopRemoteView:userId];
}

/**
 * 3.6 停止显示所有远端视频画面，同时不再拉取远端用户的视频数据流
 *
 * @note 如果有屏幕分享的画面在显示，则屏幕分享的画面也会一并被关闭。
 */
RCT_EXPORT_METHOD(stopAllRemoteView) {
    NSLog(@"ReactNativeTRTC stopAllRemoteView");
//    TODO
    [self.trtcCloud stopAllRemoteView];
}

/**
 * 3.7 暂停/恢复接收指定的远端视频流
 *
 * 该接口仅暂停/恢复接收指定的远端用户的视频流，但并不释放显示资源，所以如果暂停，视频画面会冻屏在 mute 前的最后一帧。
 *
 * @param userId 对方的用户标识
 * @param mute  是否暂停接收
 */
RCT_EXPORT_METHOD(muteRemoteVideoStream:(NSString*)userId mute:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteRemoteVideoStream userId=%@, mute=%@", userId, mute?@"YES":@"NO");
    //    TODO mute时显示占位图片
    [self.trtcCloud muteRemoteVideoStream:userId mute:mute];
}

/**
 * 3.8 暂停/恢复接收所有远端视频流
 *
 * 该接口仅暂停/恢复接收所有远端用户的视频流，但并不释放显示资源，所以如果暂停，视频画面会冻屏在 mute 前的最后一帧。
 *
 * @param mute 是否暂停接收
 */
RCT_EXPORT_METHOD(muteAllRemoteVideoStreams:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteAllRemoteVideoStreams mute=%@", mute?@"YES":@"NO");
    //    TODO mute时显示占位图片
    [self.trtcCloud muteAllRemoteVideoStreams:mute];
}

/**
 * 3.9 设置视频编码器相关参数
 *
 * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
 *
 * @param param 视频编码参数，详情请参考 TRTCCloudDef.h 中的 TRTCVideoEncParam 定义
 */
RCT_EXPORT_METHOD(setVideoEncoderParam:(TRTCVideoEncParam*)param) {
    //TODO 字典生成Param
    NSLog(@"ReactNativeTRTC setVideoEncoderParam param=%@", param);
    [self.trtcCloud setVideoEncoderParam:param];
}

/**
 * 3.10 设置网络流控相关参数
 *
 * 该设置决定 SDK 在各种网络环境下的调控策略（例如弱网下选择“保清晰”或“保流畅”）
 *
 * @param param 网络流控参数，详情请参考 TRTCCloudDef.h 中的 TRTCNetworkQosParam 定义
 */
RCT_EXPORT_METHOD(setNetworkQosParam:(TRTCNetworkQosParam*)param) {
    //TODO 字典生成Param
    NSLog(@"ReactNativeTRTC setNetworkQosParam param=%@", param);
    [self.trtcCloud setNetworkQosParam:param];
}

/**
 * 3.11 设置本地图像的渲染模式
 *
 * @param mode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：TRTCVideoFillMode_Fill
 */
RCT_EXPORT_METHOD(setLocalViewFillMode:(NSInteger)mode) {
    NSLog(@"ReactNativeTRTC setLocalViewFillMode mode=%ld", mode);
    [self.trtcCloud setLocalViewFillMode:mode];
}

/**
 * 3.12 设置远端图像的渲染模式
 *
 * @param userId 用户 ID
 * @param mode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：TRTCVideoFillMode_Fill
 */
RCT_EXPORT_METHOD(setRemoteViewFillMode:(NSString*)userId mode:(NSInteger)mode) {
    NSLog(@"ReactNativeTRTC setRemoteViewFillMode userId=%@, mode=%ld", userId, mode);
    [self.trtcCloud setRemoteViewFillMode:userId mode:mode];
}

/**
 * 3.13 设置本地图像的顺时针旋转角度
 *
 * @param rotation 支持90、180以及270旋转角度，默认值：TRTCVideoRotation_0
 */
RCT_EXPORT_METHOD(setLocalViewRotation:(NSInteger)rotation) {
    NSLog(@"ReactNativeTRTC setLocalViewRotation rotation=%ld", rotation);
    [self.trtcCloud setLocalViewRotation:rotation];
}

/**
 * 3.14 设置远端图像的顺时针旋转角度
 *
 * @param userId 用户 ID
 * @param rotation 支持90、180以及270旋转角度，默认值：TRTCVideoRotation_0
 */
RCT_EXPORT_METHOD(setRemoteViewRotation:(NSString*)userId rotation:(NSInteger)rotation) {
    NSLog(@"ReactNativeTRTC setRemoteViewRotation userId=%@, rotation=%ld", userId, rotation);
    [self.trtcCloud setRemoteViewRotation:userId rotation:rotation];
}

/**
 * 3.15 设置视频编码输出的（也就是远端用户观看到的，以及服务器录制下来的）画面方向
 *
 * 在 iPad、iPhone 等设备180度旋转时，由于摄像头的采集方向没有变，所以对方看到的画面是上下颠倒的，
 * 在这种情况下，您可以通过该接口将 SDK 输出到对方的画面旋转180度，这样可以可以确保对方看到的画面依然正常。
 *
 * @param rotation 目前支持0和180两个旋转角度，默认值：TRTCVideoRotation_0
 */
RCT_EXPORT_METHOD(setVideoEncoderRotation:(NSInteger)rotation) {
    NSLog(@"ReactNativeTRTC setVideoEncoderRotation rotation=%ld", rotation);
    [self.trtcCloud setVideoEncoderRotation:rotation];
}

#if TARGET_OS_IPHONE
/**
 * 3.16 设置本地摄像头预览画面的镜像模式（iOS）
 *
 * @param mirror 镜像模式，默认值：TRTCLocalVideoMirrorType_Auto
 */
RCT_EXPORT_METHOD(setLocalViewMirror:(NSInteger)mirror) {
    NSLog(@"ReactNativeTRTC setLocalViewMirror mirror=%ld", mirror);
    [self.trtcCloud setLocalViewMirror:mirror];
}
#elif TARGET_OS_MAC

/**
 * 3.17 设置本地摄像头预览画面的镜像模式（Mac）
 *
 * @param mirror 镜像模式，默认值：YES
 */
RCT_EXPORT_METHOD(setLocalViewMirror:(BOOL)mirror) {
    NSLog(@"ReactNativeTRTC setLocalViewMirror mirror=%@", mirror?@"YES":@"NO");
    [self.trtcCloud setLocalViewMirror:mirror];
}
#endif

/**
 * 3.18 设置编码器输出的画面镜像模式
 *
 * 该接口不改变本地摄像头的预览画面，但会改变另一端用户看到的（以及服务器录制的）画面效果。
 *
 * @param mirror 是否开启远端镜像，YES：开启远端画面镜像；NO：关闭远端画面镜像，默认值：NO。
 */
RCT_EXPORT_METHOD(setVideoEncoderMirror:(BOOL)mirror) {
    NSLog(@"ReactNativeTRTC setVideoEncoderMirror mirror=%@", mirror?@"YES":@"NO");
    [self.trtcCloud setVideoEncoderMirror:mirror];
}

/**
 * 3.19 设置重力感应的适应模式
 *
 * @param mode 重力感应模式，详情请参考 TRTCGSensorMode 的定义，默认值：TRTCGSensorMode_UIAutoLayout
 */
RCT_EXPORT_METHOD(setGSensorMode:(NSInteger) mode) {
    NSLog(@"ReactNativeTRTC setGSensorMode mode=%ld", mode);
    [self.trtcCloud setGSensorMode:mode];
}

/**
 * 3.20 开启大小画面双路编码模式
 *
 * 如果当前用户是房间中的主要角色（例如主播、老师、主持人等），并且使用 PC 或者 Mac 环境，可以开启该模式。
 * 开启该模式后，当前用户会同时输出【高清】和【低清】两路视频流（但只有一路音频流）。
 * 对于开启该模式的当前用户，会占用更多的网络带宽，并且会更加消耗 CPU 计算资源。
 *
 * 对于同一房间的远程观众而言：
 * - 如果用户下行网络很好，可以选择观看【高清】画面
 * - 如果用户下行网络较差，可以选择观看【低清】画面
 *
 * @note 双路编码开启后，会消耗更多的 CPU 和 网络带宽，所以对于 iMac、Windows 或者高性能 Pad 可以考虑开启，但请不要在手机端开启。
 *
 * @param enable 是否开启小画面编码，默认值：NO
 * @param smallVideoEncParam 小流的视频参数
 * @return 0：成功；-1：大画面已经是最低画质
 */
//- (int)enableEncSmallVideoStream:(BOOL)enable withQuality:(TRTCVideoEncParam*)smallVideoEncParam;//TODO 封装有返回值的接口

/**
 * 3.21 选定观看指定 uid 的大画面或小画面
 *
 * 此功能需要该 uid 通过 enableEncSmallVideoStream 提前开启双路编码模式。
 * 如果该 uid 没有开启双路编码模式，则此操作将无任何反应。
 *
 * @param userId 用户 ID
 * @param type 视频流类型，即选择看大画面或小画面，默认为大画面
 */
RCT_EXPORT_METHOD(setRemoteVideoStreamType:(NSString*)userId type:(NSInteger)type) {
    NSLog(@"ReactNativeTRTC setRemoteVideoStreamType userId=%@, type=%ld", userId, type);
    [self.trtcCloud setRemoteVideoStreamType:userId type:type];
}

/**
 * 3.22 设定观看方优先选择的视频质量
 *
 * 低端设备推荐优先选择低清晰度的小画面。
 * 如果对方没有开启双路视频模式，则此操作无效。
 *
 * @param type 默认观看大画面或小画面，默认为大画面
 */
RCT_EXPORT_METHOD(setPriorRemoteVideoStreamType:(NSInteger)type) {
    NSLog(@"ReactNativeTRTC setPriorRemoteVideoStreamType type=%ld", type);
    [self.trtcCloud setPriorRemoteVideoStreamType:type];
}

#if TARGET_OS_IPHONE
/**
 * 3.23 视频画面截图
 *
 * 截取本地、远程主路和远端辅流的视频画面，并通过 UIImage 对象返回给您。
 *
 * @param userId 用户 ID，nil 表示截取本地视频画面。
 * @param type 视频流类型，支持主路画面（TRTCVideoStreamTypeBig，一般用于摄像头）和 辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）。
 * @param completionBlock 画面截取后的回调。
 *
 * @note 设置 userId = nil，代表截取当前用户的本地画面，目前本地画面仅支持截取主路画面（TRTCVideoStreamTypeBig）。
 */
//- (void)snapshotVideo:(NSString *)userId type:(TRTCVideoStreamType)type completionBlock:(void (^)(UIImage *image))completionBlock;//TODO 封装有block的接口


#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）音频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 音频相关接口函数
/// @name 音频相关接口函数
/// @{

/**
 * 4.1 开启本地音频的采集和上行
 *
 * 该函数会启动麦克风采集，并将音频数据传输给房间里的其他用户。
 * SDK 不会默认开启本地音频采集和上行，您需要调用该函数开启，否则房间里的其他用户将无法听到您的声音。
 *
 * @note 该函数会检查麦克风的使用权限，如果当前 App 没有麦克风权限，SDK 会向用户申请开启。
 */
RCT_EXPORT_METHOD(startLocalAudio) {
    NSLog(@"ReactNativeTRTC startLocalAudio");
    [self.trtcCloud startLocalAudio];
}

/**
 * 4.2 关闭本地音频的采集和上行
 *
 * 当关闭本地音频的采集和上行，房间里的其它成员会收到 onUserAudioAvailable(NO) 回调通知。
 */
RCT_EXPORT_METHOD(stopLocalAudio) {
    NSLog(@"ReactNativeTRTC stopLocalAudio");
    [self.trtcCloud stopLocalAudio];
}

/**
 * 4.3 静音/取消静音本地的音频
 *
 * 当静音本地音频后，房间里的其它成员会收到 onUserAudioAvailable(userId, NO) 回调通知。
 * 当取消静音本地音频后，房间里的其它成员会收到 onUserAudioAvailable(userId, YES) 回调通知。
 *
 * 与 stopLocalAudio 不同之处在于，muteLocalAudio:YES 并不会停止发送音视频数据，而是继续发送码率极低的静音包。
 * 由于 MP4 等视频文件格式，对于音频的连续性是要求很高的，使用 stopLocalAudio 会导致录制出的 MP4 不易播放。
 * 因此在对录制质量要求很高的场景中，建议选择 muteLocalAudio，从而录制出兼容性更好的 MP4 文件。
 *
 * @param mute YES：静音；NO：取消静音
 */
RCT_EXPORT_METHOD(muteLocalAudio:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteLocalAudio mute=%@", mute?@"YES":@"NO");
    [self.trtcCloud muteLocalAudio:mute];
}

/**
 * 4.4 设置音频路由
 *
 * 微信和手机 QQ 视频通话功能的免提模式就是基于音频路由实现的。
 * 一般手机都有两个扬声器，一个是位于顶部的听筒扬声器，声音偏小；一个是位于底部的立体声扬声器，声音偏大。
 * 设置音频路由的作用就是决定声音使用哪个扬声器播放。
 *
 * @param route 音频路由，即声音由哪里输出（扬声器、听筒），默认值：TRTCAudioModeSpeakerphone
 */
RCT_EXPORT_METHOD(setAudioRoute:(NSInteger)route) {
    NSLog(@"ReactNativeTRTC setAudioRoute route=%ld", route);
    [self.trtcCloud setAudioRoute:route];
}

/**
 * 4.5 静音/取消静音指定的远端用户的声音
 *
 * @param userId 对方的用户 ID
 * @param mute YES：静音；NO：取消静音
 *
 * @note 静音时会停止接收该用户的远端音频流并停止播放，取消静音时会自动拉取该用户的远端音频流并进行播放。
 */
RCT_EXPORT_METHOD(muteRemoteAudio:(NSString *)userId mute:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteRemoteAudio userId=%@, mute=%@", userId, mute?@"YES":@"NO");
    [self.trtcCloud muteRemoteAudio:userId mute:mute];
}

/**
 * 4.6 静音/取消静音所有用户的声音
 *
 * @param mute YES：静音；NO：取消静音
 *
 * @note 静音时会停止接收所有用户的远端音频流并停止播放，取消静音时会自动拉取所有用户的远端音频流并进行播放。
 */
RCT_EXPORT_METHOD(muteAllRemoteAudio:(BOOL)mute) {
    NSLog(@"ReactNativeTRTC muteAllRemoteAudio mute=%@", mute?@"YES":@"NO");
    [self.trtcCloud muteAllRemoteAudio:mute];
}

/**
 * 4.7 设置某个远程用户的播放音量
 *
 * @param userId 远程用户 ID
 * @param volume 音量大小，取值0 - 100
 */
RCT_EXPORT_METHOD(setRemoteAudioVolume:(NSString *)userId volume:(int)volume) {
    NSLog(@"ReactNativeTRTC setRemoteAudioVolume userId=%@, volume=%d", userId, volume);
    [self.trtcCloud setRemoteAudioVolume:userId volume:volume];
}

/**
 * 4.8 设置 SDK 采集音量。
 *
 * @param volume 音量大小，取值0 - 100，默认值为100
 */
RCT_EXPORT_METHOD(setAudioCaptureVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setAudioCaptureVolume volume=%ld", volume);
    [self.trtcCloud setAudioCaptureVolume:volume];
}

/**
 * 4.9 获取 SDK 采集音量
 */
//- (NSInteger)getAudioCaptureVolume;//TODO 封装有返回值的接口

/**
 * 4.10 设置 SDK 播放音量。
 *
 * @note 该函数会控制最终交给系统播放的声音音量，会影响录制本地音频文件的音量大小，但不会影响耳返的音量。
 *
 * @param volume 音量大小，取值0 - 100，默认值为100
 */
RCT_EXPORT_METHOD(setAudioPlayoutVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setAudioPlayoutVolume volume=%ld", volume);
    [self.trtcCloud setAudioPlayoutVolume:volume];
}

/**
 * 4.11 获取 SDK 播放音量
 */
//- (NSInteger)getAudioPlayoutVolume;//TODO 封装有返回值的接口

/**
 * 4.12 启用音量大小提示
 *
 * 开启此功能后，SDK 会在 onUserVoiceVolume() 中反馈对每一路声音音量大小值的评估。
 * 如需打开此功能，请在 startLocalAudio() 之前调用。
 *
 * @note Demo 中有一个音量大小的提示条，就是基于这个接口实现的。
 * @param interval 设置 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；
 */
RCT_EXPORT_METHOD(enableAudioVolumeEvaluation:(NSUInteger)interval) {
    NSLog(@"ReactNativeTRTC enableAudioVolumeEvaluation interval=%ld", interval);
    [self.trtcCloud enableAudioVolumeEvaluation:interval];
}

/**
 * 4.13 开始录音
 *
 * 该方法调用后， SDK 会将通话过程中的所有音频（包括本地音频，远端音频，BGM 等）录制到一个文件里。
 * 无论是否进房，调用该接口都生效。
 * 如果调用 exitRoom 时还在录音，录音会自动停止。
 *
 * @param param 录音参数，请参考 TRTCAudioRecordingParams
 * @return 0：成功；-1：录音已开始；-2：文件或目录创建失败；-3：后缀指定的音频格式不支持
 */
//- (int)startAudioRecording:(TRTCAudioRecordingParams*) param;//TODO 封装有返回值的接口

/**
 * 4.14 停止录音
 *
 * 如果调用 exitRoom 时还在录音，录音会自动停止。
 */
RCT_EXPORT_METHOD(stopAudioRecording) {
    NSLog(@"ReactNativeTRTC stopAudioRecording");
    [self.trtcCloud stopAudioRecording];
}

/**
 * 4.15 设置通话时使用的系统音量类型
 *
 * 智能手机一般具备两种系统音量类型，即通话音量类型和媒体音量类型。
 * - 通话音量：手机专门为通话场景设计的音量类型，使用手机自带的回声抵消功能，音质相比媒体音量类型较差，
 *             无法通过音量按键将音量调成零，但是支持蓝牙耳机上的麦克风。
 *
 * - 媒体音量：手机专门为音乐场景设计的音量类型，音质相比于通话音量类型要好，通过通过音量按键可以将音量调成零。
 *             使用媒体音量类型时，如果要开启回声抵消（AEC）功能，SDK 会开启内置的声学处理算法对声音进行二次处理。
 *             在媒体音量模式下，蓝牙耳机无法使用自带的麦克风采集声音，只能使用手机上的麦克风进行声音采集。
 *
 * SDK 目前提供了三种系统音量类型的控制模式，分别为：
 * - {@link TRTCSystemVolumeTypeAuto}：
 *       “麦上通话，麦下媒体”，即主播上麦时使用通话音量，观众不上麦则使用媒体音量，适合在线直播场景。
 *       如果您在 enterRoom 时选择的场景为 {@link TRTCAppSceneLIVE} 或 {@link TRTCAppSceneVoiceChatRoom}，SDK 会自动选择该模式。
 *
 * - {@link TRTCSystemVolumeTypeVOIP}：
 *       通话全程使用通话音量，适合多人会议场景。
 *       如果您在 enterRoom 时选择的场景为 {@link TRTCAppSceneVideoCall} 或 {@link TRTCAppSceneAudioCall}，SDK 会自动选择该模式。
 *
 * - {@link TRTCSystemVolumeTypeMedia}：
 *       通话全程使用媒体音量，不常用，适合个别有特殊需求（如主播外接声卡）的应用场景。
 *
 * @note
 *   1. 需要在调用 startLocalAudio() 之前调用该接口。<br>
 *   2. 如无特殊需求，不推荐您自行设置，您只需通过 enterRoom 设置好适合您的场景，SDK 内部会自动选择相匹配的音量类型。
 *
 * @param type 系统音量类型，如无特殊需求，不推荐您自行设置。
 */
RCT_EXPORT_METHOD(setSystemVolumeType:(NSInteger)type) {
    NSLog(@"ReactNativeTRTC setSystemVolumeType type=%ld", type);
    [self.trtcCloud setSystemVolumeType:type];
}

#if TARGET_OS_IPHONE
/**
 * 4.16 开启耳返
 *
 * 开启后会在耳机里听到自己的声音。
 *
 * @note 仅在戴耳机时有效
 *
 * @param enable YES：开启；NO：关闭，默认值：NO
 */
RCT_EXPORT_METHOD(enableAudioEarMonitoring:(BOOL)enable) {
    NSLog(@"ReactNativeTRTC enableAudioEarMonitoring enable=%@", enable?@"YES":@"NO");
    [self.trtcCloud enableAudioEarMonitoring:enable];
}
#endif

/// @}



/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）摄像头相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 摄像头相关接口函数
/// @name 摄像头相关接口函数
/// @{
#if TARGET_OS_IPHONE

/**
 * 5.1 切换摄像头
 */
RCT_EXPORT_METHOD(switchCamera) {
    NSLog(@"ReactNativeTRTC switchCamera");
    [self.trtcCloud switchCamera];
}

/**
 * 5.2 查询当前摄像头是否支持缩放
 */
//- (BOOL)isCameraZoomSupported;//TODO 封装有返回值的接口

/**
 * 5.3 设置摄像头缩放因子（焦距）
 *
 * 取值范围1 - 5，取值为1表示最远视角（正常镜头），取值为5表示最近视角（放大镜头）。
 * 最大值推荐为5，若超过5，视频数据会变得模糊不清。
 *
 * @param distance 取值范围为1 - 5，数值越大，焦距越远
 */
RCT_EXPORT_METHOD(setZoom:(CGFloat)distance) {
    NSLog(@"ReactNativeTRTC setZoom distance=%f", distance);
    [self.trtcCloud setZoom:distance];
}


/**
 * 5.4 查询是否支持开关闪光灯（手电筒模式）
 */
//- (BOOL)isCameraTorchSupported;//TODO 封装有返回值的接口

/**
 * 5.5 开关闪光灯
 *
 * @param enable YES：开启；NO：关闭，默认值：NO
 */
//- (BOOL)enbaleTorch:(BOOL)enable;//TODO 封装有返回值的接口

/**
 * 5.6 查询是否支持设置焦点
 */
//- (BOOL)isCameraFocusPositionInPreviewSupported;//TODO 封装有返回值的接口

/**
 * 5.7 设置摄像头焦点
 *
 * @param x 对焦位置的x坐标
 * @param y 对焦位置的y坐标
 */
RCT_EXPORT_METHOD(setFocusPosition:(CGFloat)x:(CGFloat)y) {
    NSLog(@"ReactNativeTRTC setFocusPosition (%f, %f)", x, y);
    [self.trtcCloud setFocusPosition:CGPointMake(x, y)];
}

/**
 * 5.8 查询是否支持自动识别人脸位置
 */
//- (BOOL)isCameraAutoFocusFaceModeSupported;//TODO 封装有返回值的接口

/**
 * 5.9 自动识别人脸位置
 *
 * @param enable YES：开启；NO：关闭，默认值：YES
 */
RCT_EXPORT_METHOD(enableAutoFaceFoucs:(BOOL)enable) {
    NSLog(@"ReactNativeTRTC enableAutoFaceFoucs enable=%@", enable?@"YES":@"NO");
    [self.trtcCloud enableAutoFaceFoucs:enable];
}

#elif TARGET_OS_MAC

/**
 * 5.10 获取摄像头设备列表
 *
 * Mac 主机本身自带一个摄像头，也允许插入 USB 摄像头。
 * 如果您希望用户选择自己外接的摄像头，可以提供一个多摄像头选择的功能。
 *
 * @return 摄像头设备列表，第一项为当前系统默认设备
 */
//- (NSArray<TRTCMediaDeviceInfo*>*)getCameraDevicesList;//TODO 封装有返回值的接口

/**
 * 5.11 获取当前使用的摄像头
 */
//- (TRTCMediaDeviceInfo*)getCurrentCameraDevice;//TODO 封装有返回值的接口

/**
 * 5.12 设置要使用的摄像头
 *
 * @param deviceId 从 getCameraDevicesList 中得到的设备 ID
 * @return 0：成功；-1：失败
 */
//- (int)setCurrentCameraDevice:(NSString*)deviceId;//TODO 封装有返回值的接口

#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）音频设备相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 音频设备相关接口函数
/// @name 音频设备相关接口函数
/// @{
#if !TARGET_OS_IPHONE  && TARGET_OS_MAC

/**
 * 6.1 获取麦克风设备列表
 *
 * Mac 主机本身自带一个质量很好的麦克风，但它也允许用户外接其他的麦克风，而且很多 USB 摄像头上也自带麦克风。
 * 如果您希望用户选择自己外接的麦克风，可以提供一个多麦克风选择的功能。
 *
 * @return 麦克风设备列表，第一项为当前系统默认设备
 */
//- (NSArray<TRTCMediaDeviceInfo*>*)getMicDevicesList;//TODO 封装有返回值的接口

/**
 * 6.2 获取当前的麦克风设备
 *
 * @return 当前麦克风设备信息
 */
//- (TRTCMediaDeviceInfo*)getCurrentMicDevice;//TODO 封装有返回值的接口

/**
 * 6.3 设置要使用的麦克风
 *
 * @param deviceId 从 getMicDevicesList 中得到的设备 ID
 * @return 0：成功；<0：失败
 */
//- (int)setCurrentMicDevice:(NSString*)deviceId;//TODO 封装有返回值的接口

/**
 * 6.4 获取当前麦克风设备音量
 *
 * @return 麦克风音量
 */
//- (float)getCurrentMicDeviceVolume;//TODO 封装有返回值的接口

/**
 * 6.5 设置麦克风设备的音量
 *
 * 该接口的功能是调节系统采集音量，如果用户直接调节 Mac 系统设置的采集音量时，该接口的设置结果会被用户的操作所覆盖。
 *
 * @param volume 麦克风音量值，范围0 - 100
 */
RCT_EXPORT_METHOD(setCurrentMicDeviceVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setCurrentMicDeviceVolume volume=%ld", volume);
    [self.trtcCloud setCurrentMicDeviceVolume:volume];
}

/**
 * 6.6 获取扬声器设备列表
 *
 * @return 扬声器设备列表，第一项为当前系统默认设备
 */
//- (NSArray<TRTCMediaDeviceInfo*>*)getSpeakerDevicesList;//TODO 封装有返回值的接口

/**
 * 6.7 获取当前的扬声器设备
 *
 * @return 当前扬声器设备信息
 */
//- (TRTCMediaDeviceInfo*)getCurrentSpeakerDevice;//TODO 封装有返回值的接口

/**
 * 6.8 设置要使用的扬声器
 *
 * @param deviceId 从 getSpeakerDevicesList 中得到的设备 ID
 * @return 0：成功；<0：失败
 */
//- (int)setCurrentSpeakerDevice:(NSString*)deviceId;//TODO 封装有返回值的接口

/**
 * 6.9 当前扬声器设备音量
 *
 * @return 扬声器音量
 */
//- (float)getCurrentSpeakerDeviceVolume;//TODO 封装有返回值的接口

/**
 * 6.10 设置当前扬声器音量
 *
 * 该接口的功能是调节系统播放音量，如果用户直接调节 Mac 系统设置的播放音量时，该接口的设置结果会被用户的操作所覆盖。
 *
 * @param volume 设置的扬声器音量，范围0 - 100
 * @return 0：成功；<0：失败
 */
//- (int)setCurrentSpeakerDeviceVolume:(NSInteger)volume;//TODO 封装有返回值的接口

#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）美颜滤镜相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 美颜滤镜相关接口函数
/// @name 美颜滤镜相关接口函数
/// @{

/**
 * 7.1 获取美颜管理对象
 *
 * 通过美颜管理，您可以使用以下功能：
 * - 设置"美颜风格"、“美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“小鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
 * - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
 * - 设置人脸挂件（素材）等动态效果
 * - 添加美妆
 * - 进行手势识别
 */
//- (TXBeautyManager *)getBeautyManager;//TODO 封装有返回值的接口

/**
 * 7.2 添加水印
 *
 * 水印的位置是通过 rect 来指定的，rect 的格式为 (x，y，width，height)
 * - x：水印的坐标，取值范围为0 - 1的浮点数。
 * - y：水印的坐标，取值范围为0 - 1的浮点数。
 * - width：水印的宽度，取值范围为0 - 1的浮点数。
 * - height：是不用设置的，SDK 内部会根据水印图片的宽高比自动计算一个合适的高度。
 *
 * 例如，如果当前编码分辨率是540 × 960，rect 设置为（0.1，0.1，0.2，0.0）。
 * 那么水印的左上坐标点就是（540 × 0.1，960 × 0.1）即（54，96），水印的宽度是 540 × 0.2 = 108px，高度自动计算。
 *
 * @param image 水印图片，**必须使用透明底的 png 格式**
 * @param streamType 如果要给辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）也设置水印，需要调用两次的 setWatermark。
 * @param rect 水印相对于编码分辨率的归一化坐标，x，y，width，height 取值范围0 - 1。
 */

//- (void)setWatermark:(TXImage*)image streamType:(TRTCVideoStreamType)streamType rect:(CGRect)rect;//TODO 复杂传参接口，待完善

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）屏幕共享相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - （八）屏幕共享相关接口函数
/// @name 屏幕共享相关接口函数
/// @{

#if TARGET_OS_IPHONE
/**
 * 8.1 启动屏幕分享（iOS）
 *
 * iPhone 屏幕分享的推荐配置参数：
 * - 分辨率(videoResolution): 1280 x 720
 * - 帧率(videoFps): 10 FPS
 * - 码率(videoBitrate): 1600 kbps
 * - 分辨率自适应(enableAdjustRes): NO
 *
 * @param encParams 设置屏幕分享时的编码参数，推荐采用上述推荐配置，如果您指定 encParams 为 nil，则使用您调用 startScreenCapture 之前的编码参数设置。
 */
RCT_EXPORT_METHOD(startScreenCapture:(NSDictionary *)options API_AVAILABLE(ios(13.0))) {
    NSLog(@"ReactNativeTRTC startScreenCapture options=%@", [options descriptionWithLocale:nil]);
    TRTCVideoEncParam *encParams = [[TRTCVideoEncParam alloc]init];
    encParams.videoResolution = [options[@"videoResolution"] integerValue];
    encParams.videoBitrate =  [options[@"videoBitrate"] intValue];
    encParams.videoFps =  [options[@"videoFps"] intValue];
    encParams.resMode = [options[@"resMode"] integerValue];
    encParams.enableAdjustRes = [options[@"enableAdjustRes"] boolValue];
    [self.trtcCloud startScreenCapture:encParams];
}

#elif TARGET_OS_MAC

/**
 * 8.1 启动屏幕分享（Mac）
 *
 * @param view 渲染控件所在的父控件，可以设置为 nil，表示不显示屏幕分享的预览效果。
 * @param streamType 屏幕分享使用的线路，可以设置为主路（TRTCVideoStreamTypeBig）或者辅路（TRTCVideoStreamTypeSub），默认使用辅路。
 * @param encParam 屏幕分享的画面编码参数，可以设置为 nil，表示让 SDK 选择最佳的编码参数（分辨率、码率等）。
 *
 * @note 一个用户同时最多只能上传一条主路（TRTCVideoStreamTypeBig）画面和一条辅路（TRTCVideoStreamTypeSub）画面，
 * 默认情况下，屏幕分享使用辅路画面，如果使用主路画面，建议您提前停止摄像头采集（stopLocalPreview）避免相互冲突。
 */
//- (void)startScreenCapture:(NSView *)view streamType:(TRTCVideoStreamType)streamType encParam:(TRTCVideoEncParam *)encParam;//TODO 封装复杂传参的接口
#endif

/**
 * 8.2 停止屏幕采集
 *
 * @return 0：成功；<0：失败
 */
//- (int)stopScreenCapture API_AVAILABLE(ios(13.0));//TODO 封装有返回值的接口

/**
 * 8.3 暂停屏幕分享
 *
 * @return 0：成功；<0：失败
 */
//- (int)pauseScreenCapture API_AVAILABLE(ios(13.0));//TODO 封装有返回值的接口

/**
 * 8.4 恢复屏幕分享
 *
 * @return 0：成功；<0：失败
 */
//- (int)resumeScreenCapture API_AVAILABLE(ios(13.0));//TODO 封装有返回值的接口

#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 8.5 枚举可分享的屏幕窗口，仅支持 Mac OS 平台，建议在 startScreenCapture 之前调用
 *
 * 如果您要给您的 App 增加屏幕分享功能，一般需要先显示一个窗口选择界面，这样用户可以选择希望分享的窗口。
 * 通过下列函数，您可以获得可分享窗口的 ID、类型、窗口名称以及缩略图。
 * 获取上述信息后，您就可以实现一个窗口选择界面。您也可以使用 Demo 源码中已经实现好的窗口选择界面。
 *
 * @note 返回的列表中包括屏幕和应用窗口，屏幕会在列表的前面几个元素中。
 *
 * @param thumbnailSize 指定要获取的窗口缩略图大小，缩略图可用于绘制在窗口选择界面上
 * @param iconSize 指定要获取的窗口图标大小
 * @return 窗口列表包括屏幕
 */
//- (NSArray<TRTCScreenCaptureSourceInfo*>*)getScreenCaptureSourcesWithThumbnailSize:(CGSize)thumbnailSize iconSize:(CGSize)iconSize;//TODO 封装有返回值的接口

/**
 * 8.6 设置屏幕共享参数，仅支持 Mac OS 平台，该方法在屏幕共享过程中也可以调用
 *
 * 如果您期望在屏幕分享的过程中，切换想要分享的窗口，可以再次调用这个函数，无需重新开启屏幕分享。
 *
 * @param screenSource     指定分享源
 * @param rect             指定捕获的区域（传 CGRectZero 则默认分享全屏）
 * @param capturesCursor   是否捕获鼠标光标
 * @param highlight        是否高亮正在分享的窗口
 *
 */
//- (void)selectScreenCaptureTarget:(TRTCScreenCaptureSourceInfo *)screenSource
//                             rect:(CGRect)rect
//                   capturesCursor:(BOOL)capturesCursor
//                        highlight:(BOOL)highlight;

#endif

/**
 * 8.7 开始显示远端用户的辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）
 * - startRemoteView() 用于显示主路画面（TRTCVideoStreamTypeBig，一般用于摄像头）。
 * - startRemoteSubStreamView() 用于显示辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）。
 *
 * @param userId 对方的用户标识
 * @param view 渲染控件
 * @note 请在 onUserSubStreamAvailable 回调后再调用这个接口。
 */
//- (void)startRemoteSubStreamView:(NSString *)userId view:(TXView *)view;//TODO

/**
 * 8.8 停止显示远端用户的辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）。
 *
 * @param userId 对方的用户标识
 */
RCT_EXPORT_METHOD(stopRemoteSubStreamView:(NSString *)userId) {
    NSLog(@"ReactNativeTRTC stopRemoteSubStreamView userId=%@", userId);
    [self.trtcCloud stopRemoteSubStreamView:userId];
}

/**
 * 8.9 设置辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）的显示模式
 * - setRemoteViewFillMode() 用于设置远端主路画面（TRTCVideoStreamTypeBig，一般用于摄像头）的显示模式。
 * - setRemoteSubStreamViewFillMode() 用于设置远端辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）的显示模式。
 *
 * @param userId 用户的 ID
 * @param mode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：TRTCVideoFillMode_Fit
 */
RCT_EXPORT_METHOD(setRemoteSubStreamViewFillMode:(NSString *)userId mode:(NSInteger)mode) {
    NSLog(@"ReactNativeTRTC setRemoteSubStreamViewFillMode userId=%@, mode=%ld", userId, mode);
    [self.trtcCloud setRemoteSubStreamViewFillMode:userId mode:mode];
}

/**
 * 8.10 设置辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）的顺时针旋转角度
 * - setRemoteViewRotation() 用于设置远端主路画面（TRTCVideoStreamTypeBig，一般用于摄像头）的旋转角度。
 * - setRemoteSubStreamViewRotation() 用于设置远端辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）的旋转角度。
 *
 * @param userId 用户 ID
 * @param rotation 支持90、180、270旋转角度
 */
RCT_EXPORT_METHOD(setRemoteSubStreamViewRotation:(NSString*)userId rotation:(NSInteger)rotation) {
    NSLog(@"ReactNativeTRTC setRemoteSubStreamViewRotation userId=%@, rotation=%ld", userId, rotation);
    [self.trtcCloud setRemoteSubStreamViewRotation:userId rotation:rotation];
}

#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 8.11 设置屏幕分享的编码器参数，仅适用 Mac 平台
 * - setVideoEncoderParam() 用于设置主路画面（TRTCVideoStreamTypeBig，一般用于摄像头）的编码参数。
 * - setSubStreamEncoderParam() 用于设置辅路画面（TRTCVideoStreamTypeSub，一般用于屏幕分享）的编码参数。
 * 该设置决定远端用户看到的画面质量，同时也是云端录制出的视频文件的画面质量。
 *
 * @param param 辅流编码参数，详情请参考 TRTCCloudDef.h 中的 TRTCVideoEncParam 定义
 * @note 即使使用主路传输屏幕分享的数据（在调用 startScreenCapture 时设置 type=TRTCVideoStreamTypeBig），依然要使用此接口更新屏幕分享的编码参数。
 */
RCT_EXPORT_METHOD(setSubStreamEncoderParam:(NSDictionary *)options) {
    NSLog(@"ReactNativeTRTC setSubStreamEncoderParam options=%@", [options descriptionWithLocale:nil]);
    TRTCVideoEncParam encParams = [[TRTCVideoEncParam alloc]init];
    encParams.videoResolution = [options[@"videoResolution"] integerValue];
    encParams.videoBitrate =  [options[@"videoBitrate"] integerValue];
    encParams.videoFps =  [options[@"videoFps"] integerValue];
    encParams.resMode = [options[@"resMode"] integerValue];
    encParams.enableAdjustRes = [options[@"enableAdjustRes"] boolValue];
    [self.trtcCloud setSubStreamEncoderParam:encParams];
}

/**
 * 8.12 设置屏幕分享的混音音量大小，仅适用 Mac 平台
 *
 * 数值越高，辅路音量的占比越高，麦克风音量占比越小。不推荐将该参数值设置过大，数值太大容易压制麦克风的声音。
 *
 * @param volume 设置的音量大小，范围0 - 100
 */
RCT_EXPORT_METHOD(setSubStreamMixVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setSubStreamEncoderParam options=%@", [options descriptionWithLocale:nil]);
    TRTCVideoEncParam encParams = [[TRTCVideoEncParam alloc]init];
    encParams.videoResolution = [options[@"videoResolution"] integerValue];
    encParams.videoBitrate =  [options[@"videoBitrate"] integerValue];
    encParams.videoFps =  [options[@"videoFps"] integerValue];
    encParams.resMode = [options[@"resMode"] integerValue];
    encParams.enableAdjustRes = [options[@"enableAdjustRes"] boolValue];
    [self.trtcCloud setSubStreamEncoderParam:encParams];
}
#endif
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）自定义采集和渲染
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义采集和渲染
/// @name 自定义采集和渲染
/// @{
/**
 * 9.1 启用视频自定义采集模式
 *
 * 开启该模式后，SDK 不在运行原有的视频采集流程，只保留编码和发送能力。
 * 您需要用 sendCustomVideoData() 不断地向 SDK 塞入自己采集的视频画面。
 *
 * @param enable 是否启用，默认值：NO
 */
RCT_EXPORT_METHOD(enableCustomVideoCapture:(BOOL)enable) {
    NSLog(@"ReactNativeTRTC enableCustomVideoCapture enable=%@", enable?@"YES":@"NO");
    [self.trtcCloud enableCustomVideoCapture:enable];
}

/**
 * 9.2 向 SDK 投送自己采集的视频数据
 *
 * TRTCVideoFrame 推荐下列填写方式（其他字段不需要填写）：
 * - pixelFormat：推荐选择 TRTCVideoPixelFormat_NV12。
 * - bufferType：推荐选择 TRTCVideoBufferType_PixelBuffer。
 * - pixelBuffer：iOS 平台上常用的视频数据格式。
 * - data：视频裸数据格式，bufferType 为 NSData 时使用。
 * - timestamp：如果 timestamp 间隔不均匀，会严重影响音画同步和录制出的 MP4 质量。
 * - width：视频图像长度，bufferType 为 NSData 时填写。
 * - height：视频图像宽度，bufferType 为 NSData 时填写。
 *
 * 参考文档：[自定义采集和渲染](https://cloud.tencent.com/document/product/647/34066)。
 *
 * @param frame 视频数据，支持 PixelBuffer NV12，BGRA 以及 I420 格式数据。
 * @note - SDK 内部有帧率控制逻辑，目标帧率以您在 setVideoEncoderParam 中设置的为准，太快会自动丢帧，太慢则会自动补帧。
 * @note - 可以设置 frame 中的 timestamp 为 0，相当于让 SDK 自己设置时间戳，但请“均匀”地控制 sendCustomVideoData 的调用间隔，否则会导致视频帧率不稳定。
 *
 */
//- (void)sendCustomVideoData:(TRTCVideoFrame *)frame;//TODO 复杂传参

/**
 * 9.3 设置本地视频的自定义渲染回调
 *
 * 设置此方法后，SDK 内部会跳过原来的渲染流程，并把采集到的数据回调出来，您需要自己完成画面渲染。
 * - pixelFormat 指定回调的数据格式，例如 NV12、i420 以及 32BGRA。
 * - bufferType 指定 buffer 的类型，直接使用 PixelBuffer 效率最高；使用 NSData 相当于让 SDK 在内部做了一次内存转换，因此会有额外的性能损耗。
 *
 * @param delegate    自定义渲染回调
 * @param pixelFormat 指定回调的像素格式
 * @param bufferType  PixelBuffer：可以直接使用 imageWithCVImageBuffer 转成 UIImage；NSData：经过内存整理的视频数据。
 * @return 0：成功；<0：错误
 */
//- (int)setLocalVideoRenderDelegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;//TODO 封装带有返回值的接口

/**
 * 9.4 设置远端视频的自定义渲染回调
 *
 * 此方法同 setLocalVideoRenderDelegate，区别在于一个是本地画面的渲染回调， 一个是远程画面的渲染回调。
 *
 * @note 调用此函数之前，需要先调用 startRemoteView 来获取远端用户的视频流（view 设置为 nil 即可），否则不会有数据回调出来。
 *
 * @param userId 指定目标 userId。
 * @param delegate 自定义渲染的回调。
 * @param pixelFormat 指定回调的像素格式。
 * @param bufferType PixelBuffer：可以直接使用 imageWithCVImageBuffer 转成 UIImage；NSData：经过内存整理的视频数据。
 * @return 0：成功；<0：错误
 */
//- (int)setRemoteVideoRenderDelegate:(NSString*)userId delegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;//TODO 封装带有返回值的接口

/**
 * 9.5 启用音频自定义采集模式
 *
 * 开启该模式后，SDK 不在运行原有的音频采集流程，只保留编码和发送能力。
 * 您需要用 sendCustomAudioData() 不断地向 SDK 塞入自己采集的音频数据。
 *
 * @note 由于回声抵消（AEC）需要严格的控制声音采集和播放的时间，所以开启自定义音频采集后，AEC 能力可能会失效。
 *
 * @param enable 是否启用, true：启用；false：关闭，默认值：NO
 */
RCT_EXPORT_METHOD(enableCustomAudioCapture:(BOOL)enable) {
    NSLog(@"ReactNativeTRTC enableCustomAudioCapture enable=%@", enable?@"YES":@"NO");
    [self.trtcCloud enableCustomAudioCapture:enable];
}

/**
 * 9.6 向 SDK 投送自己采集的音频数据
 *
 * TRTCAudioFrame 推荐如下填写方式：
 *
 * - data：音频帧 buffer。音频帧数据必须是 PCM 格式，推荐每帧20ms采样数。【48000采样率、单声道的帧长度：48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
 * - sampleRate：采样率，仅支持48000。
 * - channel：频道数量（如果是立体声，数据是交叉的），单声道：1； 双声道：2。
 * - timestamp：如果 timestamp 间隔不均匀，会严重影响音画同步和录制出的 MP4 质量。
 *
 * 参考文档：[自定义采集和渲染](https://cloud.tencent.com/document/product/647/34066)。
 *
 * @param frame 音频数据
 * @note 可以设置 frame 中的 timestamp 为0，相当于让 SDK 自己设置时间戳，但请“均匀”地控制 sendCustomAudioData 的调用间隔，否则会导致声音断断续续。
 */
//- (void)sendCustomAudioData:(TRTCAudioFrame *)frame;//TODO 复杂传参

/**
 * 9.7 设置音频数据回调
 *
 * 设置此方法，SDK 内部会把音频数据（PCM 格式）回调出来，包括：
 * - onCapturedAudioFrame：本机麦克风采集到的音频数据
 * - onPlayAudioFrame：混音前的每一路远程用户的音频数据
 * - onMixedPlayAudioFrame：各路音频数据混合后送入扬声器播放的音频数据
 *
 * @param delegate 音频数据回调，delegate = nil 则停止回调数据
 */
//- (void)setAudioFrameDelegate:(id<TRTCAudioFrameDelegate>)delegate;//TODO 复杂传参

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）自定义消息发送
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 自定义消息发送
/// @name 自定义消息发送
/// @{

/**
 * 10.1 发送自定义消息给房间内所有用户
 *
 * 该接口可以借助音视频数据通道向当前房间里的其他用户广播您自定义的数据，但因为复用了音视频数据通道，
 * 请务必严格控制自定义消息的发送频率和消息体的大小，否则会影响音视频数据的质量控制逻辑，造成不确定性的问题。
 *
 * @param cmdID 消息 ID，取值范围为1 - 10
 * @param data 待发送的消息，最大支持1KB（1000字节）的数据大小
 * @param reliable 是否可靠发送，可靠发送的代价是会引入一定的延时，因为接收端要暂存一段时间的数据来等待重传
 * @param ordered 是否要求有序，即是否要求接收端接收的数据顺序和发送端发送的顺序一致，这会带来一定的接收延时，因为在接收端需要暂存并排序这些消息。
 * @return YES：消息已经发出；NO：消息发送失败。
 *
 * @note 本接口有以下限制：
 *       - 发送消息到房间内所有用户，每秒最多能发送30条消息。
 *       - 每个包最大为1KB，超过则很有可能会被中间路由器或者服务器丢弃。
 *       - 每个客户端每秒最多能发送总计8KB数据。
 *       - 将 reliable 和 ordered 同时设置为 YES 或 NO，暂不支持交叉设置。
 *       - 强烈建议不同类型的消息使用不同的 cmdID，这样可以在要求有序的情况下减小消息时延。
 */
//- (BOOL)sendCustomCmdMsg:(NSInteger)cmdID data:(NSData *)data reliable:(BOOL)reliable ordered:(BOOL)ordered;//TODO 复杂传参

/**
 * 10.2 将小数据量的自定义数据嵌入视频帧中
 *
 * 与 sendCustomCmdMsg 的原理不同，sendSEIMsg 是将数据直接塞入视频数据头中。因此，即使视频帧被旁路到了直播 CDN 上，
 * 这些数据也会一直存在。由于需要把数据嵌入视频帧中，建议尽量控制数据大小，推荐使用几个字节大小的数据。
 *
 * 最常见的用法是把自定义的时间戳（timstamp）用 sendSEIMsg 嵌入视频帧中，实现消息和画面的完美对齐。
 *
 * @param data 待发送的数据，最大支持1kb（1000字节）的数据大小
 * @param repeatCount 发送数据次数
 * @return YES：消息已通过限制，等待后续视频帧发送；NO：消息被限制发送
 *
 * @note 本接口有以下限制：
 *       - 数据在接口调用完后不会被即时发送出去，而是从下一帧视频帧开始带在视频帧中发送。
 *       - 发送消息到房间内所有用户，每秒最多能发送30条消息（与 sendCustomCmdMsg 共享限制）。
 *       - 每个包最大为1KB，若发送大量数据，会导致视频码率增大，可能导致视频画质下降甚至卡顿（与 sendCustomCmdMsg 共享限制）。
 *       - 每个客户端每秒最多能发送总计8KB数据（与 sendCustomCmdMsg 共享限制）。
 *       - 若指定多次发送（repeatCount > 1），则数据会被带在后续的连续 repeatCount 个视频帧中发送出去，同样会导致视频码率增大。
 *       - 如果 repeatCount > 1，多次发送，接收消息 onRecvSEIMsg 回调也可能会收到多次相同的消息，需要去重。
 */
//- (BOOL)sendSEIMsg:(NSData *)data  repeatCount:(int)repeatCount;//TODO 复杂传参

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十一）背景混音相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 背景混音相关接口函数
/// @name 背景混音相关接口函数
/// @{
/**
 * 11.1 启动播放背景音乐
 *
 * @param path 音乐文件路径，支持的文件格式：aac, mp3, m4a。
 * @param beginNotify 音乐播放开始的回调通知
 * @param progressNotify 音乐播放的进度通知，单位毫秒
 * @param completeNotify 音乐播放结束的回调通知
 */
//- (void) playBGM:(NSString *)path
// withBeginNotify:(void (^)(NSInteger errCode))beginNotify
//withProgressNotify:(void (^)(NSInteger progressMS, NSInteger durationMS))progressNotify
//andCompleteNotify:(void (^)(NSInteger errCode))completeNotify;//TODO Block传参

/**
 * 11.2 停止播放背景音乐
 */
RCT_EXPORT_METHOD(stopBGM) {
    NSLog(@"ReactNativeTRTC stopBGM");
    [self.trtcCloud stopBGM];
}

/**
 * 11.3 暂停播放背景音乐
 */
RCT_EXPORT_METHOD(pauseBGM) {
    NSLog(@"ReactNativeTRTC pauseBGM");
    [self.trtcCloud pauseBGM];
}

/**
 * 11.4 继续播放背景音乐
 */
RCT_EXPORT_METHOD(resumeBGM) {
    NSLog(@"ReactNativeTRTC resumeBGM");
    [self.trtcCloud resumeBGM];
}

/**
 * 11.5 获取音乐文件总时长，单位毫秒
 *
 * @param path 音乐文件路径，如果 path 为空，那么返回当前正在播放的 music 时长。
 * @return 成功返回时长，失败返回-1
 */
//- (NSInteger)getBGMDuration:(NSString *)path;//TODO 带有返回值的传参

/**
 * 11.6 设置 BGM 播放进度
 *
 * @param pos 单位毫秒
 * @return 0：成功；-1：失败
 */
//- (int)setBGMPosition:(NSInteger)pos;//TODO 带有返回值的传参

/**
 * 11.7 设置背景音乐播放音量的大小
 *
 * 播放背景音乐混音时使用，用来控制背景音乐播放音量的大小，
 * 该接口会同时控制远端播放音量的大小和本地播放音量的大小，
 * 因此调用该接口后，setBGMPlayoutVolume和setBGMPublishVolume设置的音量值会被覆盖
 *
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
RCT_EXPORT_METHOD(setBGMVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setBGMVolume volume=%ld", volume);
    [self.trtcCloud setBGMVolume:volume];
}

/**
 * 11.8 设置背景音乐本地播放音量的大小
 *
 * 播放背景音乐混音时使用，用来控制背景音乐在本地播放时的音量大小。
 *
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
RCT_EXPORT_METHOD(setBGMPlayoutVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setBGMPlayoutVolume volume=%ld", volume);
    [self.trtcCloud setBGMPlayoutVolume:volume];
}

/**
 * 11.9 设置背景音乐远端播放音量的大小
 *
 * 播放背景音乐混音时使用，用来控制背景音乐在远端播放时的音量大小。
 *
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
RCT_EXPORT_METHOD(setBGMPublishVolume:(NSInteger)volume) {
    NSLog(@"ReactNativeTRTC setBGMPublishVolume volume=%ld", volume);
    [self.trtcCloud setBGMPublishVolume:volume];
}

/**
 * 11.10 设置混响效果 (目前仅支持 iOS)
 *
 * @param reverbType 混响类型，详情请参见 TXReverbType
 */
RCT_EXPORT_METHOD(setReverbType:(NSInteger)reverbType) {
    NSLog(@"ReactNativeTRTC setReverbType reverbType=%ld", reverbType);
    [self.trtcCloud setReverbType:reverbType];
}

/**
 * 11.10 设置变声类型 (目前仅支持 iOS)
 *
 * @param voiceChangerType 变声类型，详情请参见 TXVoiceChangerType
 */
RCT_EXPORT_METHOD(setVoiceChangerType:(NSInteger)voiceChangerType) {
    NSLog(@"ReactNativeTRTC setVoiceChangerType voiceChangerType=%ld", voiceChangerType);
    [self.trtcCloud setVoiceChangerType:voiceChangerType];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十二）音效相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 音效相关接口函数
/// @name 音效相关接口函数
/// @{
/**
 * 12.1 播放音效
 *
 * 每个音效都需要您指定具体的 ID，您可以通过该 ID 对音效的开始、停止、音量等进行设置。
 * 支持的文件格式：aac, mp3, m4a。
 *
 * @note 若您想同时播放多个音效，请分配不同的 ID 进行播放。因为使用同一个 ID 播放不同音效，SDK 会先停止播放旧的音效，再播放新的音效。
 *
 * @param effect 音效
 */
RCT_EXPORT_METHOD(playAudioEffect:(NSDictionary *)options) {
    NSLog(@"ReactNativeTRTC playAudioEffect options=%@", [options descriptionWithLocale:nil]);
    TRTCAudioEffectParam *effect = [[TRTCAudioEffectParam alloc]initWith:[options[@"effectId"] intValue] path:[options[@"path"] stringValue]];
    effect.effectId = [options[@"effectId"] intValue];
    effect.loopCount =  [options[@"loopCount"] intValue];
    effect.path =  [options[@"path"] stringValue];
    effect.publish = [options[@"publish"] boolValue];
    effect.volume = [options[@"volume"] intValue];
    [self.trtcCloud playAudioEffect:effect];
}
/**
 * 12.2 设置音效音量
 *
 * @note 该操作会覆盖通过 setAllAudioEffectsVolume 指定的整体音效音量。
 *
 * @param effectId 音效 ID
 * @param volume   音量大小，取值范围为0 - 100；默认值：100
 */
RCT_EXPORT_METHOD(setAudioEffectVolume:(int) effectId volume:(int) volume) {
    NSLog(@"ReactNativeTRTC setAudioEffectVolume effectId=%d, volume=%d", effectId, volume);
    [self.trtcCloud setAudioEffectVolume:effectId volume:volume];
}

/**
 * 12.3 停止音效
 *
 * @param effectId 音效 ID
 */
RCT_EXPORT_METHOD(stopAudioEffect:(int) effectId) {
    NSLog(@"ReactNativeTRTC stopAudioEffect effectId=%d", effectId);
    [self.trtcCloud stopAudioEffect:effectId];
}

/**
 * 12.4 停止所有音效
 */
RCT_EXPORT_METHOD(stopAllAudioEffects) {
    NSLog(@"ReactNativeTRTC stopAllAudioEffects");
    [self.trtcCloud stopAllAudioEffects];
}

/**
 * 12.5 设置所有音效音量
 *
 * @note 该操作会覆盖通过 setAudioEffectVolume 指定的单独音效音量。
 *
 * @param volume 音量大小，取值范围为0 - 100；默认值：100
 */
RCT_EXPORT_METHOD(setAllAudioEffectsVolume:(int) volume) {
    NSLog(@"ReactNativeTRTC setAllAudioEffectsVolume volume=%d", volume);
    [self.trtcCloud setAllAudioEffectsVolume:volume];
}

/**
 * 12.6 暂停音效
 *
 * @param effectId 音效 ID
 */
RCT_EXPORT_METHOD(pauseAudioEffect:(int)effectId) {
    NSLog(@"ReactNativeTRTC pauseAudioEffect effectId=%d", effectId);
    [self.trtcCloud pauseAudioEffect:effectId];
}

/**
 * 12.7 恢复音效
 *
 * @param effectId 音效 ID
 */
RCT_EXPORT_METHOD(resumeAudioEffect:(int)effectId) {
    NSLog(@"ReactNativeTRTC resumeAudioEffect effectId=%d", effectId);
    [self.trtcCloud resumeAudioEffect:effectId];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十三）设备和网络测试
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 设备和网络测试
/// @name 设备和网络测试
/// @{

/**
 * 13.1 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）
 *
 * 测速结果将会用于优化 SDK 接下来的服务器选择策略，因此推荐您在用户首次通话前先进行一次测速，这将有助于我们选择最佳的服务器。
 * 同时，如果测试结果非常不理想，您可以通过醒目的 UI 提示用户选择更好的网络。
 *
 * @note 测速本身会消耗一定的流量，所以也会产生少量额外的流量费用。
 *
 * @param sdkAppId 应用标识
 * @param userId 用户标识
 * @param userSig 用户签名
 * @param completion 测试回调，会分多次回调
 */
//- (void)startSpeedTest:(uint32_t)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig completion:(void(^)(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount))completion;//TODO 封装有block的接口

/**
 * 13.2 停止服务器测速
 */
RCT_EXPORT_METHOD(stopSpeedTest) {
    NSLog(@"ReactNativeTRTC stopSpeedTest");
    [self.trtcCloud stopSpeedTest];
}


#if TARGET_OS_OSX
/**
 * 13.3 开始进行摄像头测试
 *
 * @note 在测试过程中可以使用 setCurrentCameraDevice 接口切换摄像头。
 * @param view 预览控件所在的父控件
 */
//- (void)startCameraDeviceTestInView:(NSView *)view;//TODO 封装复杂传参的接口

/**
 * 13.4 结束视频测试预览
 */
RCT_EXPORT_METHOD(stopCameraDeviceTest) {
    NSLog(@"ReactNativeTRTC stopCameraDeviceTest");
    [self.trtcCloud stopCameraDeviceTest];
}


/**
 * 13.5 开始进行麦克风测试
 *
 * 该方法测试麦克风是否能正常工作，volume 的取值范围为0 - 100。
 */
//- (void)startMicDeviceTest:(NSInteger)interval testEcho:(void (^)(NSInteger volume))testEcho;//TODO 封装有block的接口

/**
 * 13.6 停止麦克风测试
 */
RCT_EXPORT_METHOD(stopMicDeviceTest) {
    NSLog(@"ReactNativeTRTC stopMicDeviceTest");
    [self.trtcCloud stopMicDeviceTest];
}

/**
 * 13.7 开始扬声器测试
 *
 * 该方法播放指定的音频文件测试播放设备是否能正常工作。如果能听到声音，说明播放设备能正常工作。
 */
//- (void)startSpeakerDeviceTest:(NSString*)audioFilePath onVolumeChanged:(void (^)(NSInteger volume, BOOL isLastFrame))volumeBlock;//TODO 封装有block的接口

/**
 * 13.8 停止扬声器测试
 */
RCT_EXPORT_METHOD(stopSpeakerDeviceTest) {
    NSLog(@"ReactNativeTRTC stopSpeakerDeviceTest");
    [self.trtcCloud stopSpeakerDeviceTest];
}

#endif

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十四）Log 相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////
/// @name Log 相关接口函数
/// @{

#pragma mark - LOG 相关接口函数
/**
 * 14.1 获取 SDK 版本信息
 */
//+ (NSString *)getSDKVersion;//TODO 封装有返回值的接口

/**
 * 14.2 设置 Log 输出级别
 *
 * @param level 参见 TRTCLogLevel，默认值：TRTC_LOG_LEVEL_NULL
 */
RCT_EXPORT_METHOD(setLogLevel:(NSInteger)level) {
    NSLog(@"ReactNativeTRTC setLogLevel level=%ld", level);
    [TRTCCloud setLogLevel:level];
}

/**
 * 14.3 启用或禁用控制台日志打印
 *
 * @param enabled 指定是否启用，默认为禁止状态
 */
RCT_EXPORT_METHOD(setConsoleEnabled:(BOOL)enabled) {
    NSLog(@"ReactNativeTRTC setConsoleEnabled enabled=%@", enabled?@"YES":@"NO");
    [TRTCCloud setConsoleEnabled:enabled];
}

/**
 * 14.4 启用或禁用 Log 的本地压缩。
 *
 * 开启压缩后，Log 存储体积明显减小，但需要腾讯云提供的 Python 脚本解压后才能阅读。
 * 禁用压缩后，Log 采用明文存储，可以直接用记事本打开阅读，但占用空间较大。
 *
 *  @param enabled 指定是否启用，默认为启动状态
 */
RCT_EXPORT_METHOD(setLogCompressEnabled:(BOOL)enabled) {
    NSLog(@"ReactNativeTRTC setLogCompressEnabled enabled=%@", enabled?@"YES":@"NO");
    [TRTCCloud setLogCompressEnabled:enabled];
}

/**
 * 14.5 修改日志保存路径
 *
 * @note 日志文件默认保存在 sandbox Documents/log 下，如需修改，必须在所有方法前调用。
 * @param path 存储日志路径
 */
RCT_EXPORT_METHOD(setLogDirPath:(NSString *)path) {
    NSLog(@"ReactNativeTRTC setLogDirPath path=%@", path);
    [TRTCCloud setLogDirPath:path];
}

/**
 * 14.6 设置日志回调
 */
//+ (void)setLogDelegate:(id<TRTCLogDelegate>)logDelegate;//TODO 复杂传参

/**
 * 14.7 显示仪表盘
 *
 * 仪表盘是状态统计和事件消息浮层 view，方便调试。
 * @param showType 0：不显示；1：显示精简版；2：显示全量版
 */
RCT_EXPORT_METHOD(showDebugView:(NSInteger)showType) {
    NSLog(@"ReactNativeTRTC showDebugView showType=%ld", showType);
    [self.trtcCloud showDebugView:showType];
}

/**
 * 14.8 设置仪表盘的边距
 *
 * 必须在 showDebugView 调用前设置才会生效
 * @param userId 用户 ID
 * @param top 仪表盘上边距，注意这里是基于 parentView 的百分比，margin 的取值范围是0 - 1
 * @param left 仪表盘左边距，注意这里是基于 parentView 的百分比，margin 的取值范围是0 - 1
 * @param bottom 仪表盘下边距，注意这里是基于 parentView 的百分比，margin 的取值范围是0 - 1
 * @param right 仪表盘右边距，注意这里是基于 parentView 的百分比，margin 的取值范围是0 - 1
 */
RCT_EXPORT_METHOD(setDebugViewMargin:(NSString *)userId top:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right) {
    NSLog(@"ReactNativeTRTC setDebugViewMargin userId=%@ top=%f, left=%f, bottom=%f, right=%f", userId, top, left, bottom, right);
    TXEdgeInsets margin = UIEdgeInsetsMake(top, left, bottom, right);
    [self.trtcCloud setDebugViewMargin:userId margin:margin];
}

/**
 * 14.9 调用实验性 API 接口
 *
 * @note 该接口用于调用一些实验性功能
 * @param jsonStr 接口及参数描述的 JSON 字符串
 */
RCT_EXPORT_METHOD(callExperimentalAPI:(NSString*)jsonStr) {
    NSLog(@"ReactNativeTRTC callExperimentalAPI jsonStr=%@", jsonStr);
    [self.trtcCloud callExperimentalAPI:jsonStr];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十五）弃用接口函数
//
/////////////////////////////////////////////////////////////////////////////////
#pragma mark - 弃用接口函数
/// @name 弃用接口函数
/// @{

/**
 * 15.1 设置麦克风的音量大小
 *
 * @deprecated v6.9 版本弃用
 * 播放背景音乐混音时使用，用来控制麦克风音量大小。
 *
 * @param volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
 */
//- (void)setMicVolumeOnMixing:(NSInteger)volume __attribute__((deprecated("use setAudioCaptureVolume instead")));

/**
 * 15.2 设置美颜、美白以及红润效果级别
 *
 * SDK 内部集成两套风格不同的磨皮算法，一套我们取名叫“光滑”，适用于美女秀场，效果比较明显。
 * 另一套我们取名“自然”，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param beautyStyle 美颜风格，光滑或者自然，光滑风格磨皮更加明显，适合娱乐场景。
 * @param beautyLevel 美颜级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
 * @param whitenessLevel 美白级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 * @param ruddinessLevel 红润级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setBeautyStyle:(TRTCBeautyStyle)beautyStyle beautyLevel:(NSInteger)beautyLevel
//        whitenessLevel:(NSInteger)whitenessLevel ruddinessLevel:(NSInteger)ruddinessLevel
//__attribute__((deprecated("use getBeautyManager instead")));

#if TARGET_OS_IPHONE
/**
 * 15.3 设置大眼级别（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param eyeScaleLevel 大眼级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setEyeScaleLevel:(float)eyeScaleLevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.4 设置瘦脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 *  @param faceScaleLevel 瘦脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setFaceScaleLevel:(float)faceScaleLevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.5 设置V脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param faceVLevel V脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setFaceVLevel:(float)faceVLevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.6 设置下巴拉伸或收缩（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param chinLevel 下巴拉伸或收缩级别，取值范围 -9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
 */
//- (void)setChinLevel:(float)chinLevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.7 设置短脸级别（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param faceShortlevel 短脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setFaceShortLevel:(float)faceShortlevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.8 设置瘦鼻级别（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param noseSlimLevel 瘦鼻级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
//- (void)setNoseSlimLevel:(float)noseSlimLevel __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.9 选择使用哪一款 AI 动效挂件（企业版有效，其它版本设置此参数无效）
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param tmplPath 动效文件路径
 */
//- (void)selectMotionTmpl:(NSString *)tmplPath __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.10 设置动效静音（企业版有效，其它版本设置此参数无效）
 *
 * 部分挂件本身会有声音特效，通过此 API 可以关闭特效播放时所带的声音效果。
 *
 * @deprecated v6.9 版本弃用，请使用 TXBeautyManager 设置美颜功能
 * @param motionMute YES：静音；NO：不静音。
 */
//- (void)setMotionMute:(BOOL)motionMute __attribute__((deprecated("use getBeautyManager instead")));

#elif TARGET_OS_MAC
/**
 * 15.11 启动屏幕分享
 *
 * @deprecated v7.2 版本弃用，请使用 startScreenCapture:streamType:encParam: 启动屏幕分享
 * @param view 渲染控件所在的父控件
 */
//- (void)startScreenCapture:(NSView *)view __attribute__((deprecated("use startScreenCapture:streamType:encParam: instead")));

#endif

/**
 * 15.12 设置指定素材滤镜特效
 *
 * @deprecated v7.2 版本弃用，请使用 TXBeautyManager 设置素材滤镜
 * @param image 指定素材，即颜色查找表图片。**必须使用 png 格式**
 */
//- (void)setFilter:(TXImage *)image __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.13 设置滤镜浓度
 *
 * 在美女秀场等应用场景里，滤镜浓度的要求会比较高，以便更加突显主播的差异。
 * 我们默认的滤镜浓度是0.5，如果您觉得滤镜效果不明显，可以使用下面的接口进行调节。
 *
 * @deprecated v7.2 版本弃用，请使用 TXBeautyManager setFilterStrength 接口
 * @param concentration 从0到1，越大滤镜效果越明显，默认值为0.5。
 */
//- (void)setFilterConcentration:(float)concentration __attribute__((deprecated("use getBeautyManager instead")));

/**
 * 15.14 设置绿幕背景视频（企业版有效，其它版本设置此参数无效）
 *
 * 此处的绿幕功能并非智能抠背，需要被拍摄者的背后有一块绿色的幕布来辅助产生特效
 *
 * @deprecated v7.2 版本弃用，请使用 TXBeautyManager 设置绿幕背景视频
 * @param file 视频文件路径。支持 MP4; nil 表示关闭特效。
 */
//- (void)setGreenScreenFile:(NSURL *)file __attribute__((deprecated("use getBeautyManager instead")));
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）错误事件和警告事件
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 错误事件和警告事件
/// @{
/**
 * 1.1 错误回调：SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示。
 *
 * @param errCode 错误码
 * @param errMsg  错误信息
 * @param extInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo{
    NSLog(@"ReactNativeTRTC onError errCode=%ld errMsg=%@ extInfo=%@", errCode, errMsg, [extInfo descriptionWithLocale:nil]);
    [self sendEventWithName:@"ReactNativeTRTC_onError" body:@{@"errCode":@(errCode), @"errMsg":errMsg, @"extInfo":extInfo}];
}

/**
 * 1.2 警告回调：用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。
 *
 * @param warningCode 警告码
 * @param warningMsg 警告信息
 * @param extInfo 扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(nullable NSString *)warningMsg extInfo:(nullable NSDictionary*)extInfo{
    NSLog(@"ReactNativeTRTC onWarning warningCode=%ld warningMsg=%@ extInfo=%@", warningCode, warningMsg, [extInfo descriptionWithLocale:nil]);
    [self sendEventWithName:@"ReactNativeTRTC_onWarning" body:@{@"warningCode":@(warningCode), @"warningMsg":warningMsg, @"extInfo":extInfo}];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）房间事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 房间事件回调
/// @{
/**
 * 2.1 已加入房间的回调
 *
 * 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 SDK 的 onEnterRoom(result) 回调：
 *
 * - 如果加入成功，result 会是一个正数（result > 0），代表加入房间的时间消耗，单位是毫秒（ms）。
 * - 如果加入失败，result 会是一个负数（result < 0），代表进房失败的错误码。
 * 进房失败的错误码含义请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 *
 * @note 在 Ver6.6 之前的版本，只有进房成功会抛出 onEnterRoom(result) 回调，进房失败由 onError() 回调抛出。
 *       在 Ver6.6 及之后改为：进房成功返回正的 result，进房失败返回负的 result，同时进房失败也会有 onError() 回调抛出。
 *
 * @param result result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
 */
- (void)onEnterRoom:(NSInteger)result{
    NSLog(@"ReactNativeTRTC onEnterRoom result=%ld", result);
    [self sendEventWithName:@"ReactNativeTRTC_onEnterRoom" body:@{@"result":@(result)}];
}

/**
 * 2.2 离开房间的事件回调
 *
 * 调用 TRTCCloud 中的 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。
 * 待资源释放完毕，SDK 会通过 onExitRoom() 回调通知到您。
 *
 * 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来之后再执行相关操作。
 * 否则可能会遇到音频设备（例如 iOS 里的 AudioSession）被占用等各种异常问题。
 *
 * @param reason 离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散。
 */
- (void)onExitRoom:(NSInteger)reason{
    NSLog(@"ReactNativeTRTC onExitRoom reason=%ld", reason);
    [self sendEventWithName:@"ReactNativeTRTC_onExitRoom" body:@{@"reason":@(reason)}];
}

/**
 * 2.3 切换角色的事件回调
 *
 * 调用 TRTCCloud 中的 switchRole() 接口会切换主播和观众的角色，该操作会伴随一个线路切换的过程，
 * 待 SDK 切换完成后，会抛出 onSwitchRole() 事件回调。
 *
 * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 * @param errMsg  错误信息。
 */
- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
    NSLog(@"ReactNativeTRTC onSwitchRole errCode=%ld, errMsg=%@", errCode, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onSwitchRole" body:@{@"errCode":@(errCode), @"errMsg":errMsg}];
}

/**
 * 2.4 请求跨房通话（主播 PK）的结果回调
 *
 * 调用 TRTCCloud 中的 connectOtherRoom() 接口会将两个不同房间中的主播拉通视频通话，也就是所谓的“主播PK”功能。
 * 调用者会收到 onConnectOtherRoom() 回调来获知跨房通话是否成功，
 * 如果成功，两个房间中的所有用户都会收到 PK 主播的 onUserVideoAvailable() 回调。
 *
 * @param userId 要 PK 的目标主播 userid。
 * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 * @param errMsg  错误信息。
 */
- (void)onConnectOtherRoom:(NSString*)userId errCode:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
    NSLog(@"ReactNativeTRTC onConnectOtherRoom errCode=%ld, errMsg=%@", errCode, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onConnectOtherRoom" body:@{@"errCode":@(errCode), @"errMsg":errMsg}];
}

/**
 * 2.5 结束跨房通话（主播 PK）的结果回调
 */
- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
    NSLog(@"ReactNativeTRTC onDisconnectOtherRoom errCode=%ld, errMsg=%@", errCode, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onDisconnectOtherRoom" body:@{@"errCode":@(errCode), @"errMsg":errMsg}];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）成员事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 成员事件回调
/// @{

/**
 * 3.1 有用户加入当前房间
 *
 * 出于性能方面的考虑，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户进入房间都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：该场景不限制观众的数量，如果任何用户进出都抛出回调会引起很大的性能损耗，所以该场景下只有主播进入房间时才会触发该通知，观众进入房间不会触发该通知。
 *
 *
 * @note 注意 onRemoteUserEnterRoom 和 onRemoteUserLeaveRoom 只适用于维护当前房间里的“成员列表”，如果需要显示远程画面，建议使用监听 onUserVideoAvailable() 事件回调。
 *
 * @param userId 用户标识
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId{
    NSLog(@"ReactNativeTRTC onRemoteUserEnterRoom userId=%@", userId);
    [self sendEventWithName:@"ReactNativeTRTC_onRemoteUserEnterRoom" body:@{@"userId":userId}];
}

/**
 * 3.2 有用户离开当前房间
 *
 * 与 onRemoteUserEnterRoom 相对应，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户的离开都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：只有主播离开房间时才会触发该通知，观众离开房间不会触发该通知。
 *
 * @param userId 用户标识
 * @param reason 离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason{
    NSLog(@"ReactNativeTRTC onRemoteUserLeaveRoom userId=%@, reason=%ld", userId, reason);
    [self sendEventWithName:@"ReactNativeTRTC_onRemoteUserLeaveRoom" body:@{@"userId":userId, @"reason":@(reason)}];
}

/**
 * 3.3 远端用户是否存在可播放的主路画面（一般用于摄像头）
 *
 * 当您收到 onUserVideoAvailable(userid, YES) 通知时，表示该路画面已经有可用的视频数据帧到达。
 * 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。
 * 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
 *
 * 当您收到 onUserVideoAvailable(userid, NO) 通知时，表示该路远程画面已被关闭，
 * 可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
 *
 * @param userId 用户标识
 * @param available 画面是否开启
 */
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
    NSLog(@"ReactNativeTRTC onUserVideoAvailable userId=%@, available=%@", userId, available?@"YES":@"NO");
    [self sendEventWithName:@"ReactNativeTRTC_onUserVideoAvailable" body:@{@"userId":userId, @"available":@(available)}];
}

/**
 * 3.4 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
 *
 * @note 显示辅路画面使用的函数是 startRemoteSubStreamView() 而非 startRemoteView()。
 * @param userId 用户标识
 * @param available 屏幕分享是否开启
 */
- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available{
    NSLog(@"ReactNativeTRTC onUserSubStreamAvailable userId=%@, available=%@", userId, available?@"YES":@"NO");
    [self sendEventWithName:@"ReactNativeTRTC_onUserSubStreamAvailable" body:@{@"userId":userId, @"available":@(available)}];
}

/**
 * 3.5 远端用户是否存在可播放的音频数据
 *
 * @param userId 用户标识
 * @param available 声音是否开启
 */
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available{
    NSLog(@"ReactNativeTRTC onUserAudioAvailable userId=%@, available=%@", userId, available?@"YES":@"NO");
    [self sendEventWithName:@"ReactNativeTRTC_onUserAudioAvailable" body:@{@"userId":userId, @"available":@(available)}];
}

/**
 * 3.6 开始渲染本地或远程用户的首帧画面
 *
 * 如果 userId == nil，代表开始渲染本地采集的摄像头画面，需要您先调用 startLocalPreview 触发。
 * 如果 userId != nil，代表开始渲染远程用户的首帧画面，需要您先调用 startRemoteView 触发。
 *
 * @note 只有当您调用 startLocalPreivew()、startRemoteView() 或 startRemoteSubStreamView() 之后，才会触发该回调。
 *
 * @param userId 本地或远程用户 ID，如果 userId == nil 代表本地，userId != nil 代表远程。
 * @param streamType 视频流类型：摄像头或屏幕分享。
 * @param width  画面宽度
 * @param height 画面高度
 */
- (void)onFirstVideoFrame:(NSString*)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height{
    NSLog(@"ReactNativeTRTC onFirstVideoFrame streamType=%ld width=%d height=%d", streamType, width, height);
    [self sendEventWithName:@"ReactNativeTRTC_onFirstVideoFrame" body:@{@"width":@(width), @"height":@(height), @"streamType":@(streamType)}];
}

/**
 * 3.7 开始播放远程用户的首帧音频（本地声音暂不通知）
 *
 * @param userId 远程用户 ID。
 */
- (void)onFirstAudioFrame:(NSString*)userId{
    NSLog(@"ReactNativeTRTC onFirstAudioFrame userId=%@", userId);
    [self sendEventWithName:@"ReactNativeTRTC_onFirstAudioFrame" body:@{@"userId":userId}];
}

/**
 * 3.8 首帧本地视频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalPreview() 成功后开始摄像头采集，并将采集到的画面进行编码。
 * 当 SDK 成功向云端送出第一帧视频数据后，会抛出这个回调事件。
 *
 * @param streamType 视频流类型，主画面、小画面或辅流画面（屏幕分享）
 */
- (void)onSendFirstLocalVideoFrame: (TRTCVideoStreamType)streamType{
    NSLog(@"ReactNativeTRTC onSendFirstLocalVideoFrame streamType=%ld", streamType);
    [self sendEventWithName:@"ReactNativeTRTC_onSendFirstLocalVideoFrame" body:@{@"streamType":@(streamType)}];
}

/**
 * 3.9 首帧本地音频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalAudio() 成功后开始麦克风采集，并将采集到的声音进行编码。
 * 当 SDK 成功向云端送出第一帧音频数据后，会抛出这个回调事件。
 */
- (void)onSendFirstLocalAudioFrame{
    NSLog(@"ReactNativeTRTC onSendFirstLocalAudioFrame");
    [self sendEventWithName:@"ReactNativeTRTC_onSendFirstLocalAudioFrame" body:nil];
}

/**
 * 3.10 废弃接口：有主播加入当前房间
 *
 * 该回调接口可以被看作是 onRemoteUserEnterRoom 的废弃版本，不推荐使用。请使用 onUserVideoAvailable 或 onRemoteUserEnterRoom 进行替代。
 *
 * @note 该接口已被废弃，不推荐使用
 *
 * @param userId 用户标识
 */
- (void)onUserEnter:(NSString *)userId DEPRECATED_ATTRIBUTE{
    NSLog(@"ReactNativeTRTC onUserEnter userId=%@", userId);
    [self sendEventWithName:@"ReactNativeTRTC_onUserEnter" body:@{@"userId":userId}];
}

/**
 * 3.11 废弃接口： 有主播离开当前房间
 *
 * 该回调接口可以被看作是 onRemoteUserLeaveRoom 的废弃版本，不推荐使用。请使用 onUserVideoAvailable 或 onRemoteUserEnterRoom 进行替代。
 *
 * @note 该接口已被废弃，不推荐使用
 *
 * @param userId 用户标识
 * @param reason 离开原因。
 */
- (void)onUserExit:(NSString *)userId reason:(NSInteger)reason DEPRECATED_ATTRIBUTE{
    NSLog(@"ReactNativeTRTC onUserExit userId=%@, reason=%ld", userId, reason);
    [self sendEventWithName:@"ReactNativeTRTC_onUserExit" body:@{@"userId":userId, @"reason":@(reason)}];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）统计和质量回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 统计和质量回调
/// @{

/**
 * 4.1 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量
 *
 * @note userId == nil 代表自己当前的视频质量
 *
 * @param localQuality 上行网络质量
 * @param remoteQuality 下行网络质量
 */
//- (void)onNetworkQuality: (TRTCQualityInfo*)localQuality remoteQuality:(NSArray<TRTCQualityInfo*>*)remoteQuality;//TODO 复杂传参

/**
 * 4.2 技术指标统计回调
 *
 * 如果您是熟悉音视频领域相关术语，可以通过这个回调获取 SDK 的所有技术指标。
 * 如果您是首次开发音视频相关项目，可以只关注 onNetworkQuality 回调。
 *
 * @param statistics 统计数据，包括本地和远程的
 * @note 每2秒回调一次
 */
//- (void)onStatistics: (TRTCStatistics *)statistics;//TODO 复杂传参

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）服务器事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 服务器事件回调
/// @{

/**
 * 5.1 SDK 跟服务器的连接断开
 */
- (void)onConnectionLost{
    NSLog(@"ReactNativeTRTC onConnectionLost");
    [self sendEventWithName:@"ReactNativeTRTC_onConnectionLost" body:nil];
}

/**
 * 5.2 SDK 尝试重新连接到服务器
 */
- (void)onTryToReconnect{
    NSLog(@"ReactNativeTRTC onTryToReconnect");
    [self sendEventWithName:@"ReactNativeTRTC_onTryToReconnect" body:nil];
}

/**
 * 5.3 SDK 跟服务器的连接恢复
 */
- (void)onConnectionRecovery{
    NSLog(@"ReactNativeTRTC onConnectionRecovery");
    [self sendEventWithName:@"ReactNativeTRTC_onConnectionRecovery" body:nil];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）硬件设备事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 硬件设备事件回调
/// @{

/**
 * 6.1 摄像头准备就绪
 */
- (void)onCameraDidReady{
    NSLog(@"ReactNativeTRTC onCameraDidReady");
    [self sendEventWithName:@"ReactNativeTRTC_onCameraDidReady" body:nil];
}

/**
 * 6.2 麦克风准备就绪
 */
- (void)onMicDidReady{
    NSLog(@"ReactNativeTRTC onMicDidReady");
    [self sendEventWithName:@"ReactNativeTRTC_onMicDidReady" body:nil];
}

#if TARGET_OS_IPHONE
/**
 * 6.3 音频路由发生变化（仅 iOS），音频路由即声音由哪里输出（扬声器、听筒）
 *
 * @param route     当前音频路由
 * @param fromRoute 变更前的音频路由
 */
- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute{
    NSLog(@"ReactNativeTRTC onAudioRouteChanged route=%ld, fromRoute=%ld", route, fromRoute);
    [self sendEventWithName:@"ReactNativeTRTC_onAudioRouteChanged" body:@{@"route":@(route), @"fromRoute":@(fromRoute)}];
}
#endif

/**
 * 6.4 用于提示音量大小的回调,包括每个 userId 的音量和远端总音量
 *
 * 您可以通过调用 TRTCCloud 中的 enableAudioVolumeEvaluation 接口来开关这个回调或者设置它的触发间隔。
 * 需要注意的是，调用 enableAudioVolumeEvaluation 开启音量回调后，无论频道内是否有人说话，都会按设置的时间间隔调用这个回调;
 * 如果没有人说话，则 userVolumes 为空，totalVolume 为0。
 *
 * @param userVolumes 所有正在说话的房间成员的音量，取值范围0 - 100。
 * @param totalVolume 所有远端成员的总音量, 取值范围0 - 100。
 * @note userId 为 nil 时表示自己的音量，userVolumes 内仅包含正在说话（音量不为0）的用户音量信息。
 */
//- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume{}//TODO 复杂传参


#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 6.5 本地设备通断回调
 *
 * @param deviceId 设备 ID
 * @param deviceType 设备类型
 * @param state   0：设备断开；1：设备连接
 */
- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state{
    NSLog(@"ReactNativeTRTC onDevice deviceId=%@, deviceType=%ld, state=%ld", deviceId, deviceType, state);
    [self sendEventWithName:@"ReactNativeTRTC_onDevice" body:@{@"deviceId":deviceId, @"deviceType":@(deviceType), @"state":state}];
}

#endif

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）自定义消息的接收回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 自定义消息的接收回调
/// @{

/**
 * 7.1 收到自定义消息回调
 *
 * 当房间中的某个用户使用 sendCustomCmdMsg 发送自定义消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 接口接收消息
 *
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param seq   消息序号
 * @param message 消息数据
 */
//- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message{}//TODO 复杂传参

/**
 * 7.2 自定义消息丢失回调
 *
 * 实时音视频使用 UDP 通道，即使设置了可靠传输（reliable），也无法确保100@%不丢失，只是丢消息概率极低，能满足常规可靠性要求。
 * 在发送端设置了可靠运输（reliable）后，SDK 都会通过此回调通知过去时间段内（通常为5s）传输途中丢失的自定义消息数量统计信息。
 *
 * @note  只有在发送端设置了可靠传输（reliable），接收方才能收到消息的丢失回调
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param errCode 错误码
 * @param missed 丢失的消息数量
 */
- (void)onMissCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID errCode:(NSInteger)errCode missed:(NSInteger)missed{
    NSLog(@"ReactNativeTRTC onMissCustomCmdMsgUserId userId=%@, cmdID=%ld, errCode=%ld", userId, cmdID, errCode);
    [self sendEventWithName:@"ReactNativeTRTC_onMissCustomCmdMsgUserId" body:@{@"userId":userId, @"cmdID":@(cmdID), @"errCode":@(errCode)}];
}

/**
 * 7.3 收到 SEI 消息的回调
 *
 * 当房间中的某个用户使用 sendSEIMsg 发送数据时，房间中的其它用户可以通过 onRecvSEIMsg 接口接收数据。
 *
 * @param userId   用户标识
 * @param message  数据
 */
//- (void)onRecvSEIMsg:(NSString *)userId message:(NSData*)message;//TODO 复杂传参

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）CDN 旁路回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name CDN 旁路转推回调
/// @{
    
/**
 * 8.1 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onStartPublishing:(int)err errMsg:(NSString*)errMsg{
    NSLog(@"ReactNativeTRTC onStartPublishing err=%d, errMsg=%@", err, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onStartPublishing" body:@{@"err":@(err), @"errMsg":errMsg}];
}

/**
 * 8.2 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onStopPublishing:(int)err errMsg:(NSString*)errMsg{
    NSLog(@"ReactNativeTRTC onStopPublishing err=%d, errMsg=%@", err, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onStopPublishing" body:@{@"err":@(err), @"errMsg":errMsg}];
}

/**
 * 8.3 启动旁路推流到 CDN 完成的回调
 *
 * 对应于 TRTCCloud 中的 startPublishCDNStream() 接口
 *
 * @note Start 回调如果成功，只能说明转推请求已经成功告知给腾讯云，如果目标 CDN 有异常，还是有可能会转推失败。
 */
- (void)onStartPublishCDNStream:(int)err errMsg:(NSString *)errMsg{
    NSLog(@"ReactNativeTRTC onStartPublishCDNStream err=%d, errMsg=%@", err, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onStartPublishCDNStream" body:@{@"err":@(err), @"errMsg":errMsg}];
}

/**
 * 8.4 停止旁路推流到 CDN 完成的回调
 *
 * 对应于 TRTCCloud 中的 stopPublishCDNStream() 接口
 *
 */
- (void)onStopPublishCDNStream:(int)err errMsg:(NSString *)errMsg{
    NSLog(@"ReactNativeTRTC onStopPublishCDNStream err=%d, errMsg=%@", err, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onStopPublishCDNStream" body:@{@"err":@(err), @"errMsg":errMsg}];
}

/**
 * 8.5 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString*)errMsg{
    NSLog(@"ReactNativeTRTC onSetMixTranscodingConfig err=%d, errMsg=%@", err, errMsg);
    [self sendEventWithName:@"ReactNativeTRTC_onSetMixTranscodingConfig" body:@{@"err":@(err), @"errMsg":errMsg}];
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）音效回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 音效回调
/// @{
/**
 * 播放音效结束回调
 *
 * @param effectId 音效 ID
 * @param code 0表示播放正常结束；其他表示异常结束
 */
- (void)onAudioEffectFinished:(int) effectId code:(int) code{
    NSLog(@"ReactNativeTRTC onAudioEffectFinished effectId=%d, effectId=%d", effectId, effectId);
    [self sendEventWithName:@"ReactNativeTRTC_onAudioEffectFinished" body:@{@"effectId":@(effectId), @"code":@(code)}];
}
/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）屏幕分享回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 屏幕分享回调
/// @{
/**
 * 10.1 当屏幕分享开始时，SDK 会通过此回调通知
 */
- (void)onScreenCaptureStarted{
    NSLog(@"ReactNativeTRTC onScreenCaptureStarted");
    [self sendEventWithName:@"ReactNativeTRTC_onScreenCaptureStarted" body:nil];
}

/**
 * 10.2 当屏幕分享暂停时，SDK 会通过此回调通知
 *
 * @param reason 原因，0：用户主动暂停；1：屏幕窗口不可见暂停
 */
- (void)onScreenCapturePaused:(int)reason{
    NSLog(@"ReactNativeTRTC onScreenCapturePaused reason=%d", reason);
    [self sendEventWithName:@"ReactNativeTRTC_onScreenCapturePaused" body:@{@"reason":@(reason)}];
}

/**
 * 10.3 当屏幕分享恢复时，SDK 会通过此回调通知
 *
 * @param reason 恢复原因，0：用户主动恢复；1：屏幕窗口恢复可见从而恢复分享
 */
- (void)onScreenCaptureResumed:(int)reason{
    NSLog(@"ReactNativeTRTC onScreenCaptureResumed reason=%d", reason);
    [self sendEventWithName:@"ReactNativeTRTC_onScreenCaptureResumed" body:@{@"reason":@(reason)}];
}

/**
 * 10.4 当屏幕分享停止时，SDK 会通过此回调通知
 *
 * @param reason 停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止
 */
- (void)onScreenCaptureStoped:(int)reason{
    NSLog(@"ReactNativeTRTC onScreenCaptureStoped reason=%d", reason);
    [self sendEventWithName:@"ReactNativeTRTC_onScreenCaptureStoped" body:@{@"reason":@(reason)}];
}
/// @}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十一）自定义视频渲染回调
//
/////////////////////////////////////////////////////////////////////////////////
//#pragma mark - TRTCVideoRenderDelegate
/// @addtogroup TRTCCloudDelegate_ios
/// @{
/**
 * 视频数据帧的自定义处理回调
 */
//@protocol TRTCVideoRenderDelegate <NSObject>
/**
 * 自定义视频渲染回调
 *
 * @param frame  待渲染的视频帧信息
 * @param userId 视频源的 userId，如果是本地视频回调（setLocalVideoRenderDelegate），该参数可以忽略
 * @param streamType 视频源类型，例如，使用摄像头画面或屏幕分享画面等
 */
//@optional
//- (void) onRenderVideoFrame:(TRTCVideoFrame * _Nonnull)frame userId:(NSString* __nullable)userId streamType:(TRTCVideoStreamType)streamType;

//@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十二）音频数据回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 声音数据帧的自定义处理回调
 */
//@protocol TRTCAudioFrameDelegate <NSObject>
//@optional
/**
 * 本地麦克风采集到的音频数据回调
 *
 * @param frame      音频数据
 * @note - 请不要在此回调函数中做任何耗时操作，建议直接拷贝到另一线程进行处理，否则会导致各种声音问题。
 * @note - 此接口回调出的音频数据支持修改。
 * @note - 此接口回调出的音频时间帧长固定为0.02s。
           由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
           以SDK默认的音频录制格式48000采样率、单声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 1 × 16bit = 15360bit = 1920字节】。
 * @note - 此接口回调出的音频数据包含背景音、音效、混响等前处理效果。
 */
//- (void) onCapturedAudioFrame:(TRTCAudioFrame *)frame;

/**
 * 混音前的每一路远程用户的音频数据（例如您要对某一路的语音进行文字转换，必须要使用这里的原始数据，而不是混音之后的数据）
 *
 * @param frame      音频数据
 * @param userId     用户标识
 * @note - 请不要在此回调函数中做任何耗时操作，建议直接拷贝到另一线程进行处理，否则会导致各种声音问题。
 * @note - 此接口回调出的音频数据是只读的，不支持修改。
 */
//- (void) onPlayAudioFrame:(TRTCAudioFrame *)frame userId:(NSString *)userId;

/**
 * 各路音频数据混合后的音频数据
 *
 * @param frame      音频数据
 * @note - 请不要在此回调函数中做任何耗时操作，建议直接拷贝到另一线程进行处理，否则会导致各种声音问题。
 * @note - 此接口回调出的音频数据支持修改。
 * @note - 此接口回调出的音频时间帧长固定为0.02s。
           由时间帧长转化为字节帧长的公式为【采样率 × 时间帧长 × 声道数 × 采样点位宽】。
           以SDK默认的音频播放格式48000采样率、双声道、16采样点位宽为例，字节帧长为【48000 × 0.02s × 2 × 16bit = 30720bit = 3840字节】。
 * @note - 此接口回调出的音频数据是各路音频播放数据的混合,不包含耳返的音频数据。
 */
//- (void) onMixedPlayAudioFrame:(TRTCAudioFrame *)frame;

//@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十三）Log 信息回调
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 日志相关回调
 *
 * 建议在一个比较早初始化的类中设置回调委托对象，例如 AppDelegate
 */
//@protocol TRTCLogDelegate <NSObject>
/**
 * 有日志打印时的回调
 *
 * @param log 日志内容
 * @param level 日志等级，参见 TRTCLogLevel
 * @param module 值暂无具体意义，目前为固定值 TXLiteAVSDK
 */
//@optional
//-(void) onLog:(nullable NSString*)log LogLevel:(TRTCLogLevel)level WhichModule:(nullable NSString*)module;

@end
