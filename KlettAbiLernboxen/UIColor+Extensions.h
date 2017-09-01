//
//  UIColor+Extensions.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (Extensions)

+ (UIColor*) colorFromString:(NSString*) string;

- (UIColor*) colorByDarkingByPercent:(float) percent;

- (UIColor*) colorByLighteningByPercent:(float) percent;

- (UIColor*) colorWithSaturationFactor:(float) factor;

- (UIColor*) colorWithBrightnessFactor:(float) factor;

@end
