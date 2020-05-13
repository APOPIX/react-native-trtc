//
//  MainViewControllerBridge.h
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/4/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

#ifndef MainViewControllerBridge_h
#define MainViewControllerBridge_h
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(MainViewController, NSObject)

RCT_EXTERN_METHOD(presentStoryboard:(NSString *)name)

@end
#endif /* MainViewControllerBridge_h */
