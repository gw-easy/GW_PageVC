//
//  GW_PageModel.h
//  testPageC
//
//  Created by gw on 2018/6/28.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GW_ScrollView.h"

//导航栏高
static const CGFloat navBarHeight = 44;
//状态栏高
static const CGFloat navStateBar = 20;

@class GW_MenuItem;
@class GW_MenuView;

typedef NS_ENUM(NSUInteger, GW_MenuViewStyle) {
    GW_MenuViewStyleDefault,      // 默认
    GW_MenuViewStyleLine,         // 带下划线 (若要选中字体大小不变，设置选中和非选中大小一样即可)
    GW_MenuViewStyleTriangle,     // 三角形 (progressHeight 为三角形的高, progressWidths 为底边长)
    GW_MenuViewStyleFlood,        // 涌入效果 (填充)
    GW_MenuViewStyleFloodHollow,  // 涌入效果 (空心的)
    GW_MenuViewStyleSegmented,    // 涌入带边框,即网易新闻选项卡
};

// 以下布局均只在 item 个数较少的情况下生效，即无法滚动 MenuView 时.
typedef NS_ENUM(NSUInteger, GW_MenuViewLayoutMode) {
    GW_MenuViewLayoutModeScatter, // 默认的布局模式, item 会均匀分布在屏幕上，呈分散状
    GW_MenuViewLayoutModeLeft,    // Item 紧靠屏幕左侧
    GW_MenuViewLayoutModeRight,   // Item 紧靠屏幕右侧
    GW_MenuViewLayoutModeCenter,  // Item 紧挨且居中分布
};

NS_ASSUME_NONNULL_BEGIN

@interface GW_PageViewModel : NSObject
//GW_ScrollView
@property (weak, nonatomic) GW_ScrollView *sView;
//GW_MenuView
@property (weak, nonatomic) GW_MenuView *mView;
//控制器类
@property (strong, nonatomic) NSArray *viewControllerClasses;
//title类
@property (strong, nonatomic) NSArray *titles;
//整个导航栏高
@property (assign, nonatomic) CGFloat navHeight;
//MenuViewes
@property (assign, nonatomic) BOOL bounces;
//scrollEnable
@property (assign, nonatomic) BOOL scrollEnable;
//是否显示在bar上
@property (assign, nonatomic) BOOL showOnNavigationBar;
//内容view之间的距离
@property (assign, nonatomic) CGFloat contentMargin;
//是否记录子视图内scrollview滚动位置
@property (assign, nonatomic) BOOL rememberLocation;
//当前选择的index
@property (assign, nonatomic) NSInteger selectIndex;
#pragma mark menuView
//菜单的frame
@property (assign, nonatomic) CGRect menuViewFrame;
//view的frame
@property (assign, nonatomic) CGRect contentViewFrame;
// Menu view 的样式，默认为无下划线
@property (assign, nonatomic) GW_MenuViewStyle menuViewStyle;
//menuView布局
@property (assign, nonatomic) GW_MenuViewLayoutMode menuViewLayoutMode;
// MenuView 内部视图与左右的间距
@property (assign, nonatomic) CGFloat menuViewContentMargin;
//进度条的颜色，默认和选中颜色一致(如果 style 为 Default，则该属性无用)
// *  点击的 MenuItem 是否触发滚动动画
@property (assign, nonatomic) BOOL pageAnimatable;
// 是否自动通过字符串计算 MenuItem 的宽度，默认为 NO.
@property (assign, nonatomic) BOOL automaticallyCalculatesItemWidths;
// *  选中时的标题尺寸
@property (assign, nonatomic) CGFloat titleSizeSelected;
//非选中时的标题尺寸
@property (assign, nonatomic) CGFloat titleSizeNormal;
//标题选中时的颜色, 颜色是可动画的.
@property (strong, nonatomic) UIColor *titleColorSelected;
//标题非选择时的颜色, 颜色是可动画的.
@property (strong, nonatomic) UIColor *titleColorNormal;
//标题的字体名字
@property (copy, nonatomic) NSString *titleFontName;
//每个 MenuItem 的宽度
@property (assign, nonatomic) CGFloat menuItemWidth;
//各个 MenuItem 的宽度，可不等，数组内为 NSNumber.
@property (strong, nonatomic) NSArray<NSNumber *> *itemsWidths;
//顶部菜单栏各个 item 的间隙，因为包括头尾两端，所以确保它的数量等于控制器数量 + 1, 默认间隙为 0
@property (strong, nonatomic) NSArray *itemsMargins;
//如果各个间隙都想同，设置该属性，默认为 0
@property (assign, nonatomic) CGFloat itemMargin;


#pragma mark menuView->progress
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (assign, nonatomic) CGFloat speedFactor;
//progressColor
@property (strong, nonatomic) UIColor *progressColor;
//定制进度条在各个 item 下的宽度
@property (strong, nonatomic) NSArray *progressViewWidths;
/// 定制进度条，若每个进度条长度相同，可设置该属性
@property (assign, nonatomic) CGFloat progressWidth;
/// 调皮效果，用于实现腾讯视频新效果，请设置一个较小的 progressWidth
@property (assign, nonatomic) BOOL progressViewIsNaughty;
// progressView 到 menuView 底部的距离
@property (assign, nonatomic) CGFloat progressViewBottomSpace;
// progressView's cornerRadius
@property (assign, nonatomic) CGFloat progressViewCornerRadius;
// 下划线进度条的高度
@property (assign, nonatomic) CGFloat progressHeight;


@end
NS_ASSUME_NONNULL_END
