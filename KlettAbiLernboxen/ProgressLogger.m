//
//  ProgressLogger.m
//  KlettAbiLernboxen
//
//  Created by Wang on 07.09.12.
//
//

#import "ProgressLogger.h"

@implementation ProgressLogger

//@synthesize count;
@synthesize stepWidth;


- (id) initWithCount:(uint)theCount stepWidth:(uint)theStepWidth {
    
    if (self = [super init]) {
        
        _count = theCount;
        stepWidth = theStepWidth;
        
        _counter = 0;
    }
    
    return self;
}


- (void) count {

    uint percentage = floor((float)_counter / _count * 100);
    
    if (percentage == _nextStep) {
        
        [self printProgress:percentage];
        
        _nextStep += stepWidth;
    }
    
    ++_counter;
}


- (void) printProgress:(uint) percentage {
    
    NSLog(@"Progress: %d%% (%d)", percentage, _counter);
}


@end
