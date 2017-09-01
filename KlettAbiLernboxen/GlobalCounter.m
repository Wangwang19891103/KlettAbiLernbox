//
//  GlobalCounter.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GlobalCounter.h"

@implementation GlobalCounter

- (id) init {
    
    if ((self = [super init])) {
        
        _counters = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (GlobalCounter*) sharedInstance {
    
    static GlobalCounter* _instance;
    
    @synchronized(self) {
        
        if (!_instance) {
            _instance = [[GlobalCounter alloc] init];
        }
    }
    
    return _instance;
}


- (void) increaseCounterNamed:(NSString *)name byIntegerValue:(int) addValue {
    
    NSNumber* value = [_counters objectForKey:name];
    
    if (value) {
        
        [_counters setObject:[NSNumber numberWithInt:[value intValue] + addValue] forKey:name];
    }
    else {
        [_counters setObject:[NSNumber numberWithInt:addValue] forKey:name];
    }
}

- (void) increaseCounterNamed:(NSString *)name byFloatValue:(float) addValue {
    
    NSNumber* value = [_counters objectForKey:name];
    
    if (value) {
        
        [_counters setObject:[NSNumber numberWithFloat:[value floatValue] + addValue] forKey:name];
    }
    else {
        [_counters setObject:[NSNumber numberWithFloat:addValue] forKey:name];
    }
}

- (int) intValueForCounterNamed:(NSString *)name {
    
    return [[_counters objectForKey:name] intValue];
}

- (float) floatValueForCounterNamed:(NSString *)name {
    
    return [[_counters objectForKey:name] floatValue];
}


- (void) printAll {
    
    NSLog(@"----- GlobalCounter printAll -----");
    
    NSArray* sortedKeys = [[_counters allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString* name in sortedKeys) {
        
        NSLog(@"'%@': %@", name, [_counters objectForKey:name]);
    }
    
    NSLog(@"----------------------------------");
}

- (void) printForCounterNamed:(NSString *)name {
    
}

- (void) removeAll {

    [_counters removeAllObjects];
}


- (void) dealloc {
    
    [_counters release];
    
    [super dealloc];
}

@end
