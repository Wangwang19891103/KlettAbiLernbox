//
//  AppDelegate.m
//  KlettAbiLernboxen
//
//  Created by Stefan UeterWang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PageViewController.h"
#import "DocumentViewController.h"
#import "PDFManager.h"
#import "ModuleViewController.h"
#import "UAirship.h"
#import "UAProduct.h"
#import "UAStoreFront.h"
#import "UAConfig.h"
#import "CustomNavigationController.h"
#import "DataManager.h"
#import "CustomNavigationController.h"
#import "StatisticsViewController2.h"
#import "Contents1ViewController.h"
#import "Contents2ViewController.h"
#import "SearchIndex.h"
#import "PropertyBoard.h"
#import "NSObject+Extensions.h"
#import "ResourceManager.h"
#import "UAPush.h"
#import <Parse/Parse.h>


@implementation AppDelegate

@synthesize window = _window;
@synthesize customNavigationController;
@synthesize tabController;
@synthesize testint;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    /* PropertyBoard */
    
    //
    //    PBcreateIntVar(@"x", 200, 0, 1000);
    //    PBcreateIntVar(@"y", 100, 0, 1000);
    //    PBcreateIntVar(@"width", 20, 1, 50);
    //    PBcreateIntVar(@"height", 50, 1, 50);
 
    // correctionRect
//    PBcreateIntVar(@"alpha", 50, 0, 100);
//    PBcreateIntVar(@"x", 13, 0, 500);
//    PBcreateIntVar(@"y", 44, 0, 600);
//    PBcreateIntVar(@"width", 444, 0, 600);
//    PBcreateIntVar(@"height", 4, 0, 50);
    
    // {{13,44},{444,4}}
    // {{0,580},{420,3}}
    // {{20,533},{9,33}}
    
    
    // english normal rect: {{10,298},{398,0.2}}
    
    
    // NEEDED
    PBcreateIntVar(@"pattern saturation", 35, 0, 100);
    
    PBcreateIntVar(@"bar brightness", 100, 0, 100);
    PBcreateIntVar(@"bar saturation", 30, 0, 100);
    
    PBcreateIntVar(@"hide empty bars", 1, 0, 1);
    
    PBcreateIntVar(@"segmented saturation", 35, 0, 100);
    
    PBcreateIntVar(@"thumbnail width", 50, 30, 100);
    PBcreateIntVar(@"thumbnail alpha", 25, 0, 100);
    PBcreateIntVar(@"thumbnailbar saturation", 60, 0, 100);
    
    PBcreateIntVar(@"popupmenu saturation", 60, 0, 100);
    PBcreateIntVar(@"popupmenu marginLeft", 50, 0, 50);
    PBcreateIntVar(@"popupmenu marginTop", 3, 0, 50);
    PBcreateIntVar(@"popupmenu padding", 3, 0, 50);
    
    
    // needed? no?
    PBcreateIntVar(@"BeveledCircle lineWidth", 3, 1, 50);
    PBcreateIntVar(@"BeveledCircle ringOffset", 1, 1, 50);
    
    PBcreateIntVar(@"Statistics random", 0, 0, 1);
    
    
    // still needed?
    PBcreateIntVar(@"Title DropShadow offsetY", 3, 0, 20);
    PBcreateIntVar(@"Title DropShadow opacity", 69, 0, 100);    // 39
    PBcreateIntVar(@"Title DropShadow blur", 70, 0, 100);
    PBcreateIntVar(@"Title InnerShadow offsetY", 5, 0, 20);
    PBcreateIntVar(@"Title InnerShadow opacity", 32, 0, 100);  //43
    PBcreateIntVar(@"Title InnerShadow blur", 94, 0, 100);
    PBcreateIntVar(@"Title Stroke width", 13, 0, 20);
    PBcreateIntVar(@"Title Stroke opacity", 60, 0, 100);  // 29
    
    
    // check this
    PBcreateIntVar(@"Title Dummy opacity", 100, 0, 100);   // ?
    
    
    
    
    
    
    // print user database
    
//    [UserDataManager printToFile];
    
//    //Init Airship launch options
//    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
//    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
//    
//    // Create Airship singleton that's used to talk to Urban Airship servers.
//    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
//    [UAirship takeOff:takeOffOptions];
//    
//    [[UAPush shared] enableAutobadge:YES];
//    //    [[UAPush shared] resetBadge];//zero badge on startup
//    [[UAPush shared] setBadgeNumber:0];
//    
//    // Register for notifications
////    [[UIApplication sharedApplication]
////     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
////                                         UIRemoteNotificationTypeSound |
////                                         UIRemoteNotificationTypeAlert)];
//
//    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                         UIRemoteNotificationTypeSound |
//                                                         UIRemoteNotificationTypeAlert)];
//    
//    [[UAPush shared] handleNotification:[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]
//                       applicationState:application.applicationState];

    
    // new UA code (2.1)
    
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    
//    [[UAPush shared] resetBadge];
    [UAirship setLogging:YES];
    
