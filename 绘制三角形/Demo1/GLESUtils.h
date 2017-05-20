//
//  GLESUtils.h
//  Demo1
//
//  Created by 伍小华 on 2017/5/11.
//  Copyright © 2017年 wxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;
+ (GLuint)loadShader:(GLenum)type withFilePath:(NSString *)shaderFilePath;
@end
