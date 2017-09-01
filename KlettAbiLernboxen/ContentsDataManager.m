//
//  ContentsDataManager.m
//  KlettAbiLernboxen
//
//  Created by Wang on 20.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentsDataManager.h"


@implementation ContentsDataManager


+ (void) save {
    
    [[DataManager instanceNamed:@"contents"] save];
}


+ (ContentsCategory*) fetchOrCreateCategoryWithName:(NSString *)name wasCreated:(BOOL *)wasCreated {
    
    ContentsCategory* category = nil;
    
    NSArray* results = [[DataManager instanceNamed:@"contents"] fetchDataForEntityName:@"ContentsCategory" withPredicate:[NSPredicate predicateWithFormat:@"name == %@", name] sortedBy:nil];
    
    NSLog(@"predicate: %@", [NSPredicate predicateWithFormat:@"name == %@", name]);
    
    if (results.count == 0) {
        
        category = [[DataManager instanceNamed:@"contents"] insertNewObjectForEntityName:@"ContentsCategory"];
        category.name = name;
        *wasCreated = TRUE;
        NSLog(@"Category created: %@", name);
    }
    else {
        category = [results objectAtIndex:0];
        *wasCreated = FALSE;
    }
    
    return category;    
}


+ (ContentsSubcategory*) fetchOrCreateSubcategoryWithName:(NSString *)subcategoryName forCategory:(ContentsCategory*) category wasCreated:(BOOL *)wasCreated {
    
    ContentsSubcategory* subcategory = nil;
    
    NSArray* results = [[DataManager instanceNamed:@"contents"] fetchDataForEntityName:@"ContentsSubcategory" withPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND category == %@", subcategoryName, category] sortedBy:nil];
    
    if (results.count == 0) {
        
        subcategory = [[DataManager instanceNamed:@"contents"] insertNewObjectForEntityName:@"ContentsSubcategory"];
        subcategory.name = subcategoryName;
        subcategory.category = category;
        *wasCreated = TRUE;
        NSLog(@"Subcategory created: %@", subcategoryName);
    }
    else {
        subcategory = [results objectAtIndex:0];
        *wasCreated = FALSE;
    }
    
    return subcategory;    
}


+ (ContentsPage*) createPageWithName:(NSString *)pageName forSubcategory:(ContentsSubcategory*) subcategory {
    
    ContentsPage* page = [[DataManager instanceNamed:@"contents"] insertNewObjectForEntityName:@"ContentsPage"];
    page.name = pageName;
    page.subcategory = subcategory;
    page.category = subcategory.category;
    
    return page;
}


+ (ContentsPage*) createPageWithName:(NSString *)pageName forCategory:(ContentsCategory *) category {
    
    ContentsPage* page = [[DataManager instanceNamed:@"contents"] insertNewObjectForEntityName:@"ContentsPage"];
    page.name = pageName;
    page.category = category;
    
    return page;
}


@end
