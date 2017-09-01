//
//  AppDelegate.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAStoreFrontDelegate.h"
#import "UAStoreFront.h"
#import "CustomNavigationController.h"
#import "PDFManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UAStoreFrontDelegate, UAStoreFrontObserverProtocol, UITabBarControllerDelegate, UINavigationControllerDelegate, PDFManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) CustomNavigationController* customNavigationController;

@property (nonatomic, strong) UITabBarController* tabController;


@property (nonatomic, assign) uint testint;

@end



//@interface PortraitNavigationController : UINavigationController
//
//@end

@interface UINavigationController (Rotate)

@end


@interface UITabBarController (Rotate)

@end



@interface TabBarController2 : UITabBarController

@end

