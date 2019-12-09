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

- (void)setItemUI{
    self.font = _selected?_itemM.titleSizeSelectedFont:_itemM.titleSizeNormalFont;
    self.layer.borderWidth = _selected?_itemM.itemBorderWidthSelected:_itemM.itemBorderWidthNormal;
    
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpInside:)];
    [self addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation {
    _selected = selected;
    [self setItemUI];
    if (!animation) {
        self.rate = selected ? 1.0 : 0.0;
        return;
    }
    _sign = selected ? 1 : -1;
    _gap  = selected ? (1.0 - self.rate) : (self.rate - 0.0);
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
    CGFloat backr = _backNormalRed + (_backSelectedRed - _backNormalRed) * rate;
    CGFloat backg = _backNormalGreen + (_backSelectedGreen - _backNormalGreen) * rate;
    CGFloat backb = _backNormalBlue + (_backSelectedBlue - _backNormalBlue) * rate;
    CGFloat backa = _backNormalAlpha + (_backSelectedAlpha - _backNormalAlpha) * rate;
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    self.backgroundColor = [UIColor colorWithRed:backr green:backg blue:backb alpha:backa];
    if (_itemM.itemBorderWidthNormal > 0 || _itemM.itemBorderWidthSelected > 0) {
        CGFloat borderr = _borderNormalRed + (_borderSelectedRed - _borderNormalRed) * rate;
        CGFloat borderg = _borderNormalGreen + (_borderSelectedGreen - _borderNormalGreen) * rate;
        CGFloat borderb = _borderNormalBlue + (_borderSelectedBlue - _borderNormalBlue) * rate;
        CGFloat bordera = _borderNormalAlpha + (_borderSelectedAlpha - _borderNormalAlpha) * rate;
        self.layer.borderColor = [UIColor colorWithRed:borderr green:borderg blue:borderb alpha:bordera].CGColor;
    }
    
    
//    CGFloat minScale = _itemM.titleSizeNormalFont.pointSize / _itemM.titleSizeSelectedFont.pointSize;
//    CGFloat trueScale = minScale + (1 - minScale)*rate;
//    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
//    NSLog(@"trueScale = %f",trueScale);
}

- (void)setItemM:(GW_PageViewModel *)itemM{
    _itemM = itemM;
    [itemM.titleColorSelected getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
    [itemM.titleColorNormal getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_normalAlpha];
    [itemM.itemBackColorSelected getRed:&_backSelectedRed green:&_backSelectedGreen blue:&_backSelectedBlue alpha:&_backSelectedAlpha];
    [itemM.itemBackColorNormal getRed:&_backNormalRed green:&_backNormalGreen blue:&_backNormalBlue alpha:&_backNormalAlpha];
    
    self.backgroundColor = itemM.itemBackColorNormal;
    self.font = itemM.titleFontName != nil?[UIFont fontWithName:itemM.titleFontName size:_itemM.titleSizeSelectedFont.pointSize]:[UIFont systemFontOfSize:_itemM.titleSizeSelectedFont.pointSize];
    
    if (itemM.itemBorderWidthNormal > 0 || itemM.itemBorderWidthSelected > 0) {
        [itemM.itemBorderColorNormal getRed:&_borderNormalRed green:&_borderNormalGreen blue:&_borderNormalBlue alpha:&_borderNormalAlpha];
        [itemM.itemBorderColorSelected getRed:&_borderSelectedRed green:&_borderSelectedGreen blue:&_borderSelectedBlue alpha:&_borderSelectedAlpha];
        if (itemM.itemCornerRadius > 0) {
            self.layer.cornerRadius = itemM.itemCornerRadius;
            self.clipsToBounds = YES;
        }
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
