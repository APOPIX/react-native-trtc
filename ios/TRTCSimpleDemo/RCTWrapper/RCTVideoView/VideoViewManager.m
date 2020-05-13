//
//  VideoViewManager.m
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/5/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "VideoViewManager.h"
#import "VideoView.h"
@implementation VideoViewManager
RCT_EXPORT_MODULE(RNTVideoView);

- (UIView *)view
{
  return [[VideoView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(showLocalPreview, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(remoteUserID, NSInteger, VideoView) {
  view.remoteUserID = [RCTConvert NSString:json];
}

@end
