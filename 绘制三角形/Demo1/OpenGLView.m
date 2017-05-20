//
//  OpenGLView.m
//  Demo1
//
//  Created by 伍小华 on 2017/5/10.
//  Copyright © 2017年 wxh. All rights reserved.
//
//渲染：用3D数据生成2D图像的过程
//像素：有3个颜色元素组成的，即一个红点、一个绿点、一个蓝点
//缓存：指图像处理器能够控制和管理的连续RAM（buffers）（几乎所有程序提供给GPU的数据都应该放入缓存中）

//为缓存提供数据有如下7个步骤：
//1、生成（Generate）---请求OpenGL ES为图形处理器控制的缓存生成一个独一无二的标识符。
//2、绑定（Bind）---告诉OpenGL ES为接下来的运算使用一个缓存。
//3、缓存数据（Buffer Data）---让OpenGL ES为当前绑定的缓存分配并初始化足够连续内存（通常是从CPU控制的内存复制数据到分配的内存）。
//4、启用（Enable）或者禁止（Disable）---告诉OpenGL ES在接下来的渲染中是否使用缓存中的数据。
//5、设置指针（Set Pointers）---告诉OpenGL ES在缓存中的数据的类型和所有需要访问的数据的内存偏移值。
//6、绘图（Draw）---告诉OpenGL ES使用当前绑定并启用的缓存中的数据渲染整个场景或者某个场景的一部分。
//7、删除（Delete）---告诉OpenGL ES删除以前生成的缓存并释放相关的资源。

//对应的函数：/Users/wxh/Desktop/图标.rar
//1、glGenBuffers()
//2、glBindBuffer()
//3、glBufferData() 或者 glBufferSubData()
//4、glEnableVertexAttribArray()
//5、glVertexAttribPointer()
//6、glDrawArrays()
//7、glDeleteBuffers()

//前帧缓存：(front frame buffer)当前屏幕上显示的缓存
//后帧缓存：(back frame buffer)即将显示在屏幕上的缓存
//当渲染后的后帧缓存包含一个完成的图像时，前帧缓存与后帧缓存几乎会瞬间切换，后帧缓存变成新的前帧缓存，同事旧的前帧缓存会变成后帧缓存。

//上下文：(context)用于保存配置OpenGL ES在特定平台的软件数据结构中的信息。

//坐标系：笛卡尔坐标系、极坐标系等，GPU对于大部分非笛卡尔坐标系都是不支持的。
//顶点坐标都是以浮点数来存储的

//矢量：既有方向又有距离的一个量，（距离也叫大小）
//所有的顶点都是用它相对于OpenGL ES坐标系原点（{0，0，0}）的距离和方向来定义。
//矢量AB等于：{B.x-A.x,B.y-A.y,B.z-A.z};
//矢量是理解现代GPU的关键，因为图像处理器就是大规模并行矢量处理器。

//着色器：（shader）是用来实现图像渲染的用来替代固定渲染管线的可编辑程序。主要分有：顶点着色器（Vertex Shader）和像素着色器（Pixel Shader）。
//着色器使用步骤：
//创建/删除 shader--->装载shader--->编译shader--->创建 program--->装配 shader--->链接 program--->使用 program


#import "OpenGLView.h"
#import "GLESUtils.h"

@interface OpenGLView ()
- (void)setupLayer;
- (void)setupProgram;
@end

@implementation OpenGLView

//只有[CAEAGLLayer class]类型的layer菜支持在其上描绘OpenGL内容。
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//设置渲染Layer
- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    
    //CALayer默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    //设置描绘属性，在这里设置不维持渲染内容以及颜色格式为RGBA8
    _eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @NO,//表示不保持呈现的内容
                                      kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}
//上下文
- (void)setupContext
{
    //指定OpenGL渲染API的版本，在这里我们使用OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Faild to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    //设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
//创建渲染缓存
- (void)setupRenderBuffer
{
    glGenBuffers(1, &_colorRenderBuffer); //申请一起缓存id
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);//绑定缓存
    
    //为color rederbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

//创建缓存管理者：FBO(framebuffer object)
//告诉GPU内存中那个位置存储了渲染出来的2D图像像素数据
- (void)setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将_colorRenderBuffer装配到GL_COLOR_ATTACHMENT0这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}
//销毁现有缓存
- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}


- (void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderPath];
    
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Faild to create program.");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    glLinkProgram(_programHandle);
    
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(_programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) *infoLen);
            
            glGetShaderInfoLog(_programHandle, infoLen, NULL, infoLog);
            
            NSLog(@"Error linking program:\n%s\n",infoLog);
            free(infoLog);
        }
        
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    
    glUseProgram(_programHandle);
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
}


- (void)render
{
    glClearColor(0.1, 0.2, 0.3, 1.0);//设置清屏幕颜色，默认为黑色
    glClear(GL_COLOR_BUFFER_BIT); //指定要用清屏颜色来清除由mask指定的buffer
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat vertices[] = {
        0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];//将配置好的渲染呈现到屏幕上
}

- (void)layoutSubviews
{
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self setupProgram];
    [self render];
}
@end
