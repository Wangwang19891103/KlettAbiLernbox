//
//  ProgressLogger.h
//  KlettAbiLernboxen
//
//  Created by Wang on 07.09.12.
//
//

#import <Foundation/Foundation.h>

@interface ProgressLogger : NSObject {
    
    uint _counter;
    uint _nextStep;
    uint _count;
}

//@property (nonatomic, readonly) uint count;

@property (nonatomic, readonly) uint stepWidth;


- (id) initWithCount:(uint) theCount stepWidth:(uint) theStepWidth;

- (void) count;

@end
