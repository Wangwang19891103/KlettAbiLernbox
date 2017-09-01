//
//  AppDelegate.h
//  ContentTableImporter
//
//  Created by Wang on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) import;

- (NSMutableDictionary*) mutableDictionaryWithObject:(id)object forKey:(NSString *)key inArray:(NSArray *)array;

@end
