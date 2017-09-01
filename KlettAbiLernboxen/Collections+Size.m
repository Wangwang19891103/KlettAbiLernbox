//
//  Collections+Size.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 05.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Collections+Size.h"
#import <Malloc/malloc.h>


@implementation NSArray (SizeOf)

- (size_t) collectionSize {

    size_t totalSize = 0;
    
    for (id object in self.objectEnumerator) {
        if ([object isKindOfClass:[NSArray class]] ||
             [object isKindOfClass:[NSDictionary class]]) {
            totalSize += [object collectionSize];
        }
        else {
            totalSize += malloc_size(object);
        }
    }
    
    return totalSize;
}

@end




@implementation NSDictionary (SizeOf)

- (size_t) collectionSize {
    
    size_t totalSize = 0;
    
    for (id object in self.objectEnumerator) {
        if ([object isKindOfClass:[NSArray class]] ||
            [object isKindOfClass:[NSDictionary class]]) {
            totalSize += [object collectionSize];
        }
        else {
            totalSize += malloc_size(object);
        }
    }
    
    return totalSize;
}

@end