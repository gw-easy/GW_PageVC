//
//  GW_ProgressView.h
//  testPageC
//
//  Created by gw on 2018/6/27.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface GW_ProgressView : UIView
@property (strong, nonatomic) NSArray *itemFrames;
@property (assign, nonatomic) CGColorRef color;
@property (assign, nonatomic) CGFloat progress;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (assign, nonatomic) CGFloat speedFactor;
@property (assign, nonatomic) CGFloat cornerRadius;
/// 调皮属性，用于实现新腾讯视频效果
@property (assign, nonatomic) BOOL naughty;
@property (assign, nonatomic) BOOL isTriangle;
@property (assign, nonatomic) BOOL hollow;
@property (assign, nonatomic) BOOL hasBorder;

- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToPostion:(NSInteger)pos;
@end
NS_ASSUME_NONNULL_END
