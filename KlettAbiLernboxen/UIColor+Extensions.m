//
//  UIColor+Extensions.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor*) colorFromString:(NSString *)string {
    
    NSArray* components = [string componentsSeparatedByString:@","];
    
    if ([components count] != 3) {
        NSLog(@"Error parsing string: Must have 3 components");
    }
    
    NSMutableArray* intComponents = [NSMutableArray array];
    
    for (NSString* component in components) {
        uint intComponent = [component intValue];
        [intComponents addObject:[NSNumber numberWithInt:intComponent]];
    }
    
    return [UIColor colorWithRed:[[intComponents objectAtIndex:0] intValue] / 255.0
                           green:[[intComponents objectAtIndex:1] intValue] / 255.0
                            blue:[[intComponents objectAtIndex:2] intValue] / 255.0
                           alpha:1.0]; 
}


- (UIColor*) colorByDarkingByPercent:(float)percent {
    
    float factor = 1.0 - percent;
    
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [UIColor colorWithRed:red * factor green:green * factor blue:blue * factor alpha:alpha];
}


- (UIColor*) colorByLighteningByPercent:(float)percent {

    float factor = 1 + percent;

    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [UIColor colorWithRed:red * factor green:green * factor blue:blue * factor alpha:alpha];
}


- (UIColor*) colorWithSaturationFactor:(float)factor {
    
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    return [UIColor colorWithHue:hue saturation:saturation * factor brightness:brightness alpha:alpha];
}


- (UIColor*) colorWithBrightnessFactor:(float)factor {
    
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness * factor alpha:alpha];
}

@end
