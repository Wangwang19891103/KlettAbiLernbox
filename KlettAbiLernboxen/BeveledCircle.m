//
//  BeveledCircle.m
//  KlettAbiLernboxen
//
//  Created by Wang on 11.10.12.
//
//

#import "BeveledCircle.h"
#import "PropertyBoard.h"


#define LINE_WIDTH 1.0f
#define RING_OFFSET 0.3f


void drawBeveledCircle(CGContextRef context, CGPoint center, uint radius, uint numberOfRings, CGColorRef innerColor, CGColorRef outerColor) {
    
    CGContextSaveGState(context);
    
    float lineWidth = 0.1 * [PBvarValue(@"BeveledCircle lineWidth") intValue];
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    uint middle = ceil(numberOfRings * 0.5); //ex.: 5 -> 3
    uint distanceToOuter = numberOfRings - middle; //ex.: 5 -> 2

    float currentRadius;
    float percentage;
    CGColorRef color;
    CGRect rect;
    
//    NSLog(@"numberOfRings=%d, middle=%d, distanceToOuter=%d", numberOfRings, middle, distanceToOuter);
    
//    for (uint i = 1; i <= numberOfRings; ++i) {

    float ringOffset = [PBvarValue(@"BeveledCircle ringOffset") intValue] * 0.1;
    
    for (uint i = 1, ring = middle, direction = 1, adder = 1;
         i <= numberOfRings;
         ++i, ring += (adder * direction),direction *= -1, adder += 1) {
        
        currentRadius = (float)radius + ((int)(ring - middle) * (1.0f + ringOffset));
        percentage = abs(middle - ring) / (float)distanceToOuter;
        color = createColorBetweenColors(innerColor, outerColor, percentage);
        rect = CGRectMake(center.x - currentRadius, center.y - currentRadius, currentRadius * 2, currentRadius * 2);
        
        NSLog(@"Ring: %d, alpha: %f, radius: %0.2f", ring, CGColorGetComponents(color)[3], currentRadius);
        
        CGContextSetStrokeColorWithColor(context, color);
        CGContextAddEllipseInRect(context, rect);
        CGContextStrokePath(context);
        
        CGColorRelease(color);
    }
    
    CGContextRestoreGState(context);
}


CGColorRef createColorBetweenColors(CGColorRef color1, CGColorRef color2, float percentage) {
    
    const float* components1 = CGColorGetComponents(color1);
    const float* components2 = CGColorGetComponents(color2);
    
    float red = components1[0] + ((components2[0] - components1[0]) * percentage);
    float green = components1[1] + ((components2[1] - components1[1]) * percentage);
    float blue = components1[2] + ((components2[2] - components1[2]) * percentage);
    float alpha = components1[3] + ((components2[3] - components1[3]) * percentage);
    
    const CGFloat newComponents[4] = {red, green, blue, alpha};

//    NSLog(@"---- createColorBetweenColors");
//    NSLog(@"percentage: %f", percentage);
//    NSLog(@"color1: r=%f, g=%f, b=%f, a=%f", components1[0],components1[1],components1[2],components1[3]);
//    NSLog(@"color2: r=%f, g=%f, b=%f, a=%f", components2[0],components2[1],components2[2],components2[3]);
//    NSLog(@"color3: r=%f, g=%f, b=%f, a=%f", newComponents[0],newComponents[1],newComponents[2],newComponents[3]);

    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), newComponents);
}
