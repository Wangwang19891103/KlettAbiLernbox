//
//  PageViewController.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 29.10.14.
//
//

#import "PageViewController.h"

@implementation PageViewController


@synthesize scrollView2;
@synthesize contentView2;


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect frame = self.scrollView2.frame;
    frame.size.height *= 2;
    self.contentView2.frame = frame;
    
    [self.scrollView2 setContentSize:frame.size];
}

@end
