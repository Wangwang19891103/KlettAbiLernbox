//
//  CustomNavigationController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 18.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomNavigationController.h"
#import "AppDelegate.h"


@implementation CustomNavigationController

@synthesize firstViewController, tabBar, displayMode;


- (id) init {
    
    if (self = [super init]) {
        
        self.displayMode = DisplayModeNone;
    }
    
    return self;
}


- (UIViewController*) popViewControllerAnimated:(BOOL)animated {
    
//    UIViewController* firstViewController = [(AppDelegate*)[UIApplication sharedApplication].delegate firstViewController];
    UIViewController* previousViewController = [self.viewControllers objectAtIndex:[self.viewControllers count] - 2];
    
    if (previousViewController == firstViewController) {
        NSLog(@"previous IS first");
        firstViewController.hidesBottomBarWhenPushed = TRUE;
        [self setDisplayMode:DisplayModeNone];
    }
    
    return [super popViewControllerAnimated:animated];
}


- (void) setDisplayMode:(DisplayMode)theDisplayMode {
    
    NSLog(@"setDisplayMode: %d", theDisplayMode);
    
    if (theDisplayMode == displayMode) {
        
        NSLog(@"displayMode already set, ignoring...");
        
        return;
    }
    
    displayMode = theDisplayMode;
    
    if (self.tabBar) {
        
        uint index;
        
        switch (displayMode) {
                
            case DisplayModeContent:
                index = 1;
                break;
                
            case DisplayModeFavorites:
                index = 2;
                break;
                
            case DisplayModeNotes:
                index = 3;
                break;
                
            case DisplayModeStatistics:
                index = 4;
                break;
                
            default:
                index = 0;
                break;
        }
        
        NSLog(@"index: %d", index);
        
        UITabBarItem* item = nil;
        for (UITabBarItem* currentItem in [self.tabBar items]) {
            
            if (currentItem.tag == index) {
                item = currentItem;
                break;
            }
        }
        
        NSLog(@"item: %@", item);
        
        if (!item) {
            NSLog(@"ERROR: Could not select tab bar item with tag: %d", index);
            return;
        }
        
        self.tabBar.selectedItem = item;
        
        [self updateViewControllers];
    }
}


- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    NSLog(@"tabbar did select item tag: %d", item.tag);
    
    if (item.tag == 0) {
        self.tabBar.selectedItem = nil;
        [self popViewControllerAnimated:TRUE];
        return;
    }
    
    DisplayMode theDisplayMode;
    
    switch (item.tag) {

        case 1:
            theDisplayMode = DisplayModeContent;
            break;
            
        case 2:
            theDisplayMode = DisplayModeFavorites;
            break;
            
        case 3:
            theDisplayMode = DisplayModeNotes;
            break;
            
        case 4:
            theDisplayMode = DisplayModeStatistics;
            break;
            
        default:
            theDisplayMode = DisplayModeContent;
            break;
    }
    
    if (theDisplayMode == displayMode) {
        
        NSLog(@"item already selected, ignoring...");
        
        return;
    }
    
    displayMode = theDisplayMode;
    
    [self updateViewControllers];
}


- (void) updateViewControllers {
    
    for (UIViewController* viewController in self.viewControllers) {
        if ([viewController conformsToProtocol:@protocol(UpdatableViewController)]) {
            [(id<UpdatableViewController>)viewController updateForDisplayMode:self.displayMode];
        }
    }
}



@end
