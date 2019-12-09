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
//点击事件
- (void)gw_didPressedMenuItem:(GW_MenuItem *)menuItem;
@end
@interface GW_MenuItem : UILabel
///> 设置 rate, 并刷新标题状态 (0~1)
@property (assign, nonatomic) CGFloat rate;

//配置数据
@property (strong ,nonatomic) GW_PageViewModel *itemM;

@property (weak, nonatomic) id<GW_MenuItemDelegate> delegate;
//是否是选中状态
@property (assign, nonatomic, readonly) BOOL selected;


/// 设置选择的item
/// @param selected 是否选择
/// @param animation 动画
- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation;

@end
NS_ASSUME_NONNULL_END
