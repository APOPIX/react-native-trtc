//
//  VideoView.m
//  TRTCSimpleDemo
//
//  Created by 丁赞涵 on 2020/5/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "VideoView.h"
#import "ReactNativeTRTC.h"

@implementation VideoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 200,300)]) {
        self.userInteractionEnabled=YES;
        self.hidden=NO;
    }
    return self;
}

- (void)setShowLocalPreview:(BOOL)isShow {
    _showLocalPreview = isShow;
    NSLog(@"%f",self.frame.size.height);
  if (_showLocalPreview) {
    [[ReactNativeTRTC shareInstance] setLocalVideoView:self];
    [[ReactNativeTRTC shareInstance] startLocalPreview:false];
  }
}

-(void)setRemoteUserID:(NSString*)remoteUserID {
    _remoteUserID = remoteUserID;
    [[ReactNativeTRTC shareInstance]addRemoteView:self userId:remoteUserID];
    [[ReactNativeTRTC shareInstance] startRemoteView:_remoteUserID];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    for(UIView* view in self.subviews){
        [view setFrame:self.bounds];
    }
}



//- (void)drawRect:(CGRect)rect {
//    CGContextRef con = UIGraphicsGetCurrentContext();
//    CGContextAddEllipseInRect(con, CGRectMake(0,0,100,200));
//    CGContextSetRGBFillColor(con, 0, 0, 1, 1);
//    CGContextFillPath(con);
//}

@end
