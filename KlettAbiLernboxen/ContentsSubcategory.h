//
//  ContentsSubcategory.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentsCategory, ContentsPage;

@interface ContentsSubcategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * firstPageNumber;
@property (nonatomic, retain) NSNumber * numberOfPages;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) ContentsCategory *category;
@end

@interface ContentsSubcategory (CoreDataGeneratedAccessors)

- (void)addPagesObject:(ContentsPage *)value;
- (void)removePagesObject:(ContentsPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
