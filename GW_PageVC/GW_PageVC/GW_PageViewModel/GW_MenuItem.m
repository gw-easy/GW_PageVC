//
//  GW_MenuItem.m
//  testPageC
//
//  Created by gw on 2018/6/27.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_MenuItem.h"
@interface GW_MenuItem(){
    CGFloat _selectedRed, _selectedGreen, _selectedBlue, _selectedAlpha;
    CGFloat _normalRed, _normalGreen, _normalBlue, _normalAlpha;
    
    CGFloat _backSelectedRed, _backSelectedGreen, _backSelectedBlue, _backSelectedAlpha;
    CGFloat _backNormalRed, _backNormalGreen, _backNormalBlue, _backNormalAlpha;
    
    CGFloat _borderSelectedRed, _borderSelectedGreen, _borderSelectedBlue, _borderSelectedAlpha;
    CGFloat _borderNormalRed, _borderNormalGreen, _borderNormalBlue, _borderNormalAlpha;
}
@property (assign, nonatomic) int sign;
@property (assign, nonatomic) CGFloat gap;
@property (assign, nonatomic) CGFloat step;
@property (weak, nonatomic) CADisplayLink *link;
@end
@implementation GW_MenuItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
        [self setupGestureRecognizer];
    }
    return self;
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpInside:)];
    [self addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation {
    _selected = selected;
    BOOL selectUP = _itemM.titleSizeSelectedFont.pointSize > _itemM.titleSizeNormalFont.pointSize;
    if (!animation) {
        self.rate = selectUP?(selected ? 1.0 : 0.0):(selected ? 0.0 : 1.0);
        return;
    }
    
    _sign = selectUP?(selected ? 1 : -1):(selected ? -1 : 1);
    _gap  = selectUP?(selected?(1.0 - self.rate):(self.rate - 0.0)):(selected?(self.rate - 0.0):(1.0 - self.rate));
    _step = _gap / _itemM.speedFactor;
    if (_link) {
        [_link invalidate];
    }
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rateChange)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _link = link;
}



- (void)rateChange {
    if (_gap > 0.000001) {
        _gap -= _step;
        if (_gap < 0.0) {
            self.rate = (int)(self.rate + _sign * _step + 0.5);
            return;
        }
        self.rate += _sign * _step;
    } else {
        self.rate = (int)(self.rate + 0.5);
        [_link invalidate];
        _link = nil;
    }
}

