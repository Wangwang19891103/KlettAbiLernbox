//
//  PropertyBoard.h
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import <Foundation/Foundation.h>
#import "PropertyBoardViewController.h"
#import "PropertyBoardChangeObserver.h"


#pragma mark - Macros

#define PBcreateVar(name, type, value, min, max) [[PropertyBoard instance] createVariableNamed:name ofType:type withValue:value minValue:min maxValue:max]

#define PBcreateIntVar(name, value, min, max) [[PropertyBoard instance] createVariableNamed:name ofType:PropertyBoardTypeInt withValue:[NSNumber numberWithInt:value] minValue:[NSNumber numberWithInt:min] maxValue:[NSNumber numberWithInt:max]]

#define PBvarValue(name) [[PropertyBoard instance] valueForVariableNamed:name]

#define PBintVarValue(name) [[[PropertyBoard instance] valueForVariableNamed:name] intValue]

#define PBsetVarValue(name, value) [[PropertyBoard instance] setValue:value forVariableNamed:name]

#define PBaddObserver(obs) [[PropertyBoard instance] addChangeObserver:obs]



#pragma mark - Enums

typedef enum {
    PropertyBoardTypeInt
} PropertyBoardType;



#pragma mark - PropertyBoard

@interface PropertyBoard : NSObject {
    
    PropertyBoardViewController* _mainController;
    
    UINavigationController* _navigationController;
    
    BOOL _viewVisible;
    
    NSMutableSet* _observers;
    
    NSMutableDictionary* _variables;
    /* dict
     *     name: dict
     *         type: int(enum)
     *         value: id
     *         minValue: id
     *         maxValue: id
     */
}


@property (nonatomic, strong) NSMutableDictionary* properties;


+ (PropertyBoard*) instance;

- (void) attach;

- (void) registerIntPropertyKey:(NSString*) propertyKey forObject:(id) object;

- (void) deregisterAllPropertyKeysForObject:(id) object;

- (NSString*) stringForType:(NSNumber*) type;

- (void) toggleView;

- (void) navigateBack;

- (void) addChangeObserver:(id<PropertyBoardChangeObserver>) observer;

- (void) removeChangeObserver:(id<PropertyBoardChangeObserver>) observer;

- (void) createVariableNamed:(NSString*) name
                      ofType:(PropertyBoardType) type
                   withValue:(id) value
                    minValue:(id) minValue
                    maxValue:(id) maxValue;

- (id) valueForVariableNamed:(NSString*) name;

- (id) minValueForVariableNamed:(NSString*) name;

- (id) maxValueForVariableNamed:(NSString*) name;

- (NSNumber*) typeForVariableNamed:(NSString*) name;

- (void) setValue:(id) value forVariableNamed:(NSString*) name;

- (uint) numberOfVariables;

- (NSString*) variableNameAtIndex:(uint) index;

@end




