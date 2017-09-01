//
//  TranslateIdiom.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TranslateIdiom.h"
#import "CGExtensions.h"


#define width_iphone 320.0
#define height_iphone 480.0
#define width_ipad 768.0
#define height_ipad 1024.0

#define h_Ratio (width_ipad / width_iphone)
#define v_Ratio (height_ipad / height_iphone)


int screenWidth() {
    
    return (is_ipad) ? width_ipad : width_iphone;
}

int screenHeight() {
    
    return (is_ipad) ? height_ipad : height_iphone;
}

BOOL isIdiomIpad() {
    
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

int translateIdiomInt(int value) {
    
    return (is_ipad) ? value * 2 : value;
}

int translateIdiomInt2(int value, float scale) {
    
    return (is_ipad) ? ceil(value * scale) : value;
}

float translateIdiomFloat(float value) {
    
    return (is_ipad) ? value * 2.0f : value;
}

int translateIdiomRelativeInt(int value, TranslateIdiomAlignment align) {
    
    if (is_ipad) {
        
        if (align == TranslateIdiomAlignmentHorizontal) {
            
            return round(value * h_Ratio);
        }
        else if (align == TranslateIdiomAlignmentVertical) {
            
            return round(value * v_Ratio);
        }
        else {
            
            return value * 2;
        }
    }
    else {
        
        return value;
    }
}


CGPoint translateIdiomCGPoint(CGPoint point, BOOL useRatio) {
    
    float hFactor = (useRatio) ? h_Ratio : 2;
    float vFactor = (useRatio) ? v_Ratio : 2;
    
    if (is_ipad) {
        
        return CGPointMake(round(point.x * hFactor), round(point.y * vFactor));
    }
    else {
        
        return point;
    }
}


CGSize translateIdiomCGSize(CGSize size, BOOL useRatio) {
    
    float hFactor = (useRatio) ? h_Ratio : 2;
    float vFactor = (useRatio) ? v_Ratio : 2;
    
//    NSLog(@"%f - %f (%d)", hFactor, vFactor, useRatio);
    
    if (is_ipad) {
        
        return CGSizeMake(round(size.width * hFactor), round(size.height * vFactor));
    }
    else {
        
        return size;
    }
}


CGRect translateIdiomCGRect(CGRect rect, BOOL useRatio) {

    CGRect returnedRect = CGRectMake(0, 0, 0, 0);
    returnedRect.origin = translateIdiomCGPoint(rect.origin, useRatio);
    returnedRect.size = translateIdiomCGSize(rect.size, useRatio);
    
    return returnedRect;
}


//CGPoint translateIdiomCGPointRelativeToHCenter(CGPoint point) {  // nur mit Portrait Mode kompatibel
//    
//    int screenWidth = (is_ipad) ? 768 : 320;
//    
//    int hOffset = (point.x - (screenWidth / 2)) * ((is_ipad) ? hRatio : 1);
//    
////    return CGPointMake(screenWidth / 2 + hOffset, point.y * ((is_ipad) ? vRatio : 1));
//    
//    return CGPointMake(point.x, point.y * ((is_ipad) ? vRatio : 1));
//}


int translateIdiomRelativeCoordinate(int i, TranslateIdiomAlignment alignment) {
    
    float ratio = (is_ipad) ? 2 : 1;
    int right = (is_ipad) ? width_ipad : width_iphone;
    int hCenter = right / 2;
    int bottom = (is_ipad) ? height_ipad : height_iphone;
    int vCenter = bottom / 2;
    
    
    switch (alignment) {

        case TranslateIdiomAlignmentLeft:
            
            return round(i * ratio);
            break;

        case TranslateIdiomAlignmentHCenter:
            
            return hCenter + round(i * ratio);
            break;

        case TranslateIdiomAlignmentRight:
            
            return right + round(i * ratio);
            break;

        case TranslateIdiomAlignmentTop:
            
            return round(i * ratio);
            break;

        case TranslateIdiomAlignmentVCenter:
            
            return vCenter + round(i * ratio);
            break;

        case TranslateIdiomAlignmentBottom:
            
            return bottom + round(i * ratio);
            break;
            
        default:
            
            return 0;
            break;
    }
}

NSString* translateIdiomImageFileName(NSString* fileName) {
    
    NSString* suffix = @"";
    
    if ([fileName hasSuffix:@".png"] || [fileName hasSuffix:@".jpg"]) {
        
        suffix = [fileName substringFromIndex:fileName.length - 4];
    }
        
    return [NSString stringWithFormat:@"%@%@%@", 
            [fileName substringWithRange:NSMakeRange(0, fileName.length - 4)],
            (is_ipad) ? @"@2x" : @"",
            suffix];
}



UIFont* translateIdiomFont(UIFont* font) {
    
    return [UIFont fontWithName:font.fontName size:((is_ipad) ? 2 : 1) * font.pointSize];
}








