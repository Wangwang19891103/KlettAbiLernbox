//
//  NSDictionary+Extensions.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 11.09.12.
//
//

#import "Sorting.h"

@implementation NSDictionary (sorting)


- (NSArray*) sortIntoArrayBySumUsingKey:(NSString *)key ascending:(BOOL)ascending {

    NSArray* array = [self toSortArray];
    
    for (NSMutableDictionary* dict in array) {
        
        NSNumber* sum = [NSNumber numberWithInt:sumForKeyInStructure(key, [dict objectForKey:@"object"])];
        
        [dict setObject:sum forKey:@"sum"];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sum" ascending:ascending selector:@selector(compare:)];
    
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


/* converts dictionary into an array with the following structire
 * array
 *     dict
 *         key: id (key of the original dictionary)
 *         object: id (object corresponding to the key)
 */
- (NSArray*) toSortArray {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id key in self.allKeys) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              key, @"key",
                              [self objectForKey:key], @"object",
                              nil];
        
        [resultArray addObject:dict];
    }
    
    return resultArray;
}


@end




@implementation NSArray (sorting)


- (NSArray*) sortBySumUsingKey:(NSString *)key ascending:(BOOL)ascending {

    NSArray* array = [self toSortArray];
    
    for (NSMutableDictionary* dict in array) {
        
        NSNumber* sum = [NSNumber numberWithInt:sumForKeyInStructure(key, [dict objectForKey:@"object"])];
        
        [dict setObject:sum forKey:@"sum"];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sum" ascending:ascending selector:@selector(compare:)];
    
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [sortedArray backToNormalArray];
}


- (NSArray*) toSortArray {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     object, @"object",
                                     nil];
        
        [resultArray addObject:dict];
    }
    
    return resultArray;
}


- (NSArray*) backToNormalArray {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (NSDictionary* dict in self) {
        
        [resultArray addObject:[dict objectForKey:@"object"]];
    }
    
    return resultArray;
}


@end





int sumForKeyInArray(NSString* key, NSArray* array) {
    
    int sum = 0;
    
    for (id object in array) {
        
        sum += sumForKeyInStructure(key, object);
    }
    
    return sum;
}


int sumForKeyInStructure(NSString* key, id structure) {
    
    if ([structure isKindOfClass:[NSArray class]]) {
        
        return sumForKeyInArray(key, structure);
    }
    else if ([structure isKindOfClass:[NSDictionary class]]) {
        
        return sumForKeyInDictionary(key, structure);
    }
    else {
        
        return 0;
    }
}





int sumForKeyInDictionary(NSString* key, NSDictionary* dictionary) {
    
    if ([key isEqualToString:@"<anyNumber>"]) {
        
        int sum = 0;
        NSEnumerator* objectEnumerator = dictionary.objectEnumerator;
        
        for (id object in objectEnumerator) {
            
            if ([object isKindOfClass:[NSNumber class]]) {
                
                sum += [object intValue];
            }
        }
        
        return sum;
    }
    else if ([dictionary objectForKey:key]) {
        
        return [[dictionary objectForKey:key] intValue];
    }
    else {
        
        int sum = 0;
        
        for (id key2 in dictionary.allKeys) {
            
            sum += sumForKeyInStructure(key, [dictionary objectForKey:key2]);
        }
        
        return sum;
    }
}




