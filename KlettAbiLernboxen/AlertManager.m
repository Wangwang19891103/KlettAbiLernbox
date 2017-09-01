//
//  AlertManager.m
//  KlettAbiLernboxen
//
//  Created by Wang on 12.02.13.
//
//

#import "AlertManager.h"

@implementation AlertManager


- (id) init {

    if (self = [super init]) {
        
        _blocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}


+ (AlertManager*) instance {
    
    static AlertManager* _instance;
    
    @synchronized(self) {
        
        if (!_instance) {
            
            _instance = [[AlertManager alloc] init];
        }
    }
    
    return _instance;
}


- (void) yesNoAlertWithTitle:(NSString *) title message:(NSString *)message yesBlock:(AlertManagerBlock)block {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ja"
                                              otherButtonTitles:@"Nein", nil];
    [_blocks setObject:[block copy] forKey:[NSValue valueWithPointer:(__bridge const void *)(alertView)]];
    
    [alertView show];
}


- (void) okAlertWithTitle:(NSString *) title message:(NSString *)message okBlock:(AlertManagerBlock)block {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [_blocks setObject:[block copy] forKey:[NSValue valueWithPointer:(__bridge const void *)(alertView)]];
    
    [alertView show];
}


- (void) okAlertWithTitle:(NSString *) title message:(NSString *)message {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];

    [alertView show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) { // OK Button
        
        AlertManagerBlock block = [_blocks objectForKey:[NSValue valueWithPointer:(__bridge const void *)(alertView)]];
        
        if (block) {
            
            block();
        
            [_blocks removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(alertView)]];
        }
    }
}

@end
