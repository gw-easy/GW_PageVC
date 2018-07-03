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
        _titleSizeSelected  = 18.0f;
        _titleSizeNormal    = 15.0f;
        _titleColorSelected = [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1];
        _titleColorNormal   = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _menuItemWidth = 65.0f;

        _progressColor = [UIColor blackColor];
        _scrollEnable = YES;
        _progressViewCornerRadius = 0;
        _progressHeight = 2;
        _automaticallyCalculatesItemWidths = NO;
        _menuViewLayoutMode = GW_MenuViewLayoutModeScatter;
        _navHeight = navStateBar + navBarHeight;
    }
    return self;
}

#pragma mark setter
- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    if (self.sView) {
        self.sView.scrollEnabled = scrollEnable;
    }
}

- (void)setBounces:(BOOL)bounces{
    _bounces = bounces;
    if (self.sView) {
        self.sView.bounces = bounces;
    }
}

- (void)setContentMargin:(CGFloat)contentMargin{
    _contentMargin = contentMargin;
    if (self.mView.scrollView) {
        [self.mView resetFrames];
    }
}

- (void)setMenuViewLayoutMode:(GW_MenuViewLayoutMode)menuViewLayoutMode{
    _menuViewLayoutMode = menuViewLayoutMode;
    if (self.mView.superview) {
        [self.mView reload];
    }
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius {
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.mView.progressView) {
        self.mView.progressView.cornerRadius = _progressViewCornerRadius;
    }
}

- (void)setProgressViewIsNaughty:(BOOL)progressViewIsNaughty {
    _progressViewIsNaughty = progressViewIsNaughty;
    if (self.mView.progressView) {
        self.mView.progressView.naughty = progressViewIsNaughty;
    }
}

- (void)setProgressViewWidths:(NSArray *)progressViewWidths{
    _progressViewWidths = progressViewWidths;
    if (self.mView) {
        [self.mView resetFramesFromIndex:0];
    }
}

- (void)setSpeedFactor:(CGFloat)speedFactor {
    _speedFactor = speedFactor;
    if (self.mView.progressView) {
        self.mView.progressView.speedFactor = _speedFactor;
    }
    
    [self.sView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[GW_MenuItem class]]) {
            ((GW_MenuItem *)obj).speedFactor = _speedFactor;
        }
    }];
}

#pragma mark getter
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
