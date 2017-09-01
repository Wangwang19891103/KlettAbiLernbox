//
//  PageQueue.h
//  KlettAbiLernboxen
//
//  Created by Wang on 23.08.12.
//
//

#import <Foundation/Foundation.h>


@class PageQueue;


typedef enum {
    PageQueueLinear,
    PageQueueDiverging
} PageQueueOrder;


@protocol PageQueueDelegate <NSObject>

- (BOOL) pageQueueShouldDequeueNextPage:(PageQueue*) queue;

- (void) pageQueue:(PageQueue*) queue didDequeuePage:(id) page;

@optional

- (void) pageQueueDidStartQueuing:(PageQueue*) queue;

- (void) pageQueueDidStopQueuing:(PageQueue*) queue;

@end


@interface PageQueue : NSObject {
    
    NSArray* __strong _pages;
    // array of dicts
    
    dispatch_queue_t _queue;
    
    uint _loadedCount;
    
    NSMutableArray* __strong _orderArray;
    // array of ints
    
    uint _currentOrderIndex;
    
    NSMutableSet* _dequeuedPageIndexes;
}

@property (nonatomic, assign) id<PageQueueDelegate> delegate;

@property (nonatomic, assign) uint startingIndex;
// default: 0;

@property (nonatomic, assign) PageQueueOrder order;
// default: PageQueueAscending

@property (nonatomic, readonly) BOOL running;


- (id) initWithPages:(NSArray*) pages;

- (void) startQueue;

- (void) stopQueue;


@end
