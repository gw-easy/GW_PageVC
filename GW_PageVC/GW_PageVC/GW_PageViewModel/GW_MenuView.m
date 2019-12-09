//
//  GW_MenuView.m
//  testPageC
//
//  Created by gw on 2018/6/27.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_MenuView.h"
static const NSInteger menuItem_offset = 1111;
static const NSInteger badgeView_offset = 2222;
@interface GW_MenuView()<GW_MenuItemDelegate>
@property (strong, nonatomic) GW_MenuItem *selectItem;
@property (strong, nonatomic) NSMutableArray *frames;
@end

@implementation GW_MenuView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUI];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame mvModel:(GW_PageViewModel *)mvModel{
    _mvModel = mvModel;
    return [self initWithFrame:frame];
}

- (void)setMvModel:(GW_PageViewModel *)mvModel{
    _mvModel = mvModel;
    [self reload];
}

#pragma mark - UI
- (void)setUI{
    //    添加_scrollView
    [self scrollView];
    //    添加items
    [self addItems];
    //    添加progress
    [self makeStyle];
    //    添加badgeView 如果有角标
    [self addBadgeViews];
    //    刷新选中item的位置
    [self resetSelectionIfNeeded];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        CGFloat width = self.frame.size.width - self.mvModel.contentMargin * 2;
        CGFloat height = self.frame.size.height;
        CGRect frame = CGRectMake(self.mvModel.contentMargin, 0, width, height);
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

#pragma mark - 添加item
- (void)addItems {
    [self calculateItemFrames];
    NSInteger cTitel = [self titlesCount];
    for (int i = 0; i < cTitel; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        GW_MenuItem *item = [[GW_MenuItem alloc] initWithFrame:frame];
        item.tag = (i + menuItem_offset);
        item.delegate = self;
        item.text = [self itemTitle:i];
        item.itemM = self.mvModel;
        // MARK:- 设置自定义item
        if ([self.dataSource respondsToSelector:@selector(menuView:initialMenuItem:atIndex:)]) {
            item = [self.dataSource menuView:self initialMenuItem:item atIndex:i];
        }
        if (i == self.mvModel.selectIndex) {
            [item setSelected:YES withAnimation:NO];
            self.selectItem = item;
        } else {
            [item setSelected:NO withAnimation:NO];
        }
        [self.scrollView addSubview:item];
    }
}

// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
- (void)calculateItemFrames {
    CGFloat contentWidth = [self itemMargin:0];
    NSInteger tCount = [self titlesCount];
    for (int i = 0; i < tCount; i++) {
        CGFloat itemW = [self itemWidth:i];
        CGRect frame = CGRectMake(contentWidth, 0, itemW, self.frame.size.height);
        NSLog(@"frame = %@",NSStringFromCGRect(frame));
        // 记录frame
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemW + [self itemMargin:i+1];
    }
    // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
    if (contentWidth < self.scrollView.frame.size.width) {
        CGFloat distance = self.scrollView.frame.size.width - contentWidth;
        CGFloat (^shiftDis)(int);
        switch (self.mvModel.menuViewLayoutMode) {
            case GW_MenuViewLayoutModeLeft: {
                shiftDis = ^CGFloat(int index) { return 0.0; };
                break;
            }
            case GW_MenuViewLayoutModeRight: {
                shiftDis = ^CGFloat(int index) { return distance; };
                break;
            }
            case GW_MenuViewLayoutModeCenter: {
                shiftDis = ^CGFloat(int index) { return distance / 2; };
                break;
            }
            default:{
                CGFloat gap = distance / (tCount + 1);
                shiftDis = ^CGFloat(int index) { return gap * (index + 1); };
                break;
            }
        }
        for (int i = 0; i < self.frames.count; i++) {
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += shiftDis(i);
            NSLog(@"frame = %@",NSStringFromCGRect(frame));
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.scrollView.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

#pragma mark - title数量
- (NSInteger)titlesCount {
    NSInteger count = self.mvModel.titles.count;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numbersOfTitlesInMenuView:)]) {
        count = [self.dataSource numbersOfTitlesInMenuView:self];
    }
    return count;
}
#pragma mark - 获取title
- (NSString *)itemTitle:(NSInteger)num {
    NSString *titleS = @"";
    if (self.mvModel.titles && self.mvModel.titles.count != 0) {
        titleS = self.mvModel.titles[num];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuView:titleAtIndex:)]) {
        titleS = [self.dataSource menuView:self titleAtIndex:num];
    }
    return titleS;
}

