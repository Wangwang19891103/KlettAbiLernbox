//
//  ModuleManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 15.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAStoreFront.h"
#import "UAProduct.h"




typedef enum
{
    ModuleInstallationStatusNone,
    ModuleInstallationStatusDemo,
    ModuleInstallationStatusFull
}
ModuleInstallationStatus;



//@protocol ModuleManagerDelegate
//
//- (void) moduleManagerDidLoadInventory;
//
//- (void) moduleManagerDidUpdateStatus:(NSNumber*) status forProduct:(UAProduct*) product;
//
//@end



@protocol ModuleManagerObserver

- (void) product:(UAProduct*) product loadedForModule:(NSString*) moduleName;

- (void) product:(UAProduct*) product statusChangedTo:(NSNumber*) status forModule:(NSString*) moduleName;

- (void) product:(UAProduct*) product progressChangedTo:(NSNumber*) progress forModule:(NSString*) moduleName;

@end



@protocol ProductObserverDelegate

- (void) product:(UAProduct*) product didChangeStatus:(NSNumber*) status;

- (void) product:(UAProduct*) product didChangeProgress:(NSNumber*) progress;

@end



@interface ModuleManager : NSObject <UAStoreFrontObserverProtocol,
    ProductObserverDelegate> {
 
    NSMutableDictionary* __strong _contentInstalledForModule;
    
    NSMutableDictionary* __strong _moduleNamesForProductIDs;
        
        NSMutableDictionary* __strong _observerDict;
        
        NSMutableArray* __strong _productObservers;
        
        BOOL _wasBackgrounded;
}

@property (nonatomic, strong) NSArray* modulesArray;

//@property (nonatomic, assign) id<ModuleManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* productObservers;




+ (ModuleManager*) manager;

- (void) loadInventory;

- (void) addObserver:(id<ModuleManagerObserver>) object forModule:(NSString*) moduleName;

- (void) removeObserver:(id<ModuleManagerObserver>) object forModule:(NSString*) moduleName;

//- (NSString*) productIDForModule:(NSString*) moduleName;

- (UIColor*) colorForModule:(NSString*) module;

- (NSArray*) correctionRectsForModule:(NSString*) module;

- (NSArray*) bottomCorrectionsForModule:(NSString*) module;

- (CGRect) seperatorRectForModule:(NSString*) module;

- (BOOL) contentInstalledForModule:(NSString *)moduleName;

- (NSString*) pathForModule:(NSString*) moduleName;

- (uint) installationStatusForModule:(NSString*) moduleName;

- (NSDictionary*) seperatorRectPagesForModule:(NSString*) moduleName;

- (NSDictionary*) bottomCorrectionPagesForModule:(NSString*) moduleName;

- (NSString*) shopDescriptionFileForModule:(NSString*) moduleName;

- (UIImage*) iconImageForModule:(NSString*) moduleName;

@end



@interface ProductObserver : NSObject <UAProductObserverProtocol> {
    
    UAProduct* __weak _product;
}

@property (nonatomic, assign) id<ProductObserverDelegate> delegate;

- (id) initWithProduct:(UAProduct*) product;

- (void) unregister;
//- (void) reregister;

@end
