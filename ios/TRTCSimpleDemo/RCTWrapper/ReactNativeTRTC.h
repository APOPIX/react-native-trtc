//
//  ReactNativeTRTC.h
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/5/1.
//  Copyright © 2020 Tencent. All rights reserved.
//

#ifndef ReactNativeTRTC_h
#define ReactNativeTRTC_h
#import <React/RCTBridgeModule.h>
#import "RCTEventEmitter.h"
#import "TRTCCloud.h"

@interface ReactNativeTRTC : RCTEventEmitter< TRTCCloudDelegate,RCTBridgeModule>
+(instancetype) shareInstance;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) UIView *localVideoView;
@property (strong, atomic) NSMutableDictionary* remoteViewDic;

-(void) addRemoteView:(UIView *)view userId:(NSString *)userId;
-(void) removeRemoteView:(NSString *)userId;
-(void) startRemoteView:(NSString *)userId;
-(void) startLocalPreview:(BOOL)frontCamera;


@end

#endif /* ReactNativeTRTC_h */
