//
//  PageQueue.m
//  KlettAbiLernboxen
//
//  Created by Wang on 23.08.12.
//
//

#import "PageQueue.h"

@implementation PageQueue

@synthesize delegate;
@synthesize startingIndex;
@synthesize order;
@synthesize running;


#pragma mark - Initializer

- (id) initWithPages:(NSArray *)pages {
    
    if (self = [super init]) {
        
        _pages = pages;
        _dequeuedPageIndexes = [NSMutableSet set];
        
//        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        _queue = dispatch_queue_create("PageQueueDefaultQueue", DISPATCH_QUEUE_SERIAL);
        
//        dispatch_retain(_queue);
        
        _loadedCount = 0;
        
        _currentOrderIndex = 0;
        
        startingIndex = 0;
        
        order = PageQueueLinear;
        
        [self createOrderArray];
        
        running = FALSE;
    }
    
    return self;
}


#pragma mark - Public methods

- (void) startQueue {

    NSLog(@"PageQueue: started.");
    
    if (delegate && [delegate respondsToSelector:@selector(pageQueueDidStartQueuing:)])
        [delegate pageQueueDidStartQueuing:self];
    
    running = TRUE;
    
    dispatch_async(_queue, ^(void) {
    
        while (_dequeuedPageIndexes.count < _pages.count && running) {
    
//            NSLog(@"dequeuedPage count: %d", _dequeuedPageIndexes.count);
                  

            
            if (self.delegate && [self.delegate pageQueueShouldDequeueNextPage:self]) {

                
//                NSLog(@"PageQueue: dequeued page: %@", page);
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {

                    id page = [self nextPage];
//                    NSLog(@"PageQueue dispatching block to main thread");
                    
                    if (self.delegate)
                        [self.delegate pageQueue:self didDequeuePage:page];
                });
//                
//                sleep(1.0);
            }
            else {
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    counter_incI(@"PageQueue_delayed_cycles", 1);
                });
                
                usleep(100000); // 0.1 seconds = 100,000 microseconds
            }
        }
        
        NSLog(@"PageQueue: stopped.");
        
//        if (pageQueue && pageQueue.delegate && [delegate respondsToSelector:@selector(pageQueueDidStopQueuing:)])
//            [delegate pageQueueDidStopQueuing:self];
        
    });
}


- (void) stopQueue {
    
    NSLog(@"PageQueue: stopping...");
    
    running = FALSE;
    delegate = nil;
}


#pragma mark - Setters

- (void) setOrder:(PageQueueOrder)theOrder {
    
    if (theOrder == order) return;
    
    order = theOrder;
    
    [self createOrderArray];
}


- (void) setStartingIndex:(uint)theStartingIndex {
    
    if (theStartingIndex == startingIndex) return;
    
    startingIndex = theStartingIndex;
    
    [self createOrderArray];
}


#pragma mark - Misc Methods


- (id) nextPage {
    
    NSLog(@"nextPage");
    
    while (_currentOrderIndex < _orderArray.count) {
        
//        NSLog(@"\tcurrentOrderIndex: %d", _currentOrderIndex);
        
        uint pageIndex = [[_orderArray objectAtIndex:_currentOrderIndex] intValue];
        
//        NSLog(@"\tpageIndex: %d", pageIndex);
        
        ++_currentOrderIndex;
        
        NSNumber* containedNumber = nil;
        
        if (!(containedNumber = [_dequeuedPageIndexes member:[NSNumber numberWithInt:pageIndex]])) {
            
//            NSLog(@"containedNumber: %@", containedNumber);
            
//            NSLog(@"\tnot done yet");

            [_dequeuedPageIndexes addObject:[NSNumber numberWithInt:pageIndex]];
            
//            NSLog(@"\tset done");
            
//            ++_loadedCount;
            
            NSLog(@"PageQueue: dequeuing index (%d)", pageIndex);
            
            return [_pages objectAtIndex:pageIndex];
        }
        else {
            
//            NSLog(@"\talready done... next");
        }
    }
    
    return nil;
}


- (void) createOrderArray {
    
    NSMutableArray* orderTemp = [NSMutableArray array];
    
    switch (self.order) {
            
        case PageQueueLinear:                       // Linear
            
            for (int i = 0; i < _pages.count; ++i) {
                
                [orderTemp addObject:[NSNumber numberWithInt:i]];
            }
            
            break;
            
        case PageQueueDiverging:                    // Diverging
            
            for (int offset = 1, done = 0, index = self.startingIndex, direction = 1; done < _pages.count; index += (offset * direction), direction *= -1, ++offset) {
                
                if (index < 0 || index >= _pages.count) continue;
                
                [orderTemp addObject:[NSNumber numberWithInt:index]];
                
                ++done;
            }
            
            break;
            
        default:
            break;
    }
    
    _orderArray = orderTemp;
    
    _currentOrderIndex = 0;
    
    NSLog(@"orderArray:\n%@", _orderArray);
}


#pragma mark - Dealloc

- (void) dealloc {
    
    NSLog(@"PageQueue dealloc");
    
//    dispatch_suspend(_queue);
    
//    dispatch_
//    dispatch_release(_queue);
}


@end