#pragma mark - 获取itemWidth
- (NSInteger)itemWidth:(NSInteger)num {
    [self addItemWidths];
    CGFloat itemW = 0;
    if (self.mvModel.itemsWidths && self.mvModel.itemsWidths.count != 0) {
        itemW = [self.mvModel.itemsWidths[num] floatValue];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
        itemW = [self.dataSource menuView:self widthForItemAtIndex:num];
    }
    return itemW;
}


- (void)addItemWidths{
    if (!self.mvModel.itemsWidths || self.mvModel.itemsWidths.count == 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        NSInteger tCount = [self titlesCount];
        for (int i = 0; i<tCount; i++) {
            if (self.mvModel.menuItemWidth > 0) {
                [mArr addObject:[NSNumber numberWithFloat:self.mvModel.menuItemWidth]];
            }else{
                [mArr addObject:[NSNumber numberWithFloat:[self calculateItemWithAtIndex:i]]];
            }
            
        }
        self.mvModel.itemsWidths = mArr;
    }
}

#pragma mark - 计算item字体宽度
- (CGFloat)calculateItemWithAtIndex:(NSInteger)index {
    NSString *title = self.mvModel.titles[index];
    UIFont *titleFont = self.mvModel.titleFontName ? [UIFont fontWithName:self.mvModel.titleFontName size:self.mvModel.titleSizeSelectedFont.pointSize] : self.mvModel.titleSizeSelectedFont;
    NSDictionary *attrs = @{NSFontAttributeName: titleFont};
    CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
    return ceil(itemWidth);
}

#pragma mark - 获取itemMargin
- (NSInteger)itemMargin:(NSInteger)num {
    [self addItemMargins];
    CGFloat itemM = 0;
    if (self.mvModel.itemsMargins && self.mvModel.itemsMargins.count != 0) {
        itemM = [self.mvModel.itemsMargins[num] floatValue];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuView:itemMarginAtIndex:)]) {
        itemM = [self.dataSource menuView:self itemMarginAtIndex:num];
    }
    return itemM;
}

- (void)addItemMargins{
    if (!self.mvModel.itemsMargins && self.mvModel.itemsMargins.count == 0) {
        NSMutableArray *ma = [[NSMutableArray alloc] init];
        NSInteger tCount = [self titlesCount];
        if (self.mvModel.itemMargin>0) {
            for (int i = 0; i<tCount+1; i++) {
                [ma addObject:[NSNumber numberWithFloat:self.mvModel.itemMargin]];
            }
        }
        self.mvModel.itemsMargins = ma;
    }
}

#pragma mark resetSelectionIfNeeded
- (void)resetSelectionIfNeeded {
    if (_mvModel.selectIndex == 0) { return; }
    [self selectItemAtIndex:_mvModel.selectIndex];
}

- (void)selectItemAtIndex:(NSInteger)index {
    NSInteger currentIndex = self.selectItem.tag - menuItem_offset;
    if (index == currentIndex || !self.selectItem) { return; }
    
    NSInteger tag = index + menuItem_offset;
    _mvModel.selectIndex = index;
    GW_MenuItem *item = (GW_MenuItem *)[self.scrollView viewWithTag:tag];
    [self.selectItem setSelected:NO withAnimation:YES];
    [item setSelected:YES withAnimation:YES];
    self.selectItem = item;
    [self.progressView setProgressWithOutAnimate:index];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:index currentIndex:currentIndex];
    }
    [self refreshContenOffset];
}

