//
//  AppDelegate.m
//  ContentTableImporter
//
//  Created by Wang on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"


#define CSV_NAME @"contents_Mathematik"
#define DELIMITER @"#"
#define USE_SUBCATEGORIES TRUE


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self import];
    
    return YES;
}

- (void) import {
    
    NSString* contentsPath = [[NSBundle mainBundle] pathForResource:CSV_NAME ofType:@"csv"];
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [pathArray lastObject];
    NSString* plistPath = [documentsDirectory stringByAppendingPathComponent:@"contents.plist"];
    NSString* contents = [NSString stringWithContentsOfFile:contentsPath encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"contents path: %@", contentsPath);
    NSLog(@"plist path: %@", plistPath);
    
//    NSMutableArray* rootArray = [NSMutableArray array];
    NSMutableDictionary* rootDict = [NSMutableDictionary dictionary];
    NSMutableArray* contentsArray = [NSMutableArray array];
    
    [rootDict setObject:contentsArray forKey:@"contents"];
    [rootDict setObject:[NSNumber numberWithBool:USE_SUBCATEGORIES] forKey:@"useSubcategories"];
    
    // ...
    
    NSArray* lines = [contents componentsSeparatedByString:@"\n"];
    
    uint skipped = 0;
    uint currentPage = 1;
    
    for (NSString* line in lines) {
        
        NSLog(@"%@", line);
        
        NSArray* dataset = [line componentsSeparatedByString:DELIMITER];
        if ([dataset count] <= 1) {
            NSLog(@"--- SKIPPING!");
            ++skipped;
            continue;   
        }
        
        NSString* category1 = [dataset objectAtIndex:1];
        NSString* category2 = nil;
        NSString* title = nil;
        if (USE_SUBCATEGORIES) {
            category2 = [dataset objectAtIndex:2];
            title = [dataset objectAtIndex:3];   
        }
        else {
            title = [dataset objectAtIndex:2];   
        }
        
        NSMutableDictionary* category1Dict = [self mutableDictionaryWithObject:category1 forKey:@"category" inArray:contentsArray];
        if (!category1Dict) {
            NSLog(@"+ category1: %@", category1);
            category1Dict = [NSMutableDictionary dictionary];
            [category1Dict setObject:category1 forKey:@"category"];
            [category1Dict setObject:[NSNumber numberWithInt:0] forKey:@"pageCount"];
            if (USE_SUBCATEGORIES) {
                [category1Dict setObject:[NSMutableArray array] forKey:@"subcategories"];
            }
            else {
                [category1Dict setObject:[NSMutableArray array] forKey:@"pages"];
            }
            [contentsArray addObject:category1Dict];
        }
        
        NSMutableDictionary* pageDict = [NSMutableDictionary dictionary];
        [pageDict setObject:title forKey:@"title"];
        [pageDict setObject:[NSNumber numberWithInt:currentPage] forKey:@"number"];
        ++currentPage;
        
        if (category2) {
            NSMutableDictionary* category2Dict = [self mutableDictionaryWithObject:category2 forKey:@"category" inArray:[category1Dict objectForKey:@"subcategories"]];
            if (!category2Dict) {
                NSLog(@"+ category2: %@", category2);
                category2Dict = [NSMutableDictionary dictionary];
                [category2Dict setObject:category2 forKey:@"category"];
                [category2Dict setObject:[NSMutableArray array] forKey:@"pages"];
                [[category1Dict objectForKey:@"subcategories"] addObject:category2Dict];
            }
            [[category2Dict objectForKey:@"pages"] addObject:pageDict];
        }
        else {
            [[category1Dict objectForKey:@"pages"] addObject:pageDict];
        }
        
        [category1Dict setObject:[NSNumber numberWithInt:[[category1Dict objectForKey:@"pageCount"] intValue] + 1] forKey:@"pageCount"]; 
    }
    
    //    NSLog(@"content array:\n%@", rootArray);
    
    NSLog(@"%d lines skipped.", skipped);
    
    [rootDict writeToFile:plistPath atomically:YES];
    
    NSLog(@"%@", rootDict);
}


- (NSMutableDictionary*) mutableDictionaryWithObject:(id)object forKey:(NSString *)key inArray:(NSArray *)array {
    
    for (NSMutableDictionary* dict in array) {
        
        //        NSLog(@"key: %@, object: %@, found object: %@", key, object, [dict objectForKey:key]);
        
        if ([[dict objectForKey:key] isEqual:object]) {
            return dict;
        }
    }
    
    return nil;
}

@end
