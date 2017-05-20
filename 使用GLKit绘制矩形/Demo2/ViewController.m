//
//  ViewController.m
//  Demo2
//
//  Created by 伍小华 on 2017/5/11.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OpenGLViewController *vc = [[OpenGLViewController alloc] init];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

@end