// MARK:- 让选中的item位于中间
- (void)refreshContenOffset {
    CGRect frame = self.selectItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        } else {
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

- (void)reload {
    [self.frames removeAllObjects];
    [self.progressView removeFromSuperview];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
}

#pragma mark makeStyle
- (void)makeStyle {
    CGRect frame = [self calculateProgressViewFrame];
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }
    [self addProgressViewWithFrame:frame
                        isTriangle:(self.mvModel.menuViewStyle == GW_MenuViewStyleTriangle)
                         hasBorder:(self.mvModel.menuViewStyle == GW_MenuViewStyleSegmented)
                            hollow:(self.mvModel.menuViewStyle == GW_MenuViewStyleFloodHollow)
                      cornerRadius:self.mvModel.progressViewCornerRadius];
}

// MARK:Progress View
- (void)addProgressViewWithFrame:(CGRect)frame isTriangle:(BOOL)isTriangle hasBorder:(BOOL)hasBorder hollow:(BOOL)isHollow cornerRadius:(CGFloat)cornerRadius {
    GW_ProgressView *pView = [[GW_ProgressView alloc] initWithFrame:frame];
    pView.itemFrames = [self convertProgressWidthsToFrames];
    pView.color = self.mvModel.progressColor.CGColor;
    pView.isTriangle = isTriangle;
    pView.hasBorder = hasBorder;
    pView.hollow = isHollow;
    pView.cornerRadius = cornerRadius;
    pView.naughty = self.mvModel.progressViewIsNaughty;
    pView.speedFactor = self.mvModel.speedFactor;
    pView.backgroundColor = [UIColor clearColor];
    [pView moveToPostion:self.mvModel.selectIndex];
    self.progressView = pView;
    [self.scrollView insertSubview:self.progressView atIndex:0];
}

- (CGRect)calculateProgressViewFrame {
    switch (self.mvModel.menuViewStyle) {
        case GW_MenuViewStyleDefault: {
            return CGRectZero;
        }
        case GW_MenuViewStyleLine:
        case GW_MenuViewStyleTriangle: {
            return CGRectMake(0, self.frame.size.height - self.mvModel.progressHeight - self.mvModel.progressViewBottomSpace, self.scrollView.contentSize.width, self.mvModel.progressHeight);
        }
        case GW_MenuViewStyleFloodHollow:
        case GW_MenuViewStyleSegmented:
        case GW_MenuViewStyleFlood: {
            return CGRectMake(0, (self.frame.size.height - self.mvModel.progressHeight) / 2, self.scrollView.contentSize.width, self.mvModel.progressHeight);
        }
    }
}

#pragma mark - 刷新ProgressFrames
- (NSArray *)convertProgressWidthsToFrames {
    if (!self.frames.count) {
        return nil;
    }
    
    NSMutableArray *progressFrames = [NSMutableArray array];
    NSInteger tCount = [self titlesCount];
    for (int i = 0; i < tCount; i++) {
        CGRect itemFrame = [self.frames[i] CGRectValue];
        CGFloat progressWidth = [self progressWidth:i];
        CGFloat x = itemFrame.origin.x + (itemFrame.size.width - progressWidth) / 2;
        CGRect progressFrame = CGRectMake(x, itemFrame.origin.y, progressWidth, 0);
        [progressFrames addObject:[NSValue valueWithCGRect:progressFrame]];
    }
    return progressFrames.copy;
}

#pragma mark - 获取progressWidth
- (NSInteger)progressWidth:(NSInteger)num {
    [self addProgressWidth];
    CGFloat progressW = 0;
    if (self.mvModel.progressViewWidths && self.mvModel.progressViewWidths.count != 0) {
        progressW = [self.mvModel.progressViewWidths[num] floatValue];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menuView:widthForProgressAtIndex:)]) {
        progressW = [self.dataSource menuView:self widthForProgressAtIndex:num];
    }
    return progressW;
}

