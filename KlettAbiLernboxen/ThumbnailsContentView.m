//
//  ThumbnailsContentView.m
//  KlettAbiLernboxen
//
//  Created by Wang on 20.11.12.
//
//

#import "ThumbnailsContentView.h"

@implementation ThumbnailsContentView

@synthesize forwardView;


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    return forwardView;
}

@end
