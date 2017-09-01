//
//  ModuleManager.m
//  KlettAbiLernboxen
//
//  Created by Wang on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleManager.h"
#import "UAStoreFront.h"
#import "UAProduct.h"
#import "UIColor+Extensions.h"
#import "UADownloadManager.h"



@implementation ModuleManager

@synthesize modulesArray;
//,delegate;


- (id) init {
    
    if (self = [super init]) {
        
        NSString* fullPath = [CONTENT_DIRECTORY stringByAppendingPathComponent:@"modules.plist"];
        
        if (!fullPath) {
            
            alert(@"modules.plist not found at path: %@", fullPath);
        }
        
        self.modulesArray = [NSArray arrayWithContentsOfFile:fullPath];
        _contentInstalledForModule = [NSMutableDictionary dictionary];
        _moduleNamesForProductIDs = [NSMutableDictionary dictionary];
        _observerDict = [NSMutableDictionary dictionary];
        _productObservers = [NSMutableArray array];
        
        [self checkForInstalledContent];
        
        
        
        
        
        /*******************/
        
        if (&UIApplicationDidEnterBackgroundNotification != NULL) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(enterBackground)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
        
        if (&UIApplicationDidBecomeActiveNotification != NULL) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(enterForeground)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
        }

    
    
    }
    
    return self;
}


- (void) enterBackground {
    
    _wasBackgrounded = TRUE;
    
    NSLog(@"[ModuleManager enterBackground");
    
    [_productObservers makeObjectsPerformSelector:@selector(unregister)];
    [_productObservers removeAllObjects];
}


- (void) enterForeground {
    
    if (_wasBackgrounded) {

        NSLog(@"[ModuleManager enterForeground");

//        [_productObservers makeObjectsPerformSelector:@selector(reregister)];
//        [_productObservers removeAllObjects];
        [UAStoreFront loadInventory];
        
        _wasBackgrounded = FALSE;
    }
}


- (void) checkForInstalledContent {
    
    NSLog(@"ModuleManager -checkForInstalledContent");
    
    for (NSDictionary* dict in self.modulesArray) {
        
        NSString* moduleName = [dict objectForKey:@"title"];
        NSString* productID = [dict objectForKey:@"productID"];
        NSString* demoID = [dict objectForKey:@"demoID"];
        
        [_moduleNamesForProductIDs setObject:moduleName forKey:productID];
        
        NSLog(@"moduleName: %@", moduleName);
        NSLog(@"productID: %@", productID);
        NSLog(@"demoID: %@", demoID);

        /* 1. check for FULL module
         * 1.1. check in DOWNLOAD directory
         * 1.2. check in CONTENT directory
         * 2. check for DEMO module
         * 2.1. check in CONTENT directory
         */

        NSString* modulePath = nil;
        NSMutableDictionary* installedDict = [NSMutableDictionary dictionary];
        
        /* 1. check for FULL module */
        
        
        /* 1.1.1. check in DOWNLOAD directory */
        if ([[NSFileManager defaultManager] fileExistsAtPath:[(modulePath = [[DOWNLOAD_DIRECTORY stringByAppendingPathComponent:productID] stringByAppendingPathComponent:@"Contents"]) stringByAppendingPathComponent:@"contents.sqlite"] isDirectory:nil]) {

            [installedDict setObject:[NSNumber numberWithInt:ModuleInstallationStatusFull] forKey:@"installationStatus"];
            [installedDict setObject:modulePath forKey:@"path"];
        }

        /* 1.1.2. check in OLD DOWNLOAD directory */
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[(modulePath = [DOWNLOAD_DIRECTORY stringByAppendingPathComponent:productID]) stringByAppendingPathComponent:@"contents.sqlite"] isDirectory:nil]) {
            
            [installedDict setObject:[NSNumber numberWithInt:ModuleInstallationStatusFull] forKey:@"installationStatus"];
            [installedDict setObject:modulePath forKey:@"path"];
        }
        
        /* 1.2. check in CONTENT directory */
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[(modulePath = [CONTENT_DIRECTORY stringByAppendingPathComponent:productID]) stringByAppendingPathComponent:@"contents.sqlite"] isDirectory:nil]) {
            
            [installedDict setObject:[NSNumber numberWithInt:ModuleInstallationStatusFull] forKey:@"installationStatus"];
            [installedDict setObject:modulePath forKey:@"path"];
        }

        /* 2. check for DEMO module */
        
        /* 2.1. check in CONTENT directory */
        else if (demoID && [[NSFileManager defaultManager] fileExistsAtPath:[(modulePath = [CONTENT_DIRECTORY stringByAppendingPathComponent:demoID]) stringByAppendingPathComponent:@"contents.sqlite"] isDirectory:nil]) {
            
            [installedDict setObject:[NSNumber numberWithInt:ModuleInstallationStatusDemo] forKey:@"installationStatus"];
            [installedDict setObject:modulePath forKey:@"path"];
        }
        
        else {

            [installedDict setObject:[NSNumber numberWithInt:ModuleInstallationStatusNone] forKey:@"installationStatus"];
        }
        
        [_contentInstalledForModule setObject:installedDict forKey:moduleName];
        
        NSLog(@"installationStatus: %@", [installedDict objectForKey:@"installationStatus"]);
        NSLog(@"modulePath: %@", [installedDict objectForKey:@"path"]);
    }
}


