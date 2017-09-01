//
//  BeveledCircle.h
//  KlettAbiLernboxen
//
//  Created by Wang on 11.10.12.
//
//

#import <Foundation/Foundation.h>


void drawBeveledCircle(CGContextRef context, CGPoint center, uint radius, uint numberOfRings, CGColorRef innerColor, CGColorRef outerColor);

CGColorRef createColorBetweenColors(CGColorRef color1, CGColorRef color2, float percentage);


