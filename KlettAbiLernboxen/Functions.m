//
//  Functions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 13.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Functions.h"


NSString* stringSwitchCaseString(NSString* string, NSString* firstKey, ...) {
    
    va_list arguments;
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    
    if (firstKey) {
        
        va_start(arguments, firstKey);
        NSString* value;
        
        if ((value = va_arg(arguments, NSString*))) {
            
            //            NSLog(@"key: %@, value: %@",firstKey, value);
            
            [pairs setObject:value forKey:firstKey];
            NSString* key;
            
            while ((key = va_arg(arguments, NSString*)) && (value = va_arg(arguments, NSString*))) {
                [pairs setObject:value forKey:key];
                //                NSLog(@"key: %@, value: %@",key, value);
            }
            
            va_end(arguments);
        }
    }
    
    //    NSLog(@"pair dict: %@", pairs);
    
    for (NSString* key in pairs.keyEnumerator) {
        if ([key isEqualToString:string]) {
            return [pairs objectForKey:key];
        }
    }
    
    return nil;
}



int intSwitchCaseString(NSString* string, id firstKey, ...) {
    
    va_list arguments;
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    
    if (firstKey) {
        
        va_start(arguments, firstKey);
        int value;
        
        if ((value = va_arg(arguments, int))) {
            
            //            NSLog(@"key: %@, value: %@",firstKey, value);
            
            [pairs setObject:[NSNumber numberWithInt:value] forKey:(NSString*)firstKey];
            NSString* key;
            
            while ((key = va_arg(arguments, NSString*)) && (value = va_arg(arguments, int))) {
                [pairs setObject:[NSNumber numberWithInt:value] forKey:key];
                //                NSLog(@"key: %@, value: %@",key, value);
            }
            
            va_end(arguments);
        }
    }
    
    //    NSLog(@"pair dict: %@", pairs);
    
    for (NSString* key in pairs.keyEnumerator) {
        if ([key isEqualToString:string]) {
            return [(NSNumber*)[pairs objectForKey:key] intValue];
        }
    }
    
    return -1;
}


// example NSString* string = stringSwitchCaseInt(integer, 0, @"a", 1, @"b", 2, @"c", nil)
NSString* stringSwitchCaseInt(uint theInt, id firstKey, ...) {

    va_list arguments;
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];

    
    va_start(arguments, firstKey);
    NSString* value;
    
    if ((value = va_arg(arguments, NSString*))) {
        
//        NSLog(@"key: %d, value: %@",(int)firstKey, value);
        
        [pairs setObject:value forKey:[NSNumber numberWithInt:(int)firstKey]];
        int key;
        
        while ((key = va_arg(arguments, int)) && (value = va_arg(arguments, NSString*))) {
            [pairs setObject:value forKey:[NSNumber numberWithInt:key]];
//            NSLog(@"key: %d, value: %@",key, value);
        }
        
        va_end(arguments);
    }
    
    //    NSLog(@"pair dict: %@", pairs);
    
    for (NSNumber* key in pairs.keyEnumerator) {
        if ([key intValue] == theInt) {
            return (NSString*)[pairs objectForKey:key];
        }
    }
    
    return nil;
}


uint randomIntegerFromTo(uint from, uint to) {
    
    return (arc4random() % (to - from + 1)) + from;
}


float roundFDigits(float f, uint digits) {
    
    float factor = pow(10, digits);
    
    return floorf(f * factor) / factor;
}
