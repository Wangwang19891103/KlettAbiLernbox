//
//  CustomNavigationController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 18.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {

    DisplayModeContent,
    DisplayModeFavorites,
    DisplayModeNotes,
    DisplayModeStatistics,
    DisplayModeNone
} DisplayMode;


@protocol UpdatableViewController

- (void) updateForDisplayMode:(DisplayMode) displayMode;

@end


@interface CustomNavigationController : UINavigationController <UITabBarDelegate>

@property (nonatomic, assign) UIViewController* firstViewController;

@property (nonatomic, strong) UITabBar* tabBar;

@property (nonatomic, assign) DisplayMode displayMode;


- (void) updateViewControllers;

@end
