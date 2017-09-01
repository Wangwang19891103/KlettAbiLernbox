//
//  GlobalCounter.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 14.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define counter_incI(name, i) [[GlobalCounter sharedInstance] increaseCounterNamed:name byIntegerValue:i]

#define counter_incF(name, f) [[GlobalCounter sharedInstance] increaseCounterNamed:name byFloatValue:f]

#define counter_printall [[GlobalCounter sharedInstance] printAll]

#define counter_removeAll [[GlobalCounter sharedInstance] removeAll]


@interface GlobalCounter : NSObject {
    
    NSMutableDictionary* _counters;
}

+ (GlobalCounter*) sharedInstance;

- (void) increaseCounterNamed:(NSString*) name byIntegerValue:(int) value;

- (void) increaseCounterNamed:(NSString *)name byFloatValue:(float)value;

- (void) printAll;
- (void) printForCounterNamed:(NSString*) name;
- (void) removeAll;

- (int) intValueForCounterNamed:(NSString*) name;
- (float) floatValueForCounterNamed:(NSString*) name;

@end
