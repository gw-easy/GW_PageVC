//
//  GW_MenuItem.h
//  testPageC
//
//  Created by gw on 2018/6/27.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_PageViewModel.h"
typedef NS_ENUM(NSUInteger, GW_MenuItemState) {
    GW_MenuItemStateSelected,
    GW_MenuItemStateNormal,
};
NS_ASSUME_NONNULL_BEGIN
@class GW_MenuItem;
@protocol GW_MenuItemDelegate <NSObject>
@optional
- (void)didPressedMenuItem:(GW_MenuItem *)menuItem;
@end
@interface GW_MenuItem : UILabel

@property (assign, nonatomic) CGFloat rate;           ///> 设置 rate, 并刷新标题状态 (0~1)
@property (assign, nonatomic) CGFloat normalSize;     ///> Normal状态的字体大小，默认大小为15
@property (assign, nonatomic) CGFloat selectedSize;   ///> Selected状态的字体大小，默认大小为18
@property (strong, nonatomic) UIColor *normalColor;   ///> normal状态的字体颜色，默认为黑色 (可动画)
@property (strong, nonatomic) UIColor *selectedColor; ///> Selected状态的字体颜色，默认为红色 (可动画)
@property (assign, nonatomic) CGFloat speedFactor;    ///> 进度条的速度因数，默认 15，越小越快, 必须大于0
@property (weak, nonatomic) id<GW_MenuItemDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL selected;

@property (weak, nonatomic) GW_PageViewModel *miModel;

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation;

@end
NS_ASSUME_NONNULL_END
