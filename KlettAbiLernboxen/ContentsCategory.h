//
//  ContentsCategory.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentsPage, ContentsSubcategory;

@interface ContentsCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * firstPageNumber;
@property (nonatomic, retain) NSNumber * firstSubcategoryNumber;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfPages;
@property (nonatomic, retain) NSNumber * numberOfSubcategories;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) NSSet *subcategories;
@property (nonatomic, retain) NSManagedObject *module;
@end

@interface ContentsCategory (CoreDataGeneratedAccessors)

- (void)addPagesObject:(ContentsPage *)value;
- (void)removePagesObject:(ContentsPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

- (void)addSubcategoriesObject:(ContentsSubcategory *)value;
- (void)removeSubcategoriesObject:(ContentsSubcategory *)value;
- (void)addSubcategories:(NSSet *)values;
- (void)removeSubcategories:(NSSet *)values;

@end
