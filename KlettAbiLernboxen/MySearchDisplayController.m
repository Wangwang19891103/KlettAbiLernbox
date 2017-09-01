//
//  MySearchDisplayController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 12.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySearchDisplayController.h"

@implementation MySearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    if(self.active == visible) return;
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
//    if (visible) {
//        [self.searchBar becomeFirstResponder];
//    } else {
//        [self.searchBar resignFirstResponder];
//    }   
}

@end
