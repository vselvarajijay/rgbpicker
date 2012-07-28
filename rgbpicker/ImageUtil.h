//
//  ImageUtil.h
//  rgbpicker
//
//  Created by Vijay Selvaraj on 7/28/12.
//  Copyright (c) 2012 Vijay Selvaraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject


- (NSString *) UIColorToHexString:(UIColor *)uiColor;
- (UIColor*) getPixelColorAtLocation:(CGImageRef) inImage:(CGPoint)point;
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage;
- (UIColor*)getRGBPixelColorAtPoint:(CGImageRef) cgImage: (CGPoint)point;
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;
- (CGImageRef) cropImage:(UIImage*) sourceImage;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize:(UIImage*) sourceImage;


@end
