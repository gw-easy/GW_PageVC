//
//  GW_PageVC.m
//  testPageC
//
//  Created by gw on 2018/6/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GW_PageVC.h"
#import "GW_ScrollView.h"
#import "GW_MenuView.h"

@interface GW_PageVC ()<UIScrollViewDelegate,GW_MenuViewDataSource,GW_MenuViewDelegate>{
    CGFloat _targetX;
    BOOL    _shouldNotScroll;
}
#pragma mark data
//是否开始拖拽
@property (nonatomic, assign) BOOL startDragging;
//开始滑动
@property (assign, nonatomic) CGFloat beginOffx;
//消失vc记录
@property (strong, nonatomic) NSMutableDictionary *posVCRecords;
//子控制器view的frame
@property (strong, nonatomic) NSMutableArray *childVCViewFrames;
#pragma mark UI
@property (strong, nonatomic, readwrite) UIViewController *currentViewController;

@property (weak, nonatomic) GW_ScrollView *gwSV;

@property (weak, nonatomic) GW_MenuView *menuView;
@end

@implementation GW_PageVC

- (instancetype)initWithViewControllerClasses:(NSArray<UIViewController *> *)classes andTheirTitles:(NSArray<NSString *> *)titles {
    return [self initWithViewControllerClasses:classes andTheirTitles:titles menuViewFrame:CGRectNull contentViewFrame:CGRectNull];
}

- (instancetype)initWithViewControllerClasses:(NSArray<UIViewController *> *)classes andTheirTitles:(NSArray<NSString *> *)titles menuViewFrame:(CGRect)menuViewFrame contentViewFrame:(CGRect)contentViewFrame{
    if (self = [super init]) {
        NSParameterAssert(classes.count == titles.count);
        self.pModel = [[GW_PageViewModel alloc] init];
        self.pModel.viewControllerClasses = [NSArray arrayWithArray:classes];
        self.pModel.titles = [NSArray arrayWithArray:titles];
        self.pModel.menuViewFrame = menuViewFrame;
        self.pModel.contentViewFrame = contentViewFrame;
        self.pModel.navHeight = navBarHeight + navStateBar;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.pModel.menuViewFrame = CGRectIsNull(self.pModel.menuViewFrame)?CGRectMake(0, self.pModel.showOnNavigationBar?0:self.pModel.navHeight, CGRectGetWidth(self.view.bounds), navBarHeight):self.pModel.menuViewFrame;
    CGFloat conTop = self.pModel.showOnNavigationBar?self.pModel.navHeight:CGRectGetMaxY(self.pModel.menuViewFrame);
    self.pModel.contentViewFrame = CGRectIsNull(self.pModel.contentViewFrame)?CGRectMake(0, conTop, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-conTop):self.pModel.contentViewFrame;

    [self calculateSize];
    [self gwSV];
    [self initializedControllerWithIndexIfNeeded:self.pModel.selectIndex];
    [self menuView];
    // MARK:- 发送didEnterController代理
    [self didEnterController:self.currentViewController atIndex:self.pModel.selectIndex];
    
}

// 包括宽高，子控制器视图 frame
- (void)calculateSize {
    for (int i = 0; i < self.pModel.titles.count; i++) {
        CGRect frame = CGRectMake(i * self.pModel.contentViewFrame.size.width, 0, self.pModel.contentViewFrame.size.width, self.pModel.contentViewFrame.size.height);
        [self.childVCViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (GW_ScrollView *)gwSV{
    if (!_gwSV) {
        GW_ScrollView *sv = [[GW_ScrollView alloc] initWithFrame:self.pModel.contentViewFrame];
        sv.delegate = self;
        [self.view addSubview:sv];
        _gwSV = sv;
        self.pModel.sView = sv;
        [self adjustScrollViewFrame];
        if (!self.navigationController) return _gwSV;
        for (UIGestureRecognizer *gestureRecognizer in _gwSV.gestureRecognizers) {
            [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        }
    }
    return _gwSV;
}

- (GW_MenuView *)menuView{
    if (!_menuView) {
        GW_MenuView *mv = [[GW_MenuView alloc] initWithFrame:self.pModel.menuViewFrame mvModel:self.pModel];
        mv.delegate = self;
        mv.dataSource = self;
        if (self.pModel.showOnNavigationBar && self.navigationController.navigationBar) {
            self.navigationItem.titleView = mv;
        } else {
            [self.view addSubview:mv];
        }

        _menuView = mv;
        self.pModel.mView = mv;
        mv.mvModel = self.pModel;
        [_menuView resetFrames];
    }
    return _menuView;
}





// 创建或从缓存中获取控制器并添加到视图上
- (void)initializedControllerWithIndexIfNeeded:(NSInteger)index {
    self.currentViewController = self.pModel.viewControllerClasses[index];
    if (self.currentViewController) {
        [self addCachedViewController:self.currentViewController atIndex:index];
    }else{
        NSAssert(NO, @"viewControllerClasses 的存储数据类型有误");
    }
}

- (void)addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childVCViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.gwSV addSubview:viewController.view];
    // MARK:- 发送willEnterController代理
    [self willEnterController:viewController atIndex:index];

}

- (UIScrollView *)isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    } else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

#pragma mark delegate

- (NSDictionary *)infoWithIndex:(NSInteger)index {
    NSString *title = self.pModel.titles[index];
    return @{@"title": title ?: @"", @"index": @(index)};
}

- (void)willEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    self.pModel.selectIndex = (int)index;
    if (self.pModel.viewControllerClasses.count && self.delegate && [self.delegate respondsToSelector:@selector(GW_PageVC:willEnterViewController:withInfo:)]) {
        NSDictionary *info = [self infoWithIndex:index];
        [self.delegate GW_PageVC:self willEnterViewController:vc withInfo:info];
    }
}

// 完全进入控制器 (即停止滑动后调用)
- (void)didEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (!self.pModel.viewControllerClasses) return;
    NSDictionary *info = [self infoWithIndex:index];
    if ([self.delegate respondsToSelector:@selector(GW_PageVC:didEnterViewController:withInfo:)]) {
        [self.delegate GW_PageVC:self didEnterViewController:vc withInfo:info];
    }
    self.pModel.selectIndex = (int)index;
}

