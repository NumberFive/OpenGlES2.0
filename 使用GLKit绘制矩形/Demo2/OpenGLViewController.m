//
//  OpenGLViewController.m
//  Demo2
//
//  Created by 伍小华 on 2017/5/11.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import "OpenGLViewController.h"

typedef struct {
    GLKVector3 positionCoords;
}
sceneVertex;
static const sceneVertex vertices [] =
{
    {{-0.5f, -0.5f, 0.0}},
    {{-0.5f,  0.5f, 0.0}},
    {{ 0.5f, -0.5f, 0.0}},
    {{ 0.5f,  0.5f, 0.0}},
};

@interface OpenGLViewController ()

@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller's view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    glClearColor(0.1f, 0.2f, 0.3f, 1.0f);
    
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(sceneVertex), NULL);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
- (void)dealloc
{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
