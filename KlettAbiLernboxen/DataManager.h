//
//  DataManager.h
//  Sprachenraetsel
//
//  Created by Wang on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    DataManagerStoreLocationBundle,
    DataManagerStoreLocationDocuments
} DataManagerStoreLocation;

@interface DataManager : NSObject {
    NSManagedObjectContext* _context;
}

- (id) initWithModelName:(NSString*) modelName storeName:(NSString*) storeName location:(DataManagerStoreLocation) location;

- (id) initWithModelName:(NSString*) modelName path:(NSString *)path;

//+ (DataManager*) sharedInstance;

//+ (DataManager*) contentInstance;
//+ (DataManager*) importedContentInstance;
//+ (DataManager*) playerInstance;

+ (DataManager*) instanceNamed:(NSString*) name;

+ (DataManager*) instanceInBundleNamed:(NSString *)name;


- (id) insertNewObjectForEntityName:(NSString*) name;

- (NSArray*) fetchDataForEntityName:(NSString*) name withPredicate: (NSPredicate*) predicate sortedBy: (NSString*) firstSorter, ...;

- (id) fetchOrCreateObjectForEntityName:(NSString*) name withPredcate:(NSPredicate*) predicate;

- (int) countForEntity:(NSString*) entityName;

- (void) deleteObject:(id) object;

- (void) save;
- (void) clearStore;
- (void) handleError:(NSError*) error;

//- (void) copyDatabase;

@end

