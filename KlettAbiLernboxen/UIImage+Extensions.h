//
//  UIImage+Extensions.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 09.11.12.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (ColorAdjustment)

- (UIImage*) imageWithAdjustmentColor:(UIColor*) color;

- (UIImage*) imageWithAdjustmentSaturation:(UIColor*) color;

- (UIImage*) imageWithAdjustmentBrightness:(UIColor*) color;

- (UIImage*) imageWithRoundedCornersUsingRadius:(float) radius;

- (UIImage*) imageWithSize:(CGSize) size;

+ (UIImage*) imageWithColor:(UIColor*) color;

- (BOOL) saveInDocumentsWithName:(NSString*) name;

@end