- (void)addProgressWidth{
    if (!self.mvModel.progressViewWidths && self.mvModel.progressViewWidths.count == 0) {
        NSMutableArray *ma = [[NSMutableArray alloc] init];
        NSInteger tCount = [self titlesCount];
        for (int i = 0; i<tCount+1; i++) {
            [ma addObject:[NSNumber numberWithFloat:self.mvModel.progressWidth]];
        }
        self.mvModel.progressViewWidths = ma;
    }
}

#pragma mark addBadgeViews
- (void)addBadgeViews {
    NSInteger cTitel = [self titlesCount];
    for (int i = 0; i < cTitel; i++) {
        [self addBadgeViewAtIndex:i];
    }
}

- (void)addBadgeViewAtIndex:(NSInteger)index {
    UIView *badgeView = [self badgeViewAtIndex:index];
    if (badgeView) {
        [self.scrollView addSubview:badgeView];
    }
}

- (UIView *)badgeViewAtIndex:(NSInteger)index {
    if (![self.dataSource respondsToSelector:@selector(menuView:badgeViewAtIndex:)]) {
        return nil;
    }
    UIView *badgeView = [self.dataSource menuView:self badgeViewAtIndex:index];
    if (!badgeView) {
        return nil;
    }
    badgeView.tag = index + badgeView_offset;
    
    return badgeView;
}

- (void)resetFrames {
    CGRect frame = self.bounds;
    if (self.rightView) {
        CGRect rightFrame = self.rightView.frame;
        rightFrame.origin.x = frame.size.width - rightFrame.size.width;
        self.rightView.frame = rightFrame;
        frame.size.width -= rightFrame.size.width;
    }
    
    if (self.leftView) {
        CGRect leftFrame = self.leftView.frame;
        leftFrame.origin.x = 0;
        self.leftView.frame = leftFrame;
        frame.origin.x += leftFrame.size.width;
        frame.size.width -= leftFrame.size.width;
    }
    
    frame.origin.x += self.mvModel.contentMargin;
    frame.size.width -= self.mvModel.contentMargin * 2;
    self.scrollView.frame = frame;
    [self resetFramesFromIndex:0];
}

- (void)resetFramesFromIndex:(NSInteger)index {
    [self.frames removeAllObjects];
    [self calculateItemFrames];
    NSInteger cTitel = [self titlesCount];
    for (NSInteger i = index; i < cTitel; i++) {
        [self resetItemFrame:i];
        [self resetBadgeFrame:i];
    }
    if (!self.progressView.superview) { return; }
    
    self.progressView.frame = [self calculateProgressViewFrame];
    self.progressView.cornerRadius = self.mvModel.progressViewCornerRadius;
    self.progressView.itemFrames = [self convertProgressWidthsToFrames];
    [self.progressView setNeedsDisplay];
}

- (void)resetItemFrame:(NSInteger)index {
    GW_MenuItem *item = (GW_MenuItem *)[self.scrollView viewWithTag:(menuItem_offset + index)];
    CGRect frame = [self.frames[index] CGRectValue];
    item.frame = frame;
    if (index == _mvModel.selectIndex) {
        [item setSelected:NO withAnimation:NO];
        [item setSelected:YES withAnimation:NO];
    }
}

- (void)resetBadgeFrame:(NSInteger)index {
    CGRect frame = [self.frames[index] CGRectValue];
    UIView *badgeView = [self.scrollView viewWithTag:(badgeView_offset + index)];
    if (badgeView) {
        CGRect badgeFrame = [self badgeViewAtIndex:index].frame;
        badgeFrame.origin.x += frame.origin.x;
        badgeView.frame = badgeFrame;
    }
}

