//
//  OpenGLViewController.h
//  Demo2
//
//  Created by 伍小华 on 2017/5/11.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface OpenGLViewController : GLKViewController
{
    GLuint vertexBufferID;
}
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@end
