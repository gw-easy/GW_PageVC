//
//  GW_PageModel.m
//  testPageC
//
//  Created by gw on 2018/6/28.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_PageViewModel.h"
#import "GW_MenuView.h"
#import "GW_MenuItem.h"

@implementation GW_PageViewModel
@synthesize progressViewCornerRadius = _progressViewCornerRadius;
- (instancetype)init{
    if (self = [super init]) {
        _titleSizeSelectedFont  = [UIFont systemFontOfSize:18.0f];
        _titleSizeNormalFont    = [UIFont systemFontOfSize:15.0f];
        _titleColorSelected = [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1];
        _titleColorNormal   = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _itemBackColorNormal = _itemBackColorSelected = _itemBorderColorNormal = _itemBorderColorSelected = [UIColor clearColor];
        _menuItemWidth = 65.0f;

        _progressColor = [UIColor blackColor];
        _scrollEnable = YES;
        _itemBorderWidthNormal = _itemBorderWidthSelected = _itemCornerRadius = _progressViewCornerRadius = 0;
        _progressHeight = 2;
        _automaticallyCalculatesItemWidths = NO;
        _menuViewLayoutMode = GW_MenuViewLayoutModeScatter;
        _menuViewStyle = GW_MenuViewStyleDefault;
        _speedFactor = 15;
        _navHeight = navStateBar + navBarHeight;
    }
    return self;
}

#pragma mark getter
- (CGFloat)speedFactor {
    if (_speedFactor <= 0) {
        _speedFactor = 15.0;
    }
    return _speedFactor;
}

- (CGFloat)progressHeight{
    switch (self.menuViewStyle) {
        case GW_MenuViewStyleLine:
        case GW_MenuViewStyleTriangle:
            return _progressHeight != -1 ?_progressHeight:2;
        case GW_MenuViewStyleFlood:
        case GW_MenuViewStyleSegmented:
        case GW_MenuViewStyleFloodHollow:
            return _progressHeight != -1 ?_progressHeight:ceil(_menuViewFrame.size.height * 0.8);
        default:
            return _progressHeight;
    }
}

- (CGFloat)progressViewCornerRadius{
    return _progressViewCornerRadius != 0 ?_progressViewCornerRadius:(self.progressHeight / 2.0);
}

- (void)dealloc{
    NSLog(@"pageViewModel - dealloc");
}
@end
