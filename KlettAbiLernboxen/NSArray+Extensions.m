//
//  NSArray+Extensions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 16.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Extensions.h"


@implementation NSArray (Extensions)

+ (NSArray*) randomizedArrayFromArray:(NSArray*) array {

    NSMutableArray* randomizedArray = [NSMutableArray array];
    
    for (int i = 0; i < [array count]; ++i) {
        [randomizedArray addObject:[array objectAtIndex:i]];
    }
    
    id temp;
    
    for (int i = 0; i < [randomizedArray count]; ++i) {
        
        int newIndex = arc4random() % [randomizedArray count];
        temp = [randomizedArray objectAtIndex:newIndex];
        [randomizedArray replaceObjectAtIndex:newIndex withObject:[randomizedArray objectAtIndex:i]];
        [randomizedArray replaceObjectAtIndex:i withObject:temp];
    }
        
    return randomizedArray;                                   
}

- (NSArray*) sortUsingNumberArray:(NSArray**) array ascending:(BOOL)ascending {
    
    if (self.count == 0) {
        NSLog(@"[sortUsingNumbersArray:ascending] Error: self array is empty");
        return nil;
    }
    else if ((*array).count == 0) {
        NSLog(@"[sortUsingNumbersArray:ascending] Error: number array is empty");
        return nil;
    }
    
    
//    NSLog(@"first item: %@", array);
    
    if ([self count] != [*array count]) {
        NSLog(@"NSArray error: sortUsingNumberArray, different array lenghts");
        return nil;
    }
    else if (![[*array objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
        NSLog(@"NSArray error: sortUsingNumberArray, sorting array does not contain NSNumber objects");
    }
    
    NSMutableArray* newArray = [[*array mutableCopy] autorelease];
    NSMutableArray* newArray2 = [NSMutableArray arrayWithArray:self];
    
//    for (int i = 0; i < [*array count]; ++i) {
//        NSLog(@"player: %@, score: %@", [[newArray2 objectAtIndex:i] name], [newArray objectAtIndex:i]);
//    }
    
    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSNumber* temp = [newArray objectAtIndex:i];
        id temp2 = [newArray2 objectAtIndex:i];
        int i2 = i;

//        NSLog(@"i = %d, temp = %@", i, temp);
        
        while (i2 >= 1 && [[newArray objectAtIndex:i2 - 1] intValue] > [temp intValue]) {
//            NSLog(@"...");
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            [newArray2 replaceObjectAtIndex:i2 withObject:[newArray2 objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
        [newArray2 replaceObjectAtIndex:i2 withObject:temp2];
    }
    
//    for (int i = 0; i < [*array count]; ++i) {
//        NSLog(@"player: %@, score: %@", [[newArray2 objectAtIndex:i] name], [newArray objectAtIndex:i]);
//    }
    
//    NSLog(@"array in sort method: %@", *array);
    
    NSArray* returnedArray = nil;
    
    switch (ascending) {
        
        case TRUE:
            *array = [[NSArray alloc] initWithArray:newArray copyItems:TRUE];        
            returnedArray =  newArray2;
            break;
            
        case FALSE:
            *array = [[NSArray alloc] initWithArray:[newArray reversedArray] copyItems:TRUE];
            returnedArray =  [newArray2 reversedArray];
            break;
            
        default:
            break;
    }

    return returnedArray;
}






- (NSArray*) sortAscending:(BOOL)ascending usingNumberArrays:(NSMutableArray **) firstArray, ... {    
    // Number array
    
    NSMutableArray* numberArrays = [NSMutableArray array];
    va_list arguments;
    
    if (firstArray) {
        [numberArrays addObject:[NSValue valueWithPointer:firstArray]];
        va_start(arguments, firstArray);
        NSMutableArray** anotherArray;
        while ((anotherArray = va_arg(arguments, NSMutableArray**))) {
            [numberArrays addObject:[NSValue valueWithPointer:anotherArray]];
        }
        va_end(arguments);
    }
    
    
//    
//    if ([self count] != [*array count]) {
//        NSLog(@"NSArray error: sortUsingNumberArray, different array lenghts");
//        return nil;
//    }
//    else if (![[*array objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
//        NSLog(@"NSArray error: sortUsingNumberArray, sorting array does not contain NSNumber objects");
//    }

    NSMutableArray* newArray = [[self mutableCopy] autorelease];
    
    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {

//        NSString* logString = [NSString stringWithFormat:@"i = %d, word = %@, numbers = ", i, [[[[newArray objectAtIndex:i] wordLayouts] lastObject] word]];
        
        id temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        // temp for number arrays
        NSMutableArray* numberTemp = [NSMutableArray array];
        for (NSValue* numberArray in numberArrays) {
            NSMutableArray** array = [numberArray pointerValue];
            [numberTemp addObject:[*array objectAtIndex:i]];
            
//            logString = [NSString stringWithFormat:@"%@, %@ ", logString, [*array objectAtIndex:i]];
        }

//        NSLog(@"%@", logString);
        
        BOOL shouldBreak = FALSE;
        
        while (i2 >= 1 && !shouldBreak) {
            
//            NSLog(@"  compare with word: %@", [[[[newArray objectAtIndex:i2 - 1] wordLayouts] lastObject] word]);
            
            BOOL isGreater = FALSE;
            
            // break conditions (all number arrays)
            for (int j = 0; j < [numberArrays count]; ++j) {
                
                NSMutableArray** array = [[numberArrays objectAtIndex:j] pointerValue];
                
                NSNumber* prevNumber = [*array objectAtIndex:i2 - 1];
                NSNumber* tempNumber = [numberTemp objectAtIndex:j];
                
                if ([prevNumber intValue] > [tempNumber intValue]) {
                    isGreater = ascending;
//                    NSLog(@"j = %d, GREATER (out)", j);
                    break;
                }
                else if ([prevNumber intValue] < [tempNumber intValue]) {
//                    NSLog(@"j = %d, LOWER (out)", j);
                    isGreater = !ascending;
                    break;
                }
                else {
//                    NSLog(@"j = %d, EQUAL", j);
                }
                // if equal then next j
            }
            
            if (isGreater) {
                
//                NSLog(@"...");
                
                [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
                
                for (int j = 0; j < [numberArrays count]; ++j) {
                    
                    NSMutableArray** numberArray = [[numberArrays objectAtIndex:j] pointerValue];
                    
                    [*numberArray replaceObjectAtIndex:i2 withObject:[*numberArray objectAtIndex:i2 - 1]];
                }
                
                i2 = i2 - 1;
            }
            else {
                
                shouldBreak = TRUE;
            }
            
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
        
        for (int j = 0; j < [numberArrays count]; ++j) {
            
            NSMutableArray** array = [[numberArrays objectAtIndex:j] pointerValue];
            
            [*array replaceObjectAtIndex:i2 withObject:[numberTemp objectAtIndex:j]];
        }
        
    }

    return newArray;
}


- (NSArray*) sort2DimensionalArrayUsingNumberAtIndex:(int)sortIndex ascending:(BOOL)ascending {

    NSMutableArray* newArray = [[self mutableCopy] autorelease];
    
    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSArray* temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        NSLog(@"i = %d, temp = %@", i, temp);
        
        while (i2 >= 1 && [[[newArray objectAtIndex:i2 - 1] objectAtIndex:sortIndex] intValue] > [[temp objectAtIndex:sortIndex] intValue]) {
            NSLog(@"...");
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
    }
    
    switch (ascending) {
        
        case TRUE:
            return newArray;
            break;
            
        case FALSE:
            return [newArray reversedArray];
            break;
            
        default:
            break;
    }
    
    return nil;  // dummy
}




- (NSArray*) reversedArray {    
    
    NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (int i = [self count] - 1; i >= 0; --i) {
        [newArray addObject:[self objectAtIndex:i]];
    }
    
    return newArray;
}


- (NSArray*) copyArrayExcludingObjectsFromArray:(NSArray *)array {
    
    NSMutableArray* newArray = [[self mutableCopy] autorelease];
    
    for (id object in array) {
        [newArray removeObject:object];
    }
    
    return newArray;
}


- (NSArray*) sortByLengthOfStringsAscending:(BOOL)ascending {
    
    if (![[self objectAtIndex:0] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSMutableArray* stringLengths = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSString* string in self) {
        
        [stringLengths addObject:[NSNumber numberWithInt:string.length]];
    }
    
    return [self sortUsingNumberArray:&stringLengths ascending:ascending];
}


// nicht geprüft!
- (BOOL) containsObject:(id)object inSubArrayAtIndex:(uint)subIndex {
    
    for (NSArray* array in self) {
        
        if ([array objectAtIndex:subIndex] == object) {
            
            return true;
        }
    }
    
    return false;
}


- (id) firstElement {
    
    return [self objectAtIndex:0];
}

// setzt voraus dass sich im eigenen array keine duplikate befinden
- (NSArray*) sortUsingOrderInArray:(NSArray *)array {

    NSMutableDictionary* orderDict = [NSMutableDictionary dictionary];
    
    int i = 0;
    for (id object in array) {
        [orderDict setObject:[NSNumber numberWithInt:i] forKey:object];
        ++i;
    }
    
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    NSMutableArray* notFoundArray = [NSMutableArray array];
    
    for (id object in self) {
        if ([orderDict objectForKey:object]) {
            NSNumber* place = [orderDict objectForKey:object];
            [tempDict setObject:object forKey:place];
        }
        else {
            [notFoundArray addObject:object];
        }
    }
    
    NSMutableArray* returnArray = [NSMutableArray array];
    
    for (int j = 0; j < i; ++j) {
        id object = [tempDict objectForKey:[NSNumber numberWithInt:j]];
        if (object) {
            [returnArray addObject:object];
        }
    }
    
    return (NSArray*) returnArray;
}


- (NSArray*) sortUsingKeyInDictionary:(NSString *)key ascending:(BOOL)ascending {
    
    NSMutableArray* newArray = [[self mutableCopy] autorelease];

    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSDictionary* temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        while (i2 >= 1 && [[[newArray objectAtIndex:i2 - 1] objectForKey:key] intValue] > [[temp objectForKey:key] intValue]) {
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
    }
    
    if (ascending) return newArray;
    else return [newArray reversedArray];
}


/* supports types: NSArray, NSString, NSNumber and all Classes that perform to serializeToString */
- (NSString*) serializeToString {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        
        if ([object respondsToSelector:@selector(serializeToString)]) {
            
            [resultArray addObject:[object serializeToString]];
        }
        else if ([object isKindOfClass:[NSString class]]) {
            
            [resultArray addObject:[NSString stringWithFormat:@"\"%@\"", (NSString*)object]];
        }
        else if ([object isKindOfClass:[NSNumber class]]) {
            
            [resultArray addObject:(NSNumber*)object];
        }
    }
    
    return [NSString stringWithFormat:@"[%@]", [resultArray componentsJoinedByString:@","]];
}


@end





@implementation NSMutableArray (Extensions)

- (void) removeFirstObjectMatchingString:(id)object {
    
//    NSMutableArray* newArray = [[NSMutableArray alloc] initWithArray:self copyItems:TRUE];
    
    NSLog(@"removeFirst");
    
    for (int i = 0; i < [self count]; ++i) {
        
        if ([[self objectAtIndex:i] isEqualToString:object]) {
            [self removeObjectAtIndex:i]; 
            NSLog(@"removing object: %@", object);
            break;
        }
    }
}

+ (id) createArrayWithWeakReferences {
    
    return [self createArrayWithWeakReferencesWithCapacity:0];
}

+ (id) createArrayWithWeakReferencesWithCapacity:(int)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, &callbacks);
}

@end
