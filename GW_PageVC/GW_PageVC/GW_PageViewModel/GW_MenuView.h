//
//  GW_MenuView.h
//  testPageC
//
//  Created by gw on 2018/6/27.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_MenuItem.h"
#import "GW_ProgressView.h"
#import "GW_PageViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class GW_MenuView;
@protocol GW_MenuViewDelegate <NSObject>
- (void)menuView:(GW_MenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
@end

@protocol GW_MenuViewDataSource <NSObject>

@optional
/**
 *  角标 (例如消息提醒的小红点) 的数据源方法，在 GW_PageController 中实现这个方法来为 menuView 提供一个 badgeView
 需要在返回的时候同时设置角标的 frame 属性，该 frame 为相对于 menuItem 的位置
 *  @param index 角标的序号
 *  @return 返回一个设置好 frame 的角标视图
 */
- (UIView *)menuView:(GW_MenuView *)menu badgeViewAtIndex:(NSInteger)index;

/**
 *  自定义item 请把属性和大小都设置好
 *  @param menu            menuView
 *  @param initialMenuItem 初始化完成的 menuItem
 *  @param index           Item 所属的位置;
 *  @return 定制完成的 MenuItem
 */
- (GW_MenuItem *)menuView:(GW_MenuView *)menu initialMenuItem:(GW_MenuItem *)initialMenuItem atIndex:(NSInteger)index;

/**
 *  自定义item width
 *  @param menu            menuView
 *  @param index           Item 所属的位置;
 *  @return 自定义width
 */
- (CGFloat)menuView:(GW_MenuView *)menu widthForItemAtIndex:(NSInteger)index;

/**
 *  自定义item 间距
 *  @param menu            menuView
 *  @param index           Item 所属的位置;
 *  @return MenuItem间距
 */
- (CGFloat)menuView:(GW_MenuView *)menu itemMarginAtIndex:(NSInteger)index;

/**
 *  title 数量
 *  @param menu            menuView
 *  @return 数量
 */
- (NSInteger)numbersOfTitlesInMenuView:(GW_MenuView *)menu;

/**
 *  title
 *  @param menu            menuView
 *  @param index           Item 所属的位置;
 *  @return title
 */
- (NSString *)menuView:(GW_MenuView *)menu titleAtIndex:(NSInteger)index;

/**
 *  progress width
 *  @param menu            menuView
 *  @param index           progress 所属的位置;
 *  @return title
 */
- (CGFloat)menuView:(GW_MenuView *)menu widthForProgressAtIndex:(NSInteger)index;

@end

@interface GW_MenuView : UIView
@property (weak, nonatomic) GW_ProgressView *progressView;
@property (weak, nonatomic) UIScrollView *scrollView;
//左侧自定义view
@property (weak, nonatomic) UIView *leftView;
//右侧自定义view
@property (weak, nonatomic) UIView *rightView;
@property (weak, nonatomic) id <GW_MenuViewDelegate>delegate;
@property (weak, nonatomic) id <GW_MenuViewDataSource>dataSource;
//数据
@property (strong, nonatomic) GW_PageViewModel *mvModel;

- (instancetype)initWithFrame:(CGRect)frame mvModel:(GW_PageViewModel *)mvModel;
//选择指定位置
- (void)selectItemAtIndex:(NSInteger)index;
//刷新所有frames
- (void)resetFrames;
//从指定位置向后刷新
- (void)resetFramesFromIndex:(NSInteger)index;
//刷新偏移距离
- (void)refreshContenOffset;

- (void)slideMenuAtProgress:(CGFloat)progress;
//取消选中状态
- (void)deselectedItemsIfNeeded;
//整个view刷新 数据归于原始状态
- (void)reload;
@end

NS_ASSUME_NONNULL_END