#pragma mark public
- (void)slideMenuAtProgress:(CGFloat)progress {
    if (self.progressView) {
        self.progressView.progress = progress;
    }
    NSInteger tag = (NSInteger)progress + menuItem_offset;
    CGFloat rate = progress - tag + menuItem_offset;
    GW_MenuItem *currentItem = (GW_MenuItem *)[self.scrollView viewWithTag:tag];
    GW_MenuItem *nextItem = (GW_MenuItem *)[self.scrollView viewWithTag:tag+1];
    if (rate == 0.0) {
        [self.selectItem setSelected:NO withAnimation:NO];
        self.selectItem = currentItem;
        [self.selectItem setSelected:YES withAnimation:NO];
        [self refreshContenOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

- (void)deselectedItemsIfNeeded {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[GW_MenuItem class]] || obj == self.selectItem) { return; }
        [(GW_MenuItem *)obj setSelected:NO withAnimation:NO];
    }];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(GW_MenuItem *)menuItem {
    
    CGFloat progress = menuItem.tag - menuItem_offset;
    [self.progressView moveToPostion:progress];
    
    NSInteger currentIndex = self.selectItem.tag - menuItem_offset;
    _mvModel.selectIndex = currentIndex;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:menuItem.tag - menuItem_offset currentIndex:currentIndex];
    }
    
    [self.selectItem setSelected:NO withAnimation:NO];
    [menuItem setSelected:YES withAnimation:NO];
    self.selectItem = menuItem;
    
    NSTimeInterval delay = self.mvModel.menuViewStyle == GW_MenuViewStyleDefault ? 0 : 0.3f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 让选中的item位于中间
        [self refreshContenOffset];
    });
}

#pragma mark - Setter

- (void)setFrame:(CGRect)frame {
    // Adapt iOS 11 if is a titleView
    if (@available(iOS 11.0, *)) {
        if (self.mvModel.showOnNavigationBar) { frame.origin.x = 0; }
    }
    
    [super setFrame:frame];
    
    if (!self.scrollView) { return; }
    
    CGFloat leftMargin = self.mvModel.contentMargin + self.leftView.frame.size.width;
    CGFloat rightMargin = self.mvModel.contentMargin + self.rightView.frame.size.width;
    CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
    CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.mvModel.contentMargin;
    
    // Make the contentView center, because system will change menuView's frame if it's a titleView.
    if (startX + contentWidth / 2 != self.bounds.size.width / 2) {
        
        CGFloat xOffset = (self.bounds.size.width - contentWidth) / 2;
        self.leftView.frame = ({
            CGRect frame = self.leftView.frame;
            frame.origin.x = xOffset;
            frame;
        });
        
        self.scrollView.frame = ({
            CGRect frame = self.scrollView.frame;
            frame.origin.x = self.leftView ? CGRectGetMaxX(self.leftView.frame) + self.mvModel.contentMargin : xOffset;
            frame;
        });
        
        self.rightView.frame = ({
            CGRect frame = self.rightView.frame;
            frame.origin.x = CGRectGetMaxX(self.scrollView.frame) + self.mvModel.contentMargin;
            frame;
        });
    }
}

- (void)setLeftView:(UIView *)leftView {
    if (self.leftView) {
        [self.leftView removeFromSuperview];
        _leftView = nil;
    }
    if (leftView) {
        [self addSubview:leftView];
        _leftView = leftView;
    }
    [self resetFrames];
}

- (void)setRightView:(UIView *)rightView {
    if (self.rightView) {
        [self.rightView removeFromSuperview];
        _rightView = nil;
    }
    if (rightView) {
        [self addSubview:rightView];
        _rightView = rightView;
    }
    [self resetFrames];
}

#pragma mark lazy
- (NSMutableArray *)frames {
    if (!_frames) {
        _frames = [[NSMutableArray alloc] init];
    }
    return _frames;
}

- (void)dealloc{
    NSLog(@"menuView - dealloc");
}

@end
