//
//  NSDictionary+Extensions.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 11.09.12.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (sorting)

- (NSArray*) sortIntoArrayBySumUsingKey:(NSString*) key ascending:(BOOL) ascending;
/* output array shud have format:
 * array
 *     dict
 *         name: String (the dict's original key)
 *         object: id (the sub structure under the dict's original key
 *         sum: int (the sum of values under the sorting key
 */

@end



@interface NSArray (sorting)

- (NSArray*) sortBySumUsingKey:(NSString*) key ascending:(BOOL) ascending;

@end




int sumForKeyInStructure(NSString* key, id structure);

int sumForKeyInArray(NSString* key, NSArray* array);

int sumForKeyInDictionary(NSString* key, NSDictionary* dictionary);