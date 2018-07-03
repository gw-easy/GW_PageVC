//
//  ViewController.m
//  testPageC
//
//  Created by gw on 2018/6/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "ViewController.h"
#import "GW_PageVC.h"
#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"
#import "ViewController4.h"
#import "ViewController5.h"
@interface ViewController ()<GW_PageVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    ViewController1 *v1 = [[ViewController1 alloc] init];
//    ViewController2 *v2 = [[ViewController2 alloc] init];
    [self test1];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)test1{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    ViewController1 *v1 = [[ViewController1 alloc] init];
    ViewController2 *v2 = [[ViewController2 alloc] init];
    ViewController3 *v3 = [[ViewController3 alloc] init];
    ViewController4 *v4 = [[ViewController4 alloc] init];
    ViewController5 *v5 = [[ViewController5 alloc] init];
    ViewController1 *v6 = [[ViewController1 alloc] init];
    ViewController2 *v7 = [[ViewController2 alloc] init];
    ViewController3 *v8 = [[ViewController3 alloc] init];
    ViewController4 *v9 = [[ViewController4 alloc] init];
    ViewController5 *v10 = [[ViewController5 alloc] init];
    [arr addObject:v1];
    [arr addObject:v2];
    [arr addObject:v3];
    [arr addObject:v4];
    [arr addObject:v5];
    [arr addObject:v6];
    [arr addObject:v7];
    [arr addObject:v8];
    [arr addObject:v9];
    [arr addObject:v10];
    GW_PageVC *vc = [[GW_PageVC alloc] initWithViewControllerClasses:arr andTheirTitles:@[@"v1",@"v2",@"v3",@"v4",@"v5",@"v1",@"v2",@"v3",@"v4",@"v5"] menuViewFrame:CGRectNull contentViewFrame:CGRectNull];
    vc.delegate = self;
    
    vc.pModel.titleColorSelected = [UIColor greenColor];
    vc.pModel.titleColorNormal = [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1];
    vc.pModel.menuViewStyle = GW_MenuViewStyleLine;
    vc.pModel.progressColor = [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1];
    vc.pModel.showOnNavigationBar = NO;
    vc.pModel.menuViewLayoutMode = GW_MenuViewLayoutModeCenter;
    vc.pModel.titleSizeSelected = 15;
//    vc.pModel.selectIndex = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)GW_PageVC:(GW_PageVC *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
