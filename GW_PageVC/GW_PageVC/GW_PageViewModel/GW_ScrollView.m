//
//  GW_ScrollView.m
//  testPageC
//
//  Created by gw on 2018/6/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_ScrollView.h"

@implementation GW_ScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.scrollsToTop = NO;
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.scrollEnabled = YES;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    //MARK: UITableViewCell 删除手势
    if ([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UITableViewWrapperView"] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)dealloc{
    NSLog(@"scrollView - dealloc");
}
@end