- (BOOL) contentInstalledForModule:(NSString *)moduleName {
    
    return [[[_contentInstalledForModule objectForKey:moduleName] objectForKey:@"installationStatus"] intValue];
}


- (uint) installationStatusForModule:(NSString *)moduleName {
    
    return [[[_contentInstalledForModule objectForKey:moduleName] objectForKey:@"installationStatus"] intValue];
}


- (NSString*) pathForModule:(NSString *)moduleName {
    
    return [[_contentInstalledForModule objectForKey:moduleName] objectForKey:@"path"];
}


- (void) loadInventory {

    [UAStoreFront registerObserver:self];
    [UAStoreFront loadInventory];
}


+ (ModuleManager*) manager {
    
    static ModuleManager* _instance;
    
    @synchronized(self) {
        
        if (!_instance) {
            
            _instance = [[ModuleManager alloc] init];
        }
    }
    
    return _instance;
}


//// returns either DEMO or FULL id
//- (NSString*) productIDForModule:(NSString *)moduleName {
//    
//    
//    for (NSDictionary* dict in self.modulesArray) {
//        
//        if ([[dict objectForKey:@"title"] isEqualToString:moduleName]) {
//            
//            ModuleInstallationStatus status = [[_contentInstalledForModule objectForKey:[dict objectForKey:@"productID"]] intValue];
//
//            switch (status) {
//                case ModuleInstallationStatusFull:
//                    return [dict objectForKey:@"productID"];
//                    break;
//
//                case ModuleInstallationStatusDemo:
//                    return [dict objectForKey:@"demoID"];
//                    
//                default:
//                    NSLog(@"Module not found: %@", moduleName);
//                    return nil;
//                    break;
//            }
//        }
//    }
//}


- (UIColor*) colorForModule:(NSString *)moduleName {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:moduleName]) {
            NSString* colorString = [dict objectForKey:@"color"];
            return [UIColor colorFromString:colorString];
        }
    }
    
    NSLog(@"Module not found: %@", moduleName);
    
    return nil;
}


