//
//  AppDelegate.m
//  ThumbnailsCreator
//
//  Created by Wang on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ThumbnailCreator.h"
#import "PDFManager.h"
#import "UIColor+Extensions.h"


//#define CONTENT_DIRECTORY [[NSBundle mainBundle] pathForResource:CONTENT_PATH ofType:nil]
//#define PRODUCT_ID @"EnglischDEMO"
#define MODULE_NAME @"Physik"
//#define USE_SUFFIX @"@2x"
//#define USE_SUFFIX @""


@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString* fullPath = [[NSBundle mainBundle] pathForResource:[CONTENT_PATH stringByAppendingPathComponent:@"modules"] ofType:@"plist"];
    
     NSArray* modulesArray = [NSArray arrayWithContentsOfFile:fullPath];
    
    UIColor* color;
    
    for (NSDictionary* dict in modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:MODULE_NAME]) {
            NSString* colorString = [dict objectForKey:@"color"];
            color = [UIColor colorFromString:colorString];
        }
    }
    
    UIColor* bgColor = [color colorByDarkingByPercent:0.6];
    UIColor* fgColor = [color colorByLighteningByPercent:1.0];
    
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [pathArray lastObject];
    
//    [[PDFManager manager] setProductID:PRODUCT_ID];
    [[PDFManager manager] loadModule:MODULE_NAME];
    
    
//    for (NSDictionary* subcatDict in [PDFManager manager].contentsArray) {
//        
//        NSString* categoryName = [subcatDict objectForKey:@"category"];
//        
//        NSLog(@"category: %@", categoryName);
//        
//        [[PDFManager manager] loadCategory:categoryName];
//        
//        
//        
  
    ThumbnailCreator* creator = [[ThumbnailCreator alloc] initWithBackgroundColor:bgColor foregroundColor:fgColor];
    
    
    
    
    
    /* Non-Retina */
    
    NSArray* images = [creator createThumbnails2BeginningWithPageNumber:1 scaleFactor:1.0];

    uint currentPage = 1;

    for (UIImage* image in images) {
        
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%d.png", currentPage]];
        
        [creator saveImage:image toPNGFile:filePath];
        
        ++currentPage;
        
    }

    
    /* Retina */
    
    images = [creator createThumbnails2BeginningWithPageNumber:1 scaleFactor:2.0];
    
    currentPage = 1;
    
    for (UIImage* image in images) {
        
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%d@2x.png", currentPage]];
        
        [creator saveImage:image toPNGFile:filePath];
        
        ++currentPage;
        
    }

    
        
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
