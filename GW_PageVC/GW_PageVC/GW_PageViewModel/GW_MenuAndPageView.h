//
//  GW_MenuAndPageView.h
//  GW_PageVC
//
//  Created by gw on 2019/9/2.
//  Copyright © 2019 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_MenuView.h"
//菜单和UIScrollView结合
@interface GW_MenuAndPageView : UIView
//菜单
@property (strong ,nonatomic) GW_MenuView *menuView;
//底部视图
@property (strong ,nonatomic) UIScrollView *bottomSV;
@end