//    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
//                                         UIRemoteNotificationTypeSound |
//                                         UIRemoteNotificationTypeAlert |
//                                         UIRemoteNotificationTypeNewsstandContentAvailability);
    
    
    
    
    
    [PDFManager manager].delegate = self;
    
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.tabController = [[UITabBarController alloc] init];
    self.tabController.delegate = self;
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIOffset offset = UIOffsetMake(0, -4);
    UIImage* iconImage = nil;
    NSDictionary* titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"Helvetica-Bold" size:8.0], UITextAttributeFont,
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         nil];
    
    UITabBarItem* item0 = [[UITabBarItem alloc] initWithTitle:@"Start" image:nil tag:0];
    iconImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Icons.Home"];
    item0.image = [[iconImage imageWithAdjustmentColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item0 setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item0 setTitleTextAttributes:titleTextAttributes forState:UIControlStateSelected];
    [item0 setTitlePositionAdjustment:offset];
    
    UITabBarItem* item1 = [[UITabBarItem alloc] initWithTitle:@"Lerninhalte" image:nil tag:1];
    iconImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Icons.Contents"];
    item1.image = [[iconImage imageWithAdjustmentColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item1 setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item1 setTitleTextAttributes:titleTextAttributes forState:UIControlStateSelected];
    [item1 setTitlePositionAdjustment:offset];

    UITabBarItem* item2 = [[UITabBarItem alloc] initWithTitle:@"Favoriten" image:nil tag:2];
    iconImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Icons.Favorites"];
    item2.image = [[iconImage imageWithAdjustmentColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item2 setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item2 setTitleTextAttributes:titleTextAttributes forState:UIControlStateSelected];
    [item2 setTitlePositionAdjustment:offset];

    UITabBarItem* item3 = [[UITabBarItem alloc] initWithTitle:@"Notizen" image:nil tag:3];
    iconImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Icons.Notes"];
    item3.image = [[iconImage imageWithAdjustmentColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item3 setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item3 setTitleTextAttributes:titleTextAttributes forState:UIControlStateSelected];
    [item3 setTitlePositionAdjustment:offset];

    UITabBarItem* item4 = [[UITabBarItem alloc] initWithTitle:@"Lernstatistik" image:nil tag:4];
    iconImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Icons.Stats"];
    item4.image = [[iconImage imageWithAdjustmentColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item4 setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [item4 setTitleTextAttributes:titleTextAttributes forState:UIControlStateSelected];
    [item4 setTitlePositionAdjustment:offset];

    [item1 setEnabled:FALSE];
    [item2 setEnabled:FALSE];
    [item3 setEnabled:FALSE];
    [item4 setEnabled:FALSE];
    
    UIViewController* vc0 = [[ModuleViewController alloc] init];
    UINavigationController* nc0 = [[UINavigationController alloc] initWithRootViewController:vc0];
    [nc0 setTabBarItem:item0];
    
    UIViewController* vc1 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeAll];
    UINavigationController* nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    [nc1 setTabBarItem:item1];
    
    UIViewController* vc2 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeFavorites];    UINavigationController* nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    [nc2 setTabBarItem:item2];
    
    UIViewController* vc3 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeNotes];
    UINavigationController* nc3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    [nc3 setTabBarItem:item3];
    
    UIViewController* vc4 = [[StatisticsViewController2 alloc] init];
    UINavigationController* nc4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    [nc4 setTabBarItem:item4];
    
    [self.tabController setViewControllers:[NSArray arrayWithObjects:nc0, nc1, nc2, nc3, nc4, nil]];
    
//    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.TopShadow"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    UIImageView* topShadowImageView = [[UIImageView alloc] initWithImage:bgImage];
//    topShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [topShadowImageView setFrameY:topShadowImageView.bounds.size.height * (-1)];
//    self.tabController.tabBar.clipsToBounds = FALSE;
//    [self.tabController.tabBar addSubview:topShadowImageView];
    
    [self.window setRootViewController:self.tabController];
    
    
    
    /* Appearance */
    
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.SearchBar.Field"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:bgImage forState:UIControlStateNormal];
    
    // navigation controllers - bottom shadow
    
    bgImage = resource(@"Images.NavigationBar.BottomShadow");
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    if ([nc0.navigationBar respondsToSelector:@selector(shadowImage)]) {
        
        [nc0.navigationBar setShadowImage:bgImage];
        [nc1.navigationBar setShadowImage:bgImage];
        [nc2.navigationBar setShadowImage:bgImage];
        [nc3.navigationBar setShadowImage:bgImage];
        [nc4.navigationBar setShadowImage:bgImage];
    }
    else {
        
        UIImageView* shadowView = [[UIImageView alloc] initWithImage:bgImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.frame = CGRectMake(0, nc0.navigationBar.bounds.size.height, nc0.visibleViewController.view.bounds.size.width, bgImage.size.height);
        [nc0.navigationBar addSubview:shadowView];

        shadowView = [[UIImageView alloc] initWithImage:bgImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.frame = CGRectMake(0, nc0.navigationBar.bounds.size.height, nc0.visibleViewController.view.bounds.size.width, bgImage.size.height);
        [nc1.navigationBar addSubview:shadowView];

        shadowView = [[UIImageView alloc] initWithImage:bgImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.frame = CGRectMake(0, nc0.navigationBar.bounds.size.height, nc0.visibleViewController.view.bounds.size.width, bgImage.size.height);
        [nc2.navigationBar addSubview:shadowView];

        shadowView = [[UIImageView alloc] initWithImage:bgImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.frame = CGRectMake(0, nc0.navigationBar.bounds.size.height, nc0.visibleViewController.view.bounds.size.width, bgImage.size.height);
        [nc3.navigationBar addSubview:shadowView];

        shadowView = [[UIImageView alloc] initWithImage:bgImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.frame = CGRectMake(0, nc0.navigationBar.bounds.size.height, nc0.visibleViewController.view.bounds.size.width, bgImage.size.height);
        [nc4.navigationBar addSubview:shadowView];

    }


    // tabbar shadow image
    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.TopShadow"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImageView* topShadowImageView = [[UIImageView alloc] initWithImage:bgImage];
    topShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [topShadowImageView setFrameWidth:nc0.visibleViewController.view.bounds.size.width];
    [topShadowImageView setFrameY:topShadowImageView.bounds.size.height * (-1)];
    self.tabController.tabBar.clipsToBounds = FALSE;
    [self.tabController.tabBar addSubview:topShadowImageView];

    
//    [[DataManager instanceNamed:@"user"] clearStore];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
#ifdef PB_ATTACH
    [[PropertyBoard instance] attach];
#endif
    
    [Parse setApplicationId:@"E3tbDRIIpM8YxNbJh2LzhSPkpI9267INryjsyLEK"
                  clientKey:@"PNVA2QLUuYlXWerVVbQaZiItgCJXEp0AyqA1cZiV"];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
 

    return YES;
}



#pragma mark PushNotifications

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    if (application.applicationState != UIApplicationStateBackground) {
        //[[UAPush shared] resetBadge];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    //    NSString* token = [[[[deviceToken description]
    //                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
    //                        stringByReplacingOccurrencesOfString: @">" withString: @""]
    //                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    //
    //    NSLog(@"*** devicetoken: %@", token);
    //
    //    // Updates the device token and registers the token with UA
    //    [[UAirship shared] registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    //[[UAPush shared] resetBadge];
}




- (void) pdfManagerDidLoadModule:(NSString *)moduleName {
    
    for (UITabBarItem* item in self.tabController.tabBar.items) {
        
        [item setEnabled:TRUE];
    }
}


- (void) pdfManagerDidUnloadModule {
    
    
    
    for (UITabBarItem* item in self.tabController.tabBar.items) {

        if (item.tag != 0) {
            [item setEnabled:FALSE];
        }
    }
    
    for (UIViewController* viewController in self.tabController.viewControllers) {
        
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController*)viewController popToRootViewControllerAnimated:FALSE];
        }
    }
    
}


- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSLog(@"custom navigation controller willshowviewcontroller");
    
    CustomNavigationController* customNavigationController = (CustomNavigationController*) navigationController;
    
    if (!customNavigationController.tabBar) {
        
        customNavigationController.tabBar = [[UITabBar alloc] initWithFrame:navigationController.toolbar.bounds];
        customNavigationController.tabBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | 
                                                                UIViewAutoresizingFlexibleWidth |
                                                                UIViewAutoresizingFlexibleLeftMargin |
                                                                UIViewAutoresizingFlexibleRightMargin;
        
        UITabBarItem* item0 = [[UITabBarItem alloc] initWithTitle:@"Startseite" image:nil tag:0];
        UITabBarItem* item1 = [[UITabBarItem alloc] initWithTitle:@"Lerninhalte" image:nil tag:1];
        UITabBarItem* item2 = [[UITabBarItem alloc] initWithTitle:@"Favoriten" image:nil tag:2];
        UITabBarItem* item3 = [[UITabBarItem alloc] initWithTitle:@"Notizen" image:nil tag:3];
        UITabBarItem* item4 = [[UITabBarItem alloc] initWithTitle:@"Lernstatistik" image:nil tag:4];
        
        [customNavigationController.tabBar setItems:[NSArray arrayWithObjects:item0, item1, item2, item3, item4, nil] animated:FALSE];
        customNavigationController.tabBar.delegate = customNavigationController;
        
//        [navigationController.toolbar addSubview:customNavigationController.tabBar];
        
        navigationController.toolbar.autoresizesSubviews = TRUE;
        
//        if (viewController.hidesBottomBarWhenPushed) {
//            [navigationController setToolbarHidden:TRUE animated:FALSE];
//        }
//        else {
//            [navigationController setToolbarHidden:FALSE animated:FALSE];
//        }
        
        customNavigationController.displayMode = customNavigationController.displayMode;   // workaround 
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[UAPush shared] resetBadge];
}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    
//    [UAirship land];
//}


#pragma mark - UAStoreFrontDelegate

-(void)productPurchased:(UAProduct*) product {
    UALOG(@"[StoreFrontDelegate] Purchased: %@ -- %@", product.productIdentifier, product.title);
}

-(void)storeFrontDidHide {
    UALOG(@"[StoreFrontDelegate] StoreFront quit, do something with content");
}

-(void)storeFrontWillHide {
    UALOG(@"[StoreFrontDelegate] StoreFront will hide");
}

- (void)productsDownloadProgress:(float)progress count:(int)count {
    UALOG(@"[StoreFrontDelegate] productsDownloadProgress: %f count: %d", progress, count);
    if (count == 0) {
        UALOG(@"Downloads complete");
    }
}


#pragma mark - UAStoreFrontObserverProtocol

- (void) inventoryStatusChanged:(NSNumber *)status {
    
    if ([status intValue] == UAInventoryStatusLoaded) {
        
        NSArray* products = [UAStoreFront productsForType:ProductTypeAll];
        NSMutableArray* installedProducts = [NSMutableArray array];
        NSMutableArray* notInstalledProducts = [NSMutableArray array];
        
        for (UAProduct* product in products) {
            
            if (product.status == UAProductStatusInstalled) {
                [installedProducts addObject:product];
            }
            else {
                [notInstalledProducts addObject:product];
            }
        }
        
        NSLog(@"installed products:");
        for (UAProduct* product in installedProducts) {
            NSLog(@"id: %@, title: %@, description: %@, price: %@", product.productIdentifier, product.title, product.productDescription, product.price);
        }
        
//        [UAStoreFront displayStoreFront:nil withProductID:((UAProduct*)[installedProducts objectAtIndex:0]).productIdentifier animated:TRUE];
        [UAStoreFront displayStoreFront:self.window.rootViewController animated:TRUE];
    }
}

@end



@implementation UINavigationController (Rotate)

- (BOOL) shouldAutorotate {
    
    return [self.visibleViewController shouldAutorotate];
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return [self.visibleViewController supportedInterfaceOrientations];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return [self.visibleViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end



@implementation UITabBarController (Rotate)

- (NSUInteger) supportedInterfaceOrientations {
    
    return [self.selectedViewController supportedInterfaceOrientations];
}


- (BOOL) shouldAutorotate {
    
    return [self.selectedViewController shouldAutorotate];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end




@implementation TabBarController2

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    CGRect before = self.view.frame;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGRect after = self.view.frame;
    
    alert(@"[willRotate] before: %@\nafter: %@", NSStringFromCGRect(before), NSStringFromCGRect(after));
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGRect before = self.view.frame;
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGRect after = self.view.frame;
    
    alert(@"[willAnimateRotation] before: %@\nafter: %@", NSStringFromCGRect(before), NSStringFromCGRect(after));
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    CGRect before = self.view.frame;
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect after = self.view.frame;
    
    alert(@"[didRotate] before: %@\nafter: %@", NSStringFromCGRect(before), NSStringFromCGRect(after));
}


- (void) viewDidLayoutSubviews {
    
    CGRect before = self.view.frame;
    
    [super viewDidLayoutSubviews];
    
    CGRect after = self.view.frame;
    
    alert(@"[didLayoutSubviews] before: %@\nafter: %@", NSStringFromCGRect(before), NSStringFromCGRect(after));
}


- (void) viewWillLayoutSubviews {
    
    CGRect before = self.view.frame;
    
    [super viewWillLayoutSubviews];
    
    CGRect after = self.view.frame;
    
    alert(@"[willLayoutSubviews] before: %@\nafter: %@", NSStringFromCGRect(before), NSStringFromCGRect(after));
}



@end
