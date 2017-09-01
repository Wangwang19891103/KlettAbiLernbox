//
//  UIImage+Extensions.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 09.11.12.
//
//

#import "UIImage+Extensions.h"

@implementation UIImage (ColorAdjustment)

- (UIImage*) imageWithAdjustmentColor:(UIColor*) color {
    
//    NSLog(@"adjustmentColor: %@", color);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0.0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    /* drawing */
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
//    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextFillRect(context, rect);
    
    CGImageRef mainImageRef = self.CGImage;
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), mainImageRef);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, mainImageRef);
    
    /* /drawing */
    
//    CGImageRef image = CGBitmapContextCreateImage(context);
    
//    CGContextRelease(context);
//    free(data);

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*) imageWithAdjustmentSaturation:(UIColor*) color {
    
//    NSLog(@"adjustmentColor: %@", color);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    /* drawing */
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGImageRef mainImageRef = self.CGImage;
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), mainImageRef);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSaturation);
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, mainImageRef);
    
    /* /drawing */
    
    //    CGImageRef image = CGBitmapContextCreateImage(context);
    
    //    CGContextRelease(context);
    //    free(data);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*) imageWithAdjustmentBrightness:(UIColor *)color {
    
//    NSLog(@"adjustmentColor: %@", color);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    /* drawing */
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGImageRef mainImageRef = self.CGImage;
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), mainImageRef);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, mainImageRef);
    
    /* /drawing */
    
    //    CGImageRef image = CGBitmapContextCreateImage(context);
    
    //    CGContextRelease(context);
    //    free(data);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*) imageWithRoundedCornersUsingRadius:(float)arcRadius {
    
    UIGraphicsBeginImageContextWithOptions(self.size, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    CGRect innerRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextClearRect(context, innerRect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y);
    CGPathAddLineToPoint(path, NULL, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y);
    CGPathAddArcToPoint(path, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + arcRadius, arcRadius);
    CGPathAddLineToPoint(path, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height - arcRadius);
    CGPathAddArcToPoint(path, NULL, innerRect.origin.x + innerRect.size.width, innerRect.origin.y + innerRect.size.height, innerRect.origin.x + innerRect.size.width - arcRadius, innerRect.origin.y + innerRect.size.height, arcRadius);
    CGPathAddLineToPoint(path, NULL, innerRect.origin.x + arcRadius, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(path, NULL, innerRect.origin.x, innerRect.origin.y + innerRect.size.height, innerRect.origin.x, innerRect.origin.y + innerRect.size.height - arcRadius, arcRadius);
    CGPathAddLineToPoint(path, NULL, innerRect.origin.x, innerRect.origin.y + arcRadius);
    CGPathAddArcToPoint(path, NULL, innerRect.origin.x, innerRect.origin.y, innerRect.origin.x + arcRadius, innerRect.origin.y, arcRadius);

    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    [self drawInRect:innerRect];
    
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGPathRelease(path);
    
    return image;
}


- (UIImage*) imageWithSize:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 0.0f);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


+ (UIImage*) imageWithColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (BOOL) saveInDocumentsWithName:(NSString *)name {
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [pathArray lastObject];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:name];

    return [UIImagePNGRepresentation(self) writeToFile:filePath atomically:TRUE];
}

@end
