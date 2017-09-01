//
//  NSSet+Extensions.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 09.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSSet+Extensions.h"

@implementation NSSet (Extensions)

- (NSSet*) intersectSet:(NSSet*) set usingKeyInDictionary:(NSString*) key {
    
    NSMutableSet* resultSet = [NSMutableSet set];
    
    for (NSDictionary* dict in self) {
        
        for (NSDictionary* dict2 in set) {
            
            if ([[dict objectForKey:key] isEqual:[dict2 objectForKey:key]]) {
                [resultSet addObject:dict];
            }
        }
    }
    
    return (NSSet*)resultSet;
}


- (NSSet*) intersectSet:(NSSet *)set usingIndexInArray:(uint)index {
    
    NSMutableSet* resultSet = [NSMutableSet set];
    
    for (NSArray* array1 in self) {
        
        for (NSArray* array2 in set) {
            
            if ([[array1 objectAtIndex:index] isEqual:[array2 objectAtIndex:index]]) {
                [resultSet addObject:array1];
            }
        }
    }
    
    return (NSSet*)resultSet;
}


@end
