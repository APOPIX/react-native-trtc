//
//  VideoView.h
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/5/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoView : UIImageView
@property (nonatomic,retain) NSString *remoteUserID;
@property (nonatomic) BOOL showLocalPreview;
@end

NS_ASSUME_NONNULL_END
