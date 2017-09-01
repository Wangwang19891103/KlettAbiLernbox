//
//  StopTimer.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define timer_start(name) [[StopTimer timerForName:name] reset]
#define timer_passed(name) [[StopTimer timerForName:name] timePassed]
#define timer_add(name) counter_incF(name,timer_passed(name))


@interface StopTimer : NSObject {
    
    NSDate* _startingDate;
}

+ (StopTimer*) timerForName:(NSString*) name;

+ (void) releaseTimerForName:(NSString*) name;

- (void) reset;
- (float) timePassed;

@end
