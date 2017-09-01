//
//  PropertyBoard.m
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import "PropertyBoard.h"



#pragma mark - Defines

#define VIEW_RECT_VISIBLE CGRectMake(0, 0, 320, 480)
#define VIEW_RECT_INVISIBLE CGRectMake(0, 480, 320, 480)




@implementation PropertyBoard

@synthesize properties;


- (id) init {
    
    if (self = [super init]) {
        
        _mainController = [[PropertyBoardViewController alloc] init];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:_mainController];
        [_navigationController setNavigationBarHidden:TRUE];
        _navigationController.view.frame = VIEW_RECT_INVISIBLE;
        properties = [NSMutableDictionary dictionary];
        _variables = [NSMutableDictionary dictionary];
        _viewVisible = FALSE;
        _observers = [NSMutableSet set];
    }
    
    return self;
}


+ (PropertyBoard*) instance {
    
    static PropertyBoard* instance;
    
    @synchronized(self) {
        
        if (!instance) {
            
            instance = [[PropertyBoard alloc] init];
        }
    }
    
    return instance;
}


- (void) attach {

    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIViewController* rootViewController = window.rootViewController;

    [rootViewController.view addSubview:_navigationController.view];
}


- (void) registerIntPropertyKey:(NSString *)propertyKey forObject:(id)object {

    NSDictionary* propertyDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:PropertyBoardTypeInt], @"type",
                                  propertyKey, @"key",
                                  nil];
    
    if (![properties objectForKey:[NSValue valueWithPointer:(__bridge const void *)(object)]]) {
        
        [properties setObject:[NSMutableArray array] forKey:[NSValue valueWithPointer:(__bridge const void *)(object)]];
    }
    
    NSMutableArray* objectArray = [properties objectForKey:[NSValue valueWithPointer:(__bridge const void *)(object)]];
    
    [objectArray addObject:propertyDict];
    
    [object addObserver:self forKeyPath:propertyKey options:NSKeyValueObservingOptionNew context:@"PropertyBoard"];
    
    for (id<PropertyBoardChangeObserver> observer in _observers) {
        
        if ([(NSObject*)observer respondsToSelector:@selector(propertyDictionaryDidChange)]) {
            
            [observer propertyDictionaryDidChange];
        }
    }
}


- (void) deregisterAllPropertyKeysForObject:(id)object {
    
    NSArray* objectArray = [properties objectForKey:[NSValue valueWithPointer:(__bridge const void *)(object)]];
    
    for (NSDictionary* propertyDict in objectArray) {
        
        [object removeObserver:self];
    }
    
    [properties removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(object)]];
    
    for (id<PropertyBoardChangeObserver> observer in _observers) {

        if ([(NSObject*)observer respondsToSelector:@selector(propertyDictionaryDidChange)]) {
            
            [observer propertyDictionaryDidChange];
        }
    }
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"PropertyBoard -observeValueForKeyPath: keyPath=%@, object=%@, change=%@", keyPath, object, change);

    for (id<PropertyBoardChangeObserver> observer in _observers) {
        
        [observer propertyChangedForObject:object withKeyPath:keyPath];
    }
}


- (void) createVariableNamed:(NSString *)name ofType:(PropertyBoardType)type withValue:(id)value minValue:(id)minValue maxValue:(id)maxValue {
    
    NSMutableDictionary* varDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:type], @"type",
                             value, @"value",
                             minValue, @"minValue",
                             maxValue, @"maxValue",
                             nil];
    
    [_variables setObject:varDict forKey:name];
    
    for (id<PropertyBoardChangeObserver> observer in _observers) {
        
        if ([(NSObject*)observer respondsToSelector:@selector(variableDictionaryDidChange)]) {
            
            [observer variableDictionaryDidChange];
        }
    }
}


- (id) valueForVariableNamed:(NSString *)name {
    
    return [[_variables objectForKey:name] objectForKey:@"value"];
}


- (id) minValueForVariableNamed:(NSString *)name {
    
    return [[_variables objectForKey:name] objectForKey:@"minValue"];
}


- (id) maxValueForVariableNamed:(NSString *)name {
    
    return [[_variables objectForKey:name] objectForKey:@"maxValue"];
}


- (NSNumber*) typeForVariableNamed:(NSString *)name {
    
    return [[_variables objectForKey:name] objectForKey:@"type"];
}


- (void) setValue:(id)value forVariableNamed:(NSString *)name {
    
    [[_variables objectForKey:name] setValue:value forKey:@"value"];
    
    for (id<PropertyBoardChangeObserver> observer in _observers) {
        
        if ([(NSObject*)observer respondsToSelector:@selector(variableValueChangedForName:)]) {
            
            [observer variableValueChangedForName:name];
        }
    }
}


- (uint) numberOfVariables {
    
    return _variables.count;
}


- (NSString*) variableNameAtIndex:(uint)index {
    
    return [[_variables.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:index];
}


- (NSString*) stringForType:(NSNumber*)type {
    
    return stringSwitchCaseInt([type intValue],
                               0, @"Int",
                               nil);
}


- (void) toggleView {
    
    CGRect newRect;
    
    if (!_viewVisible) {
        
        newRect = VIEW_RECT_VISIBLE;
    }
    else {
        
        newRect = VIEW_RECT_INVISIBLE;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
                         _navigationController.view.frame = newRect;
                     }
                     completion:nil];
    
    _viewVisible = !_viewVisible;
}


- (void) navigateBack {
    
    [_navigationController popViewControllerAnimated:TRUE];
}


- (void) addChangeObserver:(id)observer {

#ifdef PB_ATTACH
    [_observers addObject:observer];
#endif
}


- (void) removeChangeObserver:(id)observer {

#ifdef PB_ATTACH
    [_observers removeObject:observer];
#endif
}


@end
