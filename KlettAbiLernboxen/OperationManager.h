//
//  OperationManager.h
//  PDFViewer
//
//  Created by Wang on 26.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationManager : NSObject {
    
//    NSOperationQueue* _queue;
}

@property (nonatomic, strong) NSOperationQueue* queue;

- (id) initWithName:(NSString*) name;

+ (OperationManager*) queueNamed:(NSString*) name;

- (void) addOperation:(NSOperation*) operation;

- (void) addOperationWithTarget:(id) target selector:(SEL) selector object:(id) object;

@end


