//
//  StopTimer.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StopTimer.h"

@implementation StopTimer


static NSMutableDictionary* _timers;


- (id) init {
    
    if ((self = [super init])) {
        
        _startingDate = [[NSDate date] retain];
    }
    
    return self;
}

+ (StopTimer*) timerForName:(NSString *)name {
    
    
    
    @synchronized(self) {
        
        if (!_timers) {
            _timers = [[NSMutableDictionary alloc] init];
        }
        
        if (![_timers objectForKey:name]) {
            
            [_timers setObject:[[[StopTimer alloc] init] autorelease] forKey:name];
        }
    }

    return [_timers objectForKey:name];
}

+ (void) releaseTimerForName:(NSString *)name {
    
    if ([_timers objectForKey:name]) {
        
        [_timers removeObjectForKey:name];
    }
}

- (void) reset {
    
    [_startingDate release];
    _startingDate = [[NSDate date] retain];
}

- (float) timePassed {

    return [[NSDate date] timeIntervalSinceDate:_startingDate];
}

- (void) dealloc {
    
    NSLog(@"StopTimer DEALLOC");
    
    [_startingDate release];
    
    [super dealloc];
}

@end
