//
//  OperationManager.m
//  PDFViewer
//
//  Created by Wang on 26.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OperationManager.h"

@implementation OperationManager

@synthesize queue;

- (id) initWithName:(NSString *)name {
    
    if ((self = [super init])) {
        
        self.queue = [[NSOperationQueue alloc] init];
//        self.queue = [NSOperationQueue mainQueue];
        [self.queue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}


+ (OperationManager*) queueNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
     
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
    }
    if ([_instances objectForKey:name]) {
        
        return [_instances objectForKey:name];
    }
    else {
        
        OperationManager* newManager = [[OperationManager alloc] initWithName:name];
        [_instances setObject:newManager forKey:name];
        return newManager;
    }
}


- (void) addOperation:(NSOperation *)operation {
    
    [self.queue addOperation:operation];
    
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:@"operations"];
    [operation addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:@"operations"];
}


- (void) addOperationWithTarget:(id)target selector:(SEL)selector object:(id)object {    

    [self addOperation:[[NSInvocationOperation alloc] initWithTarget:target selector:selector object:object]];
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([(__bridge NSString*)context isEqualToString:@"operations"]) {
        
        if ([keyPath isEqualToString:@"isFinished"]) {

            NSLog(@"Operation finished: %@", object);
        }
        else if ([keyPath isEqualToString:@"isExecuting"] && [object isExecuting]) {

            NSLog(@"Operation executing: %@", object);
        }
    }
}


@end
