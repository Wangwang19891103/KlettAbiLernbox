//
//  DataManager.m
//  Sprachenraetsel
//
//  Created by Wang on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DataManager.h"




@implementation DataManager

//@synthesize context = _context;


#pragma mark Initializer

- (id) initWithModelName:(NSString *)modelName storeName:(NSString *)storeName location:(DataManagerStoreLocation)location {
    
    if ((self = [super init])) {

        // ManagedObjectModel
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // PersistentStoreCoordinator

        NSURL *storeURL;
        
        switch (location) {
            case DataManagerStoreLocationDocuments:
            {
                NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
                NSString* fullStoreName = [NSString stringWithFormat:@"%@.sqlite", storeName];
                storeURL = [documentsDirectory URLByAppendingPathComponent:fullStoreName];
                break;
            }

            case DataManagerStoreLocationBundle:
            {    
                NSString* fullPath = [NSString stringWithFormat:@"/content/specific/database/%@", storeName];
                storeURL = [[NSBundle mainBundle] URLForResource:fullPath withExtension:@"sqlite"];
                break;
            }
                
            default:
                break;
        }
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSError* error;
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            [self handleError:error];
        
        // ManagedObjectContext
        
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
//        [coordinator release];
//        [managedObjectModel release];
    }
    
    return self;
}


- (id) initWithModelName:(NSString*) modelName path:(NSString *)path {
    
    if (self = [super init]) {
        
        // ManagedObjectModel
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // PersistentStoreCoordinator
        
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSError* error;
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            [self handleError:error];
        
        // ManagedObjectContext
        
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
        //        [coordinator release];
        //        [managedObjectModel release];
    }
    
    return self;
}


//
//- (id) init {
//    
//    if ((self = [super init])) {
//        
//        // Copy sqlite file (once)
//        
//        [self copyDatabase];
//        
//        // ManagedObjectModel
//        
//        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:model_name withExtension:@"momd"];
//        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//        
//        // PersistentStoreCoordinator
//        
//        // mainbundle pathforresource
//        
//        NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//        NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:db_name];
////        NSURL* storeURL = [[NSBundle mainBundle] URLForResource:@"Sprachenraetsel" withExtension:@"sqlite"];
//        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
//        NSError* error;
//        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
//            [self handleError:error];
//        
//        // ManagedObjectContext
//        
//        _context = [[NSManagedObjectContext alloc] init];
//        [_context setPersistentStoreCoordinator:coordinator];
//        [coordinator release];
//        [managedObjectModel release];
//    }
//    
//    return self;
//}

#pragma mark Shared Instance Method

//+ (DataManager*) sharedInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] init];
//        }
//    }
//    
//    return _instance;
//}

//+ (DataManager*) contentInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"content" storeName:@"content" location:DataManagerStoreLocationBundle];
//        }
//    }
//    
//    return _instance;
//}
//
//+ (DataManager*) importedContentInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"content" storeName:@"content" location:DataManagerStoreLocationDocuments];
//        }
//    }
//    
//    return _instance;
//}
//
//+ (DataManager*) playerInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"player" storeName:@"player" location:DataManagerStoreLocationDocuments];
//        }
//    }
//    
//    return _instance;
//}


+ (DataManager*) instanceNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
                
            DataManager* newManager = [[DataManager alloc] initWithModelName:name storeName:name location:DataManagerStoreLocationDocuments];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
    }
}

+ (DataManager*) instanceInBundleNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
            
            DataManager* newManager = [[DataManager alloc] initWithModelName:name storeName:name location:DataManagerStoreLocationBundle];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
    }
}


#pragma mark Methods

- (id) insertNewObjectForEntityName:(NSString *)name {
    
    return [NSEntityDescription insertNewObjectForEntityForName:name
                                  inManagedObjectContext:_context];
}


- (NSArray*) fetchDataForEntityName:(NSString*) name withPredicate: (NSPredicate*) predicate sortedBy: (NSString*) firstSorter, ... {
    
    // SortDescriptors erstellen
    
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    va_list arguments;
    
    if (firstSorter) {
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:firstSorter ascending:YES]];
        va_start(arguments, firstSorter);
        NSString* anotherString;
        while ((anotherString = va_arg(arguments, NSString*))) {
            [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:anotherString ascending:YES]];
        }
        va_end(arguments);
    }
    
    // Request
    NSArray* results;
    NSError* error;
    
    @synchronized(self) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:_context]];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        results = [_context executeFetchRequest:request error:&error];
    }
    
    if (!results) [self handleError:error];

    return results;
}


// WARNING: predicate might find more than 1 hit
- (id) fetchOrCreateObjectForEntityName:(NSString *)name withPredcate:(NSPredicate *)predicate {
    
    NSArray* results = [self fetchDataForEntityName:name withPredicate:predicate sortedBy:nil];
    
    if (results.count == 0) {
        
        return [self insertNewObjectForEntityName:name];
    }
    else {
        
        return [results objectAtIndex:0];
    }
}


- (int) countForEntity:(NSString *)entityName {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:_context]];
    NSError* error;
    
    int count = [_context countForFetchRequest:request error:&error];
    
//    [request release];
    
    return count;
}

- (void) deleteObject:(id)object {
    
    [_context deleteObject:object];
}

- (void) handleError:(NSError *)error {
    
    if (error) {
        NSLog(@"DataManager: Unresolved error: %@", [error userInfo]);
        abort();
    }
}

- (void) save {
    
    NSError *error = nil;
    
    if (_context && [_context hasChanges]) {
        [_context save:&error];
        [self handleError:error];
    }
}

- (void) clearStore {
    
//    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* storeURL = [[_context persistentStoreCoordinator] URLForPersistentStore:[[[_context persistentStoreCoordinator]persistentStores] lastObject] ];
//    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:db_name];
    NSError* error;
    
    // delete store file
    
    if (![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error])
        [self handleError:error];
    
    NSPersistentStoreCoordinator* coordinator = [_context persistentStoreCoordinator];
    
    [coordinator removePersistentStore:[[coordinator persistentStores] lastObject] error:&error];
    
    // recreate store file
    
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        [self handleError:error];
}


//- (void) copyDatabase {
//    
//    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
//    
//    NSString* originalDatabasePath = [resourcePath stringByAppendingPathComponent:db_name];
//    
//    // Create the path to the database in the Documents directory.
//    
//    NSArray* documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString* documentsDirectory = [documentsPaths objectAtIndex:0];
//    
//    NSString* newDatabasePath = [documentsDirectory stringByAppendingPathComponent:db_name];
//    
//    if (![[NSFileManager defaultManager] isReadableFileAtPath:newDatabasePath]) {
//        
//        if ([[NSFileManager defaultManager] copyItemAtPath:originalDatabasePath toPath:newDatabasePath error:NULL] != YES)
//            
//            NSAssert2(0, @"Fail to copy database from %@ to %@", originalDatabasePath, newDatabasePath);
//    }
//}

@end
