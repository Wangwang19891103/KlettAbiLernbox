//
//  Thumbnail.m
//  KlettAbiLernboxen
//
//  Created by Wang on 20.11.12.
//
//

#import "Thumbnail.h"
#import <QuartzCore/QuartzCore.h>


@implementation Thumbnail

@synthesize position, leftX, middleX, rightX, selected;


- (id) initWithImage:(UIImage *)image blendColor:(UIColor *)color {
    
    if (self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)]) {
        
        _image = image;
        _blendColor = color;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = FALSE;
//        self.clipsToBounds = FALSE;
        selected = FALSE;
    }
    
    return self;
}


- (void) setSelected:(BOOL)p_selected {
    
    selected = p_selected;
    
    if (selected) {
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.75;
    }
    else {

        self.layer.shadowColor = nil;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 0.0;
    }

    [self setNeedsDisplay];
}


- (void) drawRect:(CGRect)rect {
    
    NSLog(@"Thumbnail drawRect (position=%d, selected=%d)", position, selected);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_image drawInRect:rect];
    
    if (!selected) {

//        CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 0.75, [UIColor blackColor].CGColor);
        
        CGContextSetFillColorWithColor(context, [_blendColor colorWithAlphaComponent:PBintVarValue(@"thumbnail alpha") * 0.01].CGColor);
        CGContextFillRect(context, rect);
    }
}

@end