// MARK:- 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.posVCRecords removeAllObjects];
    self.posVCRecords = nil;

}

#pragma mark - Adjust Frame
- (void)adjustScrollViewFrame {
    _shouldNotScroll = YES;
    CGFloat oldContentOffsetX = _gwSV.contentOffset.x;
    CGFloat contentWidth = _gwSV.contentSize.width;
    _gwSV.contentSize = CGSizeMake(self.pModel.titles.count * self.pModel.contentViewFrame.size.width, 0);
    CGFloat xContentOffset = contentWidth == 0 ? self.pModel.selectIndex * self.pModel.contentViewFrame.size.width : oldContentOffsetX / contentWidth * self.pModel.titles.count * self.pModel.contentViewFrame.size.width;
    [_gwSV setContentOffset:CGPointMake(xContentOffset, 0)];
    _shouldNotScroll = NO;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"pageVC - dealloc");
}

- (void)layoutChildViewControllers:(BOOL)Dragging{
    int currentPage = (int)(self.gwSV.contentOffset.x / self.pModel.contentViewFrame.size.width);

//    解决手势返回滑动的冲突
    if (currentPage == 0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    if (Dragging && self.gwSV.contentOffset.x - self.beginOffx >0) {
        currentPage += 1;
        if (currentPage > self.pModel.viewControllerClasses.count-1) {
            currentPage = (int)self.pModel.viewControllerClasses.count-1;
        }
    }
    if (![self.childViewControllers containsObject:self.pModel.viewControllerClasses[currentPage]]) {
        if ([self isInScreen:[self.childVCViewFrames[currentPage] CGRectValue]]) {
            [self initializedControllerWithIndexIfNeeded:currentPage];
        }
    }
    
    if (self.childViewControllers && self.childViewControllers.count > 0) {
        for (int i = 0; i< self.childViewControllers.count; i++) {
            UIViewController *vv = self.childViewControllers[i];
            NSInteger ii = [self.pModel.viewControllerClasses indexOfObject:vv];
            if (![self isInScreen:[self.childVCViewFrames[ii] CGRectValue]]) {
                [self removeViewController:vv atIndex:ii];
            }
        }
    }
}


- (BOOL)isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat SWidth = self.gwSV.frame.size.width;
    
    CGFloat contentOffsetX = self.gwSV.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < SWidth) {
        return YES;
    } else {
        return NO;
    }
}

