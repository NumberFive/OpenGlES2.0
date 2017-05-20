//
//  ViewController.m
//  Demo1
//
//  Created by 伍小华 on 2017/5/10.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()
{
    OpenGLView *_glView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
}




@end