// 设置rate,并刷新标题状态
- (void)setRate:(CGFloat)rate {
    if (rate < 0.0 || rate > 1.0) {
        return;
    }
    _rate = rate;
    CGFloat r = _normalRed + (_selectedRed - _normalRed) * rate;
    CGFloat g = _normalGreen + (_selectedGreen - _normalGreen) * rate;
    CGFloat b = _normalBlue + (_selectedBlue - _normalBlue) * rate;
    CGFloat a = _normalAlpha + (_selectedAlpha - _normalAlpha) * rate;
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    if (!CGColorEqualToColor(_itemM.itemBorderColorSelected.CGColor, [UIColor clearColor].CGColor) && !CGColorEqualToColor(_itemM.itemBorderColorNormal.CGColor, [UIColor clearColor].CGColor)) {
        r = _backNormalRed + (_backSelectedRed - _backNormalRed) * rate;
        g = _backNormalGreen + (_backSelectedGreen - _backNormalGreen) * rate;
        b = _backNormalBlue + (_backSelectedBlue - _backNormalBlue) * rate;
        a = _backNormalAlpha + (_backSelectedAlpha - _backNormalAlpha) * rate;
        self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    
    
    
    BOOL selectUP = _itemM.titleSizeSelectedFont.pointSize > _itemM.titleSizeNormalFont.pointSize;
    
    CGFloat selFont = selectUP?_itemM.titleSizeSelectedFont.pointSize:_itemM.titleSizeNormalFont.pointSize;
    CGFloat minScale = selectUP?_itemM.titleSizeNormalFont.pointSize/_itemM.titleSizeSelectedFont.pointSize: _itemM.titleSizeSelectedFont.pointSize/_itemM.titleSizeNormalFont.pointSize;
    CGFloat trueScale = minScale + (1 - minScale)*rate;
    self.font = [UIFont systemFontOfSize:selFont*trueScale];
    
    
    
    
    if ((_itemM.itemBorderWidthNormal > 0 && !CGColorEqualToColor(_itemM.itemBorderColorNormal.CGColor, [UIColor clearColor].CGColor)) || (_itemM.itemBorderWidthSelected > 0 && !CGColorEqualToColor(_itemM.itemBorderColorSelected.CGColor, [UIColor clearColor].CGColor))) {
        r = _borderNormalRed + (_borderSelectedRed - _borderNormalRed) * rate;
        g = _borderNormalGreen + (_borderSelectedGreen - _borderNormalGreen) * rate;
        b = _borderNormalBlue + (_borderSelectedBlue - _borderNormalBlue) * rate;
        a = _borderNormalAlpha + (_borderSelectedAlpha - _borderNormalAlpha) * rate;
        self.layer.borderColor = [UIColor colorWithRed:r green:g blue:b alpha:a].CGColor;
        BOOL selectBorder = _itemM.itemBorderWidthSelected > _itemM.itemBorderWidthNormal;
        if (selectUP != selectBorder) {
            rate = 1-rate;
        }
        selFont = selectBorder?_itemM.itemBorderWidthSelected:_itemM.itemBorderWidthNormal;
        minScale = selectBorder?_itemM.itemBorderWidthNormal/_itemM.itemBorderWidthSelected:_itemM.itemBorderWidthSelected/_itemM.itemBorderWidthNormal;
        trueScale = minScale + (1 - minScale)*rate;

        self.layer.borderWidth = selFont*trueScale;
    }
}

- (void)setItemM:(GW_PageViewModel *)itemM{
    _itemM = itemM;
    [itemM.titleColorSelected getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
    [itemM.titleColorNormal getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_normalAlpha];
    
    if (!CGColorEqualToColor(itemM.itemBorderColorSelected.CGColor, [UIColor clearColor].CGColor) && !CGColorEqualToColor(itemM.itemBorderColorNormal.CGColor, [UIColor clearColor].CGColor)) {
        [itemM.itemBackColorSelected getRed:&_backSelectedRed green:&_backSelectedGreen blue:&_backSelectedBlue alpha:&_backSelectedAlpha];
        [itemM.itemBackColorNormal getRed:&_backNormalRed green:&_backNormalGreen blue:&_backNormalBlue alpha:&_backNormalAlpha];
    }
    
    self.backgroundColor = itemM.itemBackColorNormal;
    self.font = itemM.titleFontName != nil?[UIFont fontWithName:itemM.titleFontName size:_itemM.titleSizeSelectedFont.pointSize]:[UIFont systemFontOfSize:_itemM.titleSizeSelectedFont.pointSize];
    
    if ((itemM.itemBorderWidthNormal > 0 && !CGColorEqualToColor(itemM.itemBorderColorNormal.CGColor, [UIColor clearColor].CGColor)) || (itemM.itemBorderWidthSelected > 0 && !CGColorEqualToColor(itemM.itemBorderColorSelected.CGColor, [UIColor clearColor].CGColor))) {
        [itemM.itemBorderColorNormal getRed:&_borderNormalRed green:&_borderNormalGreen blue:&_borderNormalBlue alpha:&_borderNormalAlpha];
        [itemM.itemBorderColorSelected getRed:&_borderSelectedRed green:&_borderSelectedGreen blue:&_borderSelectedBlue alpha:&_borderSelectedAlpha];
    }
    if (itemM.itemCornerRadius > 0) {
        self.layer.cornerRadius = itemM.itemCornerRadius;
        self.clipsToBounds = YES;
    }
}

- (void)touchUpInside:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gw_didPressedMenuItem:)]) {
        [self.delegate gw_didPressedMenuItem:self];
    }
}

- (void)dealloc{
    NSLog(@"GW_MenuItem - dealloc");
}

@end
