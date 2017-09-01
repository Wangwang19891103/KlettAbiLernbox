//
//  Module.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface Module : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *pages;
@end

@interface Module (CoreDataGeneratedAccessors)

- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
