//
//  CustomNavigationItem.m
//  KlettAbiLernboxen
//
//  Created by Wang on 02.12.12.
//
//

#import "CustomNavigationItem.h"
#import "CustomLabel.h"


@implementation CustomNavigationItem

//@synthesize title;
@synthesize font;
@synthesize textColor;


- (id) init {

    if (self = [super init]) {
        
        self.titleView = [[CustomLabel alloc] init];
//        self.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth
////        | UIViewAutoresizingFlexibleHeight
//        | UIViewAutoresizingFlexibleLeftMargin
//        | UIViewAutoresizingFlexibleRightMargin;
        
        [self updateLabel];
    }
    
    return self;
}


- (void) setTitle:(NSString *)theTitle {
    
    [super setTitle:theTitle];
    
    [self updateLabel];
}


- (void) setFont:(UIFont *)theFont {
    
    font = theFont;

    [self updateLabel];
}


- (void) setTextColor:(UIColor *)theTextColor {
    
    textColor = theTextColor;

    [self updateLabel];
}


- (void) updateLabel {
    
    CustomLabel* label = (CustomLabel*)self.titleView;
    
    label.title = self.title;
    label.font = font;
    label.textColor = textColor;
    
    [label update];
//    [label setFrameOrigin:CGPointZero];
}


- (void) updateTitleView {
    
    [self.titleView setNeedsDisplay];
    
}
@end