// 移除控制器，且从display中移除
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self rememberPositionIfNeeded:viewController atIndex:index];
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
}

- (void)rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
    if (!self.pModel.rememberLocation) return;
    UIScrollView *scrollView = [self isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posVCRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

#pragma mark - UIScrollView Delegate
//scrollView滚动时，就调用该方法。任何offset值改变都调用该方法。即滚动过程中，调用多次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    if (_shouldNotScroll) return;
    [self layoutChildViewControllers:YES];
    if (_startDragging) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        if (contentOffsetX > scrollView.contentSize.width - self.pModel.contentViewFrame.size.width) {
            contentOffsetX = scrollView.contentSize.width - self.pModel.contentViewFrame.size.width;
        }
        CGFloat rate = contentOffsetX / self.pModel.contentViewFrame.size.width;
        [self.menuView slideMenuAtProgress:rate];
    }
    
    // Fix scrollView.contentOffset.y -> (-20) unexpectedly.
    if (scrollView.contentOffset.y == 0) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = 0.0;
    scrollView.contentOffset = contentOffset;
}

// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    self.beginOffx = scrollView.contentOffset.x;
    _startDragging = YES;
    self.menuView.userInteractionEnabled = NO;
}

// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    
    self.menuView.userInteractionEnabled = YES;
    self.pModel.selectIndex = (int)(scrollView.contentOffset.x / self.pModel.contentViewFrame.size.width);
    self.currentViewController = self.pModel.viewControllerClasses[self.pModel.selectIndex];
    
    [self didEnterController:self.currentViewController atIndex:self.pModel.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    
    self.currentViewController = self.pModel.viewControllerClasses[self.pModel.selectIndex];
    [self didEnterController:self.currentViewController atIndex:self.pModel.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

// 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次。
// decelerate,指代，当我们手指离开那一瞬后，视图是否还将继续向前滚动（一段距离），经过测试，decelerate=YES
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    
//    if (!decelerate) {
        self.menuView.userInteractionEnabled = YES;
        CGFloat rate = _targetX / self.pModel.contentViewFrame.size.width;
        [self.menuView slideMenuAtProgress:rate];
        [self.menuView deselectedItemsIfNeeded];
//    }
}

// 滑动scrollView，并且手指离开时执行。一次有效滑动，只执行一次。
// 当pagingEnabled属性为YES时，不调用，该方法
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (![scrollView isKindOfClass:_gwSV.class]) return;
    _targetX = targetContentOffset->x;
}

#pragma mark - GW_MenuView Delegate
- (void)menuView:(GW_MenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    if (currentIndex == index) {
        // MARK:- 防止重复点击
        return;
    }
    self.pModel.selectIndex = (int)index;
    _startDragging = NO;
    CGPoint targetP = CGPointMake(self.pModel.contentViewFrame.size.width * index, 0);
    [self.gwSV setContentOffset:targetP animated:self.pModel.pageAnimatable];
    if (self.pModel.pageAnimatable) return;
    // 由于不触发 -scrollViewDidScroll: 手动处理控制器
    UIViewController *currentViewController = self.pModel.viewControllerClasses[currentIndex];
    if (currentViewController) {
        [self removeViewController:currentViewController atIndex:currentIndex];
    }
    [self layoutChildViewControllers:NO];
    self.currentViewController = self.pModel.viewControllerClasses[self.pModel.selectIndex];
    [self didEnterController:self.currentViewController atIndex:index];
}

#pragma mark lazy
- (NSMutableDictionary *)posVCRecords{
    if (!_posVCRecords) {
        _posVCRecords = [[NSMutableDictionary alloc] init];
    }
    return _posVCRecords;
}

- (NSMutableArray *)childVCViewFrames{
    if (!_childVCViewFrames) {
        _childVCViewFrames = [[NSMutableArray alloc] init];
    }
    return _childVCViewFrames;
}

@end