- (NSArray*) correctionRectsForModule:(NSString *)module {

    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            NSMutableArray* correctionRects = [NSMutableArray array];
            
            NSArray* rectArray = [dict objectForKey:@"correctionRects"];
            
            if (rectArray)
            for (NSString* rectString in rectArray) {
                
                CGRect rect;
                
                if (!rectString) {

                    rect = CGRectZero;
                }
                else {

                    rect = CGRectFromString(rectString);
                }
                
                [correctionRects addObject:[NSValue valueWithCGRect:rect]];
            }

            else
                for (int i = 0; i < 3; ++i) {
                    
                    [correctionRects addObject:[NSValue valueWithCGRect:CGRectZero]];
                }
            
            return correctionRects;
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (NSArray*) bottomCorrectionsForModule:(NSString*) module {

    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            NSMutableArray* correctionRects = [NSMutableArray array];
            
            NSArray* rectArray = [dict objectForKey:@"bottomCorrections"];
            
            if (rectArray)
                for (NSString* rectString in rectArray) {
                    
                    CGRect rect;
                    
                    if (!rectString) {
                        
                        rect = CGRectZero;
                    }
                    else {
                        
                        rect = CGRectFromString(rectString);
                    }
                    
                    [correctionRects addObject:[NSValue valueWithCGRect:rect]];
                }
            
            else
                for (int i = 0; i < 3; ++i) {
                    
                    [correctionRects addObject:[NSValue valueWithCGRect:CGRectZero]];
                }
            
            return correctionRects;
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (CGRect) seperatorRectForModule:(NSString*) module {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            NSString* rectString = [dict objectForKey:@"seperatorRect"];
            
            CGRect rect = CGRectFromString(rectString);
            
            return rect;
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return CGRectZero;
}


- (NSDictionary*) seperatorRectPagesForModule:(NSString*) module {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            return [dict objectForKey:@"seperatorRectPages"];
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (NSDictionary*) bottomCorrectionPagesForModule:(NSString *)module {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            return [dict objectForKey:@"bottomCorrectionPages"];
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (NSString*) shopDescriptionFileForModule:(NSString *)module {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            return [dict objectForKey:@"shopDescriptionFile"];
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (UIImage*) iconImageForModule:(NSString *)module {
    
    for (NSDictionary* dict in self.modulesArray) {
        
        if ([[dict objectForKey:@"title"] isEqualToString:module]) {
            
            NSString* iconFileName = [dict objectForKey:@"iconFile"];
            return [UIImage imageNamed:iconFileName];
        }
    }
    
    NSLog(@"Module not found: %@", module);
    
    return nil;
}


- (void) inventoryStatusChanged:(NSNumber *)status {
    
    NSLog(@"inventoryStatusChanged: %@", status);
    
    if ([status intValue] == UAInventoryStatusLoaded) {
        
        NSArray* products = [UAStoreFront productsForType:ProductTypeAll];
        NSMutableDictionary* productDict = [NSMutableDictionary dictionary];
        
        NSLog(@"product count: %d", [products count]);
        
        for (UAProduct* product in products) {

            NSLog(@"product:\n%@", product);

            NSLog(@"RECEIPT:\n%@", product.receipt);
            
            /* create observer for product */
            
            [productDict setObject:product forKey:product.productIdentifier];
            
            ProductObserver* observer = [[ProductObserver alloc] initWithProduct:product];
            observer.delegate = self;
            
            [_productObservers addObject:observer];
            
            
            /* inform observers that product has been loaded */
            
            NSString* moduleNameForProduct = [_moduleNamesForProductIDs objectForKey:product.productIdentifier];
            
            NSArray* observerArray = [_observerDict objectForKey:moduleNameForProduct];
            
            for (id<NSObject, ModuleManagerObserver> observer in observerArray) {
                
                if ([observer respondsToSelector:@selector(product:loadedForModule:)]) {
                    
                    [observer product:product loadedForModule:moduleNameForProduct];
                }
            }
        }
        
        
        /* set products for modules in modules array */
        
        for (NSMutableDictionary* moduleDict in self.modulesArray) {
            
            NSString* productID = [moduleDict objectForKey:@"productID"];
            UAProduct* product = [productDict objectForKey:productID];
            
            if (!product) continue;

            [moduleDict setObject:product forKey:@"product"];
        }
    }
}


#pragma mark ModuleManager Observers

- (void) addObserver:(id<ModuleManagerObserver>)object forModule:(NSString *)moduleName {
    
    NSMutableArray* observerArray = [_observerDict objectForKey:moduleName];
    
    if (!observerArray) {
        
        observerArray = [NSMutableArray array];
        [_observerDict setObject:observerArray forKey:moduleName];
    }
    
    [observerArray addObject:object];
}


- (void) removeObserver:(id<ModuleManagerObserver>)object forModule:(NSString *)moduleName {
    
    NSMutableArray* observerArray = [_observerDict objectForKey:moduleName];
    
    if (!observerArray) {
        
        NSLog(@"ERROR in [ModuleManager -removeObserver:forModule:]: no observer array found for module name (%@)", moduleName);
    }
    else if (![observerArray containsObject:object]) {

        NSLog(@"ERROR in [ModuleManager -removeObserver:forModule:]: object (%@) not found in observer array for module name (%@)", object, moduleName);
    }
    else {
        
        [observerArray removeObject:object];
    }
}



#pragma mark ProductObserverDelegate

- (void) product:(UAProduct *)product didChangeStatus:(NSNumber *)status {
    
    NSLog(@"[ModuleManager product:didChangeStatus:] product=%@, status=%d", product.productIdentifier, product.status);
    
    NSString* moduleForProduct = [_moduleNamesForProductIDs objectForKey:product.productIdentifier];
    NSArray* observerArray = [_observerDict objectForKey:moduleForProduct];

    if ([status intValue] == UAProductStatusInstalled) {
        
        [self checkForInstalledContent];
    }
    
    for (id<NSObject, ModuleManagerObserver> observer in observerArray) {
        
        if ([observer respondsToSelector:@selector(product:statusChangedTo:forModule:)]) {
            
            [observer product:product statusChangedTo:status forModule:moduleForProduct];
        }
    }
}


- (void) product:(UAProduct *)product didChangeProgress:(NSNumber *)progress {
    
    NSString* moduleForProduct = [_moduleNamesForProductIDs objectForKey:product.productIdentifier];
    NSArray* observerArray = [_observerDict objectForKey:moduleForProduct];
    
    for (id<NSObject, ModuleManagerObserver> observer in observerArray) {
        
        if ([observer respondsToSelector:@selector(product:progressChangedTo:forModule:)]) {
            
            [observer product:product progressChangedTo:progress forModule:moduleForProduct];
        }
    }
}




@end




@implementation ProductObserver

@synthesize delegate;


- (id) initWithProduct:(UAProduct *)product {
    
    if (self = [super init]) {
        
        _product = product;
        [product addObserver:self];
    }
    
    return self;
}


- (void) unregister {
    
    NSLog(@"[ProductObserver unregister] product=%@", _product.productIdentifier);
    
    [_product removeObserver:self];
}


//- (void) reregister {
//
//    NSLog(@"[ProductObserver reregister] product=%@", _product.productIdentifier);
//
//    [_product addObserver:self];
//}


- (void) productStatusChanged:(NSNumber *)status {
    
    [delegate product:_product didChangeStatus:status];
}


- (void) productProgressChanged:(NSNumber *)progress {
    
    [delegate product:_product didChangeProgress:progress];
}

@end
