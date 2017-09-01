//
//  ContentsModule.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentsCategory;

@interface ContentsModule : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *categories;
@end

@interface ContentsModule (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(ContentsCategory *)value;
- (void)removeCategoriesObject:(ContentsCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
