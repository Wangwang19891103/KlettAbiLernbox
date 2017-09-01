//
//  CGExtensions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CGExtensions.h"




//- (void) scaleToSize:(CGSize)theSize withUpScale:(BOOL)upScale {
//    
//    CGRect newFrame = self.frame;
//    float oldWidth = newFrame.size.width;
//    float oldHeight = newFrame.size.height;
//    float ratioW = (theSize.width > oldWidth && !upScale) ? 1 : theSize.width / oldWidth;
//    float ratioH = (theSize.height > oldHeight && !upScale) ? 1 : theSize.height / oldHeight;
//    float ratio = (ratioW < ratioH) ? ratioW : ratioH;
//    CGSize newSize = CGSizeMake(oldWidth * ratio, oldHeight * ratio);
//    newFrame.size = newSize;    
//    self.frame = newFrame;
//}


CGSize CGSizeScaleToSize(CGSize oldSize, CGSize newSize, BOOL upscale) {

    float ratioW = (newSize.width > oldSize.width && !upscale) ? 1 : newSize.width / oldSize.width;
    float ratioH = (newSize.height > oldSize.height && !upscale) ? 1 : newSize.height / oldSize.height;
    float ratio = (ratioW < ratioH) ? ratioW : ratioH;
    CGSize returnSize = CGSizeMake(oldSize.width * ratio, oldSize.height * ratio);
    
    return returnSize;
}

// derp??
CGPoint CGSizeCenterInSize(CGSize size, CGSize parentSize) {
    
    return CGPointZero;
}

CGRect CGRectCopy(CGRect rect) {
    
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

CGRect CGRectCenterXInRect(CGRect rect, CGRect parentRect) {
    
    CGRect newRect = CGRectCopy(rect);
    newRect.origin.x = (parentRect.size.width - rect.size.width) / 2;
    
    return newRect;
}

CGRect CGRectCenterYInRect(CGRect rect, CGRect parentRect) {
    
    CGRect newRect = CGRectCopy(rect);
    newRect.origin.y = (parentRect.size.height - rect.size.height) / 2;
    
    return newRect;
}

CGSize CGSizeScaleByFactor(CGSize size, float factor) {
    
    CGSize newSize = CGSizeMake(size.width * factor, size.height * factor);
    
    return newSize;
}

CGPoint CGPointScaleByFactor(CGPoint point, float factor) {
    
    CGPoint newPoint = CGPointMake(point.x * factor, point.y * factor);
    
    return newPoint;
}

CGRect CGRectScaleByFactor(CGRect rect, float factor) {
    
    CGPoint newOrigin = CGPointScaleByFactor(rect.origin, factor);
    CGSize newSize = CGSizeScaleByFactor(rect.size, factor);
    
    return CGRectMake(newOrigin.x, newOrigin.y, newSize.width, newSize.height);
}

CGRect CGSizeCenterInRect(CGSize size, CGRect rect) {
    
    float newX = (rect.size.width - size.width) / 2;
    float newY = (rect.size.height - size.height) / 2;
    
    return CGRectMake(rect.origin.x + newX, rect.origin.y + newY, size.width, size.height);
}