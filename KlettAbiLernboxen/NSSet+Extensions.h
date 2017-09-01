//
//  NSSet+Extensions.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 09.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Extensions)

- (NSSet*) intersectSet:(NSSet*) set usingKeyInDictionary:(NSString*) key;

- (NSSet*) intersectSet:(NSSet*) set usingIndexInArray:(uint) index;


@end
