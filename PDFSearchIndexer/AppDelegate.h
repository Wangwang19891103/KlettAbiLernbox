//
//  AppDelegate.h
//  PDFSearchIndexer
//
//  Created by Wang on 28.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSArray* stopWords;


- (NSMutableArray*) cleanArray:(NSArray*) array;

- (NSArray*) wordsSortedByTotalCount:(NSDictionary*) wordsDict;

- (NSArray*) wordsSortedAlphabetically:(NSDictionary*) wordsDict;

- (CGPDFDocumentRef) createDocumentRefFromPath:(NSString *)path;

@end


@interface WordNode : NSObject

@property (nonatomic, assign) uint pageNumber;
@property (nonatomic, assign) uint count;

@end
