//
//  NSObject+Extensions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)

- (void)performBlock:(void (^)(void)) block afterDelay:(NSTimeInterval) delay {
    
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

@end
