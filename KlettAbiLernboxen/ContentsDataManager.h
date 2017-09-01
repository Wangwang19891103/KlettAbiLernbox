//
//  ContentsDataManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "ContentsPage.h"
#import "ContentsSubcategory.h"
#import "ContentsCategory.h"


@interface ContentsDataManager : DataManager

+ (void) save;

+ (ContentsCategory*) fetchOrCreateCategoryWithName:(NSString*) name wasCreated:(BOOL*) wasCreated;

+ (ContentsSubcategory*) fetchOrCreateSubcategoryWithName:(NSString *)subcategoryName forCategory:(ContentsCategory*) category wasCreated:(BOOL*) wasCreated;

+ (ContentsPage*) createPageWithName:(NSString *)pageName forSubcategory:(ContentsSubcategory*) subcategory;

+ (ContentsPage*) createPageWithName:(NSString *)pageName forCategory:(ContentsCategory*) category;


@end
