//
//  Page.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module, Note;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * learnStatus;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Module *module;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Page (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
