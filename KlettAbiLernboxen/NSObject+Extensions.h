//
//  NSObject+Extensions.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extensions)

- (void)performBlock:(void (^)(void)) block afterDelay:(NSTimeInterval) delay;

@end
