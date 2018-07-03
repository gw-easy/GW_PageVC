//
//  GW_PageVC.h
//  testPageC
//
//  Created by gw on 2018/6/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GW_MenuView.h"
NS_ASSUME_NONNULL_BEGIN

@class GW_PageVC;
#pragma mark delegate
@protocol GW_PageVCDelegate<NSObject>
@optional
- (void)GW_PageVC:(GW_PageVC *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info;

- (void)GW_PageVC:(GW_PageVC *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info;
@end

@interface GW_PageVC : UIViewController

@property (strong, nonatomic) GW_PageViewModel *pModel;
@property (strong, nonatomic, readonly) UIViewController *currentViewController;
@property (weak, nonatomic) id <GW_PageVCDelegate>delegate;

- (instancetype)initWithViewControllerClasses:(NSArray<UIViewController *> *)classes andTheirTitles:(NSArray<NSString *> *)titles;

- (instancetype)initWithViewControllerClasses:(NSArray<UIViewController *> *)classes andTheirTitles:(NSArray<NSString *> *)titles menuViewFrame:(CGRect)menuViewFrame contentViewFrame:(CGRect)contentViewFrame;
@end
NS_ASSUME_NONNULL_END
