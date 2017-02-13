//
//  ViewController.m
//  Test8
//
//  Created by 李旭 on 17/1/4.
//  Copyright © 2017年 lixu. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
@interface ViewController ()

@end

@implementation ViewController
{
    
    UIImageView *imgv;
}
NSString *imgName = @"122.png";
CGPoint point = {150,520};
CGPoint imgPoint = {40, 420};

- (void)viewDidLoad {
    [super viewDidLoad];

    imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    imgv.backgroundColor = [UIColor redColor];
    imgv.frame = CGRectMake(imgPoint.x, imgPoint.y, imgv.image.size.width, imgv.image.size.height);
    [self.view addSubview:imgv];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(delayMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    [self delayMethod];
//    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
}

- (void)delayMethod
{
    [self getPointRGB:point];
    
    CGRect maxRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    [self createScreenShot:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20) withPNGName:@"lixu.png"];
    [self findImage:imgName inFrame:maxRect];
}

- (unsigned char *)getPointRGB:(CGPoint)point
{
    unsigned char *rgb = [self colorOfPoint:CGPointMake(point.x, point.y)];
    NSLog(@"%d %d %d", rgb[0], rgb[1], rgb[2]);
    return rgb;
}

- (CGRect)findImage:(NSString *)imgName inFrame:(CGRect)maxRect
{
    double timeStart = [[NSDate date] timeIntervalSince1970];

    UIImage *img = [UIImage imageNamed:imgName];
    unsigned char *data = [self getImgRGB:img];
    size_t imgWidth = img.size.width;
    size_t imgHeight = img.size.height;
    
//    unsigned char *superData = [self getImgRGB:[self getImageFromViewWithFrame:maxRect]];
    unsigned char *superData = [self getImgRGB:[self getImageFromView]];
    
    int const accuracy = 10;
    for (int i = maxRect.origin.y; i < maxRect.size.height; i++) {
        for (int j = maxRect.origin.x; j < maxRect.size.width; j++) {
            
            for (int m = 0; m < imgHeight; m++) {
                BOOL exit = NO;
                for (int n = 0; n < imgWidth; n++) {
                    
                    size_t pixelIndex = m * imgWidth * 4 + n * 4;
                    size_t superpixelIndex = (i+m) * self.view.frame.size.width * 4 + (j+n) * 4;
//                    NSLog(@"%3d %3d, %3d %3d %3d , %3d %3d %3d ",j+n, i+m, rgb[0], rgb[1], rgb[2], data2[m][n][0], data2[m][n][1], data2[m][n][2]);
                    
                    if (!((superData[superpixelIndex] + accuracy >= data[pixelIndex] && superData[superpixelIndex] - accuracy <= data[pixelIndex])  &&
                          (superData[superpixelIndex+1] + accuracy >= data[pixelIndex+1] && superData[superpixelIndex+1] - accuracy <= data[pixelIndex+1])  &&
                          (superData[superpixelIndex+2] + accuracy >= data[pixelIndex+2] && superData[superpixelIndex+2] - accuracy <= data[pixelIndex+2]))) {
                        exit = YES;
                        break;
                    }
                }
                if (exit) {
                    break;
                }

//                NSLog(@"%d %d %d %d----------------------------------------------------",i, j, m,height);
                if (m == imgHeight - 1) {
                    NSLog(@"成功找到图片，坐标是:%@", NSStringFromCGRect(CGRectMake(j, i, j+imgWidth, i+imgHeight)));
                    double timeEnd = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"结束。 执行时间：%.3f s",timeEnd-timeStart);
                    return CGRectMake(j, i, j+imgWidth, i+imgHeight);
                }
            }
        }
    }
    
    double timeEnd = [[NSDate date] timeIntervalSince1970];
    NSLog(@"结束。 执行时间：%.3f s",timeEnd-timeStart);
    return CGRectNull;
}
- (unsigned char *)colorOfPoint:(CGPoint)point {
    unsigned char *pixel = calloc(4, sizeof(unsigned char)); ;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.view.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
//    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return pixel;
}

- (unsigned char *)getImgRGB:(UIImage *)img
{
    CGImageRef cgimage = [img CGImage];
    
    size_t width = CGImageGetWidth(cgimage); // 图片宽度
    size_t height = CGImageGetHeight(cgimage); // 图片高度
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
    size_t bitsPerComponent = 8; // r g b a 每个component bits数目
    size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间
    
    CGContextRef context =
    CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    
    return data;
}

-(UIImage *)getImageFromViewWithFrame:(CGRect)frame
{
//    UIView * view = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIView * view = self.view;

    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [[UIScreen mainScreen] scale]);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, frame);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)getImageFromView
{
//    UIView * theView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    UIView * theView = self.view;

    UIGraphicsBeginImageContext(theView.bounds.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, theView.layer.contentsScale);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/**
 *  全屏截图----区域截图-------截图命名
 */
- (void)createScreenShot:(CGRect)frame withPNGName:(NSString *)picName
{
    UIView * view = self.view;// = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [[UIScreen mainScreen] scale]);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, frame);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    UIGraphicsEndImageContext();
    
//    NSString *pathDocuments = @"/var";
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:pathDocuments]){
        NSMutableDictionary * atributes=[NSMutableDictionary dictionaryWithCapacity:0];
        [atributes setValue:[NSNumber numberWithInt:0777] forKey:@"NSFilePosixPermissions"];
        [[NSFileManager defaultManager] createDirectoryAtPath:pathDocuments withIntermediateDirectories:YES attributes:atributes error:nil];
    }
    NSString*filePath=[pathDocuments stringByAppendingPathComponent:picName];
    NSLog(@"%@", filePath);
    NSData * creenData =UIImagePNGRepresentation(newImage);
    NSFileManager * fileManager=[NSFileManager defaultManager];
    [fileManager createFileAtPath:filePath contents:creenData attributes:nil];
//    [self myNotice:filePath];
    
    
//    UIView * screenView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
//    UIGraphicsBeginImageContextWithOptions(screenView.frame.size, YES, [[UIScreen mainScreen] scale]);
//    [screenView drawViewHierarchyInRect:screenView.bounds afterScreenUpdates:YES];
//    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    
//    
//    NSString *pathDocuments = @"/var";
//    NSString*filePath=[pathDocuments stringByAppendingPathComponent:@"contact.png"];
//    NSData * creenData =UIImagePNGRepresentation(screenImage);
//    NSFileManager * fileManager=[NSFileManager defaultManager];
//    [fileManager createFileAtPath:filePath contents:creenData attributes:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
